import { FlutterEngine, MethodCall, MethodChannel, MethodCallHandler, MethodResult } from '@ohos/flutter_ohos';
import { common, wantAgent } from '@kit.AbilityKit';
import { notificationManager } from '@kit.NotificationKit';
import { reminderAgentManager } from '@kit.BackgroundTasksKit';
import { preferences } from '@kit.ArkData';
import { liveViewManager } from '@kit.LiveViewKit';

// Only generic timer copy is exposed on the lock screen. No task/account content.
export class FocusNoticeChannel implements MethodCallHandler {
  private channel: MethodChannel;
  private context: common.UIAbilityContext;
  private static readonly RUNNING_ID = 7312;
  private static readonly FINISHED_ID = 7313;
  private static readonly LIVE_ID = 7314;

  constructor(context: common.UIAbilityContext, engine: FlutterEngine) {
    this.context = context;
    this.channel = new MethodChannel(engine.getDartExecutor().getBinaryMessenger(), 'innocence/focus_notice');
    this.channel.setMethodCallHandler(this);
  }

  detach(): void { this.channel.setMethodCallHandler(null); }

  onMethodCall(call: MethodCall, result: MethodResult): void {
    this.handle(call, result).catch(() => {
      result.error('focus_notice_failed', 'Unable to update timer notifications.', null);
    });
  }

