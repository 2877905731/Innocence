# Innocence 前后端接口清单草案

## 1. 文档说明

- 文档目标：把已经确认的产品规则，整理成可以直接指导前后端开发的接口清单。
- 当前阶段：第一版接口草案。
- 适用范围：
  - 手机端 Flutter App
  - 桌面端 Flutter App / 桌面挂件
  - Spring Boot 后端
  - 管理后台
- 本文重点：
  - 明确接口边界
  - 明确哪些走普通接口，哪些走实时通道
  - 为后续 Controller、Service、Mapper 拆分提供依据

## 2. 统一接口约定

### 2.1 基础路径建议

- 前台 App 接口前缀：`/api/app/v1`
- 后台管理接口前缀：`/api/admin/v1`
- 实时通道：`/ws/app`

### 2.2 鉴权方式建议

- 登录成功后返回 `accessToken`
- 前后台统一使用 `Authorization: Bearer {token}`
- 需要附带设备信息：
  - `X-Device-Id`
  - `X-Device-Type`，取值建议：`mobile`、`desktop`

### 2.3 统一返回结构建议

```json
{
  "code": 0,
  "message": "ok",
  "data": {},
  "requestId": "8b1f2a...",
  "serverTime": "2026-07-03T23:10:00+08:00"
}
```

说明：

- `code = 0` 表示成功
- 非 0 表示业务失败
- 业务失败不要只返回 HTTP 500，尽量返回可读错误码

### 2.4 分页结构建议

```json
{
  "pageNo": 1,
  "pageSize": 20,
  "total": 100,
  "list": []
}
```

### 2.5 统一时间与同步字段建议

- 时间统一使用 ISO 8601 字符串
- 需要双端同步的写接口，建议都返回：
  - `syncVersion`
  - `updateTime`
- 客户端提交变更时，建议带上：
  - `clientTime`
  - `clientVersion`
  - `deviceId`

### 2.6 文件上传建议

- 头像上传单独走文件接口
- 使用 `multipart/form-data`
- 文件存储可先走本地映射目录，后续切对象存储

## 3. 通道划分建议

### 3.1 适合走 REST 的内容

- 注册、登录、资料修改
- 好友、团队、计划、备忘录等增删改查
- 统计中心数据拉取
- 通知列表、历史聊天记录拉取

### 3.2 适合走 WebSocket 的内容

- 私信实时收发
- 团队群聊实时收发
- 队友提醒实时推送
- 队友完成通知
- 未读数变化
- 当前学习状态同步

### 3.3 适合走系统推送 / 系统通知的内容

- 手机推送通知
- 桌面端系统通知
- 系统公告触达
- 当用户不在应用前台时的重要提醒

## 4. 前台 App 接口清单

### 4.1 认证与账户

| 接口 | 方法 | 用途 | 关键请求参数 | 关键返回字段 |
| --- | --- | --- | --- | --- |
| `/auth/email/send-register-code` | POST | 发送注册验证码 | `email` | `cooldownSeconds` |
| `/auth/email/register` | POST | 邮箱注册 | `email` `password` `emailCode` `deviceType` `deviceId` | `accessToken` `userInfo` |
| `/auth/email/send-login-code` | POST | 发送登录验证码 | `email` | `cooldownSeconds` |
| `/auth/login/password` | POST | 邮箱+密码登录 | `email` `password` `deviceType` `deviceId` | `accessToken` `userInfo` `sessionPolicy` |
| `/auth/login/code` | POST | 邮箱+验证码登录 | `email` `emailCode` `deviceType` `deviceId` | `accessToken` `userInfo` `sessionPolicy` |
| `/auth/session/replace` | POST | 超出设备限制时替换同类型设备会话 | `deviceType` `replaceSessionId` | `accessToken` `sessionInfo` |
| `/auth/logout` | POST | 当前设备退出登录 | 无 | `success` |
| `/auth/password/send-reset-code` | POST | 发送找回密码验证码 | `email` | `cooldownSeconds` |
| `/auth/password/reset` | POST | 重置密码 | `email` `emailCode` `newPassword` | `success` |
| `/account/profile` | GET | 获取自己的资料 | 无 | `userId` `userNo` `nickname` `avatarUrl` `studyDurationTotal` `checkInDaysTotal` |
| `/account/profile` | PUT | 修改自己的资料 | `nickname` `avatarUrl` `bio` | `profile` |
| `/account/avatar/upload` | POST | 上传头像 | `file` | `avatarUrl` |
| `/account/privacy` | GET | 获取隐私设置 | 无 | `allowFriendViewProfile` `allowTeammateViewStudy` |
| `/account/privacy` | PUT | 更新隐私设置 | `allowFriendViewProfile` `allowTeammateViewStudy` | `privacySetting` |
| `/account/blacklist` | GET | 黑名单列表 | `pageNo` `pageSize` | `list` |
| `/account/blacklist/{targetUserId}` | POST | 拉黑用户 | 路径参数 | `success` |
| `/account/blacklist/{targetUserId}` | DELETE | 取消拉黑 | 路径参数 | `success` |
| `/account/sessions/current` | GET | 获取当前登录信息 | 无 | `deviceType` `deviceId` `loginTime` |
| `/account/cancel` | POST | 注销账号 | `password` 或 `emailCode` | `success` |

