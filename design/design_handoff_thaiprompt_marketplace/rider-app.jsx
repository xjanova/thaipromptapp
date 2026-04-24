// Rider App
function RiderApp({initial='dash'}={}){
  const [screen, setScreen] = React.useState(initial);
  const [jobId, setJobId] = React.useState('TP-2041');
  const go = (s,o={})=>{ if(o.jobId) setJobId(o.jobId); setScreen(s); };
  const V = {dash:RiderDash, jobs:RiderJobs, jobDetail:RiderJobDetail,
    pickup:RiderPickup, deliver:RiderDeliver, earnings:RiderEarnings, profile:RiderProfile}[screen] || RiderDash;
  return (
    <div style={{display:'flex',flexDirection:'column',minHeight:'100%',background:'#2A1F3D',color:'#fff'}}>
      <div style={{flex:1,minHeight:0}}><V go={go} jobId={jobId}/></div>
      <RiderNav screen={screen} go={go}/>
    </div>
  );
}

function RiderNav({screen, go}){
  const items = [
    {id:'dash',l:'งาน',icon:'bike'},
    {id:'jobs',l:'คิว',icon:'jobs',b:3},
    {id:'earnings',l:'รายได้',icon:'earnings'},
    {id:'profile',l:'ฉัน',icon:'profile'},
  ];
  return <window.AppTabBar items={items} screen={screen} go={go} accent="#FFC94D" accentText="#0E0B1F" onDark/>;
}

