import { FlutterEngine, MethodCall, MethodChannel, MethodCallHandler, MethodResult } from '@ohos/flutter_ohos';
import { common, wantAgent, WantAgent } from '@kit.AbilityKit';
import { notificationManager } from '@kit.NotificationKit';
import { reminderAgentManager } from '@kit.BackgroundTasksKit';
import { preferences } from '@kit.ArkData';
import { liveViewManager } from '@kit.LiveViewKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { image } from '@kit.ImageKit';
import { fileIo as fs } from '@kit.CoreFileKit';

interface FocusCapabilityReceipt {
  status: string;
  backgroundError: number;
  liveError: string;
  timestampMs: number;
}

// Only generic timer copy is exposed on the lock screen. No task/account content.
export class FocusNoticeChannel implements MethodCallHandler {
  private channel: MethodChannel;
  private context: common.UIAbilityContext;
  private static readonly RUNNING_ID = 7312;
  private static readonly FINISHED_ID = 7313;
  private static readonly LIVE_ID = 7314;
  private static readonly POMODORO_LIVE_ID = 7315;
  private static readonly POMODORO_SNAPSHOT_ID = 7316;
  private lastLiveError = '';
  private lastReminderError = 0;
  private timerIcon?: image.PixelMap;
  private qaLiveRightsDenied = false;

  constructor(context: common.UIAbilityContext, engine: FlutterEngine) {
    this.context = context;
    this.channel = new MethodChannel(engine.getDartExecutor().getBinaryMessenger(), 'innocence/focus_notice');
    this.channel.setMethodCallHandler(this);
    hilog.info(0x0000, 'FocusNotice', 'Focus notification channel registered');
  }

