package com.innocence.server.modules.account.service;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import com.innocence.server.modules.account.domain.User;
import com.innocence.server.modules.account.dto.response.AvatarUploadResponse;
import com.innocence.server.modules.account.mapper.UserMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.multipart.MultipartFile;

@Service
public class AvatarUploadService {

    private final UserMapper userMapper;
    private final AvatarStorageService avatarStorageService;

    public AvatarUploadService(UserMapper userMapper, AvatarStorageService avatarStorageService) {
        this.userMapper = userMapper;
        this.avatarStorageService = avatarStorageService;
    }

    @Transactional
    public AvatarUploadResponse uploadForUser(Long userId, MultipartFile file) {
        User user = userMapper.findUserById(userId);
        if (user == null) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "用户不存在");
        }

        String avatarUrl = avatarStorageService.store(file);
        user.setAvatarUrl(avatarUrl);
        try {
            userMapper.updateUserProfile(user);
        } catch (RuntimeException exception) {
            avatarStorageService.deleteIfManaged(avatarUrl);
            throw exception;
        }
        return new AvatarUploadResponse(avatarUrl);
    }
}