接口说明：

- 邮箱只用于注册、登录、找回，不对外暴露。
- 同一账号只允许 `1 台手机 + 1 台电脑` 同时在线。
- 如果出现同类型设备冲突，后端返回可替换会话信息，由前端决定是否顶下线旧设备。

### 4.2 用户搜索与资料查看

| 接口 | 方法 | 用途 | 关键请求参数 | 关键返回字段 |
| --- | --- | --- | --- | --- |
| `/users/search` | GET | 搜索用户 | `keyword` `searchType`，支持 `userNo` `nickname` `inviteCode` | `list` |
| `/users/{userId}/profile` | GET | 查看用户资料 | 路径参数 | `nickname` `avatarUrl` `studyDurationTotal` `checkInDaysTotal` |
| `/users/{userId}/study-summary` | GET | 查看用户学习摘要 | 路径参数 | `todayStudyDuration` `todayPlanCompletion` `recentCheckIn` |

接口说明：

- 非好友查看资料时，由后端按隐私规则裁剪返回内容。
- 非队友查看学习摘要时，应直接返回无权限提示。
- 被拉黑双方不可互相查看资料。

### 4.3 设备与同步

| 接口 | 方法 | 用途 | 关键请求参数 | 关键返回字段 |
| --- | --- | --- | --- | --- |
| `/sync/bootstrap` | GET | 登录后拉取初始同步摘要 | `deviceType` `deviceId` | `lastSyncVersion` `currentStudyState` `unreadSummary` |
| `/sync/changes` | GET | 拉取指定版本之后的变更 | `sinceVersion` | `changeList` `latestVersion` |
| `/sync/upload` | POST | 上传离线或本地变更 | `changeList` | `acceptedList` `latestVersion` |
| `/sync/status` | GET | 获取当前同步状态 | 无 | `lastSyncTime` `pendingCount` `failedCount` |
| `/sync/retry` | POST | 重试失败同步任务 | `taskIds` | `successCount` |

接口说明：

- 第一版冲突策略按你前面确认的规则，采用“最后修改覆盖”。
- 桌面端离线期间可先本地记账，联网后统一补传。
- `changeList` 建议至少包含：`bizType`、`bizId`、`operationType`、`payload`、`clientVersion`。

### 4.4 好友模块

| 接口 | 方法 | 用途 | 关键请求参数 | 关键返回字段 |
| --- | --- | --- | --- | --- |
| `/friends/requests` | POST | 发起好友申请 | `targetUserId` `message` | `requestId` `status` |
| `/friends/requests` | GET | 获取收到的好友申请列表 | `status` `pageNo` `pageSize` | `list` |
| `/friends/requests/sent` | GET | 获取发出的好友申请列表 | `status` `pageNo` `pageSize` | `list` |
| `/friends/requests/{requestId}/accept` | POST | 同意好友申请 | 路径参数 | `friendInfo` |
| `/friends/requests/{requestId}/reject` | POST | 拒绝好友申请 | 路径参数 | `success` |
| `/friends` | GET | 获取好友列表 | `groupId` `keyword` | `list` |
| `/friends/{friendUserId}` | DELETE | 删除好友 | 路径参数 | `success` |
| `/friends/groups` | GET | 获取好友分组列表 | 无 | `list` |
| `/friends/groups` | POST | 新建好友分组 | `groupName` | `groupInfo` |
| `/friends/groups/{groupId}` | PUT | 修改好友分组 | `groupName` `sortNo` | `groupInfo` |
| `/friends/groups/{groupId}` | DELETE | 删除好友分组 | 路径参数 | `success` |
| `/friends/groups/{groupId}/members` | POST | 把好友加入分组 | `friendUserIdList` | `success` |
| `/friends/groups/{groupId}/members/{friendUserId}` | DELETE | 从分组移除好友 | 路径参数 | `success` |

