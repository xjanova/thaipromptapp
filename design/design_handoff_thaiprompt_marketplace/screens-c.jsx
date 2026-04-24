// Thaiprompt — Screens part 3: Profile, MLM, Seller Dashboard, Rider

function Profile(){
  return (
    <div style={{background:'#FFF8EE',minHeight:'100%',position:'relative'}}>
      <div style={{
        height:200,background:'linear-gradient(160deg,#6B4BFF,#FF3E6C 70%,#FFC94D)',
        position:'relative',overflow:'hidden',
      }}>
        <div className="dots" style={{position:'absolute',inset:0,opacity:.4}}/>
        <div style={{position:'absolute',top:14,left:14,right:14,display:'flex',justifyContent:'space-between'}}>
          <div style={{width:38,height:38,borderRadius:14,background:'rgba(255,255,255,.9)',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:700,boxShadow:'var(--clay-sm)'}}>←</div>
          <div style={{width:38,height:38,borderRadius:14,background:'rgba(255,255,255,.9)',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:700,boxShadow:'var(--clay-sm)'}}>⚙</div>
        </div>
      </div>
      <div style={{padding:'0 16px',marginTop:-50,position:'relative'}}>
        <div className="chunk" style={{padding:16,background:'#fff',display:'flex',gap:12,alignItems:'flex-end'}}>
          <div style={{
            width:84,height:84,borderRadius:28,
            background:'radial-gradient(circle at 32% 28%,#FFC99C,#FF3E6C,#8A0030)',
            boxShadow:'inset 0 -6px 10px rgba(0,0,0,.3), inset 0 4px 6px rgba(255,255,255,.5), 0 10px 20px -6px rgba(255,62,108,.5)',
            marginTop:-40,flexShrink:0,display:'flex',alignItems:'center',justifyContent:'center',
            color:'#fff',fontFamily:'Space Grotesk',fontWeight:900,fontSize:32,
          }}>ส</div>
          <div style={{flex:1,minWidth:0}}>
            <div className="mono" style={{fontSize:10,color:'#8A7FA3',letterSpacing:'.15em'}}>@SOMPORN · LV 12</div>
            <div style={{fontWeight:900,fontSize:18}}>สมพร จันทร์เพ็ญ</div>
            <div style={{fontSize:11,color:'#4B3E66',marginTop:2}}>🥈 Silver Affiliate · สมาชิกตั้งแต่ 2024</div>
          </div>
        </div>
      </div>

      <div style={{padding:'14px 16px 0',display:'grid',gridTemplateColumns:'repeat(3,1fr)',gap:8}}>
        {[{l:'ออเดอร์',v:'84'},{l:'ดาวน์ไลน์',v:'27'},{l:'คะแนน',v:'4.9'}].map((s,i)=>(
          <div key={i} className="chunk" style={{padding:'10px 8px',textAlign:'center',background:['#FFE3EB','#DFFAF3','#FFF0C7'][i]}}>
            <div className="display" style={{fontSize:20}}>{s.v}</div>
            <div className="mono" style={{fontSize:10,color:'#4B3E66'}}>{s.l}</div>
          </div>
        ))}
      </div>

      <H th="เมนูของฉัน" en="My menu"/>
      <div style={{padding:'0 16px 100px',display:'flex',flexDirection:'column',gap:8}}>
        {[
          {i:'📦',l:'ออเดอร์ของฉัน',r:'3 กำลังส่ง',c:'#FF7A3A'},
          {i:'🏪',l:'ร้านของฉัน',r:'จัดการร้าน',c:'#FFC94D'},
          {i:'🛵',l:'โหมดไรเดอร์',r:'เปิดใช้งาน',c:'#6B4BFF'},
          {i:'🌳',l:'MLM Network',r:'฿12,480 รายได้',c:'#00D4B4'},
          {i:'📍',l:'ที่อยู่จัดส่ง',r:'3 ที่อยู่',c:'#5EC9FF'},
          {i:'🎫',l:'คูปองของฉัน',r:'5 ใบ',c:'#FF3E6C'},
          {i:'?',l:'ช่วยเหลือ',r:'24/7'},
        ].map((m,i)=>(
          <div key={i} className="chunk" style={{padding:'12px 14px',display:'flex',alignItems:'center',gap:12,background:'#fff'}}>
            <div style={{width:40,height:40,borderRadius:14,background:m.c||'#EADDFB',display:'flex',alignItems:'center',justifyContent:'center',fontSize:18,boxShadow:'var(--clay-sm)'}}>{m.i}</div>
            <div style={{flex:1}}><div style={{fontWeight:700,fontSize:13}}>{m.l}</div></div>
            <div className="mono" style={{fontSize:10,color:'#8A7FA3'}}>{m.r}</div>
            <span style={{color:'#8A7FA3'}}>›</span>
          </div>
        ))}
      </div>
    </div>
  );
}

