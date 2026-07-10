import 'package:flutter/material.dart';
import 'package:innocence_flutter/core/utils/localized_text.dart';

String localizeAdminReportStatus(BuildContext context, String value) {
  switch (_normalized(value)) {
    case 'pending':
      return localizedText(context, '待处理', 'Pending');
    case 'resolved':
      return localizedText(context, '已处理', 'Resolved');
    case 'rejected':
      return localizedText(context, '已驳回', 'Rejected');
    default:
      return _fallback(value, context);
  }
}

String localizeAdminReviewDecision(BuildContext context, String value) {
  switch (_normalized(value)) {
    case 'violation':
      return localizedText(context, '确认违规', 'Violation confirmed');
    case 'reject':
      return localizedText(context, '驳回举报', 'Reject report');
    default:
      return _fallback(value, context);
  }
}

String localizeAdminPunishmentType(BuildContext context, String value) {
  switch (_normalized(value)) {
    case 'none':
      return localizedText(context, '无处罚', 'None');
    case 'warn':
      return localizedText(context, '警告', 'Warn');
    case 'mute':
      return localizedText(context, '禁言', 'Mute');
    case 'ban':
      return localizedText(context, '封号', 'Ban');
    default:
      return _fallback(value, context);
  }
}

String localizeAdminPunishmentStatus(BuildContext context, String value) {
  switch (_normalized(value)) {
    case 'active':
      return localizedText(context, '生效中', 'Active');
    case 'lifted':
      return localizedText(context, '已解除', 'Lifted');
    case 'expired':
      return localizedText(context, '已到期', 'Expired');
    default:
      return _fallback(value, context);
  }
}

String localizeAdminUserStatus(BuildContext context, String value) {
  switch (_normalized(value)) {
    case 'active':
      return localizedText(context, '正常', 'Active');
    case 'inactive':
      return localizedText(context, '停用', 'Inactive');
    case 'banned':
      return localizedText(context, '封禁', 'Banned');
    case 'cancelled':
      return localizedText(context, '已注销', 'Cancelled');
    default:
      return _fallback(value, context);
  }
}

String localizeAdminTeamStatus(BuildContext context, String value) {
  switch (_normalized(value)) {
    case 'active':
      return localizedText(context, '进行中', 'Active');
    case 'dissolved':
      return localizedText(context, '已解散', 'Dissolved');
    default:
      return _fallback(value, context);
  }
}

String localizeAdminTeamRole(BuildContext context, String value) {
  switch (_normalized(value)) {
    case 'owner':
      return localizedText(context, '队长', 'Owner');
    case 'member':
      return localizedText(context, '成员', 'Member');
    default:
      return _fallback(value, context);
  }
}

String _normalized(String value) => value.trim().toLowerCase();

String _fallback(String value, BuildContext context) {
  final trimmed = value.trim();
  if (trimmed.isEmpty) {
    return localizedText(context, '未知', 'Unknown');
  }
  return trimmed;
}
