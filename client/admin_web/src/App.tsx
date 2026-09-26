import { useEffect, useState, type DependencyList, type FormEvent, type ReactNode } from 'react'
import { Bell, BookOpenText, ChevronRight, CircleHelp, ClipboardList, DoorOpen, LayoutDashboard, LoaderCircle, Menu, RefreshCw, Search, ShieldCheck, Users, UsersRound, X } from 'lucide-react'
import { api, type Announcement, type Overview, type Punishment, type Report, type ReportDetail, type Session, type Team, type TeamDetail, type User, type UserDetail } from './api'

type Page = 'overview' | 'reports' | 'users' | 'teams' | 'announcements'
type Confirm = { title: string; body: string; tone?: 'danger'; action: () => Promise<unknown> }
type Ask = (confirm: Confirm) => void
const sessionKey = 'innocence.admin.session'
const deviceKey = 'innocence.admin.device'

function getDeviceId() {
  let id = sessionStorage.getItem(deviceKey)
  if (!id) { id = `admin-web-${crypto.randomUUID()}`; sessionStorage.setItem(deviceKey, id) }
  return id
}
function readSession(): Session | null {
  try {
    const raw = sessionStorage.getItem(sessionKey)
    const parsed = raw ? JSON.parse(raw) as Session : null
    return parsed?.accessToken && parsed?.deviceId ? parsed : null
  } catch { return null }
}
function message(error: unknown) { return error instanceof Error ? error.message : '操作失败，请稍后重试。' }
function useResource<T>(load: () => Promise<T>, dependencies: DependencyList) {
  const key = JSON.stringify(dependencies)
  const [result, setResult] = useState<{ key: string; value: T } | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState('')
  const [version, setVersion] = useState(0)
  useEffect(() => {
    let live = true
    setLoading(true); setError('')
    load().then(data => { if (live) setResult({ key, value: data }) }).catch(reason => { if (live) setError(message(reason)) }).finally(() => { if (live) setLoading(false) })
    return () => { live = false }
    // dependencies are provided by each resource owner
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [...dependencies, version])
  return { value: result?.key === key ? result.value : null, loading, error, refresh: () => setVersion(v => v + 1) }
}
function Empty({ children }: { children: ReactNode }) { return <div className="empty"><CircleHelp size={22} /><span>{children}</span></div> }
function State({ loading, error, retry }: { loading: boolean; error: string; retry: () => void }) {
  if (loading) return <div className="state"><LoaderCircle size={20} className="spin" /> 正在加载…</div>
  if (error) return <div className="state error-state"><span>{error}</span><button className="text-button" onClick={retry}>重试</button></div>
  return null
}
function Badge({ value }: { value: string | number }) {
  const labels: Record<string, string> = { pending: '待处理', resolved: '已处理', rejected: '已驳回', active: '生效中', lifted: '已解除', warn: '警告', mute: '禁言', ban: '封禁' }
  const key = String(value).toLowerCase()
  return <span className={`badge badge-${key}`}>{labels[key] || String(value)}</span>
}
function DateText({ value }: { value?: string }) { return <span className="muted">{value || '—'}</span> }
function PanelTitle({ title, description, action }: { title: string; description?: string; action?: ReactNode }) {
  return <div className="panel-title"><div><h2>{title}</h2>{description && <p>{description}</p>}</div>{action}</div>
}
function Refresh({ onClick }: { onClick: () => void }) { return <button className="icon-button" title="刷新数据" aria-label="刷新数据" onClick={onClick}><RefreshCw size={17} /></button> }

function Login({ onLogin }: { onLogin: (session: Session) => void }) {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState('')
  async function submit(event: FormEvent) {
    event.preventDefault(); setBusy(true); setError('')
    try {
      const result = await api.login(email.trim(), password, getDeviceId())
      await api.me(result)
      sessionStorage.setItem(sessionKey, JSON.stringify(result))
      onLogin(result)
    } catch (reason) { setError(message(reason)) }
    finally { setBusy(false) }
  }
  return <main className="login-screen">
    <div className="login-brand"><div className="brand-mark big">I<span>•</span></div><div className="brand-word">INNOCENCE</div><p>守护每一段专注，也守护彼此的空间。</p></div>
    <div className="login-card"><div className="login-top"><span className="eyebrow">ADMIN CONSOLE</span><ShieldCheck size={25} /></div><h1>管理后台</h1><p className="login-subtitle">使用已授权的管理员邮箱登录</p>
      <form onSubmit={submit}><label>邮箱地址<input type="email" autoComplete="username" value={email} onChange={event => setEmail(event.target.value)} required placeholder="请输入管理员邮箱" /></label><label>密码<input type="password" autoComplete="current-password" value={password} onChange={event => setPassword(event.target.value)} required placeholder="请输入密码" /></label>
      {error && <p className="form-error" role="alert">{error}</p>}<button className="primary-button login-submit" disabled={busy}>{busy ? '正在验证…' : '进入管理后台'}<ChevronRight size={18} /></button></form>
      <div className="login-foot"><ShieldCheck size={16} /> 管理操作会记录处理人及时间</div>
    </div>
  </main>
}

function OverviewPage({ session, navigate }: { session: Session; navigate: (page: Page) => void }) {
  const stats = useResource<Overview>(() => api.overview(session), [session])
  const pending = useResource<Report[]>(() => api.reports(session, 'pending'), [session])
  const cards = [
    { label: '用户总数', value: stats.value?.userCount, note: '全部注册账号', icon: Users },
    { label: '可用账号', value: stats.value?.availableUserCount, note: '账号状态正常', icon: ShieldCheck },
    { label: '活跃团队', value: stats.value?.teamCount, note: '当前未解散', icon: UsersRound },
    { label: '待处理举报', value: stats.value?.pendingReportCount, note: '需要审核', icon: ClipboardList },
  ]
  return <div className="page-flow"><div className="page-heading"><div><span className="eyebrow">OVERVIEW</span><h1>工作概览</h1><p>社区运行状态与需要处理的事项。</p></div><Refresh onClick={() => { stats.refresh(); pending.refresh() }} /></div>
    <State loading={stats.loading} error={stats.error} retry={stats.refresh} />
    {stats.value && <><div className="stat-grid">{cards.map(({ label, value, note, icon: Icon }) => <div className="stat-card" key={label}><div className="stat-top"><span>{label}</span><Icon size={19} /></div><strong>{value?.toLocaleString('zh-CN') ?? '—'}</strong><small>{note}</small></div>)}</div><div className="study-strip"><div><BookOpenText size={20} /><span>今日已完成学习时长</span></div><strong>{stats.value.todayStudyMinutes.toLocaleString('zh-CN')} <small>分钟</small></strong></div></>}
    <section className="surface"><PanelTitle title="待处理举报" description="优先查看需要审核的内容" action={<button className="text-button" onClick={() => navigate('reports')}>查看全部 <ChevronRight size={16} /></button>} /><State loading={pending.loading} error={pending.error} retry={pending.refresh} />
      {pending.value && (pending.value.length ? <div className="compact-list">{pending.value.slice(0, 5).map(report => <button key={report.reportId} className="compact-row" onClick={() => navigate('reports')}><div><strong>#{report.reportId} · {report.reason}</strong><span>{report.teamName || '团队交流'} · {report.targetUserDisplayName}</span></div><DateText value={report.createTime} /><ChevronRight size={17} /></button>)}</div> : <Empty>当前没有待处理举报</Empty>)}
    </section></div>
}

function ReportsPage({ session, ask, notify }: { session: Session; ask: Ask; notify: (value: string) => void }) {
  const [status, setStatus] = useState('pending')
  const data = useResource<Report[]>(() => api.reports(session, status), [session, status])
  const [selected, setSelected] = useState<number | null>(null)
  const detail = useResource<ReportDetail | null>(() => selected ? api.report(session, selected) : Promise.resolve(null), [session, selected])
  const [decision, setDecision] = useState('violation')
  const [punishment, setPunishment] = useState('warn')
  const [duration, setDuration] = useState(7)
  const [deleteContent, setDeleteContent] = useState(false)
  const [reason, setReason] = useState('')
  function review(event: FormEvent) {
    event.preventDefault()
    if (selected == null || detail.value?.reportId !== selected) return
    const body = { decision, deleteContent: decision === 'violation' && (deleteContent || punishment === 'none'), punishmentType: decision === 'reject' ? 'none' : punishment, durationDays: decision === 'violation' && ['mute', 'ban'].includes(punishment) ? duration : 0, reason: reason.trim() }
    ask({ title: decision === 'reject' ? '驳回这条举报？' : '确认处理这条举报？', body: `举报 #${selected} 的处理结果将写入审核记录。`, tone: decision === 'violation' ? 'danger' : undefined, action: async () => { await api.review(session, selected, body); notify('举报处理已提交'); setSelected(null); data.refresh() } })
  }
  return <div className="page-flow"><div className="page-heading"><div><span className="eyebrow">MODERATION</span><h1>举报审核</h1><p>查看内容、处理举报并保留审核轨迹。</p></div><Refresh onClick={data.refresh} /></div>
    <div className="segmented" role="group" aria-label="举报状态">{[['pending','待处理'],['resolved','已处理'],['rejected','已驳回']].map(([key,label]) => <button key={key} className={status === key ? 'selected' : ''} onClick={() => { setStatus(key); setSelected(null) }}>{label}</button>)}</div>
    <div className="split-layout"><section className="surface list-surface"><PanelTitle title="举报列表" description="显示最近 100 条" /><State loading={data.loading} error={data.error} retry={data.refresh} />{data.value && (data.value.length ? <div className="item-list">{data.value.map(item => <button key={item.reportId} className={`list-item ${selected === item.reportId ? 'active' : ''}`} onClick={() => setSelected(item.reportId)}><div className="list-item-top"><strong>#{item.reportId} · {item.reason}</strong><Badge value={item.status} /></div><p>{item.contentPreview || '内容已删除或不可用'}</p><div className="item-meta">{item.teamName || '团队交流'} <span>·</span> <DateText value={item.createTime} /></div></button>)}</div> : <Empty>这一状态下暂无举报</Empty>)}</section>
    <section className="surface detail-surface"><PanelTitle title="举报详情" description="选择左侧举报查看完整信息" />{selected ? <><State loading={detail.loading} error={detail.error} retry={detail.refresh} />{detail.value && <><div className="detail-head"><strong>#{detail.value.reportId}</strong><Badge value={detail.value.status} /></div><dl className="detail-grid"><div><dt>举报人</dt><dd>{detail.value.reportUserDisplayName}</dd></div><div><dt>被举报人</dt><dd>{detail.value.targetUserDisplayName}</dd></div><div><dt>所在团队</dt><dd>{detail.value.teamName || '—'}</dd></div><div><dt>提交时间</dt><dd>{detail.value.createTime}</dd></div></dl><div className="detail-block"><span className="detail-label">举报说明</span><p>{detail.value.description || detail.value.reason}</p></div><div className="detail-block quoted"><span className="detail-label">相关内容</span><p>{detail.value.targetMasked ? '内容已遮蔽' : detail.value.targetDeleted ? '内容已删除' : detail.value.targetContent || '无可展示内容'}</p></div>
      {detail.value.status === 'pending' && <form className="review-form" onSubmit={review}><h3>处理决定</h3><div className="field-row"><label>结论<select value={decision} onChange={event => setDecision(event.target.value)}><option value="violation">确认违规</option><option value="reject">驳回举报</option></select></label>{decision === 'violation' && <label>处罚方式<select value={punishment} onChange={event => setPunishment(event.target.value)}><option value="warn">警告</option><option value="mute">禁言</option><option value="ban">封禁</option><option value="none">仅删除内容</option></select></label>}</div>{decision === 'violation' && ['mute','ban'].includes(punishment) && <label>时长（天，0 表示长期）<input type="number" min="0" max="3650" value={duration} onChange={event => setDuration(Number(event.target.value))} required /></label>}{decision === 'violation' && <label className="check-field"><input type="checkbox" checked={deleteContent} onChange={event => setDeleteContent(event.target.checked)} /> 删除违规内容</label>}<label>处理备注<textarea maxLength={255} value={reason} onChange={event => setReason(event.target.value)} placeholder="记录判断依据，便于后续复查" /></label><button className="primary-button" type="submit">提交处理</button></form>}
      <div className="audit"><h3>审核记录</h3>{detail.value.auditHistory.length ? detail.value.auditHistory.map(record => <div className="audit-row" key={record.auditId}><div><strong>{record.decision === 'reject' ? '驳回举报' : '确认违规'}</strong> · {record.adminDisplayName}</div><p>{record.reason || '无备注'}</p><DateText value={record.createTime} /></div>) : <p className="muted">暂无审核记录</p>}</div></>}</> : <Empty>从列表中选择一条举报</Empty>}</section></div></div>
}

function UsersPage({ session, ask, notify }: { session: Session; ask: Ask; notify: (value: string) => void }) {
  const [draft, setDraft] = useState('')
  const [keyword, setKeyword] = useState('')
  const list = useResource<User[]>(() => api.users(session, keyword), [session, keyword])
  const [selected, setSelected] = useState<number | null>(null)
  const profile = useResource<UserDetail | null>(() => selected ? api.user(session, selected) : Promise.resolve(null), [session, selected])
  const penalties = useResource<Punishment[]>(() => selected ? api.punishments(session, selected) : Promise.resolve([]), [session, selected])
  const reports = useResource<Report[]>(() => selected ? api.userReports(session, selected) : Promise.resolve([]), [session, selected])
  return <div className="page-flow"><div className="page-heading"><div><span className="eyebrow">PEOPLE</span><h1>用户管理</h1><p>查找账号、查看关联举报与处罚记录。</p></div><Refresh onClick={list.refresh} /></div>
    <form className="search-bar" onSubmit={event => { event.preventDefault(); setKeyword(draft.trim()) }}><Search size={18} /><input value={draft} onChange={event => setDraft(event.target.value)} placeholder="搜索用户编号、昵称或邮箱" aria-label="搜索用户" /><button className="secondary-button">搜索</button></form>
    <div className="split-layout"><section className="surface list-surface"><PanelTitle title="用户列表" description="显示最近 100 条匹配结果" /><State loading={list.loading} error={list.error} retry={list.refresh} />{list.value && (list.value.length ? <div className="item-list">{list.value.map(item => <button key={item.userId} className={`list-item ${selected === item.userId ? 'active' : ''}`} onClick={() => setSelected(item.userId)}><div className="list-item-top"><strong>{item.displayName || item.userNo}</strong><Badge value={item.statusLabel || item.statusCode} /></div><div className="item-meta">{item.userNo} {item.teamName && `· ${item.teamName}`}</div><small>最近登录：{item.lastLoginTime || '暂无记录'}</small></button>)}</div> : <Empty>没有找到匹配的用户</Empty>)}</section>
    <section className="surface detail-surface"><PanelTitle title="用户档案" />{selected ? <><State loading={profile.loading} error={profile.error} retry={profile.refresh} />{profile.value && <><div className="detail-head"><strong>{profile.value.displayName || profile.value.userNo}</strong><Badge value={profile.value.statusLabel || profile.value.statusCode} /></div><dl className="detail-grid"><div><dt>用户编号</dt><dd>{profile.value.userNo}</dd></div><div><dt>邮箱</dt><dd className="wrap">{profile.value.email}</dd></div><div><dt>团队</dt><dd>{profile.value.teamName || '未加入'}</dd></div><div><dt>总学习时长</dt><dd>{profile.value.totalStudyMinutes} 分钟</dd></div><div><dt>累计签到</dt><dd>{profile.value.totalCheckInDays} 天</dd></div><div><dt>最近登录</dt><dd>{profile.value.lastLoginTime || '—'}</dd></div></dl><div className="detail-block"><span className="detail-label">个人简介</span><p>{profile.value.bio || '暂无简介'}</p></div></>}
      <div className="subsection"><h3>处罚记录</h3><State loading={penalties.loading} error={penalties.error} retry={penalties.refresh} />{penalties.value && (penalties.value.length ? penalties.value.map(item => <div className="record-row" key={item.punishmentId}><div><Badge value={item.punishmentType} /> <Badge value={item.status} /><p>{item.reason || '无备注'}</p><small>{item.startTime} {item.endTime && `— ${item.endTime}`}</small></div>{item.liftable && <button className="secondary-button small" onClick={() => ask({ title: '解除这项处罚？', body: `将解除用户 ${selected} 的 ${item.punishmentType} 处罚。`, action: async () => { await api.lift(session, selected, item.punishmentId); notify('处罚已解除'); penalties.refresh(); profile.refresh() } })}>解除</button>}</div>) : <Empty>暂无处罚记录</Empty>)}</div>
      <div className="subsection"><h3>相关举报</h3><State loading={reports.loading} error={reports.error} retry={reports.refresh} />{reports.value && (reports.value.length ? reports.value.map(item => <div className="record-row" key={item.reportId}><div><strong>#{item.reportId} · {item.reason}</strong><p>{item.description || item.contentPreview || '无说明'}</p></div><Badge value={item.status} /></div>) : <Empty>暂无相关举报</Empty>)}</div></> : <Empty>从列表中选择用户</Empty>}</section></div></div>
}

function TeamsPage({ session, ask, notify }: { session: Session; ask: Ask; notify: (value: string) => void }) {
  const [draft, setDraft] = useState('')
  const [keyword, setKeyword] = useState('')
  const list = useResource<Team[]>(() => api.teams(session, keyword), [session, keyword])
  const [selected, setSelected] = useState<number | null>(null)
  const detail = useResource<TeamDetail | null>(() => selected ? api.team(session, selected) : Promise.resolve(null), [session, selected])
  return <div className="page-flow"><div className="page-heading"><div><span className="eyebrow">TEAMS</span><h1>团队管理</h1><p>查看团队成员，处理违规团队。</p></div><Refresh onClick={list.refresh} /></div><form className="search-bar" onSubmit={event => { event.preventDefault(); setKeyword(draft.trim()) }}><Search size={18} /><input value={draft} onChange={event => setDraft(event.target.value)} placeholder="搜索团队名称或邀请码" aria-label="搜索团队" /><button className="secondary-button">搜索</button></form>
    <div className="split-layout"><section className="surface list-surface"><PanelTitle title="团队列表" description="显示最近 100 条匹配结果" /><State loading={list.loading} error={list.error} retry={list.refresh} />{list.value && (list.value.length ? <div className="item-list">{list.value.map(item => <button key={item.teamId} className={`list-item ${selected === item.teamId ? 'active' : ''}`} onClick={() => setSelected(item.teamId)}><div className="list-item-top"><strong>{item.teamName}</strong><Badge value={item.statusLabel || item.statusCode} /></div><div className="item-meta">{item.memberCount} 位成员 · 队长 {item.ownerDisplayName}</div><small>创建于 {item.createTime}</small></button>)}</div> : <Empty>没有找到匹配的团队</Empty>)}</section>
    <section className="surface detail-surface"><PanelTitle title="团队详情" />{selected ? <><State loading={detail.loading} error={detail.error} retry={detail.refresh} />{detail.value && <><div className="detail-head"><strong>{detail.value.teamName}</strong><Badge value={detail.value.statusLabel || detail.value.statusCode} /></div><dl className="detail-grid"><div><dt>邀请码</dt><dd>{detail.value.inviteCode}</dd></div><div><dt>成员</dt><dd>{detail.value.memberCount} / {detail.value.memberLimit}</dd></div><div><dt>队长</dt><dd>{detail.value.ownerDisplayName}</dd></div><div><dt>创建时间</dt><dd>{detail.value.createTime}</dd></div></dl><div className="subsection"><h3>成员列表</h3>{detail.value.members.map(member => <div className="record-row" key={member.userId}><div><strong>{member.nickname || member.userNo}</strong><p>{member.owner ? '队长' : '成员'} · {member.userNo}{member.activeStudy ? ' · 正在学习' : ''}</p></div>{!member.owner && detail.value?.statusCode === 1 && <button className="secondary-button small" onClick={() => ask({ title: '移除这位成员？', body: `将从 ${detail.value?.teamName} 移除 ${member.nickname || member.userNo}。`, tone: 'danger', action: async () => { await api.removeMember(session, selected, member.userId); notify('成员已移除'); detail.refresh(); list.refresh() } })}>移除</button>}</div>)}</div>{detail.value.statusCode === 1 && <div className="danger-zone"><div><strong>解散团队</strong><p>所有成员将退出该团队，此操作不可撤销。</p></div><button className="danger-button" onClick={() => ask({ title: '确认解散团队？', body: `即将解散「${detail.value?.teamName}」，请确认处理对象。`, tone: 'danger', action: async () => { await api.dissolve(session, selected); notify('团队已解散'); detail.refresh(); list.refresh() } })}>解散团队</button></div>}</>}</> : <Empty>从列表中选择团队</Empty>}</section></div></div>
}

function AnnouncementsPage({ session, ask, notify }: { session: Session; ask: Ask; notify: (value: string) => void }) {
  const list = useResource<Announcement[]>(() => api.announcements(session), [session])
  const [title, setTitle] = useState('')
  const [content, setContent] = useState('')
  function publish(event: FormEvent) {
    event.preventDefault()
    const nextTitle = title.trim(), nextContent = content.trim()
    if (!nextTitle || !nextContent) return
    ask({ title: '发布系统公告？', body: '公告会发送给符合条件的用户。', action: async () => { await api.createAnnouncement(session, nextTitle, nextContent); setTitle(''); setContent(''); notify('系统公告已发布'); list.refresh() } })
  }
  return <div className="page-flow"><div className="page-heading"><div><span className="eyebrow">ANNOUNCEMENTS</span><h1>系统公告</h1><p>向用户发布重要通知，查看近期发布记录。</p></div><Refresh onClick={list.refresh} /></div><div className="announcement-grid"><section className="surface"><PanelTitle title="发布公告" description="发布前请核对标题与内容" /><form className="announcement-form" onSubmit={publish}><label>公告标题<input maxLength={64} value={title} onChange={event => setTitle(event.target.value)} placeholder="输入公告标题" required /><small>{title.length} / 64</small></label><label>公告内容<textarea maxLength={255} rows={7} value={content} onChange={event => setContent(event.target.value)} placeholder="输入要发送给用户的内容" required /><small>{content.length} / 255</small></label><button className="primary-button">发布公告</button></form></section><section className="surface"><PanelTitle title="近期公告" description="最近 100 条" /><State loading={list.loading} error={list.error} retry={list.refresh} />{list.value && (list.value.length ? <div className="announcement-list">{list.value.map(item => <div className="announcement-item" key={item.announcementId}><div className="announcement-head"><strong>{item.title}</strong><DateText value={item.createTime} /></div><p>{item.content}</p><div className="announcement-bottom"><span>已发送给 {item.recipientCount} 位用户</span><button className="text-button danger-text" onClick={() => ask({ title: '删除这条公告？', body: `将删除「${item.title}」及其通知记录。`, tone: 'danger', action: async () => { await api.deleteAnnouncement(session, item.announcementId); notify('公告已删除'); list.refresh() } })}>删除</button></div></div>)}</div> : <Empty>暂无已发布公告</Empty>)}</section></div></div>
}

const nav: { id: Page; label: string; icon: typeof LayoutDashboard }[] = [
  { id: 'overview', label: '工作概览', icon: LayoutDashboard },
  { id: 'reports', label: '举报审核', icon: ClipboardList },
  { id: 'users', label: '用户管理', icon: Users },
  { id: 'teams', label: '团队管理', icon: UsersRound },
  { id: 'announcements', label: '系统公告', icon: Bell },
]
function Shell({ session, onLogout }: { session: Session; onLogout: () => void }) {
  const [page, setPage] = useState<Page>('overview')
  const [menuOpen, setMenuOpen] = useState(false)
  const [confirm, setConfirm] = useState<Confirm | null>(null)
  const [confirmBusy, setConfirmBusy] = useState(false)
  const [toast, setToast] = useState('')
  const [actionError, setActionError] = useState('')
  function navigate(target: Page) { setPage(target); setMenuOpen(false) }
  function notify(value: string) { setToast(value); window.setTimeout(() => setToast(''), 4500) }
  async function runConfirm() {
    if (!confirm) return
    setConfirmBusy(true); setActionError('')
    try { await confirm.action(); setConfirm(null) }
    catch (reason) { setActionError(message(reason)) }
    finally { setConfirmBusy(false) }
  }
  const pageContent: Record<Page, ReactNode> = {
    overview: <OverviewPage session={session} navigate={navigate} />,
    reports: <ReportsPage session={session} ask={setConfirm} notify={notify} />,
    users: <UsersPage session={session} ask={setConfirm} notify={notify} />,
    teams: <TeamsPage session={session} ask={setConfirm} notify={notify} />,
    announcements: <AnnouncementsPage session={session} ask={setConfirm} notify={notify} />,
  }
  return <div className="admin-shell"><aside className={`sidebar ${menuOpen ? 'open' : ''}`}><div className="sidebar-brand"><div className="brand-mark">I<span>•</span></div><div><strong>INNOCENCE</strong><small>管理后台</small></div><button className="mobile-close icon-button" aria-label="关闭菜单" onClick={() => setMenuOpen(false)}><X size={20} /></button></div><div className="nav-label">工作空间</div><nav aria-label="管理导航">{nav.map(item => <button key={item.id} className={`nav-item ${page === item.id ? 'active' : ''}`} onClick={() => navigate(item.id)}><item.icon size={19} strokeWidth={1.8} /><span>{item.label}</span>{page === item.id && <span className="nav-indicator" />}</button>)}</nav><div className="sidebar-bottom"><div className="admin-identity"><div className="avatar">{(session.userInfo?.nickname || '管').slice(0, 1)}</div><div><strong>{session.userInfo?.nickname || '管理员'}</strong><small>已验证管理员</small></div></div><button className="logout-button" onClick={onLogout}><DoorOpen size={17} /> 退出登录</button></div></aside>
    {menuOpen && <button className="mobile-scrim" aria-label="关闭菜单" onClick={() => setMenuOpen(false)} />}
    <main className="workspace"><header className="topbar"><button className="mobile-menu icon-button" aria-label="打开菜单" onClick={() => setMenuOpen(true)}><Menu size={22} /></button><span className="topbar-path">管理后台 <ChevronRight size={15} /> <strong>{nav.find(item => item.id === page)?.label}</strong></span><span className="topbar-right"><span className="private-pill"><ShieldCheck size={15} /> 管理员会话</span></span></header><div className="content">{pageContent[page]}</div></main>
    {toast && <div className="toast" role="status">{toast}</div>}
    {confirm && <div className="modal-backdrop" role="presentation"><div className="modal" role="dialog" aria-modal="true" aria-labelledby="confirm-title"><div className="modal-top"><ShieldCheck size={22} /><button className="icon-button" aria-label="关闭" disabled={confirmBusy} onClick={() => { setConfirm(null); setActionError('') }}><X size={18} /></button></div><h2 id="confirm-title">{confirm.title}</h2><p>{confirm.body}</p>{actionError && <p className="form-error" role="alert">{actionError}</p>}<div className="modal-actions"><button className="secondary-button" disabled={confirmBusy} onClick={() => { setConfirm(null); setActionError('') }}>取消</button><button className={confirm.tone === 'danger' ? 'danger-button' : 'primary-button'} disabled={confirmBusy} onClick={runConfirm}>{confirmBusy ? '处理中…' : '确认'}</button></div></div></div>}
  </div>
}

export default function App() {
  const [session, setSession] = useState<Session | null>(null)
  const [checking, setChecking] = useState(true)
  useEffect(() => {
    const existing = readSession()
    if (!existing) { setChecking(false); return }
    api.me(existing).then(() => setSession(existing)).catch(() => sessionStorage.removeItem(sessionKey)).finally(() => setChecking(false))
  }, [])
  useEffect(() => {
    const expire = () => { sessionStorage.removeItem(sessionKey); setSession(null) }
    window.addEventListener('innocence-admin-session-expired', expire)
    return () => window.removeEventListener('innocence-admin-session-expired', expire)
  }, [])
  async function logout() {
    const current = session
    sessionStorage.removeItem(sessionKey)
    setSession(null)
    if (current) { try { await api.logout(current) } catch { /* local session is already removed */ } }
  }
  if (checking) return <div className="bootstrap"><LoaderCircle className="spin" size={24} /> 正在验证会话…</div>
  return session ? <Shell session={session} onLogout={logout} /> : <Login onLogin={setSession} />
}
