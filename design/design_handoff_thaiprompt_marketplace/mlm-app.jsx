// MLM App
function MLMApp({initial='dash'}={}){
  const [screen, setScreen] = React.useState(initial);
  const go = (s)=>setScreen(s);
  const V = {dash:MLMDash, tree:MLMTree, earnings:MLMEarnings, invite:MLMInvite, leaderboard:MLMLeaderboard, training:MLMTraining, rank:MLMRank, withdraw:MLMWithdraw}[screen] || MLMDash;
  return (
    <div style={{display:'flex',flexDirection:'column',minHeight:'100%',background:'linear-gradient(180deg,#1a0f2e,#2A1F3D)',color:'#fff'}}>
      <div style={{flex:1,minHeight:0}}><V go={go}/></div>
      <MLMNav screen={screen} go={go}/>
    </div>
  );
}

function MLMNav({screen, go}){
  const items = [
    {id:'dash',l:'แดชบอร์ด',icon:'dash'},
    {id:'tree',l:'ทีม',icon:'tree'},
    {id:'earnings',l:'รายได้',icon:'earnings'},
    {id:'invite',l:'ชวน',icon:'invite'},
  ];
  return <window.AppTabBar items={items} screen={screen} go={go} accent="#FFC94D" accentText="#0E0B1F" onDark/>;
}

function MLMHeader({title,sub,go,back}){
  return (
    <div style={{padding:'14px 16px',display:'flex',alignItems:'center',gap:10}}>
      {back && <button onClick={()=>go(back)} style={{width:34,height:34,borderRadius:12,border:0,background:'rgba(255,255,255,.1)',color:'#fff',fontWeight:900,cursor:'pointer',fontFamily:'inherit'}}>←</button>}
      <div style={{flex:1}}>
        {sub && <div className="mono" style={{fontSize:9,letterSpacing:'.18em',opacity:.6}}>{sub}</div>}
        <div style={{fontWeight:900,fontSize:16}}>{title}</div>
      </div>
    </div>
  );
}