  detach(): void { this.channel.setMethodCallHandler(null); }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    this.handle(call, result).catch((error: BusinessError) => {
      if (this.context.abilityInfo.bundleName.endsWith('.focusqa')) {
        this.lastLiveError = `${error.code ?? 0}: ${error.message?.slice(0, 160) ?? ''}`;
      }
      hilog.warn(0x0000, 'FocusNotice', 'Timer operation failed: %{public}d', error.code ?? 0);
      result.error('focus_notice_failed', 'Unable to update timer notifications.', null);
    });
  }

  private async handle(call: MethodCall, result: MethodResult): Promise<void> {
    if (call.method === 'qaLiveRightsUnavailable' && this.context.abilityInfo.bundleName.endsWith('.focusqa')) {
      if (typeof call.args !== 'boolean') {
        result.error('invalid_arguments', 'Invalid QA capability.', null);
        return;
      }
      this.qaLiveRightsDenied = call.args as boolean;
      result.success(null);
      return;
    }
    if (call.method === 'diagnostics' && this.context.abilityInfo.bundleName.endsWith('.focusqa')) {
      // The isolated QA entry point can inspect only its own generic notifications.
      const notices = await notificationManager.getActiveNotifications();
      const reminders = await reminderAgentManager.getValidReminders();
      const receipt = new Map<string, Object>();
      receipt.set('notificationEnabled', await notificationManager.isNotificationEnabled());
      receipt.set('running', notices.filter((item) => item.id === FocusNoticeChannel.RUNNING_ID).length);
      receipt.set('finished', notices.filter((item) => item.id === FocusNoticeChannel.FINISHED_ID).length);
      receipt.set('reminders', reminders.length);
      receipt.set('reminderError', this.lastReminderError);
      receipt.set('liveError', this.lastLiveError);
      receipt.set('forcedLiveRights', this.qaLiveRightsDenied);
      try { receipt.set('liveEnabled', await liveViewManager.isLiveViewEnabled()); }
      catch (error) { receipt.set('liveEnabledError', (error as BusinessError).code ?? 0); }
      try {
        const live = await liveViewManager.getActiveLiveView(FocusNoticeChannel.LIVE_ID);
        receipt.set('livePresent', true);
        receipt.set('timerPaused', live.timer?.isPaused ?? false);
        receipt.set('capsulePaused', (live.liveViewData.capsule as liveViewManager.TimerCapsule)?.isPaused ?? false);
        receipt.set('timerMs', live.timer?.time ?? -1);
      } catch (_) { receipt.set('livePresent', false); }
      result.success(receipt);
      return;
    }
    if (call.method === 'requestPermission') {
      // Denial is a normal user choice; sync reports the resulting capability.
      try { await notificationManager.requestEnableNotification(this.context); } catch (_) {}
      result.success(null);
      return;
    }
    if (call.method === 'openSettings') {
      await notificationManager.openNotificationSettings(this.context);
      result.success(null);
      return;
    }
    if (call.method !== 'sync') { result.notImplemented(); return; }
    if (!(call.args instanceof Map)) {
      result.error('invalid_arguments', 'Invalid timer snapshot.', null);
      return;
    }
    const args = call.args as Map<string, Object>;
    const owner = args.get('owner') as string;
    const key = args.get('key') as string;
    const active = args.get('active') as boolean;
    const paused = args.get('paused') as boolean;
    const deadline = args.get('deadlineMs') as number;
    const remaining = args.get('remainingSeconds') as number;
    const completed = args.get('completed') as boolean;
    const chinese = args.get('isChinese') as boolean;
    const bound = args.get('bindPomodoro') === true;
    const stage = args.get('pomodoroStage') as string;
    const cycle = args.get('pomodoroCycle') as number;
    const stageDeadline = args.get('pomodoroDeadlineMs') as number;
    const stageRemaining = args.get('pomodoroRemainingSeconds') as number;
    const study = args.get('pomodoroStudyMinutes') as number;
    const rest = args.get('pomodoroBreakMinutes') as number;
    if (typeof owner !== 'string' || typeof key !== 'string' || owner.length > 128 || key.length > 256 ||
        typeof active !== 'boolean' || typeof paused !== 'boolean' || typeof completed !== 'boolean' ||
        typeof chinese !== 'boolean' || !Number.isSafeInteger(deadline) || !Number.isSafeInteger(remaining) ||
        deadline < 0 || remaining < 0 || (active && key.length === 0) ||
        (key.length > 0 && (owner.length === 0 || !key.startsWith(owner + '/')))) {
      result.error('invalid_arguments', 'Invalid timer snapshot.', null);
      return;
    }
    if ((args.has('bindPomodoro') && typeof args.get('bindPomodoro') !== 'boolean') ||
        (bound && (!active || !Number.isSafeInteger(study) || study < 1 || study > 1440 ||
          !Number.isSafeInteger(rest) || rest < 0 || rest > 1440 ||
          (stage !== 'study' && !(stage === 'break' && rest > 0)) ||
          !Number.isSafeInteger(cycle) || cycle < 1 || !Number.isSafeInteger(stageDeadline) ||
          stageDeadline < 0 || stageDeadline > deadline || !Number.isSafeInteger(stageRemaining) ||
          stageRemaining < 1 || stageRemaining > remaining || stageRemaining > (stage === 'study' ? study : rest) * 60))) {
      result.error('invalid_arguments', 'Invalid pomodoro snapshot.', null);
      return;
    }
    const store = await preferences.getPreferences(this.context, { name: 'focus_notice' });
    const oldOwner = await store.get('owner', '') as string;
    const oldKey = await store.get('key', '') as string;
    const enabled = await notificationManager.isNotificationEnabled();
    if (completed && key === oldKey && key.length > 0) {
      // The system reminder delivers independently of Flutter. Do not race or duplicate it.
      await this.stopLiveView();
      await this.stopPomodoro();
      await this.cancelNotice(FocusNoticeChannel.RUNNING_ID);
      if (enabled && (await store.get('reminderId', -1) as number) < 0) {
        await this.publishForegroundCompletion(store, key, chinese);
      }
      result.success(enabled ? 'available' : 'permissionRequired');
      return;
    }
    if (!active) {
      const expired = owner.length > 0 && owner === oldOwner && oldKey.length > 0 && key.length === 0 &&
        (await store.get('deadline', 0) as number) <= Date.now() &&
        (await store.get('paused', false) as boolean) === false;
      if (!expired) {
        await this.cancelReminder(store);
        // An explicit end or identity change must remain cancelled after restart.
        // Otherwise the old deadline could later look like a natural completion.
        await store.put('owner', owner);
        await store.put('key', '');
        await store.put('deadline', 0);
        await store.put('paused', true);
        await store.flush();
      }
      await this.stopLiveView();
      await this.stopPomodoro();
      await this.cancelNotice(FocusNoticeChannel.RUNNING_ID);
      if (expired && enabled && (await store.get('reminderId', -1) as number) < 0) {
        await this.publishForegroundCompletion(store, oldKey, chinese);
      }
      if (owner.length === 0 || owner !== oldOwner) {
        await this.cancelNotice(FocusNoticeChannel.FINISHED_ID);
      }
      result.success('available');
      return;
    }
    await this.cancelReminder(store);
    if (key !== oldKey || owner !== oldOwner) {
      await this.stopLiveView();
      await this.stopPomodoro();
      await this.cancelNotice(FocusNoticeChannel.FINISHED_ID);
    }
    await store.put('owner', owner);
    await store.put('key', key);
    await store.put('deadline', deadline);
    await store.put('paused', paused);
    await store.flush();
    if (!enabled) {
      await this.stopPomodoro();
      this.recordCapability('permissionRequired');
      result.success('permissionRequired');
      return;
    }
    const title = chinese ? (paused ? '专注已暂停' : '专注倒计时') : (paused ? 'Focus paused' : 'Focus countdown');
    const doneTitle = chinese ? '专注计时已完成' : 'Focus timer complete';
    const doneText = chinese ? '本次倒计时已到点，休息一下吧。' : 'Your countdown has ended. Take a break.';
    const seconds = Math.max(1, Math.ceil((deadline - Date.now()) / 1000));
    let backgroundReady = true;
    if (!paused) {
      const reminder: reminderAgentManager.ReminderRequestTimer = {
        reminderType: reminderAgentManager.ReminderType.REMINDER_TYPE_TIMER,
        triggerTimeInSeconds: seconds,
        title: doneTitle,
        content: doneText,
        expiredContent: doneText,
        notificationId: FocusNoticeChannel.FINISHED_ID,
        ringDuration: 0,
        slotType: notificationManager.SlotType.SOCIAL_COMMUNICATION,
        wantAgent: { pkgName: this.context.abilityInfo.bundleName, abilityName: 'EntryAbility' }
      };
      try {
        const id = await reminderAgentManager.publishReminder(reminder);
        this.lastReminderError = 0;
        await store.put('reminderId', id);
        await store.flush();
      } catch (error) {
        // Huawei controls agent-reminder rights separately from the SDK permission.
        backgroundReady = false;
        this.lastReminderError = (error as BusinessError).code ?? 0;
        hilog.warn(0x0000, 'FocusNotice', 'Background timer unavailable: %{public}d',
          (error as BusinessError).code ?? 0);
      }
    }
    const click = await wantAgent.getWantAgent({
      wants: [{ bundleName: this.context.abilityInfo.bundleName, abilityName: 'EntryAbility' }],
      operationType: wantAgent.OperationType.START_ABILITY,
      requestCode: FocusNoticeChannel.RUNNING_ID,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    });
    const pomodoroReady = bound
      ? await this.publishPomodoro(stage, cycle, stageDeadline, stageRemaining, paused, chinese, click, deadline)
      : true;
    if (!bound) await this.stopPomodoro();
    let liveResultCode = 0;
    try {
      if (this.qaLiveRightsDenied) {
        liveResultCode = 1003500005;
        throw new Error('qa_live_rights_denied');
      }
      const live: liveViewManager.LiveView = {
        id: FocusNoticeChannel.LIVE_ID,
        event: 'TIMER',
        isMute: true,
        timer: { time: paused ? remaining * 1000 : seconds * 1000, isCountdown: true, isPaused: paused },
        liveViewData: {
          primary: {
            title: title,
            content: [{ text: '${placeholder.timer}' }],
            // API26 runtime requires layoutData even though the SDK marks it optional.
            layoutData: { layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_DEFAULT },
            keepTime: 0,
            aliveTime: paused ? 28800 : seconds,
            clickAction: click
          },
          capsule: { type: liveViewManager.CapsuleType.CAPSULE_TYPE_TIMER, status: 1,
            icon: await this.capsuleIcon(), backgroundColor: '#FF242424',
            isContentDisplayed: true, isTailIconDisplayed: false,
            content: title, time: paused ? remaining * 1000 : seconds * 1000,
            isCountdown: true, isPaused: paused }
        }
      };
      let exists = false;
      try { await liveViewManager.getActiveLiveView(FocusNoticeChannel.LIVE_ID); exists = true; } catch (_) {}
      const response = exists ? await liveViewManager.updateLiveView(live) : await liveViewManager.startLiveView(live);
      if (response.resultCode !== 0) {
        liveResultCode = response.resultCode;
        throw new Error('live_countdown_unavailable');
      }
      this.lastLiveError = '';
      await this.cancelNotice(FocusNoticeChannel.RUNNING_ID);
      const status = pomodoroReady
        ? (backgroundReady ? 'available' : 'backgroundReminderUnavailable')
        : (backgroundReady ? 'liveCountdownUnavailable' : 'backgroundAndLiveUnavailable');
      this.recordCapability(status);
      result.success(status);
    } catch (error) {
      const code = liveResultCode || (error as BusinessError).code || 0;
      this.lastLiveError = `${code}`;
      if (this.context.abilityInfo.bundleName.endsWith('.focusqa')) {
        this.lastLiveError += `: ${(error as BusinessError).message?.slice(0, 160) ?? ''}`;
      }
      hilog.warn(0x0000, 'FocusNotice', 'Live countdown unavailable: %{public}d',
        code);
      const end = new Date(deadline);
      const endLabel = `${end.getHours().toString().padStart(2, '0')}:${end.getMinutes().toString().padStart(2, '0')}`;
      const text = paused ? `${chinese ? '剩余' : 'Remaining'} ${this.duration(remaining)}` :
        `${chinese ? '剩余' : 'Remaining'} ${this.duration(seconds)} · ${chinese ? '结束于' : 'Ends at'} ${endLabel}`;
      // isCountDown is explicitly unsupported in SDK26 ordinary notifications.
      const snapshot: notificationManager.NotificationRequest = {
        id: FocusNoticeChannel.RUNNING_ID,
        content: { notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: { title: title, text: text } },
        notificationSlotType: notificationManager.SlotType.OTHER_TYPES,
        isOngoing: true,
        isAlertOnce: true,
        tapDismissed: false,
        wantAgent: click,
        autoDeletedTime: paused ? 0 : deadline
      };
      // Updating the same ID can retain its previous scheduled deletion even
      // when no deadline is supplied. Replace the snapshot so a paused timer
      // survives the old deadline, and never pass undefined to the device NAPI.
      await this.cancelNotice(FocusNoticeChannel.RUNNING_ID);
      await notificationManager.publish(snapshot);
      const status = code === 1003500005
        ? (backgroundReady ? 'liveCountdownRightsRequired' : 'backgroundAndLiveRightsRequired')
        : (backgroundReady ? 'liveCountdownUnavailable' : 'backgroundAndLiveUnavailable');
      this.recordCapability(status);
      result.success(status);
    }
  }

  private recordCapability(status: string): void {
    if (!this.context.applicationInfo.debug) return;
    // Debug receipts contain only capability/error codes. Never copy owner,
    // session, task content, or credentials out of the native preferences.
    const receipt: FocusCapabilityReceipt = {
      status: status, backgroundError: this.lastReminderError,
      liveError: this.lastLiveError, timestampMs: Date.now()
    };
    let file: fs.File | undefined;
    try {
      file = fs.openSync(`${this.context.cacheDir}/focus_notice_capability.json`,
        fs.OpenMode.CREATE | fs.OpenMode.TRUNC | fs.OpenMode.READ_WRITE);
      fs.writeSync(file.fd, JSON.stringify(receipt));
    } catch (_) {
      // Optional debug evidence cannot change timer or notification behavior.
    } finally {
      if (file) { try { fs.closeSync(file.fd); } catch (_) {} }
    }
  }

  private async publishForegroundCompletion(store: preferences.Preferences, key: string,
    chinese: boolean): Promise<void> {
    if ((await store.get('completedKey', '') as string) === key) return;
    const click = await wantAgent.getWantAgent({
      wants: [{ bundleName: this.context.abilityInfo.bundleName, abilityName: 'EntryAbility' }],
      operationType: wantAgent.OperationType.START_ABILITY,
      requestCode: FocusNoticeChannel.FINISHED_ID,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    });
    await notificationManager.publish({
      id: FocusNoticeChannel.FINISHED_ID,
      content: { notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
        normal: { title: chinese ? '专注计时已完成' : 'Focus timer complete',
          text: chinese ? '本次倒计时已到点，休息一下吧。' : 'Your countdown has ended. Take a break.' } },
      notificationSlotType: notificationManager.SlotType.SOCIAL_COMMUNICATION,
      isAlertOnce: true,
      wantAgent: click
    });
    await store.put('completedKey', key);
    await store.flush();
  }

  private async capsuleIcon(): Promise<image.PixelMap> {
    if (this.timerIcon) return this.timerIcon;
    const bytes = await this.context.resourceManager.getMediaContent($r('app.media.icon').id);
    const source = image.createImageSource(bytes.buffer);
    // 80x80 RGBA is below both the older 30 KB and API26 192 KB pixel-map limits.
    this.timerIcon = await source.createPixelMap({ desiredSize: { width: 80, height: 80 } });
    await source.release();
    return this.timerIcon;
  }

  private async cancelReminder(store: preferences.Preferences): Promise<void> {
    const id = await store.get('reminderId', -1) as number;
    if (id < 0) return;
    const valid = await reminderAgentManager.getValidReminders();
    if (valid.some((item: reminderAgentManager.ReminderRequest) => item.notificationId === FocusNoticeChannel.FINISHED_ID)) {
      await reminderAgentManager.cancelReminder(id);
    }
    await store.put('reminderId', -1);
    await store.flush();
  }

  private async cancelNotice(id: number): Promise<void> {
    try { await notificationManager.cancel(id); } catch (error) {
      // Cleanup is idempotent; a missing notification is already cancelled.
      if ((error as BusinessError).code !== 1600007) throw error as Error;
    }
  }

  private async stopLiveView(id: number = FocusNoticeChannel.LIVE_ID): Promise<void> {
    try { await liveViewManager.getActiveLiveView(id); } catch (_) { return; }
    // The getter includes default/invalid optional values and UINT_MAX sequence.
    // Send a fresh valid payload and explicitly end the capsule as well.
    const click = await wantAgent.getWantAgent({
      wants: [{ bundleName: this.context.abilityInfo.bundleName, abilityName: 'EntryAbility' }],
      operationType: wantAgent.OperationType.START_ABILITY,
      requestCode: FocusNoticeChannel.RUNNING_ID,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    });
    const stopped: liveViewManager.LiveView = {
      id: id, event: 'TIMER', isMute: true,
      liveViewData: {
        primary: { title: 'Innocence', content: [{ text: 'Innocence' }], keepTime: 0,
          layoutData: { layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_DEFAULT }, clickAction: click },
        capsule: { type: liveViewManager.CapsuleType.CAPSULE_TYPE_TIMER, status: -1,
          icon: await this.capsuleIcon(), backgroundColor: '#FF242424', content: 'Innocence',
          isContentDisplayed: true, isTailIconDisplayed: false,
          time: 0, isCountdown: true, isPaused: true }
      }
    };
    try {
      const response = await liveViewManager.stopLiveView(stopped);
      if (response.resultCode !== 0) throw new Error(`live_countdown_stop_failed_${response.resultCode}`);
    } catch (error) {
      // The system may expire the live view between the query and stop call.
      const code = (error as BusinessError).code;
      if (code !== 1003500009 && code !== 1003500010) throw error as Error;
    }
  }

  private async stopPomodoro(): Promise<void> {
    await this.stopLiveView(FocusNoticeChannel.POMODORO_LIVE_ID);
    await this.cancelNotice(FocusNoticeChannel.POMODORO_SNAPSHOT_ID);
  }

  private async publishPomodoro(stage: string, cycle: number, deadline: number, remaining: number,
    paused: boolean, chinese: boolean, click: WantAgent, totalDeadline: number): Promise<boolean> {
    const title = chinese ? `番茄 · ${stage === 'break' ? '休息' : '学习'}${paused ? ' · 已暂停' : ''}` :
      `Pomodoro · ${stage === 'break' ? 'Break' : 'Study'}${paused ? ' · Paused' : ''}`;
    const cycleText = chinese ? `第 ${cycle} 轮` : `Cycle ${cycle}`;
    const seconds = paused ? remaining : Math.max(1, Math.ceil((deadline - Date.now()) / 1000));
    try {
      if (this.qaLiveRightsDenied) throw new Error('qa_live_rights_denied');
      const live: liveViewManager.LiveView = {
        id: FocusNoticeChannel.POMODORO_LIVE_ID, event: 'TIMER', isMute: true,
        timer: { time: seconds * 1000, isCountdown: true, isPaused: paused },
        liveViewData: {
          primary: { title: title, content: [{ text: cycleText }, { text: '${placeholder.timer}' }],
            layoutData: { layoutType: liveViewManager.LayoutType.LAYOUT_TYPE_DEFAULT }, keepTime: 0,
            aliveTime: paused ? 28800 : seconds, clickAction: click },
          capsule: { type: liveViewManager.CapsuleType.CAPSULE_TYPE_TIMER, status: 1,
            icon: await this.capsuleIcon(), backgroundColor: '#FF242424',
            isContentDisplayed: true, isTailIconDisplayed: false, content: title,
            time: seconds * 1000, isCountdown: true, isPaused: paused }
        }
      };
      let exists = false;
      try { await liveViewManager.getActiveLiveView(FocusNoticeChannel.POMODORO_LIVE_ID); exists = true; } catch (_) {}
      const response = exists ? await liveViewManager.updateLiveView(live) : await liveViewManager.startLiveView(live);
      if (response.resultCode !== 0) throw new Error('pomodoro_live_unavailable');
      await this.cancelNotice(FocusNoticeChannel.POMODORO_SNAPSHOT_ID);
      return true;
    } catch (_) {
      await this.stopLiveView(FocusNoticeChannel.POMODORO_LIVE_ID);
      await this.cancelNotice(FocusNoticeChannel.POMODORO_SNAPSHOT_ID);
      const end = new Date(deadline);
      const endLabel = `${end.getHours().toString().padStart(2, '0')}:${end.getMinutes().toString().padStart(2, '0')}:${end.getSeconds().toString().padStart(2, '0')}`;
      const text = `${cycleText} · ${this.duration(seconds)}${paused ? '' : ` · ${chinese ? '阶段结束于' : 'Stage ends at'} ${endLabel}`}`;
      await notificationManager.publish({ id: FocusNoticeChannel.POMODORO_SNAPSHOT_ID,
        content: { notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: { title: title, text: text } }, notificationSlotType: notificationManager.SlotType.OTHER_TYPES,
        isOngoing: true, isAlertOnce: true, tapDismissed: false, wantAgent: click,
        autoDeletedTime: paused ? 0 : totalDeadline });
      return false;
    }
  }

  private duration(seconds: number): string {
    const h = Math.floor(seconds / 3600);
    const m = Math.floor(seconds / 60) % 60;
    const s = seconds % 60;
    return `${h > 0 ? h.toString().padStart(2, '0') + ':' : ''}${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
  }
}
