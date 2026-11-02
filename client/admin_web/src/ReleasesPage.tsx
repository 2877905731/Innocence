import { useEffect, useState, type FormEvent } from 'react'
import { api, type Release, type Session } from './api'

export function ReleasesPage({ session }: { session: Session }) {
  const [items, setItems] = useState<Release[]>([])
  const [platform, setPlatform] = useState('windows')
  const [version, setVersion] = useState('')
  const [build, setBuild] = useState('')
  const [notes, setNotes] = useState('')
  const [file, setFile] = useState<File | null>(null)
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState('')
  const [progress, setProgress] = useState(0)
  const refresh = async () => { setItems(await api.releases(session)) }
  useEffect(() => { let live = true; api.releases(session).then(v => { if (live) setItems(v) }).catch(e => { if (live) setError(String(e.message)) }); return () => { live = false } }, [session])
  async function upload(event: FormEvent) {
    event.preventDefault(); if (!file || busy) return
    setBusy(true); setError(''); setProgress(0)
    try {
      await api.uploadRelease(session, { platform, arch: platform === 'windows' ? 'x64' : platform === 'android' ? 'universal' : 'arm64', version, build: Number(build), notes, installMethod: platform === 'windows' ? 'windows_installer' : platform === 'android' ? 'android_apk' : 'manual_hdc' }, file, setProgress)
      await refresh(); setFile(null); setVersion(''); setBuild(''); setNotes('')
    } catch (e) { setError(e instanceof Error ? e.message : '上传失败') } finally { setBusy(false) }
  }
  async function change(item: Release, publish: boolean) {
    if (!window.confirm(publish ? `发布 ${item.platform} ${item.version}（${item.build}）？在线用户检查更新后即可下载。` : `下架 ${item.version}？新的下载请求将被拒绝。`)) return
    setBusy(true); setError('')
    try { await api.changeRelease(session, item.id, publish); await refresh() } catch (e) { setError(e instanceof Error ? e.message : '操作失败') } finally { setBusy(false) }
  }
  return <div className="page-flow"><div className="page-heading"><div><span className="eyebrow">RELEASES</span><h1>版本发布</h1><p>在本机编译并签名，上传后发布给在线账号。</p></div><button className="secondary-button" disabled={busy} onClick={() => refresh().catch(e => setError(e.message))}>刷新</button></div>
    {error && <p className="form-error" role="alert">{error}</p>}
    <section className="surface"><div className="panel-title"><div><h2>上传新版本</h2><p>单包最多 300 MiB。上传后先保存为草稿，核对后再发布。</p></div></div>
      <form className="announcement-form" onSubmit={upload}>
        <label>平台<select value={platform} disabled={busy} onChange={e => { setPlatform(e.target.value); setFile(null) }}><option value="windows">Windows x64 安装器</option><option value="android">Android 通用 APK（原签名）</option><option value="harmonyos">鸿蒙 ARM64 HAP（电脑签名覆盖）</option></select></label>
        <div className="detail-grid"><label>版本号<input placeholder="1.3.4" pattern="[0-9]+\.[0-9]+\.[0-9]+" required value={version} onChange={e => setVersion(e.target.value)} disabled={busy} /></label><label>构建号<input type="number" min="1" step="1" required value={build} onChange={e => setBuild(e.target.value)} disabled={busy} /></label></div>
        <label>更新说明<textarea rows={5} maxLength={8000} required value={notes} onChange={e => setNotes(e.target.value)} disabled={busy} /></label>
        <label>安装包<input key={platform} type="file" accept={platform === 'windows' ? '.exe' : platform === 'android' ? '.apk' : '.hap'} required disabled={busy} onChange={e => setFile(e.target.files?.[0] ?? null)} /></label>
        {platform === 'harmonyos' && <p className="muted">当前 HAP 需电脑签名覆盖。不要上传个人设备 Profile 或将开发包当作通用自动更新包。</p>}
        {busy && <p role="status">正在处理… 上传 {progress}%</p>}
        <button className="primary-button" disabled={busy || !file}>上传并保存草稿</button>
      </form></section>
    <section className="surface"><div className="panel-title"><div><h2>版本记录</h2><p>已发布版本按构建号选择；下架后停止新的下载。</p></div></div>
      {!items.length && <p className="empty">尚无版本</p>}
      {items.map(item => <article className="announcement-item" key={item.id}><div className="announcement-head"><strong>{item.platform} · {item.version}（{item.build}）</strong><span className="badge">{item.state === 'published' ? '已发布' : item.state === 'draft' ? '草稿' : '已下架'}</span></div><p className="release-notes">{item.notes}</p><p className="muted">{(item.size / 1048576).toFixed(1)} MiB · {item.installMethod === 'manual_hdc' ? '电脑签名覆盖' : '系统安装器'}</p><details><summary>校验与操作记录</summary><p className="release-hash">SHA256：{item.sha256}</p>{item.history.map((event, index) => <p key={index}>{event.at} · {event.action === 'upload' ? '上传' : event.action === 'publish' ? '发布' : '下架'} · 管理员 #{event.actorId}</p>)}</details><div className="announcement-bottom"><span>{item.publishedAt || '尚未发布'}</span><button className="secondary-button" disabled={busy} onClick={() => change(item, item.state !== 'published')}>{item.state === 'published' ? '下架' : '发布'}</button></div></article>)}
    </section></div>
}