接口说明：

- 好友申请必须经过对方同意。
- 好友数量上限先按 `200` 控制。
- 删除好友后，按已确认规则，私信记录一并删除。
- 团队队友可以互相加好友，也可以只保留队友关系。

### 4.5 团队模块

| 接口 | 方法 | 用途 | 关键请求参数 | 关键返回字段 |
| --- | --- | --- | --- | --- |
| `/teams` | POST | 创建团队 | `teamName` | `teamInfo` `inviteCode` |
| `/teams/current` | GET | 获取当前所在团队 | 无 | `teamInfo` `memberList` `inviteCodeInfo` |
| `/teams/current/invite-code` | GET | 获取当前团队邀请码 | 无 | `inviteCode` `expireTime` |
| `/teams/current/invite-code/refresh` | POST | 刷新邀请码 | 无 | `inviteCode` `expireTime` |
| `/teams/invitations` | POST | 邀请用户加入团队 | `targetUserId` 或 `inviteCode` | `invitationId` |
| `/teams/invitations` | GET | 获取收到的团队邀请 | `status` `pageNo` `pageSize` | `list` |
| `/teams/invitations/{invitationId}/accept` | POST | 同意团队邀请 | 路径参数 | `teamInfo` |
| `/teams/invitations/{invitationId}/reject` | POST | 拒绝团队邀请 | 路径参数 | `success` |
| `/teams/join-by-code` | POST | 通过邀请码申请加入团队 | `inviteCode` | `invitationId` `status` |
| `/teams/current/members` | GET | 获取团队成员列表 | 无 | `list` |
| `/teams/current/members/{memberUserId}` | DELETE | 移除某个团队成员 | 路径参数 | `success` |
| `/teams/current/dismiss` | DELETE | 解散团队 | 无 | `success` |
| `/teams/current/overview` | GET | 获取团队总览 | 无 | `memberProgressList` `todayNoticeList` |

接口说明：

- 一个用户只能加入 `1` 个团队。
- 一个团队最多 `5` 人。
- 只有队长可以移除成员和解散团队。
- 所有团队邀请都需要对方同意。
- 团队解散后，按已确认规则，团队聊天和相关团队数据整体清除。

### 4.6 私信、团队交流、提醒、未读

| 接口 | 方法 | 用途 | 关键请求参数 | 关键返回字段 |
| --- | --- | --- | --- | --- |
| `/chat/private/sessions` | GET | 获取私信会话列表 | 无 | `list` |
| `/chat/private/messages` | GET | 获取与某好友的私信历史 | `targetUserId` `pageNo` `pageSize` | `list` |
| `/chat/private/messages` | POST | 发送私信 | `targetUserId` `content` | `messageInfo` |
| `/chat/team/messages` | GET | 获取团队群聊记录 | `pageNo` `pageSize` | `list` |
| `/chat/team/messages` | POST | 发送团队消息 | `content` | `messageInfo` |
| `/chat/messages/{messageId}/report` | POST | 举报消息内容 | `reportType` `reason` `description` | `reportId` |
| `/reminders/team` | POST | 提醒整个团队 | `content` | `remindRecord` |
| `/reminders/member` | POST | 提醒某个队友 | `targetUserId` `content` | `remindRecord` |
| `/unread/summary` | GET | 获取未读摘要 | 无 | `privateChatUnread` `teamChatUnread` `notificationUnread` |
| `/unread/read` | POST | 批量标记已读 | `bizType` `targetId` | `success` |

接口说明：

- 私信仅好友可发，陌生人不可私信。
- 团队交流首版只做文字消息。
- 未读展示以红点为主，不以数字角标作为主要表现方式。
- 消息内容先过敏感词拦截，再决定替换或禁止发送。

### 4.7 学习计划

