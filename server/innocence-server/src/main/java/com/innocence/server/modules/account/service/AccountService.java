package com.innocence.server.modules.account.service;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import com.innocence.server.modules.account.domain.User;
import com.innocence.server.modules.account.domain.UserAuth;
import com.innocence.server.modules.account.domain.UserBlacklist;
import com.innocence.server.modules.account.domain.UserPrivacySetting;
import com.innocence.server.modules.account.domain.UserProfile;
import com.innocence.server.modules.account.domain.UserSession;
import com.innocence.server.modules.account.dto.request.CancelAccountRequest;
import com.innocence.server.modules.account.dto.request.CodeLoginRequest;
import com.innocence.server.modules.account.dto.request.EmailRegisterRequest;
import com.innocence.server.modules.account.dto.request.PasswordLoginRequest;
import com.innocence.server.modules.account.dto.request.ResetPasswordRequest;
import com.innocence.server.modules.account.dto.request.UpdatePrivacyRequest;
import com.innocence.server.modules.account.dto.request.UpdateProfileRequest;
import com.innocence.server.modules.account.dto.response.AuthTokenResponse;
import com.innocence.server.modules.account.dto.response.BlacklistItemResponse;
import com.innocence.server.modules.account.dto.response.CurrentSessionResponse;
import com.innocence.server.modules.account.dto.response.PrivacySettingResponse;
import com.innocence.server.modules.account.dto.response.UserProfileResponse;
import com.innocence.server.modules.checkin.service.CheckInService;
import com.innocence.server.modules.friend.mapper.FriendMapper;
import com.innocence.server.modules.account.mapper.UserMapper;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.time.LocalDateTime;
import java.util.HexFormat;
import java.util.List;
import java.util.Locale;
import java.util.UUID;

@Service
public class AccountService {

    private final UserMapper userMapper;
    private final EmailCodeService emailCodeService;
    private final CheckInService checkInService;
    private final FriendMapper friendMapper;

    public AccountService(
            UserMapper userMapper,
            EmailCodeService emailCodeService,
            CheckInService checkInService,
            FriendMapper friendMapper
    ) {
        this.userMapper = userMapper;
        this.emailCodeService = emailCodeService;
        this.checkInService = checkInService;
        this.friendMapper = friendMapper;
    }