function MLMDash({go}){
  return (
    <div>
      <div style={{padding:'18px 16px 0'}}>
        <div className="mono" style={{fontSize:10,letterSpacing:'.2em',opacity:.6}}>THAIPROMPT NETWORK</div>
        <div style={{fontWeight:900,fontSize:22}}>สวัสดี, <span style={{color:'#FFC94D'}}>พี่น้อย</span> ✨</div>
      </div>

      <div style={{padding:'14px 16px 0'}}>
        <div onClick={()=>go('rank')} style={{padding:16,borderRadius:22,background:'linear-gradient(135deg,#FFC94D,#FF3E6C,#6B4BFF)',color:'#fff',cursor:'pointer',position:'relative',overflow:'hidden'}}>
          <div style={{position:'absolute',top:-30,right:-30,width:120,height:120,borderRadius:'50%',background:'rgba(255,255,255,.15)'}}/>
          <div style={{display:'flex',alignItems:'center',gap:10,position:'relative'}}>
            <div style={{width:54,height:54,borderRadius:18,background:'#2A1F3D',color:'#FFC94D',display:'flex',alignItems:'center',justifyContent:'center',fontSize:26,fontWeight:900,boxShadow:'var(--clay-sm)'}}>◈</div>
            <div style={{flex:1}}>
              <div className="mono" style={{fontSize:10,opacity:.85,letterSpacing:'.15em'}}>RANK · SILVER</div>
              <div style={{fontWeight:900,fontSize:18}}>เงินสดใส 💎</div>
              <div style={{fontSize:11,opacity:.9}}>อีก 3 คน เพื่อขึ้น GOLD</div>
            </div>
          </div>
          <div style={{marginTop:12,position:'relative'}}>
            <div style={{height:8,borderRadius:999,background:'rgba(255,255,255,.25)',overflow:'hidden'}}>
              <div style={{width:'70%',height:'100%',background:'#fff',borderRadius:999}}/>
            </div>
            <div style={{display:'flex',justifyContent:'space-between',fontSize:10,fontWeight:700,marginTop:4}}>
              <span>7 / 10 สมาชิก</span>
              <span>ดูรายละเอียด →</span>
            </div>
          </div>
        </div>
      </div>

      <div style={{padding:'14px 16px 0',display:'grid',gridTemplateColumns:'1fr 1fr',gap:10}}>
        <div onClick={()=>go('earnings')} style={{padding:14,borderRadius:18,background:'rgba(255,201,77,.15)',border:'1.5px solid rgba(255,201,77,.3)',cursor:'pointer'}}>
          <div className="mono" style={{fontSize:9,letterSpacing:'.15em',opacity:.7}}>รายได้เดือนนี้</div>
          <div className="display" style={{fontSize:24,color:'#FFC94D'}}>฿12,450</div>
          <div style={{fontSize:10,opacity:.8,marginTop:2}}>↑ 18% vs เดือนก่อน</div>
        </div>
        <div onClick={()=>go('tree')} style={{padding:14,borderRadius:18,background:'rgba(107,75,255,.15)',border:'1.5px solid rgba(107,75,255,.3)',cursor:'pointer'}}>
          <div className="mono" style={{fontSize:9,letterSpacing:'.15em',opacity:.7}}>ทีมรวม</div>
          <div className="display" style={{fontSize:24,color:'#C9B8FF'}}>48 คน</div>
          <div style={{fontSize:10,opacity:.8,marginTop:2}}>3 ชั้น · Active 32</div>
        </div>
      </div>

      <H th="ด่วน · ต้องทำ" en="Quick actions"/>
      <div style={{padding:'0 16px',display:'grid',gridTemplateColumns:'repeat(4,1fr)',gap:8}}>
        {[{i:'↗',l:'ชวน',s:'invite',c:'#FFC94D'},{i:'◈',l:'ทีม',s:'tree',c:'#6B4BFF'},{i:'🏆',l:'ลีดเดอร์',s:'leaderboard',c:'#FF3E6C'},{i:'🎓',l:'อบรม',s:'training',c:'#00D4B4'}].map(a=>(
          <div key={a.l} onClick={()=>go(a.s)} style={{padding:'12px 6px',borderRadius:16,background:'rgba(255,255,255,.06)',textAlign:'center',cursor:'pointer'}}>
            <div style={{width:38,height:38,borderRadius:12,background:a.c,margin:'0 auto',display:'flex',alignItems:'center',justifyContent:'center',color:'#2A1F3D',fontWeight:900,fontSize:16,boxShadow:'var(--clay-sm)'}}>{a.i}</div>
            <div style={{fontSize:10,fontWeight:700,marginTop:6}}>{a.l}</div>
          </div>
        ))}
      </div>

      <H th="กิจกรรมทีม" en="Team activity"/>
      <div style={{padding:'0 16px 20px',display:'flex',flexDirection:'column',gap:8}}>
        {[{n:'นิดา ขนมไทย',a:'ขายได้ ฿1,280 · คุณได้ ฿64',t:'5 นาที',c:'#FF3E6C'},{n:'สมชาย ช่างไม้',a:'ชวน 2 คนใหม่เข้าทีม',t:'1 ชม.',c:'#FFC94D'},{n:'พี่แตง ครัวบ้านไทย',a:'เลื่อนขั้นเป็น BRONZE',t:'เช้า',c:'#00D4B4'}].map((a,i)=>(
          <div key={i} style={{padding:'10px 12px',borderRadius:14,background:'rgba(255,255,255,.06)',display:'flex',alignItems:'center',gap:10}}>
            <div style={{width:36,height:36,borderRadius:12,background:a.c,color:'#2A1F3D',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900}}>{a.n[0]}</div>
            <div style={{flex:1,minWidth:0}}>
              <div style={{fontWeight:800,fontSize:12}}>{a.n}</div>
              <div style={{fontSize:10,opacity:.8}}>{a.a}</div>
            </div>
            <div className="mono" style={{fontSize:9,opacity:.6}}>{a.t}</div>
          </div>
        ))}
      </div>
    </div>
  );
}

