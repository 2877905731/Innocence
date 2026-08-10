package com.innocence.server.modules.account.service;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import com.innocence.server.modules.account.config.AvatarStorageProperties;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.nio.file.AtomicMoveNotSupportedException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;
import java.util.Locale;
import java.util.UUID;

@Service
public class AvatarStorageService {

    private static final String JPEG = "image/jpeg";
    private static final String PNG = "image/png";

    private final AvatarStorageProperties properties;

    public AvatarStorageService(AvatarStorageProperties properties) {
        this.properties = properties;
    }

    public String store(MultipartFile file) {
        byte[] content = validateAndRead(file);
        String contentType = normalizeContentType(file.getContentType());
        String extension = JPEG.equals(contentType) ? ".jpg" : ".png";
        Path storageDirectory = storageDirectory();
        Path temporaryFile = null;
        Path target = storageDirectory.resolve(UUID.randomUUID() + extension).normalize();
        if (!target.startsWith(storageDirectory)) {
            throw new BusinessException(ErrorCode.INTERNAL_ERROR, "头像存储路径无效");
        }

        try {
            Files.createDirectories(storageDirectory);
            temporaryFile = Files.createTempFile(storageDirectory, ".avatar-", ".upload");
            Files.write(temporaryFile, content);
            try {
                Files.move(temporaryFile, target, StandardCopyOption.ATOMIC_MOVE);
            } catch (AtomicMoveNotSupportedException exception) {
                Files.move(temporaryFile, target);
            }
            return publicUrl(target.getFileName().toString());
        } catch (IOException exception) {
            deleteQuietly(temporaryFile);
            throw new BusinessException(ErrorCode.INTERNAL_ERROR, "头像保存失败，请稍后重试");
        }
    }

    public void deleteIfManaged(String avatarUrl) {
        if (avatarUrl == null || avatarUrl.isBlank()) {
            return;
        }
        String publicPath = normalizePublicPath(properties.getPublicPath());
        if (!avatarUrl.startsWith(publicPath + "/")) {
            return;
        }
        String filename = avatarUrl.substring(publicPath.length() + 1);
        if (filename.contains("/") || filename.contains("\\") || filename.isBlank()) {
            return;
        }
        Path storageDirectory = storageDirectory();
        Path target = storageDirectory.resolve(filename).normalize();
        if (!target.startsWith(storageDirectory)) {
            return;
        }
        deleteQuietly(target);
    }

    Path storageDirectory() {
        return Path.of(properties.getStorageDir()).toAbsolutePath().normalize();
    }

    private byte[] validateAndRead(MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "请选择头像文件");
        }
        if (file.getSize() > properties.getMaxBytes()) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "头像文件不能超过 5 MiB");
        }

        String contentType = normalizeContentType(file.getContentType());
        if (!JPEG.equals(contentType) && !PNG.equals(contentType)) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "头像仅支持 JPEG 或 PNG 图片");
        }

        try {
            byte[] content = file.getBytes();
            if (content.length > properties.getMaxBytes()
                    || !matchesSignature(content, contentType)
                    || ImageIO.read(new ByteArrayInputStream(content)) == null) {
                throw new BusinessException(ErrorCode.BAD_REQUEST, "头像文件不是有效图片");
            }
            return content;
        } catch (IOException exception) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "头像文件读取失败");
        }
    }

    private String publicUrl(String filename) {
        return normalizePublicPath(properties.getPublicPath()) + "/" + filename;
    }

    private boolean matchesSignature(byte[] content, String contentType) {
        if (JPEG.equals(contentType)) {
            return content.length >= 3
                    && (content[0] & 0xff) == 0xff
                    && (content[1] & 0xff) == 0xd8
                    && (content[2] & 0xff) == 0xff;
        }
        return content.length >= 8
                && (content[0] & 0xff) == 0x89
                && content[1] == 0x50
                && content[2] == 0x4e
                && content[3] == 0x47
                && content[4] == 0x0d
                && content[5] == 0x0a
                && content[6] == 0x1a
                && content[7] == 0x0a;
    }

    private String normalizePublicPath(String publicPath) {
        if (publicPath == null || publicPath.isBlank()) {
            return "/uploads/avatars";
        }
        String normalized = publicPath.trim();
        return normalized.startsWith("/") ? normalized.replaceAll("/+$", "") : "/" + normalized.replaceAll("/+$", "");
    }

    private String normalizeContentType(String contentType) {
        if (contentType == null) {
            return "";
        }
        int parameterIndex = contentType.indexOf(';');
        String value = parameterIndex >= 0 ? contentType.substring(0, parameterIndex) : contentType;
        return value.trim().toLowerCase(Locale.ROOT);
    }

    private void deleteQuietly(Path path) {
        if (path == null) {
            return;
        }
        try {
            Files.deleteIfExists(path);
        } catch (IOException ignored) {
            // A failed cleanup must not hide the original upload or persistence error.
        }
    }
}