function MLM(){
  return (
    <div style={{background:'#FFF8EE',minHeight:'100%'}}>
      <div style={{
        padding:'16px 16px 40px',color:'#fff',position:'relative',overflow:'hidden',
        background:'linear-gradient(160deg,#2A1F3D,#6B4BFF 80%)',
      }}>
        <div className="mono" style={{fontSize:10,letterSpacing:'.18em',opacity:.7}}>MLM · เครือข่ายของฉัน</div>
        <h1 className="display" style={{fontSize:24,margin:'4px 0 12px'}}>ต้นไม้เครือข่าย</h1>

        {/* Network tree visualization */}
        <svg viewBox="0 0 320 150" style={{width:'100%',height:150}}>
          <defs>
            <radialGradient id="nodeG"><stop offset="0" stopColor="#FFF3C7"/><stop offset=".5" stopColor="#FFC94D"/><stop offset="1" stopColor="#7A5200"/></radialGradient>
            <radialGradient id="nodeM"><stop offset="0" stopColor="#E3FFF8"/><stop offset=".5" stopColor="#00D4B4"/><stop offset="1" stopColor="#006B5A"/></radialGradient>
            <radialGradient id="nodeP"><stop offset="0" stopColor="#FFDCE6"/><stop offset=".5" stopColor="#FF3E6C"/><stop offset="1" stopColor="#8A0030"/></radialGradient>
          </defs>
          {/* lines */}
          <g stroke="rgba(255,255,255,.4)" strokeWidth="2" fill="none">
            <path d="M160 40 Q100 60 60 110"/><path d="M160 40 Q160 60 160 110"/><path d="M160 40 Q220 60 260 110"/>
          </g>
          {/* root (me) */}
          <circle cx="160" cy="40" r="22" fill="url(#nodeG)" stroke="#FFF" strokeWidth="2"/>
          <text x="160" y="45" textAnchor="middle" fontWeight="900" fontSize="14" fill="#2A1F3D">ฉัน</text>
          {/* downlines */}
          {[{x:60,c:'M',l:'ฝน'},{x:160,c:'P',l:'ตุ๊ก'},{x:260,c:'M',l:'เนตร'}].map((n,i)=>(
            <g key={i}>
              <circle cx={n.x} cy="110" r="18" fill={`url(#node${n.c})`} stroke="#FFF" strokeWidth="2"/>
              <text x={n.x} y="114" textAnchor="middle" fontWeight="800" fontSize="11" fill="#fff">{n.l}</text>
            </g>
          ))}
        </svg>
      </div>

      <div style={{padding:'0 16px',marginTop:-24,position:'relative'}}>
        <div className="chunk" style={{padding:14,background:'#fff',display:'grid',gridTemplateColumns:'1fr 1fr 1fr',gap:8}}>
          {[{l:'Level 1',v:'3',c:'#FF3E6C'},{l:'Level 2',v:'12',c:'#00D4B4'},{l:'Level 3',v:'42',c:'#FFC94D'}].map((s,i)=>(
            <div key={i} style={{textAlign:'center',padding:'6px 4px',borderRadius:14,background:s.c+'22'}}>
              <div className="display" style={{fontSize:20,color:s.c}}>{s.v}</div>
              <div className="mono" style={{fontSize:9,color:'#4B3E66'}}>{s.l}</div>
            </div>
          ))}
        </div>
      </div>

      <H th="รายได้เครือข่าย" en="Network income"/>
      <div style={{padding:'0 16px'}}>
        <div className="chunk" style={{padding:16,background:'linear-gradient(140deg,#00D4B4,#6B4BFF)',color:'#fff'}}>
          <div className="mono" style={{fontSize:10,opacity:.8}}>TOTAL EARNED · APR</div>
          <div className="display" style={{fontSize:32,margin:'4px 0'}}>฿12,480</div>
          <div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:8,marginTop:8}}>
            <div style={{background:'rgba(0,0,0,.2)',borderRadius:10,padding:8}}>
              <div style={{fontSize:10,opacity:.8}}>Direct (Lv1) · 15%</div>
              <div className="display" style={{fontSize:16}}>฿6,200</div>
            </div>
            <div style={{background:'rgba(0,0,0,.2)',borderRadius:10,padding:8}}>
              <div style={{fontSize:10,opacity:.8}}>Passive (Lv2-5)</div>
              <div className="display" style={{fontSize:16}}>฿6,280</div>
            </div>
          </div>
        </div>
      </div>

      <H th="ทีมของฉัน" en="My downlines"/>
      <div style={{padding:'0 16px 100px',display:'flex',flexDirection:'column',gap:8}}>
        {[
          {n:'ฝน สุดา',lv:1,e:2800,t:'🥇',c:'#FFC94D'},
          {n:'ตุ๊ก มานะ',lv:1,e:2100,t:'🥈',c:'#FF3E6C'},
          {n:'เนตร วิชัย',lv:1,e:1300,t:'🥉',c:'#00D4B4'},
          {n:'พลอย กมล',lv:2,e:820,t:'—',c:'#6B4BFF'},
        ].map((d,i)=>(
          <div key={i} className="chunk" style={{padding:'10px 12px',display:'flex',alignItems:'center',gap:10,background:'#fff'}}>
            <div style={{width:38,height:38,borderRadius:12,background:d.c,color:'#fff',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900,boxShadow:'var(--clay-sm)'}}>{d.n[0]}</div>
            <div style={{flex:1}}>
              <div style={{fontWeight:700,fontSize:13}}>{d.n} <span style={{fontSize:12}}>{d.t}</span></div>
              <div className="mono" style={{fontSize:10,color:'#8A7FA3'}}>Level {d.lv} · 18 orders this month</div>
            </div>
            <div className="display" style={{fontSize:15,color:'#00D4B4'}}>+฿{d.e}</div>
          </div>
        ))}
      </div>
    </div>
  );
}

