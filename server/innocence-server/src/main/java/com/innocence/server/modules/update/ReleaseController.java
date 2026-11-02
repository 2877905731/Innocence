package com.innocence.server.modules.update;

import com.innocence.server.common.api.ApiResponse;
import com.innocence.server.common.web.RequestUserContext;
import com.innocence.server.modules.report.service.AdminAccessService;
import org.springframework.core.io.FileSystemResource;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import java.util.*;

@RestController
public class ReleaseController {
    private final ReleaseService releases;
    private final AdminAccessService admins;
    public ReleaseController(ReleaseService releases, AdminAccessService admins) { this.releases = releases; this.admins = admins; }
    private long admin() { Long id = RequestUserContext.getUserId(); admins.requireAdmin(id); return id; }
    @GetMapping("/api/admin/v1/releases")
    public ApiResponse<List<ReleaseService.Release>> list() throws Exception { admin(); return ApiResponse.success(releases.list()); }
    @PostMapping(value = "/api/admin/v1/releases", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ApiResponse<ReleaseService.Release> upload(@RequestPart("metadata") ReleaseService.Input metadata, @RequestPart("file") MultipartFile file) throws Exception {
        return ApiResponse.success(releases.upload(admin(), metadata, file));
    }
    @PostMapping("/api/admin/v1/releases/{id}/publish")
    public ApiResponse<ReleaseService.Release> publish(@PathVariable String id) throws Exception { return ApiResponse.success(releases.change(admin(), id, true)); }
    @PostMapping("/api/admin/v1/releases/{id}/withdraw")
    public ApiResponse<ReleaseService.Release> withdraw(@PathVariable String id) throws Exception { return ApiResponse.success(releases.change(admin(), id, false)); }
    @GetMapping("/api/app/v1/updates/latest")
    public ApiResponse<Map<String, Object>> latest(@RequestHeader("X-Device-Type") String device,
             @RequestParam String platform, @RequestParam String arch, @RequestParam int currentBuild) throws Exception {
        Map<String, Object> result = new HashMap<>();
        result.put("update", publicRelease(releases.latest(device, platform, arch, currentBuild)));
        return ApiResponse.success(result);
    }
    private Map<String, Object> publicRelease(ReleaseService.Release r) {
        if (r == null) return null;
        return Map.ofEntries(Map.entry("id", r.id()), Map.entry("platform", r.platform()), Map.entry("arch", r.arch()),
                Map.entry("version", r.version()), Map.entry("build", r.build()), Map.entry("notes", r.notes()),
                Map.entry("installMethod", r.installMethod()), Map.entry("fileName", r.fileName()), Map.entry("size", r.size()),
                Map.entry("sha256", r.sha256()), Map.entry("publishedAt", r.publishedAt()));
    }
    @GetMapping("/api/app/v1/updates/{id}/download")
    public ResponseEntity<?> download(@RequestHeader("X-Device-Type") String device, @PathVariable String id) throws Exception {
        var release = releases.download(device, id);
        var headers = new HttpHeaders(); headers.setCacheControl("private, no-store");
        headers.setContentType(MediaType.APPLICATION_OCTET_STREAM);
        headers.setContentDisposition(ContentDisposition.attachment().filename(release.fileName()).build());
        headers.setETag("\"" + release.sha256() + "\"");
        if (releases.usesAccel()) {
            headers.set("X-Accel-Redirect", "/_innocence_updates/" + release.fileName());
            return new ResponseEntity<>(null, headers, HttpStatus.OK);
        }
        return new ResponseEntity<>(new FileSystemResource(releases.packagePath(release)), headers, HttpStatus.OK);
    }
    @GetMapping("/api/app/v1/updates/{id}")
    public ApiResponse<Map<String, Object>> descriptor(@RequestHeader("X-Device-Type") String device, @PathVariable String id) throws Exception {
        return ApiResponse.success(publicRelease(releases.download(device, id)));
    }
}