  private async handle(call: MethodCall, result: MethodResult): Promise<void> {
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
    const args = call.args as Map<string, Object>;
    const owner = args.get('owner') as string;
    const key = args.get('key') as string;
    const active = args.get('active') as boolean;
    const paused = args.get('paused') as boolean;
    const deadline = args.get('deadlineMs') as number;
    const remaining = args.get('remainingSeconds') as number;
    const completed = args.get('completed') as boolean;
    const chinese = args.get('isChinese') as boolean;
    if (typeof owner !== 'string' || typeof key !== 'string' || owner.length > 128 || key.length > 256 ||
        typeof active !== 'boolean' || typeof paused !== 'boolean' || typeof completed !== 'boolean' ||
        typeof chinese !== 'boolean' || !Number.isFinite(deadline) || !Number.isFinite(remaining) ||
        remaining < 0 || (active && key.length === 0) ||
        (key.length > 0 && (owner.length === 0 || !key.startsWith(owner + '/')))) {
      result.error('invalid_arguments', 'Invalid timer snapshot.', null);
      return;
    }
    const store = await preferences.getPreferences(this.context, { name: 'focus_notice' });
    const oldOwner = await store.get('owner', '') as string;
    const oldKey = await store.get('key', '') as string;
    const enabled = await notificationManager.isNotificationEnabled();
    if (completed && key === oldKey && key.length > 0) {
      // The system reminder delivers independently of Flutter. Do not race or duplicate it.
      await this.stopLiveView();
      await notificationManager.cancel(FocusNoticeChannel.RUNNING_ID);
      result.success(enabled ? 'available' : 'permissionRequired');
      return;
    }
    if (!active) {
      const expired = owner.length > 0 && owner === oldOwner && key.length === 0 &&
        (await store.get('deadline', 0) as number) <= Date.now() &&
        (await store.get('paused', false) as boolean) === false;
      if (!expired) await this.cancelReminder(store);
      await this.stopLiveView();
      await notificationManager.cancel(FocusNoticeChannel.RUNNING_ID);
      if (owner.length === 0 || owner !== oldOwner) {
        await notificationManager.cancel(FocusNoticeChannel.FINISHED_ID);
      }
      result.success('available');
      return;
    }
    await this.cancelReminder(store);
    if (key !== oldKey || owner !== oldOwner) {
      await this.stopLiveView();
      await notificationManager.cancel(FocusNoticeChannel.FINISHED_ID);
    }
    await store.put('owner', owner);
    await store.put('key', key);
    await store.put('deadline', deadline);
    await store.put('paused', paused);
    await store.flush();
    if (!enabled) { result.success('permissionRequired'); return; }
    const title = chinese ? (paused ? '专注已暂停' : '专注倒计时') : (paused ? 'Focus paused' : 'Focus countdown');
    const doneTitle = chinese ? '专注计时已完成' : 'Focus timer complete';
    const doneText = chinese ? '本次倒计时已到点，休息一下吧。' : 'Your countdown has ended. Take a break.';
    const seconds = Math.max(1, Math.ceil((deadline - Date.now()) / 1000));
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
      const id = await reminderAgentManager.publishReminder(reminder);
      await store.put('reminderId', id);
      await store.flush();
    }
    const click = await wantAgent.getWantAgent({
      wants: [{ bundleName: this.context.abilityInfo.bundleName, abilityName: 'EntryAbility' }],
      operationType: wantAgent.OperationType.START_ABILITY,
      requestCode: FocusNoticeChannel.RUNNING_ID,
      wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT_FLAG]
    });
    try {
      const live: liveViewManager.LiveView = {
        id: FocusNoticeChannel.LIVE_ID,
        event: 'TIMER',
        isMute: true,
        timer: { time: paused ? remaining * 1000 : seconds * 1000, isCountdown: true, isPaused: paused },
        liveViewData: {
          primary: {
            title: title,
            content: [{ text: '${placeholder.timer}' }],
            keepTime: 0,
            aliveTime: paused ? 28800 : seconds,
            clickAction: click
          },
          capsule: { type: liveViewManager.CapsuleType.CAPSULE_TYPE_TIMER, status: 1,
            content: title, time: paused ? remaining * 1000 : seconds * 1000, isCountdown: true }
        }
      };
      let exists = false;
      try { await liveViewManager.getActiveLiveView(FocusNoticeChannel.LIVE_ID); exists = true; } catch (_) {}
      const response = exists ? await liveViewManager.updateLiveView(live) : await liveViewManager.startLiveView(live);
      if (response.resultCode !== 0) throw new Error('live_countdown_unavailable');
      await notificationManager.cancel(FocusNoticeChannel.RUNNING_ID);
      result.success('available');
    } catch (_) {
      const end = new Date(deadline);
      const endLabel = `${end.getHours().toString().padStart(2, '0')}:${end.getMinutes().toString().padStart(2, '0')}`;
      const text = paused ? `${chinese ? '剩余' : 'Remaining'} ${this.duration(remaining)}` :
        `${chinese ? '剩余' : 'Remaining'} ${this.duration(seconds)} · ${chinese ? '结束于' : 'Ends at'} ${endLabel}`;
      // isCountDown is explicitly unsupported in SDK26 ordinary notifications.
      await notificationManager.publish({
        id: FocusNoticeChannel.RUNNING_ID,
        content: { notificationContentType: notificationManager.ContentType.NOTIFICATION_CONTENT_BASIC_TEXT,
          normal: { title: title, text: text } },
        notificationSlotType: notificationManager.SlotType.OTHER_TYPES,
        isOngoing: true,
        isAlertOnce: true,
        tapDismissed: false,
        wantAgent: click,
        autoDeletedTime: paused ? undefined : deadline
      });
      result.success('liveCountdownUnavailable');
    }
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

  private async stopLiveView(): Promise<void> {
    let live: liveViewManager.LiveView;
    try { live = await liveViewManager.getActiveLiveView(FocusNoticeChannel.LIVE_ID); } catch (_) { return; }
    live.liveViewData.primary.keepTime = 0;
    const response = await liveViewManager.stopLiveView(live);
    if (response.resultCode !== 0) throw new Error('live_countdown_stop_failed');
  }

  private duration(seconds: number): string {
    const h = Math.floor(seconds / 3600);
    const m = Math.floor(seconds / 60) % 60;
    const s = seconds % 60;
    return `${h > 0 ? h.toString().padStart(2, '0') + ':' : ''}${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
  }
}