function SellerDash(){
  const hours = [12,28,45,38,52,62,48,35];
  return (
    <div style={{background:'#FFF8EE',minHeight:'100%'}}>
      <div style={{padding:'14px 16px',background:'linear-gradient(160deg,#FFC94D,#FF7A3A)',color:'#2A1F3D',position:'relative'}}>
        <div className="mono" style={{fontSize:10,letterSpacing:'.15em',opacity:.8}}>SELLER · ร้านค้า</div>
        <div style={{display:'flex',alignItems:'center',gap:10,marginTop:4}}>
          <div style={{width:42,height:42,borderRadius:14,background:'#fff',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900,boxShadow:'var(--clay-sm)'}}>ป</div>
          <div style={{flex:1}}>
            <div style={{fontWeight:900,fontSize:16}}>ครัวยายปราณี</div>
            <div style={{fontSize:11}}>● เปิดร้านอยู่ · 4.9★</div>
          </div>
          <div style={{width:40,height:22,borderRadius:999,background:'#00D4B4',position:'relative',boxShadow:'var(--clay-sm)'}}>
            <div style={{position:'absolute',top:2,right:2,width:18,height:18,borderRadius:'50%',background:'#fff'}}/>
          </div>
        </div>
      </div>

      <div style={{padding:'14px 16px 0',display:'grid',gridTemplateColumns:'1fr 1fr',gap:10}}>
        <div className="chunk" style={{padding:12,background:'#fff'}}>
          <div className="mono" style={{fontSize:9,color:'#8A7FA3',letterSpacing:'.15em'}}>ยอดขายวันนี้</div>
          <div className="display" style={{fontSize:22,color:'#2A1F3D'}}>฿3,820</div>
          <div style={{fontSize:11,color:'#00D4B4',fontWeight:700}}>↑ 18% vs เมื่อวาน</div>
        </div>
        <div className="chunk" style={{padding:12,background:'#2A1F3D',color:'#fff'}}>
          <div className="mono" style={{fontSize:9,opacity:.7,letterSpacing:'.15em'}}>รอจัดส่ง</div>
          <div className="display" style={{fontSize:22}}>7</div>
          <div style={{fontSize:11,color:'#FFC94D',fontWeight:700}}>⚡ 2 ด่วน</div>
        </div>
      </div>

      <div style={{padding:'10px 16px 0'}}>
        <div className="chunk" style={{padding:14,background:'#fff'}}>
          <div style={{display:'flex',justifyContent:'space-between',alignItems:'baseline'}}>
            <div style={{fontWeight:800,fontSize:13}}>ยอดขาย 8 ชม.ล่าสุด</div>
            <div className="mono" style={{fontSize:10,color:'#8A7FA3'}}>฿/hr</div>
          </div>
          <div style={{display:'flex',alignItems:'flex-end',gap:5,height:70,marginTop:10}}>
            {hours.map((v,i)=>(
              <div key={i} style={{flex:1,height:`${v}%`,
                borderRadius:8,
                background:i===5?'linear-gradient(180deg,#FF3E6C,#8A0030)':'linear-gradient(180deg,#FFC94D,#7A5200)',
                boxShadow:'inset 0 -3px 4px rgba(0,0,0,.2), inset 0 2px 2px rgba(255,255,255,.4)',
              }}/>
            ))}
          </div>
        </div>
      </div>

      <H th="ออเดอร์เข้ามา" en="Active orders"/>
      <div style={{padding:'0 16px',display:'flex',flexDirection:'column',gap:8}}>
        {[
          {id:'#TP-2041',n:'ข้าวซอยไก่ x2, ไข่ต้ม',s:'ใหม่!',c:'#FF3E6C',t:'1 นาทีที่แล้ว',p:170},
          {id:'#TP-2040',n:'แกงเหลือง x1, ผัดไทย x1',s:'กำลังทำ',c:'#FFC94D',t:'8 นาที',p:175},
          {id:'#TP-2039',n:'ขนมจีน x3',s:'รอไรเดอร์',c:'#6B4BFF',t:'12 นาที',p:210},
        ].map((o,i)=>(
          <div key={i} className="chunk" style={{padding:12,background:'#fff'}}>
            <div style={{display:'flex',alignItems:'center',gap:8}}>
              <div className="mono" style={{fontSize:11,fontWeight:700}}>{o.id}</div>
              <div style={{flex:1}}/>
              <div className="chip" style={{background:o.c,color:'#fff',fontSize:10,padding:'3px 8px'}}>{o.s}</div>
            </div>
            <div style={{fontWeight:700,fontSize:13,margin:'6px 0 2px'}}>{o.n}</div>
            <div style={{display:'flex',justifyContent:'space-between',alignItems:'baseline',marginTop:6}}>
              <span className="mono" style={{fontSize:10,color:'#8A7FA3'}}>{o.t}</span>
              <span className="display" style={{fontSize:16}}>฿{o.p}</span>
            </div>
            {i===0 && (
              <div style={{display:'flex',gap:6,marginTop:10}}>
                <button className="btn pink" style={{flex:1,padding:'8px',fontSize:12}}>รับออเดอร์</button>
                <button className="btn ghost" style={{padding:'8px 10px',fontSize:12}}>ปฏิเสธ</button>
              </div>
            )}
          </div>
        ))}
      </div>

      <H th="จัดการสินค้า" en="Products"/>
      <div style={{padding:'0 16px 100px',display:'grid',gridTemplateColumns:'1fr 1fr',gap:10}}>
        {[
          {n:'ข้าวซอยไก่',p:85,st:42,hue:'tomato',on:true},
          {n:'แกงเหลือง',p:85,st:18,hue:'mango',on:true},
          {n:'ผัดไทย',p:90,st:0,hue:'pink',on:false},
          {n:'+ เพิ่มสินค้า',add:true},
        ].map((p,i)=>(
          p.add ? (
            <div key={i} className="chunk" style={{
              padding:20,display:'flex',alignItems:'center',justifyContent:'center',
              background:'#FFF0C7',minHeight:140,flexDirection:'column',gap:6,
            }}>
              <div style={{fontSize:24}}>＋</div>
              <div style={{fontWeight:700,fontSize:12}}>เพิ่มสินค้า</div>
            </div>
          ) : (
            <div key={i} className="chunk" style={{padding:0,overflow:'hidden',background:'#fff'}}>
              <div style={{height:70,background:i%2?'#DFFAF3':'#FFE3EB',display:'flex',alignItems:'center',justifyContent:'center',position:'relative'}}>
                <Puff w={60} h={42} hue={p.hue}/>
                {!p.on && <div style={{position:'absolute',inset:0,background:'rgba(42,31,61,.6)',display:'flex',alignItems:'center',justifyContent:'center',color:'#fff',fontWeight:800,fontSize:11}}>หมด</div>}
              </div>
              <div style={{padding:'8px 10px'}}>
                <div style={{fontWeight:700,fontSize:12}}>{p.n}</div>
                <div style={{display:'flex',justifyContent:'space-between',alignItems:'baseline',marginTop:2}}>
                  <span className="display" style={{fontSize:13}}>฿{p.p}</span>
                  <span className="mono" style={{fontSize:10,color:'#8A7FA3'}}>เหลือ {p.st}</span>
                </div>
              </div>
            </div>
          )
        ))}
      </div>
    </div>
  );
}

