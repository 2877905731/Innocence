import 'package:flutter/material.dart';
import 'package:innocence_flutter/core/theme/app_colors.dart';
import 'package:innocence_flutter/core/widgets/aurora_background.dart';
import 'package:innocence_flutter/core/widgets/glass_panel.dart';
import 'package:innocence_flutter/core/widgets/status_banner.dart';
import 'package:innocence_flutter/features/account/domain/models/user_profile.dart';
import 'package:innocence_flutter/features/plans/domain/models/today_plan.dart';
import 'package:innocence_flutter/features/plans/presentation/widgets/today_plan_editor_dialog.dart';
import 'package:innocence_flutter/features/plans/presentation/widgets/today_plan_panel.dart';

class HomePage extends StatelessWidget {
  const HomePage({
    super.key,
    required this.profile,
    required this.todayPlan,
    required this.onRefresh,
    required this.onLogout,
    required this.onSaveTodayPlan,
    required this.onToggleTodayPlanItem,
    required this.isBusy,
    required this.onClearBanner,
    this.bannerMessage,
  });

  final UserProfile profile;
  final TodayPlan todayPlan;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLogout;
  final Future<void> Function(TodayPlan plan) onSaveTodayPlan;
  final Future<void> Function(int index, bool completed) onToggleTodayPlanItem;
  final bool isBusy;
  final String? bannerMessage;
  final VoidCallback onClearBanner;

  Future<void> _openEditor(BuildContext context) async {
    final result = await showDialog<TodayPlan>(
      context: context,
      builder: (context) {
        return TodayPlanEditorDialog(initialPlan: todayPlan);
      },
    );
    if (result == null) {
      return;
    }
    await onSaveTodayPlan(result);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: AuroraBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text('Innocence', style: textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                'The account system is stable now, and the first real study-plan loop is live on the home page.',
                style: textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  OutlinedButton.icon(
                    onPressed: isBusy
                        ? null
                        : () async {
                            await onRefresh();
                          },
                    icon: isBusy
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh_rounded),
                    label: Text(isBusy ? 'Syncing' : 'Refresh'),
                  ),
                  OutlinedButton.icon(
                    onPressed: isBusy
                        ? null
                        : () async {
                            await onLogout();
                          },
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Sign out'),
                  ),
                ],
              ),
              if (bannerMessage != null) ...[
                const SizedBox(height: 16),
                StatusBanner(
                  message: bannerMessage!,
                  onClose: onClearBanner,
                ),
              ],
              const SizedBox(height: 24),
              GlassPanel(
                child: _OverviewCard(profile: profile),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  GlassPanel(
                    child: SizedBox(
                      width: 232,
                      child: _MetricTile(
                        title: 'Total study time',
                        value: profile.studyDurationLabel,
                        hint: 'Loaded from the current account profile',
                      ),
                    ),
                  ),
                  GlassPanel(
                    child: SizedBox(
                      width: 232,
                      child: _MetricTile(
                        title: 'Check-in days',
                        value: '${profile.checkInDaysTotal} d',
                        hint: 'Will keep growing after check-in is connected',
                      ),
                    ),
                  ),
                  GlassPanel(
                    child: SizedBox(
                      width: 232,
                      child: _MetricTile(
                        title: 'Today tasks',
                        value: '${todayPlan.completedCount}/${todayPlan.totalCount}',
                        hint: todayPlan.hasItems
                            ? 'Planned ${todayPlan.plannedDurationLabel}'
                            : 'Create a today plan to start',
                      ),
                    ),
                  ),
                  const GlassPanel(
                    child: SizedBox(
                      width: 232,
                      child: _MetricTile(
                        title: 'Online policy',
                        value: '1 phone + 1 desktop',
                        hint: 'Same-slot login will replace the older session',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GlassPanel(
                child: TodayPlanPanel(
                  plan: todayPlan,
                  isBusy: isBusy,
                  onEdit: () => _openEditor(context),
                  onToggleItem: onToggleTodayPlanItem,
                ),
              ),
              const SizedBox(height: 16),
              const GlassPanel(
                child: _TeamPreviewCard(),
              ),
              const SizedBox(height: 16),
              const GlassPanel(
                child: _RoadmapCard(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome back, ${profile.displayName}', style: textTheme.titleLarge),
        const SizedBox(height: 10),
        Text(
          'The home view is no longer only a shell. Today plan editing and checklist completion are connected now.',
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _Tag(label: 'User No ${profile.userNo.isEmpty ? 'pending' : profile.userNo}'),
            _Tag(label: 'Timezone ${profile.timezone.isEmpty ? 'Asia/Shanghai' : profile.timezone}'),
            const _Tag(label: 'Profile visible to friends'),
            const _Tag(label: 'Study data visible to teammates'),
          ],
        ),
        if (profile.bio.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(profile.bio, style: textTheme.bodyMedium),
          ),
        ],
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.title,
    required this.value,
    required this.hint,
  });

  final String title;
  final String value;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: textTheme.titleMedium),
        const SizedBox(height: 12),
        Text(
          value,
          style: textTheme.headlineMedium?.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        Text(hint, style: textTheme.bodyMedium),
      ],
    );
  }
}

class _TeamPreviewCard extends StatelessWidget {
  const _TeamPreviewCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Team preview', style: textTheme.titleMedium),
        const SizedBox(height: 12),
        Text(
          'The next module will surface teammate progress, reminders, and completion notifications here.',
          style: textTheme.bodyLarge,
        ),
        const SizedBox(height: 16),
        const _InfoRow(
          icon: Icons.notifications_active_rounded,
          text: 'Teammates can be reminded and the team sees completion notices',
        ),
        const SizedBox(height: 10),
        const _InfoRow(
          icon: Icons.checklist_rounded,
          text: 'Checklist progress and study duration will appear here',
        ),
        const SizedBox(height: 10),
        const _InfoRow(
          icon: Icons.mark_chat_unread_rounded,
          text: 'Group chat and unread indicators are planned next',
        ),
      ],
    );
  }
}

class _RoadmapCard extends StatelessWidget {
  const _RoadmapCard();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Current progress', style: textTheme.titleMedium),
        const SizedBox(height: 12),
        const _InfoRow(
          icon: Icons.mark_email_read_rounded,
          text: 'Account login, email code, and register flow are connected',
        ),
        const SizedBox(height: 10),
        const _InfoRow(
          icon: Icons.task_alt_rounded,
          text: 'Today plan create, save, load, and item completion are connected',
        ),
        const SizedBox(height: 10),
        const _InfoRow(
          icon: Icons.dashboard_customize_rounded,
          text: 'Next recommended step: richer short-plan time-block scheduling',
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.mint, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                ),
          ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textPrimary,
            ),
      ),
    );
  }
}