    @Transactional
    public AuthTokenResponse registerByEmail(EmailRegisterRequest request) {
        UserAuth existing = userMapper.findAuthByEmail(request.getEmail());
        if (existing != null) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "该邮箱已注册");
        }

        emailCodeService.validateCode(request.getEmail(), "register", request.getEmailCode());

        User user = new User();
        user.setUserNo(generateUserNo());
        user.setNickname(defaultNickname(request.getEmail()));
        user.setStatus(1);
        user.setLastLoginTime(LocalDateTime.now());
        userMapper.insertUser(user);

        String salt = UUID.randomUUID().toString().replace("-", "");
        UserAuth userAuth = new UserAuth();
        userAuth.setUserId(user.getId());
        userAuth.setAuthType("email");
        userAuth.setAuthAccount(request.getEmail());
        userAuth.setPasswordSalt(salt);
        userAuth.setPasswordHash(sha256(request.getPassword() + salt));
        userAuth.setIsVerified(1);
        userMapper.insertUserAuth(userAuth);

        UserProfile userProfile = new UserProfile();
        userProfile.setUserId(user.getId());
        userProfile.setBio("");
        userProfile.setTimezone("Asia/Shanghai");
        userMapper.insertUserProfile(userProfile);

        UserPrivacySetting privacySetting = new UserPrivacySetting();
        privacySetting.setUserId(user.getId());
        privacySetting.setAllowFriendViewProfile(1);
        privacySetting.setAllowTeammateViewStudy(1);
        privacySetting.setAllowStrangerMessage(0);
        userMapper.insertUserPrivacySetting(privacySetting);

        emailCodeService.clearCode(request.getEmail(), "register");

        UserSession session = createOrReplaceSession(user.getId(), request.getDeviceType(), request.getDeviceId());
        return buildAuthResponse(user, userProfile, session);
    }

    @Transactional
    public AuthTokenResponse loginByPassword(PasswordLoginRequest request) {
        UserAuth userAuth = requireUserAuth(request.getEmail());
        String expectedHash = sha256(request.getPassword() + userAuth.getPasswordSalt());
        if (!expectedHash.equals(userAuth.getPasswordHash())) {
            throw new BusinessException(ErrorCode.UNAUTHORIZED, "邮箱或密码错误");
        }

        userMapper.updateUserLoginTime(userAuth.getUserId());
        User user = requireUser(userAuth.getUserId());
        UserProfile profile = requireProfile(userAuth.getUserId());
        UserSession session = createOrReplaceSession(userAuth.getUserId(), request.getDeviceType(), request.getDeviceId());
        return buildAuthResponse(user, profile, session);
    }

    @Transactional
    public AuthTokenResponse loginByCode(CodeLoginRequest request) {
        emailCodeService.validateCode(request.getEmail(), "login", request.getEmailCode());

        UserAuth userAuth = requireUserAuth(request.getEmail());
        userMapper.updateUserLoginTime(userAuth.getUserId());
        User user = requireUser(userAuth.getUserId());
        UserProfile profile = requireProfile(userAuth.getUserId());
        emailCodeService.clearCode(request.getEmail(), "login");
        UserSession session = createOrReplaceSession(userAuth.getUserId(), request.getDeviceType(), request.getDeviceId());
        return buildAuthResponse(user, profile, session);
    }

    @Transactional(readOnly = true)
    public UserProfileResponse getMyProfile(Long userId) {
        User user = requireUser(userId);
        UserProfile profile = requireProfile(userId);
        return buildProfileResponse(user, profile);
    }

    @Transactional
    public UserProfileResponse updateMyProfile(Long userId, UpdateProfileRequest request) {
        User user = requireUser(userId);
        UserProfile profile = requireProfile(userId);

        user.setNickname(request.getNickname());
        user.setAvatarUrl(request.getAvatarUrl());
        profile.setBio(request.getBio());

        userMapper.updateUserProfile(user);
        userMapper.updateProfileExtra(profile);
        return buildProfileResponse(user, profile);
    }

    @Transactional(readOnly = true)
    public PrivacySettingResponse getPrivacySetting(Long userId) {
        UserPrivacySetting setting = requirePrivacy(userId);
        return buildPrivacyResponse(setting);
    }

    @Transactional
    public PrivacySettingResponse updatePrivacySetting(Long userId, UpdatePrivacyRequest request) {
        UserPrivacySetting setting = requirePrivacy(userId);
        setting.setAllowFriendViewProfile(request.getAllowFriendViewProfile());
        setting.setAllowTeammateViewStudy(request.getAllowTeammateViewStudy());
        setting.setAllowStrangerMessage(0);
        userMapper.updatePrivacy(setting);
        return buildPrivacyResponse(setting);
    }

    @Transactional
    public void resetPassword(ResetPasswordRequest request) {
        emailCodeService.validateCode(request.getEmail(), "reset", request.getEmailCode());

        UserAuth userAuth = requireUserAuth(request.getEmail());
        String salt = UUID.randomUUID().toString().replace("-", "");
        String hash = sha256(request.getNewPassword() + salt);
        userMapper.updatePassword(userAuth.getUserId(), hash, salt);
        emailCodeService.clearCode(request.getEmail(), "reset");
    }

    @Transactional(readOnly = true)
    public CurrentSessionResponse getCurrentSession(Long userId, String deviceType, String deviceId, String sessionToken) {
        requireUser(userId);

        String normalizedType = normalizeDeviceType(deviceType);
        String deviceSlot = normalizeDeviceSlot(normalizedType);
        UserSession session = userMapper.findSessionByUserIdAndSlot(userId, deviceSlot);

        CurrentSessionResponse response = new CurrentSessionResponse();
        response.setDeviceType(normalizedType);
        response.setDeviceSlot(deviceSlot);
        response.setDeviceId(deviceId);

        if (session == null) {
            response.setOnline(0);
            response.setReplaced(0);
            response.setSessionToken("");
            response.setLoginTime("");
            response.setLogoutTime("");
            return response;
        }

        response.setDeviceId(session.getDeviceId());
        response.setSessionToken(session.getSessionToken());
        response.setOnline(session.getStatus());
        response.setReplaced(isCurrentDeviceReplaced(session, deviceId, sessionToken) ? 1 : 0);
        response.setLoginTime(formatTime(session.getLoginTime()));
        response.setLogoutTime(formatTime(session.getLogoutTime()));
        return response;
    }

    @Transactional
    public void cancelAccount(Long userId, CancelAccountRequest request) {
        User user = requireUser(userId);
        UserAuth userAuth = requireUserAuthByUserId(userId);

        boolean hasPassword = request.getPassword() != null && !request.getPassword().isBlank();
        boolean hasCode = request.getEmailCode() != null && !request.getEmailCode().isBlank();
        if (!hasPassword && !hasCode) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "注销账号需要密码或验证码");
        }
        if (hasPassword) {
            String expectedHash = sha256(request.getPassword() + userAuth.getPasswordSalt());
            if (!expectedHash.equals(userAuth.getPasswordHash())) {
                throw new BusinessException(ErrorCode.UNAUTHORIZED, "注销失败，密码错误");
            }
        }
        if (hasCode) {
            emailCodeService.validateCode(userAuth.getAuthAccount(), "reset", request.getEmailCode());
        }

        userMapper.cancelSessions(user.getId(), LocalDateTime.now());
        userMapper.cancelAccount(user.getId());
    }

    @Transactional(readOnly = true)
    public List<BlacklistItemResponse> getBlacklist(Long userId) {
        return userMapper.findBlacklistByUserId(userId).stream().map(this::buildBlacklistItem).toList();
    }

    @Transactional
    public void addBlacklist(Long userId, Long blockedUserId) {
        requireUser(userId);
        requireUser(blockedUserId);
        if (userId.equals(blockedUserId)) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "不能拉黑自己");
        }
        try {
            userMapper.insertBlacklist(userId, blockedUserId);
            friendMapper.deleteFriendRelation(userId, blockedUserId);
            friendMapper.deleteFriendRelation(blockedUserId, userId);
            friendMapper.deleteFriendRequestsBetweenUsers(userId, blockedUserId);
        } catch (DuplicateKeyException exception) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "该用户已在黑名单中");
        }
    }

    @Transactional
    public void removeBlacklist(Long userId, Long blockedUserId) {
        requireUser(userId);
        userMapper.deleteBlacklist(userId, blockedUserId);
    }

    private UserAuth requireUserAuth(String email) {
        UserAuth userAuth = userMapper.findAuthByEmail(email);
        if (userAuth == null) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "账号不存在");
        }
        return userAuth;
    }

    private UserAuth requireUserAuthByUserId(Long userId) {
        UserAuth userAuth = userMapper.findAuthByUserId(userId);
        if (userAuth == null) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "账号认证信息不存在");
        }
        return userAuth;
    }

    private User requireUser(Long userId) {
        User user = userMapper.findUserById(userId);
        if (user == null) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "用户不存在");
        }
        return user;
    }

    private UserProfile requireProfile(Long userId) {
        UserProfile profile = userMapper.findProfileByUserId(userId);
        if (profile == null) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "用户资料不存在");
        }
        return profile;
    }

    private UserPrivacySetting requirePrivacy(Long userId) {
        UserPrivacySetting setting = userMapper.findPrivacyByUserId(userId);
        if (setting == null) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "隐私设置不存在");
        }
        return setting;
    }

    private AuthTokenResponse buildAuthResponse(User user, UserProfile profile, UserSession session) {
        AuthTokenResponse response = new AuthTokenResponse();
        response.setAccessToken(session.getSessionToken());
        response.setTokenType("Bearer");
        response.setDeviceType(session.getDeviceType());
        response.setDeviceSlot(session.getDeviceSlot());
        response.setDeviceId(session.getDeviceId());
        response.setUserInfo(buildProfileResponse(user, profile));
        return response;
    }

    private UserProfileResponse buildProfileResponse(User user, UserProfile profile) {
        Integer totalStudySeconds = userMapper.findTotalStudySecondsByUserId(user.getId());
        int totalCheckInDays = checkInService.getTotalCheckInDays(user.getId());

        UserProfileResponse response = new UserProfileResponse();
        response.setUserId(user.getId());
        response.setUserNo(user.getUserNo());
        response.setNickname(user.getNickname());
        response.setAvatarUrl(user.getAvatarUrl());
        response.setBio(profile.getBio());
        response.setTimezone(profile.getTimezone());
        response.setStudyDurationTotal((totalStudySeconds == null ? 0 : Math.max(totalStudySeconds, 0)) / 60);
        response.setCheckInDaysTotal(totalCheckInDays);
        return response;
    }

    private PrivacySettingResponse buildPrivacyResponse(UserPrivacySetting setting) {
        PrivacySettingResponse response = new PrivacySettingResponse();
        response.setAllowFriendViewProfile(setting.getAllowFriendViewProfile());
        response.setAllowTeammateViewStudy(setting.getAllowTeammateViewStudy());
        response.setAllowStrangerMessage(setting.getAllowStrangerMessage());
        return response;
    }

    private BlacklistItemResponse buildBlacklistItem(UserBlacklist item) {
        BlacklistItemResponse response = new BlacklistItemResponse();
        response.setBlockedUserId(item.getBlockedUserId());
        response.setCreateTime(formatTime(item.getCreateTime()));
        return response;
    }

    private UserSession createOrReplaceSession(Long userId, String deviceType, String deviceId) {
        String normalizedType = normalizeDeviceType(deviceType);
        String deviceSlot = normalizeDeviceSlot(normalizedType);
        LocalDateTime now = LocalDateTime.now();

        UserSession session = new UserSession();
        session.setUserId(userId);
        session.setDeviceType(normalizedType);
        session.setDeviceSlot(deviceSlot);
        session.setDeviceId(normalizeDeviceId(deviceId));
        session.setSessionToken(UUID.randomUUID().toString().replace("-", ""));
        session.setStatus(1);
        session.setLoginTime(now);
        session.setLogoutTime(null);
        userMapper.upsertSession(session);
        return session;
    }

    private String normalizeDeviceType(String deviceType) {
        if (deviceType == null || deviceType.isBlank()) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "设备类型不能为空");
        }
        String normalized = deviceType.trim().toLowerCase(Locale.ROOT);
        return switch (normalized) {
            case "android", "ios", "mobile", "phone" -> "android";
            case "windows", "desktop", "pc" -> "windows";
            default -> throw new BusinessException(ErrorCode.BAD_REQUEST, "当前只支持 android 和 windows 设备登录");
        };
    }

    private String normalizeDeviceSlot(String deviceType) {
        return "windows".equals(deviceType) ? "desktop" : "mobile";
    }

    private String normalizeDeviceId(String deviceId) {
        if (deviceId == null || deviceId.isBlank()) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "设备标识不能为空");
        }
        return deviceId.trim();
    }

    private boolean isCurrentDeviceReplaced(UserSession activeSession, String deviceId, String sessionToken) {
        String normalizedDeviceId = normalizeDeviceId(deviceId);
        boolean sameDevice = normalizedDeviceId.equals(activeSession.getDeviceId());
        if (sessionToken == null || sessionToken.isBlank()) {
            return !sameDevice;
        }
        return !(sameDevice && sessionToken.equals(activeSession.getSessionToken()));
    }

    private String generateUserNo() {
        return "U" + System.currentTimeMillis();
    }

    private String defaultNickname(String email) {
        int index = email.indexOf('@');
        return index > 0 ? email.substring(0, index) : email;
    }

    private String formatTime(LocalDateTime time) {
        return time == null ? "" : time.toString();
    }

    private String sha256(String content) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] hash = digest.digest(content.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(hash);
        } catch (NoSuchAlgorithmException exception) {
            throw new IllegalStateException("SHA-256 not available", exception);
        }
    }
}
