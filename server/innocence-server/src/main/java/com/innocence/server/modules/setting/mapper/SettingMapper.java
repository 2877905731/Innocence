package com.innocence.server.modules.setting.mapper;

import com.innocence.server.modules.setting.domain.UserAppearanceSetting;
import com.innocence.server.modules.setting.domain.UserNotificationSetting;
import com.innocence.server.modules.setting.domain.UserWidgetSetting;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface SettingMapper {

    UserNotificationSetting findNotificationSettingByUserId(@Param("userId") Long userId);

    UserWidgetSetting findWidgetSettingByUserId(@Param("userId") Long userId);

    UserAppearanceSetting findAppearanceSettingByUserId(@Param("userId") Long userId);

    void insertNotificationSetting(UserNotificationSetting setting);

    void insertWidgetSetting(UserWidgetSetting setting);

    void insertAppearanceSetting(UserAppearanceSetting setting);

    void updateNotificationSetting(UserNotificationSetting setting);

    void updateWidgetSetting(UserWidgetSetting setting);

    void updateAppearanceSetting(UserAppearanceSetting setting);
}