function RiderDash({go}){
  return (
    <div>
      <div style={{height:200,background:'linear-gradient(180deg,#4B3E66,#2A1F3D)',position:'relative',overflow:'hidden'}}>
        <div className="dots" style={{position:'absolute',inset:0,opacity:.3}}/>
        <svg viewBox="0 0 360 200" style={{position:'absolute',inset:0,width:'100%',height:'100%'}}>
          <path d="M-10 150 Q 100 80 200 120 T 380 60" stroke="rgba(255,201,77,.8)" strokeWidth="3" strokeDasharray="6 4" fill="none"/>
          {[{x:60,y:150,c:'#FF3E6C',l:'A'},{x:200,y:120,c:'#FFC94D',l:'B'},{x:320,y:60,c:'#00D4B4',l:'C'}].map((p,i)=>(
            <g key={i}><circle cx={p.x} cy={p.y} r="14" fill={p.c} stroke="#fff" strokeWidth="3"/><text x={p.x} y={p.y+4} textAnchor="middle" fontWeight="900" fontSize="12" fill="#2A1F3D">{p.l}</text></g>
          ))}
        </svg>
        <div style={{position:'absolute',top:14,left:14,right:14,display:'flex',justifyContent:'space-between'}}>
          <div style={{padding:'6px 12px',borderRadius:14,background:'rgba(0,0,0,.4)',backdropFilter:'blur(8px)',fontSize:11,fontWeight:700,display:'flex',alignItems:'center',gap:6}}>
            <span style={{width:8,height:8,borderRadius:'50%',background:'#00D4B4',animation:'pulse-ring 1.4s infinite'}}/> ออนไลน์
          </div>
          <div className="mono" style={{padding:'6px 12px',borderRadius:14,background:'rgba(0,0,0,.4)',backdropFilter:'blur(8px)',fontSize:11,fontWeight:700}}>9.8 km · ฿180</div>
        </div>
      </div>

      <div style={{padding:'14px 16px 0',display:'grid',gridTemplateColumns:'repeat(3,1fr)',gap:8}}>
        {[{l:'วันนี้',v:'฿840',c:'#FFC94D',s:'earnings'},{l:'เที่ยว',v:'14',c:'#FF3E6C'},{l:'ชม.',v:'6.5h',c:'#00D4B4'}].map(s=>(
          <div key={s.l} onClick={()=>s.s&&go(s.s)} style={{padding:'10px 8px',borderRadius:14,background:'rgba(255,255,255,.08)',textAlign:'center',cursor:s.s?'pointer':'default'}}>
            <div className="display" style={{fontSize:18,color:s.c}}>{s.v}</div>
            <div className="mono" style={{fontSize:9,opacity:.7}}>{s.l}</div>
          </div>
        ))}
      </div>

      <div style={{padding:'14px 16px 0'}}>
        <div className="chunk" style={{padding:14,background:'linear-gradient(140deg,#FFC94D,#FF7A3A)',color:'#2A1F3D',cursor:'pointer'}} onClick={()=>go('jobDetail',{jobId:'TP-2041'})}>
          <div style={{display:'flex',alignItems:'center',gap:8}}>
            <div className="mono" style={{fontSize:10,letterSpacing:'.15em',opacity:.7,flex:1}}>JOB #TP-2041 · เร่งด่วน</div>
            <div style={{fontWeight:900,fontSize:14}}>⏱ 8:32</div>
          </div>
          <div style={{display:'flex',flexDirection:'column',gap:8,marginTop:10}}>
            {[{l:'รับของที่ ครัวยายปราณี',a:'สุขุมวิท 24',c:'#FF3E6C',done:true},{l:'ส่งที่ คุณสมพร',a:'สุขุมวิท 36 · 1.2km',c:'#00D4B4'}].map((s,i)=>(
              <div key={i} style={{display:'flex',gap:10}}>
                <div style={{width:24,height:24,borderRadius:'50%',background:s.c,color:'#fff',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900,fontSize:11,boxShadow:'var(--clay-sm)',flexShrink:0}}>{String.fromCharCode(65+i)}</div>
                <div style={{flex:1}}>
                  <div style={{fontWeight:800,fontSize:12}}>{s.l} {s.done && '✓'}</div>
                  <div className="mono" style={{fontSize:10,opacity:.7}}>{s.a}</div>
                </div>
              </div>
            ))}
          </div>
          <div style={{display:'flex',gap:8,marginTop:12}}>
            <button className="btn" style={{flex:1,background:'#2A1F3D',color:'#FFC94D',fontSize:13,padding:'10px'}}>🧭 นำทาง</button>
            <button onClick={(e)=>{e.stopPropagation();go('deliver');}} className="btn pink" style={{padding:'10px 14px',fontSize:13}}>✓ ส่งสำเร็จ</button>
          </div>
        </div>
      </div>

      <div style={{padding:'14px 16px 0',fontWeight:800,fontSize:13,display:'flex',justifyContent:'space-between',alignItems:'center'}}>
        <span>คิวงานถัดไป</span>
        <button onClick={()=>go('jobs')} style={{border:0,background:'transparent',color:'#FFC94D',fontSize:10,fontWeight:700,cursor:'pointer',fontFamily:'inherit'}}>ดูทั้งหมด →</button>
      </div>
      <div style={{padding:'8px 16px 20px',display:'flex',flexDirection:'column',gap:8}}>
        {[{id:'TP-2042',d:'0.8km',t:'ครัวยายปราณี → สุขุมวิท 40',p:85,m:12},{id:'TP-2043',d:'1.4km',t:'น้องฟ้า → อโศก',p:70,m:18}].map(j=>(
          <div key={j.id} onClick={()=>go('jobDetail',{jobId:j.id})} style={{padding:12,borderRadius:18,background:'rgba(255,255,255,.08)',display:'flex',alignItems:'center',gap:10,cursor:'pointer'}}>
            <div style={{width:46,height:46,borderRadius:14,background:'linear-gradient(160deg,#6B4BFF,#2A1F3D)',display:'flex',flexDirection:'column',alignItems:'center',justifyContent:'center',color:'#fff',boxShadow:'var(--clay-sm)'}}>
              <div style={{fontWeight:900,fontSize:12,lineHeight:1}}>{j.d}</div>
            </div>
            <div style={{flex:1,minWidth:0}}>
              <div style={{fontWeight:700,fontSize:12}}>{j.t}</div>
              <div className="mono" style={{fontSize:10,opacity:.6}}>~{j.m} นาที</div>
            </div>
            <div style={{textAlign:'right'}}>
              <div className="display" style={{fontSize:16,color:'#FFC94D'}}>฿{j.p}</div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function RiderHeader({title,go,back,sub}){
  return (
    <div style={{padding:'14px 16px',display:'flex',alignItems:'center',gap:10,borderBottom:'1px solid rgba(255,255,255,.08)'}}>
      {back && <button onClick={()=>go(back)} style={{width:34,height:34,borderRadius:12,border:0,background:'rgba(255,255,255,.1)',color:'#fff',fontWeight:900,cursor:'pointer',fontFamily:'inherit'}}>←</button>}
      <div style={{flex:1}}>
        {sub && <div className="mono" style={{fontSize:9,letterSpacing:'.18em',opacity:.6}}>{sub}</div>}
        <div style={{fontWeight:900,fontSize:16}}>{title}</div>
      </div>
    </div>
  );
}

function RiderJobs({go}){
  const jobs = [
    {id:'TP-2042',d:'0.8km',t:'ครัวยายปราณี → สุขุมวิท 40',p:85,m:12,tag:'ใกล้'},
    {id:'TP-2043',d:'1.4km',t:'น้องฟ้า ขนมไทย → อโศก',p:70,m:18},
    {id:'TP-2044',d:'2.1km',t:'ลุงโต ก๋วยเตี๋ยว → เพลินจิต',p:95,m:24,tag:'💰'},
    {id:'TP-2045',d:'3.0km',t:'ป้าสม → ทองหล่อ',p:110,m:30},
    {id:'TP-2046',d:'0.5km',t:'ร้านแดง → สีลม',p:60,m:10,tag:'ใกล้'},
  ];
  return (
    <div>
      <RiderHeader title="คิวงานทั้งหมด" sub="JOBS QUEUE" go={go}/>
      <div style={{padding:'10px 16px',display:'flex',gap:6}}>
        {['ทั้งหมด','ใกล้สุด','ราคาสูง'].map((t,i)=>(
          <span key={t} style={{padding:'6px 12px',borderRadius:999,background:i===0?'#FFC94D':'rgba(255,255,255,.08)',color:i===0?'#2A1F3D':'#fff',fontSize:11,fontWeight:700}}>{t}</span>
        ))}
      </div>
      <div style={{padding:'0 16px 20px',display:'flex',flexDirection:'column',gap:8}}>
        {jobs.map(j=>(
          <div key={j.id} onClick={()=>go('jobDetail',{jobId:j.id})} style={{padding:12,borderRadius:18,background:'rgba(255,255,255,.08)',display:'flex',alignItems:'center',gap:10,cursor:'pointer'}}>
            <div style={{width:46,height:46,borderRadius:14,background:'linear-gradient(160deg,#6B4BFF,#2A1F3D)',display:'flex',flexDirection:'column',alignItems:'center',justifyContent:'center',color:'#fff',boxShadow:'var(--clay-sm)'}}>
              <div style={{fontWeight:900,fontSize:12}}>{j.d}</div>
            </div>
            <div style={{flex:1,minWidth:0}}>
              <div style={{fontWeight:700,fontSize:12}}>{j.t}</div>
              <div className="mono" style={{fontSize:10,opacity:.6}}>~{j.m} นาที {j.tag && `· ${j.tag}`}</div>
            </div>
            <div className="display" style={{fontSize:16,color:'#FFC94D'}}>฿{j.p}</div>
          </div>
        ))}
      </div>
    </div>
  );
}

function RiderJobDetail({go,jobId}){
  return (
    <div>
      <RiderHeader title={`#${jobId}`} sub="JOB DETAIL" go={go} back="jobs"/>
      <div style={{padding:'14px 16px'}}>
        <div style={{padding:14,borderRadius:18,background:'linear-gradient(140deg,#FFC94D,#FF7A3A)',color:'#2A1F3D'}}>
          <div className="mono" style={{fontSize:10,letterSpacing:'.15em',opacity:.7}}>รายได้</div>
          <div style={{display:'flex',alignItems:'baseline',gap:8}}>
            <div className="display" style={{fontSize:32}}>฿85</div>
            <div style={{fontSize:11,fontWeight:700}}>+ ทิป ฿10 (ลูกค้า VIP)</div>
          </div>
          <div style={{fontSize:11}}>ระยะทาง 2.1km · เวลาเฉลี่ย 18 นาที</div>
        </div>
      </div>

      <div style={{padding:'0 16px',display:'flex',flexDirection:'column',gap:10}}>
        {[{t:'จุดรับของ · PICKUP',n:'ครัวยายปราณี',a:'ซ.สุขุมวิท 24 เลขที่ 48/12',d:'120m · 2 นาที',c:'#FF3E6C'},
          {t:'จุดส่ง · DROPOFF',n:'คุณสมพร (สมพร จันทร์เพ็ญ)',a:'ซ.สุขุมวิท 40 เลขที่ 224',d:'1.2km · 5 นาที',c:'#00D4B4'}].map((p,i)=>(
          <div key={i} style={{padding:12,borderRadius:18,background:'rgba(255,255,255,.08)'}}>
            <div className="mono" style={{fontSize:9,letterSpacing:'.15em',opacity:.6,color:p.c}}>{p.t}</div>
            <div style={{fontWeight:800,fontSize:14,marginTop:4}}>{p.n}</div>
            <div style={{fontSize:12,opacity:.85}}>{p.a}</div>
            <div className="mono" style={{fontSize:10,opacity:.6,marginTop:4}}>{p.d}</div>
            <div style={{display:'flex',gap:6,marginTop:10}}>
              <button style={{flex:1,border:0,padding:'8px',borderRadius:12,background:'rgba(255,255,255,.12)',color:'#fff',fontSize:11,fontWeight:700,cursor:'pointer',fontFamily:'inherit'}}>📞 โทร</button>
              <button style={{flex:1,border:0,padding:'8px',borderRadius:12,background:'rgba(255,255,255,.12)',color:'#fff',fontSize:11,fontWeight:700,cursor:'pointer',fontFamily:'inherit'}}>🧭 นำทาง</button>
            </div>
          </div>
        ))}
      </div>

      <div style={{padding:'14px 16px 20px',display:'flex',gap:8}}>
        <button onClick={()=>go('jobs')} className="btn ghost" style={{padding:'12px 14px',fontSize:12}}>ปฏิเสธ</button>
        <button onClick={()=>go('pickup')} className="btn" style={{flex:1,background:'#FF7A3A',color:'#fff',padding:'12px',fontSize:14}}>รับงานนี้ · ฿85</button>
      </div>
    </div>
  );
}

function RiderPickup({go}){
  return (
    <div>
      <RiderHeader title="ยืนยันรับของ" sub="PICKUP CONFIRM" go={go} back="jobDetail"/>
      <div style={{padding:'16px',display:'flex',flexDirection:'column',gap:12}}>
        <div style={{padding:14,borderRadius:18,background:'rgba(255,255,255,.08)'}}>
          <div className="mono" style={{fontSize:9,letterSpacing:'.15em',opacity:.6}}>ของที่ต้องรับ</div>
          {[{n:'ข้าวซอยไก่ (กลาง)',q:2},{n:'ไข่ต้ม',q:2}].map((it,i)=>(
            <div key={i} style={{display:'flex',alignItems:'center',gap:10,padding:'8px 0',borderTop:i?'1px dashed rgba(255,255,255,.1)':'none'}}>
              <div style={{width:32,height:32,borderRadius:10,background:'#FF3E6C',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900,color:'#fff'}}>×{it.q}</div>
              <div style={{flex:1,fontWeight:700,fontSize:13}}>{it.n}</div>
              <div style={{width:24,height:24,borderRadius:7,background:'#00D4B4',display:'flex',alignItems:'center',justifyContent:'center',color:'#fff',fontWeight:900,fontSize:13}}>✓</div>
            </div>
          ))}
        </div>

        <div style={{padding:14,borderRadius:18,background:'rgba(255,201,77,.15)',border:'1.5px solid rgba(255,201,77,.3)'}}>
          <div style={{fontWeight:800,fontSize:13}}>📸 ถ่ายรูปของ</div>
          <div style={{fontSize:11,opacity:.8,marginTop:2}}>เพื่อยืนยันว่ารับของครบถ้วน</div>
          <div style={{marginTop:10,aspectRatio:'16/9',borderRadius:14,border:'2px dashed rgba(255,201,77,.5)',display:'flex',alignItems:'center',justifyContent:'center',fontSize:32}}>📷</div>
        </div>

        <button onClick={()=>go('deliver')} className="btn" style={{background:'#FF7A3A',color:'#fff',padding:'14px',fontSize:14}}>ยืนยันรับของ → ไปส่ง</button>
      </div>
    </div>
  );
}

function RiderDeliver({go}){
  return (
    <div>
      <RiderHeader title="ส่งสำเร็จ" sub="DELIVERY CONFIRM" go={go} back="dash"/>
      <div style={{padding:'16px',display:'flex',flexDirection:'column',gap:12}}>
        <div style={{padding:14,borderRadius:18,background:'rgba(0,212,180,.15)',border:'1.5px solid rgba(0,212,180,.3)',textAlign:'center'}}>
          <div style={{width:60,height:60,borderRadius:'50%',background:'#00D4B4',margin:'0 auto',display:'flex',alignItems:'center',justifyContent:'center',color:'#fff',fontSize:30,fontWeight:900,boxShadow:'var(--clay-sm)'}}>✓</div>
          <div style={{fontWeight:900,fontSize:16,marginTop:10}}>ถึงจุดส่งแล้ว</div>
          <div style={{fontSize:11,opacity:.8}}>ยืนยันด้วย OTP หรือถ่ายรูป</div>
        </div>

        <div style={{padding:14,borderRadius:18,background:'rgba(255,255,255,.08)'}}>
          <div className="mono" style={{fontSize:9,letterSpacing:'.15em',opacity:.6,marginBottom:8}}>รหัส OTP จากลูกค้า</div>
          <div style={{display:'flex',gap:6,justifyContent:'center'}}>
            {['4','8','2','—'].map((d,i)=>(
              <div key={i} style={{width:48,height:54,borderRadius:12,background:d==='—'?'rgba(255,255,255,.08)':'#FFC94D',color:d==='—'?'#8A7FA3':'#2A1F3D',display:'flex',alignItems:'center',justifyContent:'center',fontFamily:'JetBrains Mono',fontWeight:900,fontSize:24,boxShadow:d==='—'?'none':'var(--clay-sm)'}}>{d}</div>
            ))}
          </div>
        </div>

        <div style={{padding:14,borderRadius:18,background:'rgba(255,255,255,.08)'}}>
          <div style={{fontWeight:700,fontSize:13}}>📸 ถ่ายรูปตอนส่ง (option)</div>
          <div style={{marginTop:8,aspectRatio:'16/9',borderRadius:12,border:'2px dashed rgba(255,255,255,.2)',display:'flex',alignItems:'center',justifyContent:'center',fontSize:28}}>📷</div>
        </div>

        <button onClick={()=>go('dash')} className="btn" style={{background:'#00D4B4',color:'#2A1F3D',padding:'14px',fontSize:14}}>✓ ยืนยันส่งสำเร็จ · รับ ฿95</button>
      </div>
    </div>
  );
}

function RiderEarnings({go}){
  const week = [180,240,120,320,280,420,380];
  return (
    <div>
      <RiderHeader title="รายได้ของฉัน" sub="EARNINGS" go={go}/>
      <div style={{padding:'14px 16px'}}>
        <div style={{padding:16,borderRadius:20,background:'linear-gradient(135deg,#FF3E6C,#FFC94D)',color:'#2A1F3D'}}>
          <div className="mono" style={{fontSize:10,letterSpacing:'.15em',opacity:.75}}>สัปดาห์นี้</div>
          <div className="display" style={{fontSize:36,lineHeight:1}}>฿1,940</div>
          <div style={{fontSize:11,fontWeight:700,marginTop:4}}>ขึ้น 24% จากสัปดาห์ที่แล้ว</div>
          <div style={{display:'flex',alignItems:'flex-end',gap:5,height:60,marginTop:12}}>
            {week.map((v,i)=>(
              <div key={i} style={{flex:1,height:`${(v/420)*100}%`,borderRadius:6,background:i===5?'#2A1F3D':'rgba(42,31,61,.5)'}}/>
            ))}
          </div>
        </div>
      </div>

      <div style={{padding:'0 16px',display:'grid',gridTemplateColumns:'1fr 1fr',gap:10}}>
        {[{l:'เที่ยวส่ง',v:'24',c:'#00D4B4'},{l:'เฉลี่ย/เที่ยว',v:'฿81',c:'#FFC94D'},{l:'ทิป',v:'฿140',c:'#FF3E6C'},{l:'ชั่วโมง',v:'28h',c:'#6B4BFF'}].map(s=>(
          <div key={s.l} style={{padding:12,borderRadius:16,background:'rgba(255,255,255,.08)'}}>
            <div className="mono" style={{fontSize:9,opacity:.6,letterSpacing:'.15em'}}>{s.l.toUpperCase()}</div>
            <div className="display" style={{fontSize:22,color:s.c}}>{s.v}</div>
          </div>
        ))}
      </div>

      <H th="ประวัติงาน" en="Recent trips"/>
      <div style={{padding:'0 16px 20px',display:'flex',flexDirection:'column',gap:8}}>
        {[{id:'TP-2041',t:'สุขุมวิท 24 → 40',p:95,d:'เมื่อกี้'},{id:'TP-2039',t:'อโศก → ทองหล่อ',p:110,d:'เช้านี้'},{id:'TP-2036',t:'สีลม → สาทร',p:75,d:'เมื่อวาน'}].map(h=>(
          <div key={h.id} style={{padding:'10px 12px',borderRadius:14,background:'rgba(255,255,255,.06)',display:'flex',alignItems:'center',gap:10}}>
            <div style={{width:32,height:32,borderRadius:10,background:'#00D4B4',color:'#2A1F3D',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900}}>✓</div>
            <div style={{flex:1}}>
              <div style={{fontWeight:700,fontSize:12}}>{h.t}</div>
              <div className="mono" style={{fontSize:10,opacity:.6}}>#{h.id} · {h.d}</div>
            </div>
            <div className="display" style={{fontSize:15,color:'#FFC94D'}}>+฿{h.p}</div>
          </div>
        ))}
      </div>
    </div>
  );
}

function RiderProfile({go}){
  return (
    <div>
      <RiderHeader title="โปรไฟล์ไรเดอร์" sub="PROFILE" go={go}/>
      <div style={{padding:'14px 16px'}}>
        <div style={{padding:16,borderRadius:20,background:'linear-gradient(135deg,#6B4BFF,#FF3E6C)',color:'#fff',display:'flex',alignItems:'center',gap:12}}>
          <div style={{width:64,height:64,borderRadius:20,background:'#FFC94D',color:'#2A1F3D',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900,fontSize:28,boxShadow:'var(--clay-sm)'}}>ว</div>
          <div style={{flex:1}}>
            <div className="mono" style={{fontSize:10,opacity:.8,letterSpacing:'.15em'}}>RIDER · LV 8</div>
            <div style={{fontWeight:900,fontSize:18}}>วิชัย แสงดาว</div>
            <div style={{fontSize:11,opacity:.9}}>⭐ 4.8 · 1,240 เที่ยว · Honda Wave กข-1482</div>
          </div>
        </div>
      </div>

      <div style={{padding:'0 16px',display:'grid',gridTemplateColumns:'repeat(4,1fr)',gap:8}}>
        {[{l:'🏆',v:'Gold'},{l:'✓',v:'98%'},{l:'⚡',v:'12m'},{l:'🛡',v:'ยืนยัน'}].map((b,i)=>(
          <div key={i} style={{padding:'10px 6px',borderRadius:14,background:'rgba(255,255,255,.08)',textAlign:'center'}}>
            <div style={{fontSize:18}}>{b.l}</div>
            <div className="mono" style={{fontSize:9,opacity:.7,marginTop:2}}>{b.v}</div>
          </div>
        ))}
      </div>

      <div style={{padding:'14px 16px 20px',display:'flex',flexDirection:'column',gap:8}}>
        {[{i:'🛵',l:'ยานพาหนะ',r:'Honda Wave'},{i:'📄',l:'เอกสาร',r:'ครบ'},{i:'🏥',l:'ประกัน',r:'กำลังใช้งาน'},{i:'🆘',l:'SOS · ฉุกเฉิน',r:''},{i:'⚙',l:'ตั้งค่า',r:''},{i:'↗',l:'ออกจากระบบ',r:''}].map((m,i)=>(
          <div key={i} style={{padding:'12px 14px',borderRadius:14,background:'rgba(255,255,255,.06)',display:'flex',alignItems:'center',gap:10}}>
            <div style={{width:34,height:34,borderRadius:10,background:'rgba(255,201,77,.2)',display:'flex',alignItems:'center',justifyContent:'center',fontSize:15}}>{m.i}</div>
            <div style={{flex:1,fontWeight:700,fontSize:13}}>{m.l}</div>
            <div className="mono" style={{fontSize:10,opacity:.6}}>{m.r}</div>
            <span style={{opacity:.4}}>›</span>
          </div>
        ))}
      </div>
    </div>
  );
}

Object.assign(window, {RiderApp});
