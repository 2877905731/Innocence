package com.innocence.server.modules.update;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.*;
import java.nio.file.*;
import java.security.MessageDigest;
import java.time.Instant;
import java.util.*;
import java.util.concurrent.locks.ReentrantLock;
import java.util.zip.ZipFile;

/** Single backend instance, atomic durable catalog. Package files are immutable and never public. */
@Service
public class ReleaseService {
    public record Input(String platform, String arch, String version, Integer build, String notes, String installMethod) {}
    public record Event(long actorId, String action, String at) {}
    public record Release(String id, String platform, String arch, String version, int build,
                          String notes, String installMethod, String fileName, long size, String sha256,
                          String state, String publishedAt, List<Event> history) {}
    private static final long MAX_FILE = 300L * 1024 * 1024;
    private final Path root;
    private final ObjectMapper json;
    private final long reserveBytes, budgetBytes;
    private final boolean accel;
    private final ReentrantLock uploadLock = new ReentrantLock();

    public ReleaseService(ObjectMapper json,
                          @Value("${innocence.updates.storage-dir:./data/updates}") String directory,
                          @Value("${innocence.updates.reserve-bytes:8589934592}") long reserveBytes,
                          @Value("${innocence.updates.budget-bytes:3221225472}") long budgetBytes,
                          @Value("${innocence.updates.x-accel:false}") boolean accel) {
        this.json = json; this.root = Path.of(directory).toAbsolutePath().normalize();
        this.reserveBytes = reserveBytes; this.budgetBytes = budgetBytes; this.accel = accel;
    }
    public boolean usesAccel() { return accel; }
    private BusinessException bad(String message) { return new BusinessException(ErrorCode.BAD_REQUEST, message); }
    public static String platformFor(String deviceType) {
        return switch (deviceType == null ? "" : deviceType) {
            case "desktop", "windows" -> "windows";
            case "mobile", "android" -> "android";
            case "tablet", "harmonyos" -> "harmonyos";
            default -> throw new BusinessException(ErrorCode.FORBIDDEN, "此设备不支持应用更新。");
        };
    }
    private String extension(Input input) {
        if (input == null || input.build() == null || input.build() < 1 || input.version() == null ||
                !input.version().matches("[0-9]{1,4}\\.[0-9]{1,4}\\.[0-9]{1,4}") || input.notes() == null ||
                input.notes().isBlank() || input.notes().length() > 8000) throw bad("请填写有效的版本、构建号和更新说明。");
        String key = input.platform() + "/" + input.arch() + "/" + input.installMethod();
        return switch (key) {
            case "windows/x64/windows_installer" -> "exe";
            case "android/universal/android_apk" -> "apk";
            case "harmonyos/arm64/manual_hdc" -> "hap";
            default -> throw bad("平台、架构与安装方式不匹配。");
        };
    }
    private void initialize() throws IOException {
        Files.createDirectories(root.resolve("packages"));
    }
    public synchronized List<Release> list() throws IOException {
        initialize();
        Path catalog = root.resolve("catalog.json");
        if (!Files.exists(catalog)) return List.of();
        List<Release> entries = json.readValue(catalog.toFile(), new TypeReference<>() {});
        return entries.stream().sorted(Comparator.comparingInt(Release::build).reversed()).toList();
    }
    private void save(List<Release> releases) throws IOException {
        Path temp = root.resolve("catalog.json.tmp");
        byte[] bytes = json.writeValueAsBytes(releases);
        try (var output = new FileOutputStream(temp.toFile())) {
            output.write(bytes); output.getFD().sync();
        }
        Files.move(temp, root.resolve("catalog.json"), StandardCopyOption.ATOMIC_MOVE, StandardCopyOption.REPLACE_EXISTING);
    }
    public Release upload(long actor, Input input, MultipartFile file) throws Exception {
        String ext = extension(input);
        if (file == null || file.isEmpty() || file.getSize() > MAX_FILE) throw bad("安装包不能为空，且不能超过 300 MiB。");
        if (!uploadLock.tryLock()) throw bad("已有安装包正在上传，请稍后重试。");
        Path temporary = null, target = null;
        try {
            synchronized (this) {
                initialize();
                if (list().stream().anyMatch(r -> r.platform().equals(input.platform()) && r.build() == input.build()))
                    throw bad("此平台的构建号已经存在，请使用新构建号。");
                long occupied;
                try (var paths = Files.list(root.resolve("packages"))) {
                    occupied = paths.filter(Files::isRegularFile).mapToLong(p -> p.toFile().length()).sum();
                }
                if (Files.getFileStore(root).getUsableSpace() - file.getSize() < reserveBytes || occupied + file.getSize() > budgetBytes)
                    throw bad("更新存储空间不足，请先清理归档或扩容。");
            }
            temporary = Files.createTempFile(root.resolve("packages"), "upload-", ".part");
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            long length = 0;
            try (InputStream in = file.getInputStream(); OutputStream out = Files.newOutputStream(temporary)) {
                byte[] buffer = new byte[65536]; int count;
                while ((count = in.read(buffer)) != -1) {
                    length += count;
                    if (length > MAX_FILE || length > file.getSize()) throw bad("安装包长度不正确。");
                    digest.update(buffer, 0, count); out.write(buffer, 0, count);
                }
            }
            if (length != file.getSize()) throw bad("安装包上传不完整。");
            validatePackage(temporary, ext);
            String id = UUID.randomUUID().toString(), name = id + "." + ext;
            target = root.resolve("packages").resolve(name);
            Files.move(temporary, target, StandardCopyOption.ATOMIC_MOVE);
            if (Files.getFileStore(target).supportsFileAttributeView("posix"))
                Files.setPosixFilePermissions(target, java.nio.file.attribute.PosixFilePermissions.fromString("rw-r--r--"));
            Release release = new Release(id, input.platform(), input.arch(), input.version(), input.build(), input.notes().trim(),
                    input.installMethod(), name, length, HexFormat.of().formatHex(digest.digest()), "draft", null,
                    List.of(new Event(actor, "upload", Instant.now().toString())));
            synchronized (this) {
                var all = new ArrayList<>(list()); all.add(release); save(all);
            }
            target = null; // Catalog owns the immutable file only after durable save.
            return release;
        } finally {
            if (temporary != null) Files.deleteIfExists(temporary);
            if (target != null) Files.deleteIfExists(target);
            uploadLock.unlock();
        }
    }
    private void validatePackage(Path path, String ext) throws IOException {
        if (ext.equals("exe")) {
            try (InputStream in = Files.newInputStream(path)) {
                if (in.read() != 'M' || in.read() != 'Z' || Files.size(path) < 4096) throw bad("不是有效的 Windows 安装包。");
            }
        } else {
            try (ZipFile archive = new ZipFile(path.toFile())) {
                String entry = ext.equals("apk") ? "AndroidManifest.xml" : "module.json";
                if (archive.getEntry(entry) == null || archive.size() > 50000) throw bad("安装包缺少平台清单。");
            } catch (java.util.zip.ZipException e) { throw bad("安装包结构无效。"); }
        }
    }
    public synchronized Release change(long actor, String id, boolean publish) throws Exception {
        var all = new ArrayList<>(list());
        Release old = all.stream().filter(r -> r.id().equals(id)).findFirst().orElseThrow(() -> bad("版本不存在。"));
        String state = publish ? "published" : "withdrawn";
        if (old.state().equals(state)) return old;
        if (publish) {
            if (all.stream().anyMatch(r -> r.platform().equals(old.platform()) && r.state().equals("published") && r.build() > old.build()))
                throw bad("已有更新构建，不能将旧版本重新发布为最新版本。");
            Path file = packagePath(old);
            if (Files.size(file) != old.size() || !hash(file).equals(old.sha256())) throw bad("安装包校验失败，禁止发布。");
        }
        var history = new ArrayList<>(old.history()); history.add(new Event(actor, publish ? "publish" : "withdraw", Instant.now().toString()));
        Release next = new Release(old.id(), old.platform(), old.arch(), old.version(), old.build(), old.notes(), old.installMethod(),
                old.fileName(), old.size(), old.sha256(), state, publish ? Instant.now().toString() : old.publishedAt(), history);
        all.set(all.indexOf(old), next); save(all); return next;
    }
    public String hash(Path file) throws Exception {
        MessageDigest digest = MessageDigest.getInstance("SHA-256");
        try (InputStream in = Files.newInputStream(file)) { byte[] buffer = new byte[65536]; int n; while ((n = in.read(buffer)) != -1) digest.update(buffer, 0, n); }
        return HexFormat.of().formatHex(digest.digest());
    }
    public Path packagePath(Release release) {
        if (!release.fileName().matches("[a-f0-9-]{36}\\.(exe|apk|hap)")) throw bad("安装包路径无效。");
        return root.resolve("packages").resolve(release.fileName());
    }
    public Release latest(String device, String platform, String arch, int currentBuild) throws IOException {
        if (currentBuild < 0 || !platformFor(device).equals(platform)) throw bad("更新平台与当前设备不匹配。");
        return list().stream().filter(r -> r.state().equals("published") && r.platform().equals(platform) && r.arch().equals(arch) && r.build() > currentBuild)
                .findFirst().orElse(null);
    }
    public Release download(String device, String id) throws IOException {
        String platform = platformFor(device);
        return list().stream().filter(r -> r.id().equals(id) && r.state().equals("published") && r.platform().equals(platform))
                .findFirst().orElseThrow(() -> new BusinessException(ErrorCode.NOT_FOUND, "此版本已下架或不适用于当前设备。"));
    }
}
