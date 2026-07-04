package com.innocence.server.modules.account.mapper;

import com.innocence.server.modules.account.domain.User;
import com.innocence.server.modules.account.domain.UserAuth;
import com.innocence.server.modules.account.domain.UserBlacklist;
import com.innocence.server.modules.account.domain.UserPrivacySetting;
import com.innocence.server.modules.account.domain.UserProfile;
import com.innocence.server.modules.account.domain.UserSession;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface UserMapper {

    UserAuth findAuthByEmail(@Param("email") String email);

    UserAuth findAuthByUserId(@Param("userId") Long userId);

    User findUserById(@Param("userId") Long userId);

    UserProfile findProfileByUserId(@Param("userId") Long userId);

    UserPrivacySetting findPrivacyByUserId(@Param("userId") Long userId);

    List<UserBlacklist> findBlacklistByUserId(@Param("userId") Long userId);

    UserSession findSessionByUserIdAndSlot(@Param("userId") Long userId, @Param("deviceSlot") String deviceSlot);

    void insertUser(User user);

    void insertUserAuth(UserAuth userAuth);

    void insertUserProfile(UserProfile userProfile);

    void insertUserPrivacySetting(UserPrivacySetting userPrivacySetting);

    void upsertSession(UserSession userSession);

    void updateUserLoginTime(@Param("userId") Long userId);

    void updateUserProfile(User user);

    void updateProfileExtra(UserProfile userProfile);

    void updatePrivacy(UserPrivacySetting userPrivacySetting);

    void updatePassword(@Param("userId") Long userId, @Param("passwordHash") String passwordHash, @Param("passwordSalt") String passwordSalt);

    void cancelAccount(@Param("userId") Long userId);

    void cancelSessions(@Param("userId") Long userId, @Param("logoutTime") java.time.LocalDateTime logoutTime);

    void insertBlacklist(@Param("userId") Long userId, @Param("blockedUserId") Long blockedUserId);

    void deleteBlacklist(@Param("userId") Long userId, @Param("blockedUserId") Long blockedUserId);
}