| 接口 | 方法 | 用途 | 关键请求参数 | 关键返回字段 |
| --- | --- | --- | --- | --- |
| `/study/plans` | POST | 创建计划 | `planType` `planDate` `planName` `blockList` `taskList` | `planInfo` |
| `/study/plans/{planId}` | PUT | 修改计划 | `planName` `blockList` `taskList` | `planInfo` |
| `/study/plans/{planId}` | GET | 获取计划详情 | 路径参数 | `planInfo` `blockList` `taskList` |
| `/study/plans/{planId}` | DELETE | 删除计划 | 路径参数 | `success` |
| `/study/plans/calendar` | GET | 获取计划日历视图数据 | `planType` `startDate` `endDate` | `datePlanList` |
| `/study/plans/today` | GET | 获取今日计划 | 无 | `planInfo` |
| `/study/plans/templates` | GET | 获取短计划模板列表 | 无 | `list` |
| `/study/plans/{planId}/save-template` | POST | 把某个短计划保存为模板 | `templateName` | `templateInfo` |
| `/study/plans/templates/{templateId}/apply` | POST | 套用模板到某一天 | `targetDate` | `planInfo` |
| `/study/plans/progress/{progressId}/toggle` | POST | 切换某项完成状态 | `finished` | `progressInfo` |
| `/study/plans/fail-records` | GET | 获取失败记录 | `pageNo` `pageSize` | `list` |
| `/study/plans/fail-records/{recordId}` | DELETE | 删除失败记录 | 路径参数 | `success` |

接口说明：

- `planType` 建议取值：`short`、`long`、`ultra`。
- 短计划按天，以半小时为单位排布时间块。
- 长计划按周，支持直接套用短计划模板到某一天。
- 超长计划按天做长期目标安排。
- 过期未完成任务写入失败记录，用户可以手动删除。

### 4.8 定时系统与番茄模式

| 接口 | 方法 | 用途 | 关键请求参数 | 关键返回字段 |
| --- | --- | --- | --- | --- |
| `/focus/session/start` | POST | 开始一次学习时段 | `taskName` `planId` `planTaskId` `endTime` `bindPomodoro` `pomodoroConfig` | `sessionInfo` |
| `/focus/session/current` | GET | 获取当前进行中的学习状态 | 无 | `sessionInfo` |
| `/focus/session/finish` | POST | 手动结束学习 | `sessionId` | `sessionResult` |
| `/focus/session/state-sync` | POST | 同步当前学习状态 | `sessionId` `currentStage` `remainingSeconds` `clientTime` | `syncResult` |
| `/focus/session/history` | GET | 获取学习记录 | `pageNo` `pageSize` `startDate` `endDate` | `list` |
| `/focus/pomodoro/configs` | GET | 获取常用番茄配置 | 无 | `list` |
| `/focus/pomodoro/configs` | POST | 保存常用番茄配置 | `configName` `studyMinutes` `breakMinutes` | `configInfo` |

接口说明：

- 学习时段以“结束时间”作为核心输入，前端自行实时显示对应学习时长。
- `bindPomodoro = true` 时，不允许再单独设置循环次数。
- 绑定后番茄循环一直持续到学习时段结束。
- 用户手动提前结束时，学习时段和番茄同时结束。
- 桌面锁屏、临时断网、切后台后，状态仍需继续累计。

### 4.9 签到系统

| 接口 | 方法 | 用途 | 关键请求参数 | 关键返回字段 |
| --- | --- | --- | --- | --- |
| `/check-in/today` | GET | 获取今日签到状态 | 无 | `canCheckIn` `todayPlanStatus` `todayStudyDuration` |
| `/check-in/submit` | POST | 手动发起签到 | 无 | `success` `consecutiveDays` `totalDays` `totalStudyDuration` |
| `/check-in/summary` | GET | 获取签到汇总 | 无 | `consecutiveDays` `totalDays` `totalStudyDuration` |
| `/check-in/fail-records` | GET | 获取签到失败记录 | `pageNo` `pageSize` | `list` |

接口说明：

- 首版不做自定义签到任务。
- 只有用户手动点击且当天计划完成，才算签到成功。
- 当天没有计划时，不允许签到成功。
- 学习了但未达到签到条件时，学习时长仍保留，但签到记为失败。
- 不支持补签。

### 4.10 备忘录

