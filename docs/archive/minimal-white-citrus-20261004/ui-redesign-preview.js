/* Independent design reference. All records are fictional, in-memory samples. */
'use strict';
(() => {
  const glass = document.body.dataset.theme === 'glass';
  const paths = {
    home:'M3 10 12 3l9 7v10a1 1 0 0 1-1 1h-5v-7H9v7H4a1 1 0 0 1-1-1Z',
    plans:'M7 3v4m10-4v4M4 10h16M5 5h14a1 1 0 0 1 1 1v14H4V6a1 1 0 0 1 1-1Zm3 9h2m4 0h2m-8 3h2',
    focus:'M9 3h6m-3 0v3m6 2 2-2M12 11v5m8-2a8 8 0 1 1-16 0 8 8 0 0 1 16 0',
    people:'M16 21v-2a4 4 0 0 0-4-4H7a4 4 0 0 0-4 4v2m15-7a4 4 0 0 1 3 4v3M13 7a4 4 0 1 1-8 0 4 4 0 0 1 8 0m4-3a4 4 0 0 1 0 8',
    stats:'M4 20V10m8 10V4m8 16v-7M2 21h20',
    sound:'M8 5v14l-5-4H1V9h2l5-4m5 3a6 6 0 0 1 0 8m3-11a10 10 0 0 1 0 14',
    play:'m9 5 10 7-10 7Z',pause:'M8 5v14M16 5v14',
    plus:'M12 5v14M5 12h14',close:'m6 6 12 12M6 18 18 6',reset:'M4 8a9 9 0 1 1-1 8M4 3v5h5',
    leaf:'M5 19c-7-14 7-16 15-16 0 9-2 21-15 16Zm0 0L16 8',
    sun:'M12 2v2m0 16v2M2 12h2m16 0h2M5 5l1 1m12 12 1 1M5 19l1-1M18 6l1-1m-2 7a5 5 0 1 1-10 0 5 5 0 0 1 10 0',
    book:'M4 4h7a3 3 0 0 1 3 3v14a3 3 0 0 0-3-3H4Zm16 0h-3a3 3 0 0 0-3 3m6-3v14h-3a3 3 0 0 0-3 3',
    infinity:'M12 12C7 2 1 7 2 12s6 10 10 0 11-5 10 0-6 10-10 0'
  };
  const icon = (name) => `<svg class="icon" viewBox="0 0 24 24" aria-hidden="true"><path d="${paths[name] || paths.home}"/></svg>`;
  const mark = '<svg viewBox="0 0 24 24" fill="none" aria-hidden="true"><path d="M6 18V6m12 12V6M6 6l12 12" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"/></svg>';
  const dial = `<div class="focus-dial"><svg viewBox="0 0 120 120" aria-hidden="true"><circle class="dial-track" cx="60" cy="60" r="50"/><circle class="dial-progress" cx="60" cy="60" r="50"/></svg><span class="timer numeric">25:00</span><span class="dial-caption">保持心流</span></div>`;
  document.getElementById('preview').innerHTML = `
    <header class="toolbar">
      <div class="preview-label"><strong>INNOCENCE / DESIGN STUDY</strong>设计参考 · 示例数据</div>
      <nav class="theme-links" aria-label="参考主题"><a href="liquid-glass-preview.html" ${glass?'aria-current="page"':''}>01 液态玻璃</a><a href="minimal-white-preview.html" ${!glass?'aria-current="page"':''}>02 简约白色</a></nav>
      <div class="view-controls" aria-label="画布尺寸"><button data-size="large" aria-pressed="true" title="大画布">L</button><button data-size="medium" aria-pressed="false" title="中画布">M</button><button data-size="small" aria-pressed="false" title="小画布">S</button><button class="orb-launch" data-size="orb" aria-pressed="false">专注球</button></div>
    </header>
    <div class="ambient" aria-hidden="true">${glass?'<div class="space-horizon"></div>':''}</div>
    <div class="stage" data-size="large">
      <div class="app">
        <aside class="sidebar">
          <a class="brand" href="#home" aria-label="Innocence 首页"><span class="brand-mark">${mark}</span><span class="brand-name">Innocence</span></a>
          <nav class="nav-list" aria-label="页面区块">
            ${[['home','首页'],['plans','计划'],['focus','专注'],['people','陪伴'],['stats','统计']].map(([id,label])=>`<a href="#${id}" title="${label}" aria-label="${label}" class="nav-link ${id==='home'?'active':''}">${icon(id)}<span class="nav-text">${label}</span></a>`).join('')}
          </nav>
          <div class="sidebar-bottom"><span class="muted" title="每一点积累，都有意义">${icon('leaf')}</span><span class="avatar" aria-label="本地演示用户">IN</span></div>
        </aside>
        <main class="workspace" id="home">
          <div class="appbar"><div class="row"><strong>我的空间</strong><span class="divider"></span><span>每一天，都算数</span></div><div class="row session-label">${icon('sun')}<span>一个适合专注的午后</span></div></div>
          <div class="greeting"><div><div class="eyebrow">${glass?'TUESDAY, SEPTEMBER 29':'TUESDAY, SEPTEMBER 29'}</div><h1>${glass?'留一点时间，专注当下。':'把今天，过得从容一点。'}</h1><p>${glass?'在安静的光里，找回属于自己的节奏。':'一件重要的事，一段专注的时间。'}</p></div><div class="date-badge"><strong>09 / 29</strong><br>${glass?'TUESDAY · 2026':'2026 · 秋日'}</div></div>
          <div class="overview">
            <section class="panel focus-card" id="focus" aria-labelledby="focus-title">${!glass?'<div class="focus-art" aria-hidden="true"></div><div class="focus-veil" aria-hidden="true"></div>':''}
              <div class="between"><h2 id="focus-title">专注此刻</h2><span class="tag">${icon('infinity')}<span id="focus-status">准备开始</span></span></div>
              <div class="focus-main"><div class="focus-copy"><div class="eyebrow">ONE THING AT A TIME</div><h3>阅读《设计心理学》</h3><p>第 03 章 · 知识存在于头脑与外界<br>给自己一段不被打扰的时间。</p></div>${dial}</div>
              <div class="focus-footer"><label class="muted small"><select class="duration-select" aria-label="专注时长"><option value="25">25 分钟</option><option value="45">45 分钟</option><option value="60">60 分钟</option></select></label><div class="focus-actions"><button class="quiet-button reset-timer" aria-label="重置计时" title="重置计时">${icon('reset')}</button><button class="primary timer-toggle">${icon('play')}<span>开始专注</span></button></div></div>
            </section>
            <section class="panel summary-panel" aria-labelledby="rhythm-title">
              <div class="between"><h2 id="rhythm-title">今日节奏</h2><span class="muted small">慢慢来，也很好</span></div>
              <div class="stats"><div class="metric"><small>累计专注</small><div class="metric-value"><strong class="numeric">2<span> h </span>15</strong><span>min</span></div><div class="metric-foot">比昨日多 25 分钟</div></div><div class="metric"><small>计划完成</small><div class="metric-value"><strong class="numeric" id="completion-number">2 / 4</strong><span>项</span></div><div class="summary-progress" role="progressbar" aria-label="计划完成率" aria-valuemin="0" aria-valuemax="100" aria-valuenow="50"><i></i></div></div></div>
              <div class="weekly-strip" aria-label="选择日期">${['一','二','三','四','五','六','日'].map((day,i)=>`<button class="day" data-day="${i}" aria-label="${i<3?'9 月 '+(28+i):'10 月 '+(i-2)} 日，周${day}" aria-pressed="${i===1}"><span class="weekday">${day}</span><strong>${i<3?28+i:i-2}</strong><span class="day-dot"></span></button>`).join('')}</div>
            </section>
          </div>
          <div class="lower-grid">
            <section class="panel tasks-panel" id="plans" aria-labelledby="plans-title"><div class="section-title between"><div><h2 id="plans-title">今日计划</h2><div class="eyebrow" id="plans-subtitle">A LITTLE PROGRESS, EVERY DAY</div></div><button class="text-button" id="add-task">${icon('plus')}添加计划</button></div><div id="task-list"></div></section>
            <section class="panel trend-panel" id="stats" aria-labelledby="stats-title"><div class="section-title between"><h2 id="stats-title">专注足迹</h2><div class="trend-tabs" aria-label="趋势周期"><button data-period="week" aria-pressed="true">本周</button><button data-period="month" aria-pressed="false">本月</button></div></div><div class="between"><div class="trend-total"><strong class="numeric" id="trend-number">12.5</strong><span>小时</span></div><span class="trend-caption" id="trend-caption">比上周 +18%</span></div><div class="chart" role="img" aria-label="本周每日专注小时：1.5、2.25、1、2.5、1.75、2、1.5"></div><div class="chart-labels"></div></section>
          </div>
          <section class="panel companion" id="people" aria-label="陪伴摘要"><div class="row">${icon('people')}<div><p>各自努力，也彼此陪伴。</p><div class="muted">图书馆小队 · 示例：3 位伙伴正在专注</div></div></div><div class="avatars" aria-hidden="true"><span class="avatar">林</span><span class="avatar">小</span><span class="avatar">木</span></div><button class="quiet-button" id="companion-detail">看看伙伴</button></section>
          <footer class="app-footer"><span>INNOCENCE <span style="opacity:.5;padding:0 7px">/</span> 留一点时间，成为自己。</span><div class="palette">${glass?'<button class="motion-toggle" id="motion-toggle" aria-pressed="true">背景流动 · 暂停</button>':'<span>主题色</span>'}${(glass?[]:[['柑橘','#ed762c'],['鸢紫','#8c7ab9'],['松绿','#438878']]).map(([name,color],i)=>`<button class="swatch" style="--swatch:${color}" data-color="${color}" aria-label="${name}主题色" title="${name}" aria-pressed="${i===0}"></button>`).join('')}</div></footer>
        </main>
      </div>
      <section class="orb-view panel" hidden aria-label="专注球预览"><div class="eyebrow muted" style="margin-bottom:30px">FOCUS ORB</div>${dial}<p>把空间还给桌面。<br>把注意力留给当下。</p><div class="row" style="justify-content:center"><button class="primary timer-toggle">${icon('play')}<span>开始专注</span></button><button class="quiet-button" id="restore-canvas">返回画布</button></div></section>
      <footer class="design-footer"><span>${glass?'01 / FROSTED GLASS · 流动光场 / 中性磨砂 / 透光叠层':'02 / CITRUS WHITE · 暖白留白 / 局部磨砂 / 柑橘细节'}</span><span>独立视觉原型 · 数据仅在本页演示，刷新后重置</span></footer>
    </div>
    <dialog class="sheet" id="task-dialog" aria-labelledby="task-dialog-title"><form id="task-form"><header class="between"><h2 id="task-dialog-title">留下一件想做的事</h2><button class="close-button" type="button" data-close aria-label="关闭">${icon('close')}</button></header><label for="task-input">计划名称</label><input id="task-input" name="task" placeholder="例如：整理今天的学习笔记" required maxlength="60" autocomplete="off"><label for="task-time">预计时间</label><input id="task-time" type="time" value="16:00" required><p>这是参考页中的交互演示，计划不会写入实际账号。</p><footer><button class="quiet-button" type="button" data-close>取消</button><button class="primary" type="submit">添加计划</button></footer></form></dialog>
    <dialog class="sheet" id="companion-dialog" aria-labelledby="companion-title"><header class="between"><h2 id="companion-title">图书馆小队</h2><button class="close-button" data-close aria-label="关闭">${icon('close')}</button></header><p>演示伙伴 · 一起拥有安静的下午</p><div class="task"><span class="avatar">林</span><div><h3>林间</h3><span class="task-meta">阅读 · 已专注 18 分钟</span></div><span class="task-category">专注中</span></div><div class="task"><span class="avatar">小</span><div><h3>小满</h3><span class="task-meta">英语 · 已专注 32 分钟</span></div><span class="task-category">专注中</span></div><div class="task"><span class="avatar">木</span><div><h3>木木</h3><span class="task-meta">写作 · 已专注 12 分钟</span></div><span class="task-category">专注中</span></div></dialog>
    <div class="toast" role="status" aria-live="polite"></div>`;

  if(glass){
    const toggle=document.getElementById('motion-toggle');
    const preference=window.matchMedia('(prefers-reduced-motion: reduce)');
    let motion=!preference.matches;
    function syncMotion(){
      document.body.dataset.motion=motion?'running':'paused';
      toggle.setAttribute('aria-pressed',String(motion));
      toggle.disabled=preference.matches;
      toggle.textContent=preference.matches?'背景静止 · 跟随系统':motion?'背景流动 · 暂停':'背景静止 · 播放';
    }
    toggle.addEventListener('click',()=>{motion=!motion;syncMotion();});
    preference.addEventListener('change',()=>{motion=!preference.matches;syncMotion();});
    syncMotion();
  }

  let selectedDay = 1;
  const dayTasks = {
    0:[{title:'整理一周学习安排',time:'09:00',category:'计划',done:true},{title:'英语听力练习',time:'15:00',category:'学习',done:true}],
    1:[{title:'晨间阅读 20 分钟',time:'08:30',category:'阅读',done:true},{title:'完成英语单词复习',time:'10:00',category:'学习',done:true},{title:'阅读《设计心理学》',time:'14:00',category:'阅读',done:false},{title:'整理今天的灵感笔记',time:'16:00',category:'记录',done:false}],
    2:[{title:'把阅读笔记整理成卡片',time:'09:30',category:'记录',done:false},{title:'练习英语口语',time:'15:00',category:'学习',done:false}],
    3:[],4:[],5:[],6:[]
  };
  const list = document.getElementById('task-list');
  function renderTasks(){
    list.replaceChildren();
    const tasks = dayTasks[selectedDay];
    if(!tasks.length){const empty=document.createElement('p');empty.className='task-empty';empty.textContent='给这一天留白，或添加一个小计划。';list.append(empty);}
    tasks.forEach((task,i)=>{
      const row=document.createElement('div');row.className='task';
      const checkbox=document.createElement('input');checkbox.type='checkbox';checkbox.className='task-check';checkbox.id=`task-${selectedDay}-${i}`;checkbox.checked=task.done;
      const copy=document.createElement('div');
      const title=document.createElement('label');title.className='task-title';title.htmlFor=checkbox.id;title.textContent=task.title;
      const meta=document.createElement('span');meta.className='task-meta';meta.textContent=task.time+' · '+(task.done?'已完成':'待开始');copy.append(title,meta);
      const category=document.createElement('span');category.className='task-category';category.textContent=task.category;
      checkbox.addEventListener('change',()=>{task.done=checkbox.checked;renderTasks();document.getElementById(checkbox.id).focus();});
      row.append(checkbox,copy,category);list.append(row);
    });
    const today=dayTasks[1],done=today.filter(t=>t.done).length;
    document.getElementById('completion-number').textContent=done+' / '+today.length;
    const percentage=today.length?Math.round(done/today.length*100):0;
    const progress=document.querySelector('.summary-progress');progress.setAttribute('aria-valuenow',String(percentage));progress.firstElementChild.style.width=percentage+'%';
    document.getElementById('plans-title').textContent=selectedDay===1?'今日计划':(selectedDay<3?'9 月 '+(28+selectedDay):'10 月 '+(selectedDay-2))+' 日计划';
  }
  renderTasks();
  document.querySelectorAll('.day').forEach(button=>button.addEventListener('click',()=>{selectedDay=Number(button.dataset.day);document.querySelectorAll('.day').forEach(b=>b.setAttribute('aria-pressed',String(b===button)));renderTasks();}));
  let toastTimeout;
  function toast(message){const el=document.querySelector('.toast');el.textContent=message;clearTimeout(toastTimeout);toastTimeout=setTimeout(()=>el.textContent='',3000);}
  const taskDialog=document.getElementById('task-dialog');
  document.getElementById('add-task').addEventListener('click',()=>taskDialog.showModal());
  document.querySelectorAll('[data-close]').forEach(button=>button.addEventListener('click',()=>button.closest('dialog').close()));
  document.getElementById('companion-detail').addEventListener('click',()=>document.getElementById('companion-dialog').showModal());
  document.getElementById('task-form').addEventListener('submit',event=>{
    event.preventDefault();const input=document.getElementById('task-input'),title=input.value.trim();
    if(!title){input.setCustomValidity('请输入计划名称');input.reportValidity();return;}
    dayTasks[selectedDay].push({title,time:document.getElementById('task-time').value,category:'计划',done:false});
    renderTasks();taskDialog.close();event.target.reset();toast('已添加到当前日期的演示计划');
  });
  document.getElementById('task-input').addEventListener('input',event=>event.target.setCustomValidity(''));
  let duration=25*60,remaining=duration,running=false,deadline=0,completed=false;
  function syncTimer(){
    if(running){remaining=Math.max(0,Math.ceil((deadline-Date.now())/1000));if(!remaining){running=false;completed=true;toast('这一段专注完成了，休息一下吧。');}}
    const text=String(Math.floor(remaining/60)).padStart(2,'0')+':'+String(remaining%60).padStart(2,'0');
    document.querySelectorAll('.timer').forEach(el=>el.textContent=text);
    document.querySelectorAll('.dial-progress').forEach(el=>el.style.strokeDashoffset=String(314.16*(1-remaining/duration)));
    document.querySelectorAll('.timer-toggle').forEach(el=>el.innerHTML=icon(running?'pause':'play')+'<span>'+(running?'暂停专注':completed?'再来一段':remaining<duration?'继续专注':'开始专注')+'</span>');
    document.getElementById('focus-status').textContent=running?'专注进行中':completed?'本段已完成':remaining<duration?'已暂停':'准备开始';
    document.querySelector('.duration-select').disabled=running;
  }
  document.querySelectorAll('.timer-toggle').forEach(button=>button.addEventListener('click',()=>{if(running){syncTimer();running=false;}else{if(completed){remaining=duration;completed=false;}deadline=Date.now()+remaining*1000;running=true;}syncTimer();}));
  document.querySelector('.reset-timer').addEventListener('click',()=>{running=false;completed=false;remaining=duration;syncTimer();});
  document.querySelector('.duration-select').addEventListener('change',event=>{duration=Number(event.target.value)*60;remaining=duration;completed=false;syncTimer();});
  setInterval(()=>{if(running)syncTimer();},250);syncTimer();
  const stage=document.querySelector('.stage');
  function resize(size){stage.dataset.size=size;document.querySelector('.orb-view').hidden=size!=='orb';document.querySelectorAll('[data-size]').forEach(button=>{if(button.tagName==='BUTTON')button.setAttribute('aria-pressed',String(button.dataset.size===size));});}
  document.querySelectorAll('button[data-size]').forEach(button=>button.addEventListener('click',()=>resize(button.dataset.size)));
  document.getElementById('restore-canvas').addEventListener('click',()=>resize('large'));
  document.querySelectorAll('.swatch').forEach(button=>button.addEventListener('click',()=>{
    const color=button.dataset.color,rgb=color.match(/[a-f0-9]{2}/gi).map(c=>parseInt(c,16)).join(',');
    document.body.style.setProperty('--accent',color);document.body.style.setProperty('--accent-rgb',rgb);
    document.querySelectorAll('.swatch').forEach(b=>b.setAttribute('aria-pressed',String(b===button)));
  }));
  function renderChart(period){
    const month=period==='month',values=month?[5.5,8,6.25,9.5,7,12.5,4.75]:[1.5,2.25,1,2.5,1.75,2,1.5],labels=month?['1–4','5–8','9–12','13–16','17–20','21–24','25–29']:['一','二','三','四','五','六','日'];
    const chart=document.querySelector('.chart');chart.innerHTML=values.map((v,i)=>`<div class="chart-column ${i===(month?5:1)?'selected':''}" data-value="${v} h" title="${labels[i]}：${v} 小时"><div class="bar" style="--height:${v/Math.max(...values)*100}%"></div></div>`).join('');
    chart.setAttribute('aria-label',(month?'本月分段':'本周每日')+'专注小时：'+values.join('、'));
    document.querySelector('.chart-labels').innerHTML=labels.map(v=>`<span>${v}</span>`).join('');
    document.getElementById('trend-number').textContent=month?'53.5':'12.5';document.getElementById('trend-caption').textContent=month?'比上月 +12%':'比上周 +18%';
  }
  document.querySelectorAll('[data-period]').forEach(button=>button.addEventListener('click',()=>{renderChart(button.dataset.period);document.querySelectorAll('[data-period]').forEach(b=>b.setAttribute('aria-pressed',String(b===button)));}));renderChart('week');
  document.querySelectorAll('.nav-link').forEach(link=>link.addEventListener('click',()=>{document.querySelectorAll('.nav-link').forEach(a=>a.classList.toggle('active',a===link));}));
})();
