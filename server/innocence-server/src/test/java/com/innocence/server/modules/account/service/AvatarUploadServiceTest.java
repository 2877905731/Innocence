package com.innocence.server.modules.account.service;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import com.innocence.server.modules.account.config.AvatarStorageProperties;
import com.innocence.server.modules.account.domain.User;
import com.innocence.server.modules.account.dto.response.AvatarUploadResponse;
import com.innocence.server.modules.account.mapper.UserMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.io.TempDir;
import org.springframework.mock.web.MockMultipartFile;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

class AvatarUploadServiceTest {

    @TempDir
    Path temporaryDirectory;

    private UserMapper userMapper;
    private AvatarUploadService avatarUploadService;
    private User currentUser;

    @BeforeEach
    void setUp() {
        userMapper = mock(UserMapper.class);
        AvatarStorageProperties properties = new AvatarStorageProperties();
        properties.setStorageDir(temporaryDirectory.toString());
        AvatarStorageService storageService = new AvatarStorageService(properties);
        avatarUploadService = new AvatarUploadService(userMapper, storageService);
        currentUser = new User();
        currentUser.setId(7L);
        currentUser.setNickname("synthetic-user");
        currentUser.setAvatarUrl("");
        when(userMapper.findUserById(7L)).thenReturn(currentUser);
    }

    @Test
    void storesValidPngAndUpdatesOnlyCurrentUserProfile() throws IOException {
        AvatarUploadResponse response = avatarUploadService.uploadForUser(
                7L,
                multipart("avatar.png", "image/png", pngBytes())
        );

        assertEquals("/uploads/avatars/" + response.getAvatarUrl().substring(response.getAvatarUrl().lastIndexOf('/') + 1), response.getAvatarUrl());
        assertEquals(response.getAvatarUrl(), currentUser.getAvatarUrl());
        verify(userMapper).updateUserProfile(currentUser);
        assertEquals(1, storedFileCount());
    }

    @Test
    void rejectsMissingFile() {
        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> avatarUploadService.uploadForUser(7L, null)
        );

        assertEquals(ErrorCode.BAD_REQUEST, exception.getCode());
        verify(userMapper, never()).updateUserProfile(currentUser);
    }

    @Test
    void rejectsUnsupportedContentTypeBeforeWriting() {
        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> avatarUploadService.uploadForUser(
                        7L,
                        multipart("avatar.gif", "image/gif", new byte[]{1, 2, 3})
                )
        );

        assertEquals(ErrorCode.BAD_REQUEST, exception.getCode());
        assertFalse(Files.exists(temporaryDirectory.resolve("avatar.gif")));
        verify(userMapper, never()).updateUserProfile(currentUser);
    }

    @Test
    void rejectsInvalidImagePayloadEvenWhenContentTypeLooksValid() {
        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> avatarUploadService.uploadForUser(
                        7L,
                        multipart("avatar.png", "image/png", new byte[]{1, 2, 3})
                )
        );

        assertEquals(ErrorCode.BAD_REQUEST, exception.getCode());
        verify(userMapper, never()).updateUserProfile(currentUser);
    }

    @Test
    void rejectsFileOverFiveMib() {
        AvatarStorageProperties properties = new AvatarStorageProperties();
        properties.setStorageDir(temporaryDirectory.toString());
        properties.setMaxBytes(2);
        avatarUploadService = new AvatarUploadService(
                userMapper,
                new AvatarStorageService(properties)
        );

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> avatarUploadService.uploadForUser(
                        7L,
                        multipart("avatar.png", "image/png", new byte[]{1, 2, 3})
                )
        );

        assertEquals(ErrorCode.BAD_REQUEST, exception.getCode());
        verify(userMapper, never()).updateUserProfile(currentUser);
    }

    @Test
    void rejectsUnknownUserWithoutWritingFile() throws IOException {
        when(userMapper.findUserById(8L)).thenReturn(null);

        BusinessException exception = assertThrows(
                BusinessException.class,
                () -> avatarUploadService.uploadForUser(8L, multipart("avatar.png", "image/png", pngBytes()))
        );

        assertEquals(ErrorCode.NOT_FOUND, exception.getCode());
        assertEquals(0, storedFileCount());
    }

    private MockMultipartFile multipart(String name, String contentType, byte[] content) {
        return new MockMultipartFile("file", name, contentType, content);
    }

    private byte[] pngBytes() throws IOException {
        BufferedImage image = new BufferedImage(2, 2, BufferedImage.TYPE_INT_ARGB);
        ByteArrayOutputStream output = new ByteArrayOutputStream();
        ImageIO.write(image, "png", output);
        return output.toByteArray();
    }

    private long storedFileCount() throws IOException {
        try (var files = Files.list(temporaryDirectory)) {
            return files.count();
        }
    }
}