| 接口 | 方法 | 用途 | 关键请求参数 | 关键返回字段 |
| --- | --- | --- | --- | --- |
| `/memos` | GET | 获取备忘录列表 | `pageNo` `pageSize` | `list` |
| `/memos` | POST | 新建备忘录卡片 | `title` `content` `checkItemList` | `memoInfo` |
| `/memos/{memoId}` | GET | 获取备忘录详情 | 路径参数 | `memoInfo` |
| `/memos/{memoId}` | PUT | 修改备忘录 | `title` `content` `checkItemList` | `memoInfo` |
| `/memos/{memoId}` | DELETE | 删除备忘录 | 路径参数 | `success` |
| `/memos/widget-summary` | GET | 获取桌面挂件展示摘要 | 无 | `list` |

接口说明：

- 备忘录支持文本和清单。
- 首版只做记录，不做提醒。
- 删除直接生效，不做回收站。
- 桌面挂件要能直接展示摘要信息。

### 4.11 统计中心

| 接口 | 方法 | 用途 | 关键请求参数 | 关键返回字段 |
| --- | --- | --- | --- | --- |
| `/stats/overview` | GET | 获取统计中心总览 | 无 | `pomodoroCount` `studyDuration` `checkInDays` `failureCount` |
| `/stats/completion-rate` | GET | 获取完成率数据 | 无 | `planCompletionRate` `checkInSuccessRate` |
| `/stats/trend` | GET | 获取趋势图数据 | `rangeType`，支持 `7d` `30d` | `xAxis` `series` |
| `/stats/failures` | GET | 获取失败数据摘要 | `rangeType` | `failureSummary` |
| `/stats/team/teammates` | GET | 获取队友学习摘要 | 无 | `list` |
| `/stats/team/remind/{targetUserId}` | POST | 从统计中心提醒队友 | 路径参数 | `remindRecord` |

接口说明：

- 完成率拆成两类：计划完成率、签到成功率。
- 趋势图一张图切换近 7 天和近 30 天。
- 队友信息以轻量摘要为主，不做强竞技排行榜。
- 失败数据保留，但展示风格应尽量低压力。

### 4.12 系统通知

| 接口 | 方法 | 用途 | 关键请求参数 | 关键返回字段 |
| --- | --- | --- | --- | --- |
| `/notifications` | GET | 获取通知列表 | `type` `readStatus` `pageNo` `pageSize` | `list` |
| `/notifications/unread-summary` | GET | 获取通知未读摘要 | 无 | `unreadCount` `typeSummary` |
| `/notifications/{notificationId}/read` | POST | 标记单条已读 | 路径参数 | `success` |
| `/notifications/read-all` | POST | 全部标记已读 | `type` | `success` |
| `/notifications/{notificationId}/action` | POST | 处理可操作通知 | `actionType`，如 `accept` `reject` | `actionResult` |
| `/announcements/active` | GET | 获取当前系统公告 | 无 | `list` |

接口说明：

- 首版通知类型至少包含：
  - 好友申请
  - 团队邀请
  - 队友提醒
  - 队友完成通知
  - 签到结果
  - 系统公告
- 首版至少保证好友申请、团队邀请可以在通知内直接处理。
- 通知保留最近 `30 天`。

### 4.13 系统设置

| 接口 | 方法 | 用途 | 关键请求参数 | 关键返回字段 |
| --- | --- | --- | --- | --- |
| `/settings/profile` | GET | 获取设置总览 | 无 | `accountSetting` `notificationSetting` `widgetSetting` `appearanceSetting` |
| `/settings/notifications` | GET | 获取通知设置 | 无 | `mobilePushEnabled` `desktopNoticeEnabled` `teamRemindEnabled` `systemAnnouncementEnabled` |
| `/settings/notifications` | PUT | 更新通知设置 | 同上字段 | `notificationSetting` |
| `/settings/appearance` | GET | 获取外观设置 | 无 | `themeMode` `desktopEffect` |
| `/settings/appearance` | PUT | 更新外观设置 | `themeMode` `desktopEffect` | `appearanceSetting` |
| `/settings/widget` | GET | 获取桌面挂件设置 | 无 | `autoStart` `alwaysOnTop` `showModules` |
| `/settings/widget` | PUT | 更新桌面挂件设置 | `autoStart` `alwaysOnTop` `showModules` | `widgetSetting` |
| `/settings/cache/clear` | POST | 清理缓存 | 无 | `success` |

接口说明：

- 外观设置要预留桌面端毛玻璃、半透明、沉浸光效相关配置位。
- 通知开关按渠道和类型分别控制。
- 设置模块与账户、隐私、通知、桌面挂件体验强关联。

### 4.14 首页聚合接口