function Rider(){
  return (
    <div style={{background:'#2A1F3D',minHeight:'100%',color:'#fff',position:'relative'}}>
      {/* map */}
      <div style={{height:200,background:'linear-gradient(180deg,#4B3E66,#2A1F3D)',position:'relative',overflow:'hidden'}}>
        <div className="dots" style={{position:'absolute',inset:0,opacity:.3}}/>
        <svg viewBox="0 0 360 200" style={{position:'absolute',inset:0,width:'100%',height:'100%'}}>
          <path d="M-10 150 Q 100 80 200 120 T 380 60" stroke="rgba(255,201,77,.8)" strokeWidth="3" strokeDasharray="6 4" fill="none"/>
          {[{x:60,c:'#FF3E6C',l:'A'},{x:200,c:'#FFC94D',l:'B'},{x:320,c:'#00D4B4',l:'C'}].map((p,i)=>(
            <g key={i}>
              <circle cx={p.x} cy={i===0?150:i===1?120:60} r="14" fill={p.c} stroke="#fff" strokeWidth="3"/>
              <text x={p.x} y={(i===0?150:i===1?120:60)+4} textAnchor="middle" fontWeight="900" fontSize="12" fill="#2A1F3D">{p.l}</text>
            </g>
          ))}
        </svg>
        <div style={{position:'absolute',top:14,left:14,right:14,display:'flex',justifyContent:'space-between'}}>
          <div style={{padding:'6px 12px',borderRadius:14,background:'rgba(0,0,0,.4)',backdropFilter:'blur(8px)',fontSize:11,fontWeight:700,display:'flex',alignItems:'center',gap:6}}>
            <span style={{width:8,height:8,borderRadius:'50%',background:'#00D4B4',animation:'pulse-ring 1.4s infinite'}}/> ออนไลน์
          </div>
          <div className="mono" style={{padding:'6px 12px',borderRadius:14,background:'rgba(0,0,0,.4)',backdropFilter:'blur(8px)',fontSize:11,fontWeight:700}}>
            9.8 km · ฿180
          </div>
        </div>
      </div>

      {/* stats */}
      <div style={{padding:'14px 16px 0',display:'grid',gridTemplateColumns:'repeat(3,1fr)',gap:8}}>
        {[{l:'วันนี้',v:'฿840',c:'#FFC94D'},{l:'เที่ยว',v:'14',c:'#FF3E6C'},{l:'ชั่วโมง',v:'6.5h',c:'#00D4B4'}].map((s,i)=>(
          <div key={i} style={{padding:'10px 8px',borderRadius:14,background:'rgba(255,255,255,.08)',textAlign:'center',boxShadow:'inset 0 1px 2px rgba(255,255,255,.1)'}}>
            <div className="display" style={{fontSize:18,color:s.c}}>{s.v}</div>
            <div className="mono" style={{fontSize:9,opacity:.7}}>{s.l}</div>
          </div>
        ))}
      </div>

      {/* current job */}
      <div style={{padding:'14px 16px 0'}}>
        <div className="chunk" style={{padding:14,background:'linear-gradient(140deg,#FFC94D,#FF7A3A)',color:'#2A1F3D'}}>
          <div style={{display:'flex',alignItems:'center',gap:8}}>
            <div className="mono" style={{fontSize:10,letterSpacing:'.15em',opacity:.7,flex:1}}>JOB #TP-2041 · เร่งด่วน</div>
            <div style={{fontWeight:900,fontSize:14}}>⏱ 8:32</div>
          </div>
          <div style={{display:'flex',flexDirection:'column',gap:8,marginTop:10,position:'relative'}}>
            {[{l:'รับของที่ ครัวยายปราณี',a:'สุขุมวิท 24',c:'#FF3E6C',done:true},
              {l:'ส่งที่ คุณสมพร',a:'สุขุมวิท 36 · 1.2km',c:'#00D4B4'}].map((s,i)=>(
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
            <button className="btn pink" style={{padding:'10px 14px',fontSize:13}}>✓ ส่งสำเร็จ</button>
          </div>
        </div>
      </div>

      {/* Incoming jobs */}
      <div style={{padding:'14px 16px 0',fontWeight:800,fontSize:13,display:'flex',justifyContent:'space-between',alignItems:'center'}}>
        <span>คิวงานถัดไป</span>
        <span className="mono" style={{fontSize:10,opacity:.6}}>3 ใกล้คุณ</span>
      </div>
      <div style={{padding:'8px 16px 100px',display:'flex',flexDirection:'column',gap:8}}>
        {[
          {d:'0.8km',t:'ครัวยายปราณี → สุขุมวิท 40',p:85,m:12},
          {d:'1.4km',t:'น้องฟ้า ขนมไทย → อโศก',p:70,m:18},
          {d:'2.1km',t:'ลุงโต ก๋วยเตี๋ยว → เพลินจิต',p:95,m:24},
        ].map((j,i)=>(
          <div key={i} style={{
            padding:12,borderRadius:18,background:'rgba(255,255,255,.08)',
            boxShadow:'inset 0 1px 2px rgba(255,255,255,.1), 0 6px 12px rgba(0,0,0,.2)',
            display:'flex',alignItems:'center',gap:10,
          }}>
            <div style={{width:46,height:46,borderRadius:14,background:'linear-gradient(160deg,#6B4BFF,#2A1F3D)',display:'flex',flexDirection:'column',alignItems:'center',justifyContent:'center',color:'#fff',boxShadow:'var(--clay-sm)'}}>
              <div style={{fontWeight:900,fontSize:12,lineHeight:1}}>{j.d}</div>
              <div style={{fontSize:8,opacity:.7}}>距離</div>
            </div>
            <div style={{flex:1,minWidth:0}}>
              <div style={{fontWeight:700,fontSize:12}}>{j.t}</div>
              <div className="mono" style={{fontSize:10,opacity:.6}}>~{j.m} นาที</div>
            </div>
            <div style={{textAlign:'right'}}>
              <div className="display" style={{fontSize:16,color:'#FFC94D'}}>฿{j.p}</div>
              <button style={{
                marginTop:4,border:0,padding:'5px 10px',borderRadius:999,
                background:'#00D4B4',color:'#2A1F3D',fontWeight:800,fontSize:11,cursor:'pointer',boxShadow:'var(--clay-sm)',fontFamily:'inherit',
              }}>รับ</button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

Object.assign(window, {Profile, MLM, SellerDash, Rider});
