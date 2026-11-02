package com.innocence.server.modules.update;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.innocence.server.common.exception.BusinessException;
import org.junit.jupiter.api.*;
import org.junit.jupiter.api.io.TempDir;
import org.springframework.mock.web.MockMultipartFile;
import java.nio.file.*;
import static org.junit.jupiter.api.Assertions.*;

class ReleaseServiceTest {
    @TempDir Path directory;
    ReleaseService service;
    ReleaseService.Input input(int build) { return new ReleaseService.Input("windows", "x64", "1.3.4", build, "计时与更新", "windows_installer"); }
    MockMultipartFile file() { byte[] data = new byte[8192]; data[0] = 'M'; data[1] = 'Z'; return new MockMultipartFile("file", "untrusted-name.exe", "application/octet-stream", data); }
    @BeforeEach void setup() { service = new ReleaseService(new ObjectMapper(), directory.toString(), 0, 1048576, false); }
    @Test void draftIsInvisiblePublicationPersistsAndWithdrawalStopsDownloads() throws Exception {
        var draft = service.upload(7, input(16), file());
        assertNull(service.latest("windows", "windows", "x64", 15));
        assertThrows(BusinessException.class, () -> service.download("windows", draft.id()));
        var published = service.change(7, draft.id(), true);
        assertEquals(draft.sha256(), service.hash(service.packagePath(draft)));
        assertEquals(draft.id(), service.latest("windows", "windows", "x64", 15).id());
        assertNull(service.latest("windows", "windows", "x64", 16));
        assertThrows(BusinessException.class, () -> service.download("android", draft.id()));
        assertThrows(BusinessException.class, () -> service.latest("android", "windows", "x64", 15));
        var restarted = new ReleaseService(new ObjectMapper(), directory.toString(), 0, 1048576, false);
        assertEquals(published, restarted.list().getFirst());
        restarted.change(9, draft.id(), false);
        assertNull(restarted.latest("windows", "windows", "x64", 15));
        assertThrows(BusinessException.class, () -> restarted.download("windows", draft.id()));
        assertEquals(3, restarted.list().getFirst().history().size());
    }
    @Test void duplicateBuildDowngradeAndTamperingCannotPublish() throws Exception {
        var first = service.upload(7, input(16), file());
        assertThrows(BusinessException.class, () -> service.upload(7, input(16), file()));
        var second = service.upload(7, input(17), file()); service.change(7, second.id(), true);
        assertThrows(BusinessException.class, () -> service.change(7, first.id(), true));
        var third = service.upload(7, input(18), file());
        Files.write(service.packagePath(third), new byte[]{0});
        assertThrows(BusinessException.class, () -> service.change(7, third.id(), true));
        assertEquals("draft", service.list().getFirst().state());
    }
    @Test void invalidFieldsWrongPackagesAndDiskBudgetsLeaveNoCatalogEntry() throws Exception {
        assertThrows(BusinessException.class, () -> service.upload(7, null, file()));
        assertThrows(BusinessException.class, () -> service.upload(7, new ReleaseService.Input("harmonyos", "arm64", "1.3.4",16,"x","android_apk"), file()));
        assertThrows(BusinessException.class, () -> service.upload(7, input(16), new MockMultipartFile("file", new byte[]{1,2,3})));
        var exhausted = new ReleaseService(new ObjectMapper(), directory.toString(), Long.MAX_VALUE, 1048576, false);
        assertThrows(BusinessException.class, () -> exhausted.upload(7, input(16), file()));
        assertTrue(service.list().isEmpty());
        try (var files = Files.list(directory.resolve("packages"))) { assertEquals(0, files.count()); }
    }
}