| 接口 | 方法 | 用途 | 关键请求参数 | 关键返回字段 |
| --- | --- | --- | --- | --- |
| `/home/overview` | GET | 获取首页聚合数据 | 无 | `currentStudyState` `todayPlan` `checkInSummary` `trendSummary` `teammateSummary` `memoSummary` |
| `/home/widget` | GET | 获取桌面挂件聚合数据 | 无 | `currentStudyState` `todayPlanSummary` `memoSummary` `notificationDots` |

接口说明：

- 首页是聚合页面，最终展示已经基本确定，但后续仍可在“首页模块”阶段继续细化。
- 桌面挂件接口建议返回更轻的数据，避免频繁拉取大对象。

## 5. 实时通道与事件建议

### 5.1 WebSocket 连接

- 连接地址：`/ws/app`
- 握手建议参数：
  - `token`
  - `deviceId`
  - `deviceType`

### 5.2 服务端推送事件

| 事件名 | 用途 | 主要载荷 |
| --- | --- | --- |
| `notification.new` | 新通知到达 | `notificationId` `type` `title` `summary` |
| `chat.private.new` | 收到新的私信 | `messageId` `fromUserId` `content` `sendTime` |
| `chat.team.new` | 收到新的团队消息 | `messageId` `teamId` `fromUserId` `content` `sendTime` |
| `team.remind.new` | 收到队友提醒 | `remindId` `fromUserId` `content` |
| `team.progress.update` | 队友完成计划或学习状态变化 | `userId` `taskName` `status` `studyDuration` |
| `focus.state.update` | 当前学习状态同步 | `sessionId` `currentStage` `remainingSeconds` |
| `sync.change.notice` | 有新同步变更待拉取 | `latestVersion` `bizType` |
| `announcement.publish` | 系统公告推送 | `announcementId` `title` `summary` |

### 5.3 客户端上行事件

| 事件名 | 用途 | 主要载荷 |
| --- | --- | --- |
| `focus.state.report` | 上报学习状态变化 | `sessionId` `currentStage` `remainingSeconds` |
| `chat.read.report` | 上报已读状态 | `bizType` `targetId` |
| `heartbeat` | 保持在线 | `deviceId` `clientTime` |

说明：

- 消息发送主流程仍建议走 REST 入库。
- WebSocket 主要负责实时分发与状态同步。
- 如果 WebSocket 临时断开，前端应回退到“接口拉取 + 系统通知”模式。

## 6. 管理后台接口清单

### 6.1 管理员认证与首页

| 接口 | 方法 | 用途 | 关键请求参数 | 关键返回字段 |
| --- | --- | --- | --- | --- |
| `/auth/login` | POST | 管理员登录 | `username` `password` | `accessToken` `adminInfo` |
| `/dashboard/overview` | GET | 后台首页摘要 | 无 | `userCount` `teamCount` `pendingReportCount` `todayNoticeCount` |
| `/dashboard/trend` | GET | 后台趋势数据 | `rangeType` | `xAxis` `series` |

### 6.2 用户管理

| 接口 | 方法 | 用途 | 关键请求参数 | 关键返回字段 |
| --- | --- | --- | --- | --- |
| `/users` | GET | 查询用户列表 | `keyword` `status` `pageNo` `pageSize` | `list` |
| `/users/{userId}` | GET | 查看用户详情 | 路径参数 | `userInfo` `privacyInfo` `teamInfo` |
| `/users/{userId}/mute` | POST | 对用户禁言 | `days` `reason` | `punishmentInfo` |
| `/users/{userId}/ban` | POST | 对用户封号 | `days` 或 `permanent` `reason` | `punishmentInfo` |
| `/users/{userId}/unban` | POST | 解除封禁/禁言 | `reason` | `success` |
| `/users/{userId}/reports` | GET | 查看该用户相关举报 | 路径参数 | `list` |

管理说明：

- 管理员可以看用户状态、处罚记录、举报历史。
- 非举报场景下，不应开放管理员随意查看私信内容。

### 6.3 团队管理

| 接口 | 方法 | 用途 | 关键请求参数 | 关键返回字段 |
| --- | --- | --- | --- | --- |
| `/teams` | GET | 查询团队列表 | `keyword` `pageNo` `pageSize` | `list` |
| `/teams/{teamId}` | GET | 查看团队详情 | 路径参数 | `teamInfo` `memberList` |
| `/teams/{teamId}/dismiss` | POST | 强制解散团队 | `reason` | `success` |
| `/teams/{teamId}/members/{userId}/remove` | POST | 后台移除团队成员 | `reason` | `success` |