function MLMTree({go}){
  return (
    <div>
      <MLMHeader title="โครงสร้างทีม" sub="TEAM TREE" go={go}/>
      <div style={{padding:'0 16px'}}>
        <div style={{display:'flex',gap:6,fontSize:10}}>
          {['ทั้งหมด (48)','Active (32)','Pending (16)'].map((t,i)=>(
            <span key={t} style={{padding:'6px 12px',borderRadius:999,background:i===0?'#FFC94D':'rgba(255,255,255,.08)',color:i===0?'#2A1F3D':'#fff',fontWeight:700}}>{t}</span>
          ))}
        </div>
      </div>

      <div style={{padding:'14px 16px'}}>
        <div style={{display:'flex',justifyContent:'center',marginBottom:16}}>
          <div style={{padding:'12px 16px',borderRadius:18,background:'linear-gradient(135deg,#FFC94D,#FF3E6C)',color:'#2A1F3D',textAlign:'center',boxShadow:'var(--clay-md)'}}>
            <div className="mono" style={{fontSize:9,letterSpacing:'.15em'}}>YOU · SILVER</div>
            <div style={{fontWeight:900,fontSize:15}}>พี่น้อย</div>
          </div>
        </div>

        {[{n:'นิดา ขนมไทย',r:'BRONZE',d:12,s:'฿3,200'},{n:'สมชาย ช่างไม้',r:'BRONZE',d:8,s:'฿2,100'},{n:'พี่แตง ครัวบ้าน',r:'BRONZE',d:15,s:'฿4,800'}].map((m,i)=>(
          <div key={i} style={{marginBottom:12}}>
            <div style={{display:'flex',alignItems:'center',gap:10,padding:12,borderRadius:16,background:'rgba(255,201,77,.1)',border:'1px solid rgba(255,201,77,.2)'}}>
              <div style={{width:40,height:40,borderRadius:12,background:'#FFC94D',color:'#2A1F3D',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900}}>{m.n[0]}</div>
              <div style={{flex:1,minWidth:0}}>
                <div style={{fontWeight:800,fontSize:13}}>{m.n}</div>
                <div className="mono" style={{fontSize:10,opacity:.7}}>{m.r} · {m.d} คน · {m.s}</div>
              </div>
              <span style={{fontSize:18,opacity:.5}}>▾</span>
            </div>
            {i===0 && (
              <div style={{marginLeft:24,marginTop:8,paddingLeft:12,borderLeft:'2px dashed rgba(255,255,255,.15)'}}>
                {['ป้าจี๊ด','น้องฟ้า','ลุงโต'].map((sub,j)=>(
                  <div key={j} style={{padding:'8px 10px',marginTop:j?6:0,borderRadius:12,background:'rgba(255,255,255,.05)',display:'flex',alignItems:'center',gap:8}}>
                    <div style={{width:28,height:28,borderRadius:9,background:'#FF3E6C',color:'#fff',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900,fontSize:11}}>{sub[0]}</div>
                    <div style={{flex:1,fontSize:11,fontWeight:700}}>{sub}</div>
                    <div className="mono" style={{fontSize:9,opacity:.6}}>L3</div>
                  </div>
                ))}
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}

function MLMEarnings({go}){
  return (
    <div>
      <MLMHeader title="รายได้ของฉัน" sub="EARNINGS" go={go}/>
      <div style={{padding:'0 16px'}}>
        <div style={{padding:16,borderRadius:20,background:'linear-gradient(135deg,#6B4BFF,#FF3E6C)',color:'#fff'}}>
          <div className="mono" style={{fontSize:10,opacity:.8,letterSpacing:'.15em'}}>รายได้สะสมรวม</div>
          <div className="display" style={{fontSize:36}}>฿148,200</div>
          <div style={{display:'flex',gap:6,marginTop:8}}>
            <button onClick={()=>go('withdraw')} className="btn" style={{background:'#FFC94D',color:'#2A1F3D',padding:'8px 14px',fontSize:12}}>ถอนเงิน</button>
            <button className="btn ghost" style={{padding:'8px 14px',fontSize:12,color:'#fff',borderColor:'rgba(255,255,255,.3)'}}>ประวัติ</button>
          </div>
        </div>
      </div>

      <div style={{padding:'14px 16px',display:'grid',gridTemplateColumns:'repeat(2,1fr)',gap:10}}>
        {[{l:'Direct (L1)',v:'฿5,200',p:'7 คน',c:'#FFC94D'},{l:'Level 2',v:'฿3,800',p:'18 คน',c:'#FF3E6C'},{l:'Level 3',v:'฿2,150',p:'23 คน',c:'#00D4B4'},{l:'Bonus',v:'฿1,300',p:'Rank up',c:'#6B4BFF'}].map(e=>(
          <div key={e.l} style={{padding:12,borderRadius:16,background:'rgba(255,255,255,.06)'}}>
            <div className="mono" style={{fontSize:9,letterSpacing:'.15em',opacity:.6}}>{e.l.toUpperCase()}</div>
            <div className="display" style={{fontSize:20,color:e.c}}>{e.v}</div>
            <div style={{fontSize:10,opacity:.7}}>{e.p}</div>
          </div>
        ))}
      </div>

      <H th="รายการรายได้" en="Commission log"/>
      <div style={{padding:'0 16px 20px',display:'flex',flexDirection:'column',gap:8}}>
        {[{n:'นิดา · ข้าวซอย',v:64,l:'L1 · 5%'},{n:'ป้าจี๊ด · ขนมเปี๊ยะ',v:28,l:'L2 · 2%'},{n:'สมชาย · ไม้แกะสลัก',v:150,l:'L1 · 5%'},{n:'น้องฟ้า · น้ำพริก',v:12,l:'L3 · 1%'}].map((c,i)=>(
          <div key={i} style={{padding:'10px 12px',borderRadius:14,background:'rgba(255,255,255,.06)',display:'flex',alignItems:'center',gap:10}}>
            <div style={{width:32,height:32,borderRadius:10,background:'#FFC94D',color:'#2A1F3D',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900,fontSize:13}}>฿</div>
            <div style={{flex:1,minWidth:0}}>
              <div style={{fontWeight:700,fontSize:12}}>{c.n}</div>
              <div className="mono" style={{fontSize:10,opacity:.6}}>{c.l}</div>
            </div>
            <div className="display" style={{fontSize:15,color:'#00D4B4'}}>+฿{c.v}</div>
          </div>
        ))}
      </div>
    </div>
  );
}

function MLMInvite({go}){
  return (
    <div>
      <MLMHeader title="ชวนเพื่อนเข้าทีม" sub="INVITE" go={go}/>
      <div style={{padding:'0 16px'}}>
        <div style={{padding:18,borderRadius:20,background:'linear-gradient(135deg,#FFC94D,#FF7A3A)',color:'#2A1F3D',textAlign:'center'}}>
          <div className="mono" style={{fontSize:10,letterSpacing:'.2em'}}>YOUR INVITE CODE</div>
          <div className="display" style={{fontSize:32,letterSpacing:'.1em'}}>NOI-288</div>
          <div style={{width:140,height:140,margin:'12px auto 8px',background:'#2A1F3D',borderRadius:18,display:'grid',gridTemplateColumns:'repeat(8,1fr)',gridTemplateRows:'repeat(8,1fr)',padding:10,gap:1}}>
            {Array.from({length:64}).map((_,i)=>(
              <div key={i} style={{background:[0,2,3,7,8,10,15,17,20,22,26,29,31,35,38,40,43,48,50,53,56,59,62].includes(i)?'#FFC94D':'transparent'}}/>
            ))}
          </div>
          <div style={{fontSize:11,fontWeight:700}}>สแกน หรือบอกรหัส</div>
        </div>
      </div>

      <H th="แชร์ผ่าน" en="Share via"/>
      <div style={{padding:'0 16px',display:'grid',gridTemplateColumns:'repeat(4,1fr)',gap:8}}>
        {[{i:'L',l:'LINE',c:'#06C755'},{i:'◉',l:'เฟซ',c:'#1877F2'},{i:'▶',l:'IG',c:'#E4405F'},{i:'⎘',l:'คัดลอก',c:'#6B4BFF'}].map(s=>(
          <div key={s.l} style={{padding:'12px 6px',borderRadius:16,background:'rgba(255,255,255,.06)',textAlign:'center'}}>
            <div style={{width:40,height:40,borderRadius:12,background:s.c,color:'#fff',margin:'0 auto',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900,fontSize:16,boxShadow:'var(--clay-sm)'}}>{s.i}</div>
            <div style={{fontSize:10,fontWeight:700,marginTop:6}}>{s.l}</div>
          </div>
        ))}
      </div>

      <H th="สิทธิประโยชน์" en="Rewards"/>
      <div style={{padding:'0 16px 20px',display:'flex',flexDirection:'column',gap:8}}>
        {[{t:'ชวน 1 คน',d:'รับโบนัส ฿50 ทันที',c:'#FFC94D'},{t:'ชวน 5 คน',d:'ปลดล็อกอัตรา 6%',c:'#FF3E6C'},{t:'ชวน 10 คน',d:'เลื่อนขั้นเป็น GOLD',c:'#6B4BFF'}].map((r,i)=>(
          <div key={i} style={{padding:'12px',borderRadius:14,background:'rgba(255,255,255,.06)',display:'flex',alignItems:'center',gap:10}}>
            <div style={{width:32,height:32,borderRadius:10,background:r.c,color:'#2A1F3D',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900}}>🎁</div>
            <div style={{flex:1}}>
              <div style={{fontWeight:800,fontSize:13}}>{r.t}</div>
              <div style={{fontSize:11,opacity:.8}}>{r.d}</div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function MLMLeaderboard({go}){
  const lb = [{n:'พี่แตง',p:28400,r:1},{n:'ลุงโต',p:19200,r:2},{n:'คุณน้อย (คุณ)',p:12450,r:3,me:true},{n:'นิดา',p:9800,r:4},{n:'สมชาย',p:7600,r:5}];
  return (
    <div>
      <MLMHeader title="ลีดเดอร์บอร์ด" sub="LEADERBOARD · THIS MONTH" go={go}/>
      <div style={{padding:'0 16px',display:'flex',justifyContent:'center',gap:8,alignItems:'flex-end',marginTop:10}}>
        {[{p:2,c:'#C9B8FF',h:80},{p:1,c:'#FFC94D',h:110},{p:3,c:'#FF3E6C',h:60}].map(pd=>{
          const u = lb.find(x=>x.r===pd.p);
          return (
            <div key={pd.p} style={{textAlign:'center',flex:1,maxWidth:90}}>
              <div style={{width:48,height:48,borderRadius:16,background:pd.c,color:'#2A1F3D',margin:'0 auto',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900,fontSize:18,boxShadow:'var(--clay-sm)'}}>{u.n[0]}</div>
              <div style={{fontWeight:800,fontSize:11,marginTop:6}}>{u.n}</div>
              <div className="mono" style={{fontSize:9,opacity:.7}}>฿{u.p.toLocaleString()}</div>
              <div style={{height:pd.h,marginTop:6,borderRadius:'14px 14px 0 0',background:`linear-gradient(180deg,${pd.c},transparent)`,display:'flex',alignItems:'flex-start',justifyContent:'center',paddingTop:8,fontWeight:900,fontSize:20,color:'#2A1F3D'}}>{pd.p}</div>
            </div>
          );
        })}
      </div>

      <div style={{padding:'14px 16px 20px',display:'flex',flexDirection:'column',gap:6}}>
        {lb.map(u=>(
          <div key={u.r} style={{padding:'10px 12px',borderRadius:14,background:u.me?'rgba(255,201,77,.18)':'rgba(255,255,255,.06)',border:u.me?'1.5px solid rgba(255,201,77,.4)':'none',display:'flex',alignItems:'center',gap:10}}>
            <div className="mono" style={{width:24,textAlign:'center',fontWeight:900,fontSize:13,color:u.r<=3?'#FFC94D':'#8A7FA3'}}>#{u.r}</div>
            <div style={{width:34,height:34,borderRadius:11,background:'#6B4BFF',color:'#fff',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900}}>{u.n[0]}</div>
            <div style={{flex:1,fontWeight:700,fontSize:12}}>{u.n}</div>
            <div className="display" style={{fontSize:14,color:'#FFC94D'}}>฿{u.p.toLocaleString()}</div>
          </div>
        ))}
      </div>
    </div>
  );
}

function MLMTraining({go}){
  return (
    <div>
      <MLMHeader title="ห้องเรียน" sub="TRAINING" go={go}/>
      <div style={{padding:'0 16px',display:'flex',flexDirection:'column',gap:10}}>
        {[{t:'เริ่มต้นขาย 101',d:'8 บท · 42 นาที',p:100,c:'#00D4B4'},{t:'สร้างทีมให้ยั่งยืน',d:'5 บท · 28 นาที',p:60,c:'#FFC94D'},{t:'กลยุทธ์ LINE & Facebook',d:'6 บท · 35 นาที',p:20,c:'#FF3E6C'},{t:'จัดการเงินสำหรับผู้ขาย',d:'4 บท · 22 นาที',p:0,c:'#6B4BFF'}].map((c,i)=>(
          <div key={i} style={{padding:12,borderRadius:18,background:'rgba(255,255,255,.06)',display:'flex',gap:12}}>
            <div style={{width:72,height:80,borderRadius:14,background:`linear-gradient(160deg,${c.c},#2A1F3D)`,display:'flex',alignItems:'center',justifyContent:'center',fontSize:28,color:'#fff'}}>▶</div>
            <div style={{flex:1}}>
              <div style={{fontWeight:800,fontSize:13}}>{c.t}</div>
              <div className="mono" style={{fontSize:10,opacity:.6,marginTop:2}}>{c.d}</div>
              <div style={{marginTop:10,height:6,borderRadius:999,background:'rgba(255,255,255,.1)',overflow:'hidden'}}>
                <div style={{width:`${c.p}%`,height:'100%',background:c.c}}/>
              </div>
              <div style={{fontSize:10,marginTop:3,opacity:.7}}>{c.p===100?'✓ จบแล้ว':`ก้าวหน้า ${c.p}%`}</div>
            </div>
          </div>
        ))}
      </div>

      <H th="เวิร์กชอปสด" en="Live workshops"/>
      <div style={{padding:'0 16px 20px'}}>
        <div style={{padding:14,borderRadius:18,background:'linear-gradient(135deg,#FF3E6C,#FFC94D)',color:'#2A1F3D'}}>
          <div className="mono" style={{fontSize:10,letterSpacing:'.15em',opacity:.75}}>LIVE · ศุกร์นี้ 20:00</div>
          <div style={{fontWeight:900,fontSize:16}}>สร้างแบรนด์จากที่บ้าน</div>
          <div style={{fontSize:11,fontWeight:700}}>โดย พี่นาย · ผู้ก่อตั้ง Thaiprompt</div>
          <button className="btn" style={{marginTop:10,background:'#2A1F3D',color:'#FFC94D',padding:'8px 14px',fontSize:12}}>จองที่นั่ง</button>
        </div>
      </div>
    </div>
  );
}

function MLMRank({go}){
  const ranks = [{n:'SEED',c:'#6B4BFF'},{n:'BRONZE',c:'#FF7A3A'},{n:'SILVER',c:'#C9B8FF',cur:true},{n:'GOLD',c:'#FFC94D'},{n:'DIAMOND',c:'#00D4B4'},{n:'LEGEND',c:'#FF3E6C'}];
  return (
    <div>
      <MLMHeader title="เส้นทางการเลื่อนขั้น" sub="RANK JOURNEY" go={go} back="dash"/>
      <div style={{padding:'0 16px 20px'}}>
        <div style={{position:'relative',paddingLeft:26}}>
          <div style={{position:'absolute',left:14,top:12,bottom:12,width:3,background:'linear-gradient(180deg,#00D4B4,#FFC94D,#FF3E6C,rgba(255,255,255,.1))',borderRadius:999}}/>
          {ranks.map((r,i)=>(
            <div key={r.n} style={{display:'flex',gap:12,padding:'10px 0',alignItems:'flex-start'}}>
              <div style={{position:'absolute',left:0,width:28,height:28,borderRadius:10,background:r.c,color:'#2A1F3D',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900,fontSize:11,border:r.cur?'3px solid #fff':'none',boxShadow:r.cur?'0 0 0 4px rgba(255,201,77,.3)':'none'}}>{i+1}</div>
              <div style={{flex:1,padding:12,borderRadius:14,background:r.cur?'rgba(255,201,77,.18)':'rgba(255,255,255,.05)',border:r.cur?'1.5px solid rgba(255,201,77,.4)':'none',marginLeft:12}}>
                <div style={{fontWeight:900,fontSize:14,color:r.c}}>{r.n} {r.cur && '← คุณอยู่นี่'}</div>
                <div style={{fontSize:11,opacity:.8,marginTop:2}}>{i===0?'เริ่มต้น · ค่าคอม 3%':i===1?'3 สมาชิก · 4%':i===2?'7 สมาชิก · 5%':i===3?'10 สมาชิก · 6% + โบนัสเดือน':i===4?'25 สมาชิก · 7% + รถ':'50 สมาชิก · 10% + ทริป'}</div>
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

function MLMWithdraw({go}){
  return (
    <div>
      <MLMHeader title="ถอนเงิน" sub="WITHDRAW" go={go} back="earnings"/>
      <div style={{padding:'0 16px',display:'flex',flexDirection:'column',gap:12}}>
        <div style={{padding:14,borderRadius:18,background:'rgba(255,201,77,.12)',border:'1.5px solid rgba(255,201,77,.3)'}}>
          <div className="mono" style={{fontSize:10,letterSpacing:'.15em',opacity:.7}}>ยอดที่ถอนได้</div>
          <div className="display" style={{fontSize:30,color:'#FFC94D'}}>฿12,450</div>
        </div>

        <div style={{padding:14,borderRadius:18,background:'rgba(255,255,255,.06)'}}>
          <div style={{fontWeight:800,fontSize:12,marginBottom:8}}>จำนวนเงินที่ต้องการถอน</div>
          <div style={{padding:'14px 12px',borderRadius:12,background:'#2A1F3D',border:'1.5px solid rgba(255,201,77,.3)',display:'flex',alignItems:'center',gap:8}}>
            <span className="display" style={{fontSize:22,color:'#FFC94D'}}>฿</span>
            <input defaultValue="5,000" style={{background:'transparent',border:0,color:'#fff',fontFamily:'Prompt',fontSize:22,fontWeight:700,flex:1,outline:'none'}}/>
          </div>
          <div style={{display:'flex',gap:6,marginTop:8}}>
            {['ทั้งหมด','฿5,000','฿2,000','฿500'].map(q=><span key={q} style={{padding:'4px 10px',borderRadius:999,background:'rgba(255,255,255,.08)',fontSize:10,fontWeight:700}}>{q}</span>)}
          </div>
        </div>

        <div style={{padding:14,borderRadius:18,background:'rgba(255,255,255,.06)'}}>
          <div style={{fontWeight:800,fontSize:12,marginBottom:8}}>โอนเข้า</div>
          <div style={{display:'flex',alignItems:'center',gap:10,padding:10,borderRadius:12,background:'#6B4BFF'}}>
            <div style={{width:36,height:36,borderRadius:10,background:'#fff',color:'#6B4BFF',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900}}>K</div>
            <div style={{flex:1}}>
              <div style={{fontWeight:800,fontSize:13}}>กสิกรไทย · xxx-x-x4821</div>
              <div style={{fontSize:10,opacity:.8}}>คุณน้อย ณัฐภรณ์</div>
            </div>
            <span style={{fontSize:18}}>✓</span>
          </div>
        </div>

        <div style={{padding:'10px 14px',borderRadius:12,background:'rgba(255,255,255,.04)',fontSize:11,opacity:.8}}>
          ค่าธรรมเนียม ฿10 · เข้าบัญชีภายใน 1 วันทำการ
        </div>

        <button className="btn" style={{background:'linear-gradient(135deg,#FFC94D,#FF7A3A)',color:'#2A1F3D',padding:'14px',fontSize:14}}>ยืนยันถอน ฿5,000</button>
      </div>
    </div>
  );
}

Object.assign(window, {MLMApp});
