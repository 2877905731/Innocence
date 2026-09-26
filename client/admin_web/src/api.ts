export type Session = { accessToken: string; deviceId: string; userInfo: { userId: number; nickname: string } }
export type Overview = { userCount: number; availableUserCount: number; teamCount: number; pendingReportCount: number; todayStudyMinutes: number }
export type Report = { reportId: number; reportType: string; status: string; reason: string; description?: string; reportUserDisplayName: string; targetUserDisplayName: string; teamName: string; contentPreview: string; createTime: string }
export type ReportDetail = Report & { description: string; targetContent: string; targetMasked: boolean; targetDeleted: boolean; auditHistory: { auditId: number; decision: string; punishmentType: string; durationDays: number; reason: string; adminDisplayName: string; createTime: string }[] }
export type User = { userId: number; userNo: string; displayName: string; statusCode: number; statusLabel: string; teamName: string; lastLoginTime: string; createTime: string }
export type UserDetail = User & { email: string; bio: string; timezone: string; totalStudyMinutes: number; totalCheckInDays: number; consecutiveCheckInDays: number; teamRole: string; teamJoinedTime: string }
export type Punishment = { punishmentId: number; reportId: number; punishmentType: string; status: string; liftable: boolean; durationDays: number; reason: string; startTime: string; endTime: string }
export type Team = { teamId: number; teamName: string; inviteCode: string; ownerDisplayName: string; statusCode: number; statusLabel: string; memberCount: number; createTime: string }
export type TeamDetail = Team & { memberLimit: number; latestChatPreview: string; members: { userId: number; userNo: string; nickname: string; role: string; owner: boolean; activeStudy: boolean }[] }
export type Announcement = { announcementId: number; title: string; content: string; recipientCount: number; createTime: string }

type Envelope<T> = { code: number; message: string; data: T }
export class ApiError extends Error { constructor(message: string, public status: number) { super(message) } }

const API = '/api/admin/v1'
async function request<T>(path: string, options: RequestInit = {}, session?: Session): Promise<T> {
  let response: Response
  try {
    response = await fetch(`${API}${path}`, {
      ...options,
      headers: {
        Accept: 'application/json',
        ...(options.body ? { 'Content-Type': 'application/json' } : {}),
        ...(session ? { Authorization: `Bearer ${session.accessToken}`, 'X-Device-Type': 'admin_web', 'X-Device-Id': session.deviceId } : {}),
        ...options.headers,
      },
      cache: 'no-store',
    })
  } catch {
    throw new ApiError('无法连接服务器，请检查网络与服务状态。', 0)
  }
  let envelope: Envelope<T>
  try { envelope = await response.json() as Envelope<T> }
  catch { throw new ApiError('服务器返回了无法识别的数据。', response.status) }
  if (!response.ok || envelope.code !== 0) {
    if (response.status === 401 && session) window.dispatchEvent(new Event('innocence-admin-session-expired'))
    throw new ApiError(envelope.message || '请求失败，请稍后重试。', response.status)
  }
  return envelope.data
}
const query = (values: Record<string, string | number | undefined>) => `?${new URLSearchParams(Object.entries(values).filter(([, value]) => value !== undefined).map(([key, value]) => [key, String(value)])).toString()}`
const post = <T>(path: string, session: Session, body?: object) => request<T>(path, { method: 'POST', ...(body ? { body: JSON.stringify(body) } : {}) }, session)

export const api = {
  login: (email: string, password: string, deviceId: string) => request<Session>('/auth/login', { method: 'POST', body: JSON.stringify({ email, password, deviceId }) }),
  me: (session: Session) => request<{ userId: number }>('/auth/me', {}, session),
  logout: (session: Session) => post<{ success: boolean }>('/auth/logout', session),
  overview: (session: Session) => request<Overview>('/dashboard/overview', {}, session),
  reports: (session: Session, status: string) => request<Report[]>(`/reports${query({ status, limit: 100 })}`, {}, session),
  report: (session: Session, id: number) => request<ReportDetail>(`/reports/${id}`, {}, session),
  review: (session: Session, id: number, body: { decision: string; deleteContent: boolean; punishmentType: string; durationDays: number; reason: string }) => post(`/reports/${id}/review`, session, body),
  users: (session: Session, keyword: string) => request<User[]>(`/users/search${query({ keyword, limit: 100 })}`, {}, session),
  user: (session: Session, id: number) => request<UserDetail>(`/users/${id}`, {}, session),
  userReports: (session: Session, id: number) => request<Report[]>(`/users/${id}/reports?limit=50`, {}, session),
  punishments: (session: Session, id: number) => request<Punishment[]>(`/users/${id}/punishments?limit=50`, {}, session),
  lift: (session: Session, userId: number, punishmentId: number) => post(`/users/${userId}/punishments/${punishmentId}/lift`, session),
  teams: (session: Session, keyword: string) => request<Team[]>(`/teams${query({ keyword, limit: 100 })}`, {}, session),
  team: (session: Session, id: number) => request<TeamDetail>(`/teams/${id}`, {}, session),
  removeMember: (session: Session, teamId: number, userId: number) => post(`/teams/${teamId}/remove-member${query({ memberUserId: userId })}`, session),
  dissolve: (session: Session, teamId: number) => post(`/teams/${teamId}/dissolve`, session),
  announcements: (session: Session) => request<Announcement[]>('/announcements?limit=100', {}, session),
  createAnnouncement: (session: Session, title: string, content: string) => post('/announcements', session, { title, content }),
  deleteAnnouncement: (session: Session, id: number) => post(`/announcements/${id}/delete`, session),
}