### 6.4 通知与公告管理

| 接口 | 方法 | 用途 | 关键请求参数 | 关键返回字段 |
| --- | --- | --- | --- | --- |
| `/announcements` | GET | 获取公告列表 | `status` `pageNo` `pageSize` | `list` |
| `/announcements` | POST | 新建系统公告 | `title` `content` `publishTime` | `announcementInfo` |
| `/announcements/{announcementId}` | PUT | 修改系统公告 | `title` `content` `publishTime` `status` | `announcementInfo` |
| `/announcements/{announcementId}` | DELETE | 删除系统公告 | 路径参数 | `success` |
| `/notifications/user` | POST | 定向通知单个用户 | `targetUserId` `title` `content` | `noticeInfo` |
| `/notifications/team` | POST | 定向通知某个团队 | `targetTeamId` `title` `content` | `noticeInfo` |

### 6.5 举报与内容处理

| 接口 | 方法 | 用途 | 关键请求参数 | 关键返回字段 |
| --- | --- | --- | --- | --- |
| `/reports` | GET | 获取举报列表 | `status` `reportType` `pageNo` `pageSize` | `list` |
| `/reports/{reportId}` | GET | 获取举报详情 | 路径参数 | `reportInfo` `targetContent` `auditHistory` |
| `/reports/{reportId}/review` | POST | 处理举报 | `decision` `reason` `punishmentType` | `reviewResult` |
| `/reports/{reportId}/recheck` | POST | 发起复核 | `reason` | `recheckResult` |
| `/content/team-chat` | GET | 查询团队交流内容 | `keyword` `pageNo` `pageSize` | `list` |
| `/content/team-chat/{messageId}` | DELETE | 删除违规团队消息 | `reason` | `success` |

管理说明：

- 内容治理流程按已确认规则执行：先发出，再由用户举报后管理员处理。
- 处罚方式支持：删除内容、警告、禁言、封号。
- 举报数据和处理记录应完整保留，便于后续复核。

### 6.6 敏感词管理

| 接口 | 方法 | 用途 | 关键请求参数 | 关键返回字段 |
| --- | --- | --- | --- | --- |
| `/sensitive-words` | GET | 查询敏感词列表 | `keyword` `pageNo` `pageSize` | `list` |
| `/sensitive-words` | POST | 新增敏感词 | `word` `actionType` | `wordInfo` |
| `/sensitive-words/{wordId}` | PUT | 修改敏感词策略 | `word` `actionType` `status` | `wordInfo` |
| `/sensitive-words/{wordId}` | DELETE | 删除敏感词 | 路径参数 | `success` |

说明：

- `actionType` 建议支持：
  - `replace`
  - `reject`
- 第一版只做简单敏感词拦截，不做复杂语义审核。

## 7. 第一版优先开发接口建议

### 7.1 P0 必做

- 认证与账户
- 用户搜索与资料权限
- 设备与同步基础
- 好友申请、好友列表、好友删除、好友分组
- 团队创建、邀请、加入、移除、解散
- 私信、团队群聊、提醒、未读
- 学习计划
- 学习时段与番茄绑定逻辑
- 签到
- 备忘录
- 通知中心
- 统计中心基础接口
- 后台用户管理、团队管理、举报处理、系统公告

### 7.2 P1 次阶段增强

- 更细的同步日志排障能力
- 更丰富的桌面挂件配置
- 更完整的趋势和统计切片
- 更多后台筛选与复核能力

## 8. 对后续开发的直接建议

- Spring Boot 包结构可以直接按本文模块拆分 Controller。
- 实时部分建议使用 `WebSocket + Redis` 做在线分发。
- 聊天消息、提醒、通知建议统一抽象未读状态，避免每个模块单独算红点。
- 首页和桌面挂件尽量走聚合接口，不要让前端一次加载十几个独立接口。
- 桌面端 UI 已经明确要求毛玻璃、半透明、沉浸光效，接口层要尽量支持轻量高频刷新，不要返回过重对象。

## 9. 当前文档结论

- `Innocence` 第一版已经具备可进入接口设计阶段的功能边界。
- 本文可作为后续输出以下文档的基础：
  - `MVP 第一版功能范围`
  - `开发排期草案`
  - `后端模块拆分建议`
  - `前端页面与接口映射表`
