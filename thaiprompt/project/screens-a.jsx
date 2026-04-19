// Thaiprompt — Screens part 1: Onboarding, Home, Explore, Product, Shop

function Onboarding(){
  return (
    <div style={{height:'100%',position:'relative',overflow:'hidden',background:'linear-gradient(170deg,#FFE8F0,#FFF0C7 55%,#DFFAF3)'}}>
      {/* bg dots */}
      <div className="dots" style={{position:'absolute',inset:0,opacity:.6}}/>
      {/* floating 3D blobs */}
      <div style={{position:'absolute',top:30,right:-20}} className="float">
        <Blob3D size={110} hue="pink"/>
      </div>
      <div style={{position:'absolute',top:120,left:-30,animationDelay:'.5s'}} className="float">
        <Blob3D size={80} hue="mango"/>
      </div>
      <div style={{position:'absolute',top:200,right:30}} className="float">
        <Blob3D size={60} hue="mint"/>
      </div>
      <div style={{position:'absolute',top:260,left:40}} className="float">
        <Coin size={56}/>
      </div>
      <div style={{position:'absolute',top:310,right:80}} className="float">
        <Blob3D size={44} hue="purple"/>
      </div>

      {/* Logo */}
      <div style={{position:'absolute',top:60,left:24,display:'flex',alignItems:'center',gap:8}}>
        <div style={{
          width:30,height:30,borderRadius:10,background:'#0E0B1F',
          display:'flex',alignItems:'center',justifyContent:'center',
          color:'#FFC94D',fontFamily:'Space Grotesk',fontWeight:900,fontSize:18,
          border:'0',boxShadow:'0 4px 8px -2px rgba(70,42,92,.2), inset 0 -2px 3px rgba(70,42,92,.12), inset 0 2px 2px rgba(255,255,255,.85)',
        }}>T</div>
        <div>
          <div style={{fontWeight:900,fontSize:14,letterSpacing:'-.02em'}}>Thaiprompt</div>
          <div className="mono" style={{fontSize:9,color:'#6E6A85',letterSpacing:'.1em'}}>ไทยพร๊อม</div>
        </div>
      </div>

      {/* Bottom content */}
      <div style={{position:'absolute',bottom:0,left:0,right:0,padding:'0 20px 30px'}}>
        <div className="chunk grain" style={{padding:22,background:'#FFF8EE',position:'relative',overflow:'hidden'}}>
          <div className="chip" style={{background:'#FFC94D',marginBottom:14}}>
            <span style={{width:6,height:6,borderRadius:'50%',background:'#0E0B1F'}}/>
            ตลาดของชุมชน · v1.0
          </div>
          <h1 className="display" style={{fontSize:30,lineHeight:1.05,margin:'0 0 8px'}}>
            ตลาดนัด<br/>
            <span style={{background:'#FF3E6C',color:'#fff',padding:'0 8px',borderRadius:10,display:'inline-block',transform:'rotate(-2deg)',boxShadow:'0 4px 8px -2px rgba(70,42,92,.2), inset 0 -2px 3px rgba(70,42,92,.12), inset 0 2px 2px rgba(255,255,255,.85)'}}>อยู่ในมือ</span>
          </h1>
          <p style={{margin:'12px 0 18px',color:'#2A2640',fontSize:14,lineHeight:1.5}}>
            ซื้อของจากร้านเพื่อนบ้าน · เติมเงิน PromptPay · แชร์ลิงก์หารายได้จากการแนะนำ
          </p>
          {/* features row */}
          <div style={{display:'grid',gridTemplateColumns:'1fr 1fr 1fr',gap:6,marginBottom:16}}>
            {[
              {l:'Wallet',i:'◈',c:'#00D4B4'},
              {l:'Affiliate',i:'◇',c:'#FFC94D'},
              {l:'ส่งใกล้บ้าน',i:'◉',c:'#FF3E6C'},
            ].map(f=>(
              <div key={f.l} style={{
                border:'0',borderRadius:14,padding:'8px 6px',textAlign:'center',
                background:'#fff',
              }}>
                <div style={{
                  width:26,height:26,margin:'0 auto 4px',borderRadius:8,background:f.c,
                  display:'flex',alignItems:'center',justifyContent:'center',
                  color:'#0E0B1F',fontWeight:900,fontSize:14,border:'0',
                }}>{f.i}</div>
                <div style={{fontSize:10,fontWeight:700}}>{f.l}</div>
              </div>
            ))}
          </div>
          <button className="btn pink" style={{width:'100%',padding:'14px',fontSize:15}}>
            เริ่มใช้เลย · Get started
          </button>
          <div style={{textAlign:'center',marginTop:10,fontSize:12,color:'#6E6A85'}}>
            มีบัญชีแล้ว? <b style={{color:'#0E0B1F'}}>เข้าสู่ระบบ</b>
          </div>
        </div>
      </div>
    </div>
  );
}

function Home(){
  return (
    <div style={{background:'#FFF8EE',minHeight:'100%',position:'relative'}}>
      {/* top bar */}
      <div style={{padding:'12px 16px 0',display:'flex',alignItems:'center',gap:10}}>
        <div style={{
          width:40,height:40,borderRadius:14,background:'#FFC94D',
          display:'flex',alignItems:'center',justifyContent:'center',
          border:'0',boxShadow:'0 4px 8px -2px rgba(70,42,92,.2), inset 0 -2px 3px rgba(70,42,92,.12), inset 0 2px 2px rgba(255,255,255,.85)',
          fontWeight:900,fontFamily:'Space Grotesk',
        }}>ส</div>
        <div style={{flex:1}}>
          <div className="mono" style={{fontSize:10,color:'#6E6A85',letterSpacing:'.1em'}}>BANGKOK · CHATUCHAK</div>
          <div style={{fontWeight:700,fontSize:14}}>สวัสดี, สมพร 👋</div>
        </div>
        <div style={{
          width:40,height:40,borderRadius:12,background:'#fff',
          border:'0',boxShadow:'0 4px 8px -2px rgba(70,42,92,.2), inset 0 -2px 3px rgba(70,42,92,.12), inset 0 2px 2px rgba(255,255,255,.85)',
          display:'flex',alignItems:'center',justifyContent:'center',
          position:'relative',
        }}>
          <span style={{fontSize:16}}>♡</span>
          <span style={{
            position:'absolute',top:-6,right:-6,background:'#FF3E6C',color:'#fff',
            borderRadius:'50%',width:18,height:18,fontSize:10,fontWeight:700,
            display:'flex',alignItems:'center',justifyContent:'center',border:'0',
          }}>3</span>
        </div>
      </div>

      {/* search */}
      <div style={{margin:'14px 16px 0',display:'flex',gap:8}}>
        <div className="chunk" style={{flex:1,display:'flex',alignItems:'center',gap:8,padding:'10px 14px',boxShadow:'0 4px 8px -2px rgba(70,42,92,.2), inset 0 -2px 3px rgba(70,42,92,.12), inset 0 2px 2px rgba(255,255,255,.85)'}}>
          <span style={{fontSize:14}}>⌕</span>
          <input placeholder="ค้นหาของอร่อย ร้านใกล้บ้าน..." style={{
            flex:1,border:0,outline:'none',background:'transparent',
            font:'500 13px "IBM Plex Sans Thai"',color:'#0E0B1F',
          }} readOnly/>
        </div>
        <button className="btn mint" style={{padding:'10px 14px'}}>⊛</button>
      </div>

      {/* Hero card — Today's market */}
      <div style={{padding:'16px'}}>
        <div className="chunk grain" style={{
          background:'linear-gradient(140deg,#FF3E6C,#FF7A3A)',
          color:'#fff',padding:'16px',position:'relative',overflow:'hidden',minHeight:160,
        }}>
          {/* iso stall offset */}
          <div style={{position:'absolute',right:-40,bottom:-20, opacity:.95, transform:'scale(.95)'}}>
            <IsoStall w={240} h={180}/>
          </div>
          <div className="chip" style={{background:'#FFC94D',color:'#0E0B1F',marginBottom:10,borderColor:'#0E0B1F'}}>
            🔥 ตลาดวันนี้
          </div>
          <h2 className="display" style={{fontSize:22,lineHeight:1.05,margin:'0 0 4px'}}>
            ตลาดนัดคลองเตย<br/>เปิดแล้ว!
          </h2>
          <div style={{fontSize:12,opacity:.9, maxWidth:200}}>128 ร้าน · ส่งฟรีในรัศมี 3km</div>
          <button style={{
            marginTop:12,background:'#0E0B1F',color:'#FFC94D',border:'0',
            borderRadius:999,padding:'8px 16px',fontWeight:700,fontSize:12,cursor:'pointer',
            boxShadow:'0 4px 8px -2px rgba(70,42,92,.2), inset 0 -2px 3px rgba(70,42,92,.12), inset 0 2px 2px rgba(255,255,255,.85)', fontFamily:'inherit',
          }}>เข้าตลาด →</button>
        </div>
      </div>

      {/* Wallet + Affiliate mini widgets */}
      <div style={{padding:'0 16px',display:'grid',gridTemplateColumns:'1.3fr 1fr',gap:10}}>
        <div className="chunk" style={{padding:14, background:'#0E0B1F', color:'#fff',position:'relative',overflow:'hidden'}}>
          <div className="mono" style={{fontSize:9,letterSpacing:'.15em',opacity:.7}}>MY WALLET</div>
          <div style={{display:'flex',alignItems:'baseline',gap:4,margin:'4px 0'}}>
            <span className="display" style={{fontSize:22}}>฿2,481</span>
            <span style={{fontSize:11,opacity:.6}}>.50</span>
          </div>
          <div style={{display:'flex',gap:6,marginTop:8}}>
            <button style={{background:'#FFC94D',color:'#0E0B1F',border:0,borderRadius:10,padding:'6px 10px',fontSize:11,fontWeight:700,fontFamily:'inherit',cursor:'pointer'}}>+ เติม</button>
            <button style={{background:'transparent',color:'#fff',border:'1.5px solid #fff',borderRadius:10,padding:'6px 10px',fontSize:11,fontWeight:700,fontFamily:'inherit',cursor:'pointer'}}>ถอน</button>
          </div>
          <div style={{position:'absolute',right:-10,top:-10,opacity:.9}}>
            <Coin size={60}/>
          </div>
        </div>
        <div className="chunk" style={{padding:14, background:'#00D4B4',position:'relative',overflow:'hidden'}}>
          <div className="mono" style={{fontSize:9,letterSpacing:'.15em',color:'#003028'}}>AFFILIATE</div>
          <div className="display" style={{fontSize:20,margin:'4px 0',color:'#0E0B1F'}}>
            +฿420<span style={{fontSize:10,fontWeight:600,opacity:.6}}> /wk</span>
          </div>
          <div style={{fontSize:10,fontWeight:600,color:'#003028'}}>🥈 Silver · 8.5%</div>
          <div style={{position:'absolute',right:-14,bottom:-14,transform:'rotate(-8deg)'}}>
            <Blob3D size={60} hue="purple"/>
          </div>
        </div>
      </div>

      {/* Categories chips marquee */}
      <H th="หมวดหมู่" en="Categories" action="ทั้งหมด"/>
      <div style={{overflow:'hidden',maskImage:'linear-gradient(90deg,transparent,#000 6%,#000 94%,transparent)'}}>
        <div className="marquee" style={{padding:'4px 16px'}}>
          {[...Array(2)].map((_,k)=>(
            <React.Fragment key={k}>
              {[
                {l:'ผัก-ผลไม้',e:'Produce',c:'leaf',i:'🥬'},
                {l:'อาหารสด',e:'Cooked',c:'tomato',i:'🍜'},
                {l:'ขนม',e:'Sweet',c:'mango',i:'🍡'},
                {l:'งานแฮนด์เมด',e:'Craft',c:'purple',i:'🧵'},
                {l:'ของมือสอง',e:'Thrift',c:'pink',i:'♻︎'},
                {l:'ต้นไม้',e:'Plants',c:'mint',i:'🌿'},
              ].map((cat,i)=>(
                <div key={`${k}-${i}`} style={{
                  flexShrink:0,width:108,padding:12,borderRadius:18,
                  border:'0',background:'#fff',
                  boxShadow:'0 4px 8px -2px rgba(70,42,92,.2), inset 0 -2px 3px rgba(70,42,92,.12), inset 0 2px 2px rgba(255,255,255,.85)',
                  display:'flex',flexDirection:'column',alignItems:'center',gap:6,
                }}>
                  <Puff w={68} h={52} hue={cat.c}/>
                  <div style={{fontWeight:700,fontSize:12,marginTop:12}}>{cat.l}</div>
                  <div className="mono" style={{fontSize:9,color:'#6E6A85'}}>{cat.e}</div>
                </div>
              ))}
            </React.Fragment>
          ))}
        </div>
      </div>

      {/* Near you */}
      <H th="ใกล้บ้าน" en="Near you · 2.4km" action="แผนที่"/>
      <div style={{padding:'0 16px',display:'flex',gap:12,overflowX:'auto',paddingBottom:4}} className="phone-scroll">
        {[
          {n:'ป้าสม ผักสด',t:'Produce',d:'120m',r:'4.9',img:'leaf'},
          {n:'ลุงโต ก๋วยเตี๋ยว',t:'Noodles',d:'340m',r:'4.8',img:'tomato'},
          {n:'น้องฟ้า ขนมไทย',t:'Sweets',d:'580m',r:'5.0',img:'mango'},
        ].map((s,i)=>(
          <div key={i} className="chunk" style={{minWidth:180,overflow:'hidden',padding:0}}>
            <div style={{
              height:100,background:`linear-gradient(140deg,#FFE8F0,#FFF0C7)`,
              display:'flex',alignItems:'center',justifyContent:'center',position:'relative',
              borderBottom:'1px solid rgba(70,42,92,.12)',
            }}>
              <Puff w={120} h={80} hue={s.img}/>
              <div style={{position:'absolute',top:8,left:8,background:'#0E0B1F',color:'#FFC94D',borderRadius:8,padding:'2px 6px',fontSize:10,fontWeight:700}}>
                ★ {s.r}
              </div>
            </div>
            <div style={{padding:10}}>
              <div style={{fontWeight:700,fontSize:13}}>{s.n}</div>
              <div className="mono" style={{fontSize:10,color:'#6E6A85'}}>{s.t} · {s.d}</div>
            </div>
          </div>
        ))}
      </div>

      {/* Big seller of the day */}
      <H th="ร้านแนะนำวันนี้" en="Featured shop"/>
      <div style={{padding:'0 16px 20px'}}>
        <div className="chunk" style={{
          padding:14,display:'flex',gap:12,alignItems:'center',
          background:'#FFC94D',
        }}>
          <div style={{
            width:68,height:68,borderRadius:18,border:'0',
            background:'linear-gradient(140deg,#FFE3D6,#FF7A3A)',flexShrink:0,
            display:'flex',alignItems:'center',justifyContent:'center',overflow:'hidden',position:'relative',
          }}>
            <Puff w={58} h={44} hue="tomato"/>
          </div>
          <div style={{flex:1,minWidth:0}}>
            <div style={{fontWeight:800,fontSize:15}}>ครัวยายปราณี</div>
            <div style={{fontSize:11,color:'#2A2640',marginTop:2}}>อาหารใต้ · เปิด 7:00-19:00</div>
            <div style={{display:'flex',gap:6,marginTop:6}}>
              <span className="chip" style={{fontSize:10,padding:'3px 8px',background:'#fff'}}>ส่งฟรี</span>
              <span className="chip" style={{fontSize:10,padding:'3px 8px',background:'#fff'}}>เปิดอยู่</span>
            </div>
          </div>
          <button className="btn" style={{padding:'8px 12px',fontSize:11}}>เข้าร้าน</button>
        </div>
      </div>
    </div>
  );
}

function Product(){
  return (
    <div style={{minHeight:'100%',background:'#FFF8EE',position:'relative'}}>
      {/* hero */}
      <div style={{
        height:320,background:'linear-gradient(160deg,#FF3E6C,#FF7A3A)',
        position:'relative',overflow:'hidden',
        borderBottom:'1px solid rgba(70,42,92,.12)',
      }}>
        {/* nav */}
        <div style={{position:'absolute',top:16,left:16,right:16,display:'flex',justifyContent:'space-between',zIndex:3}}>
          {['←','♡'].map((c,i)=>(
            <div key={i} style={{
              width:40,height:40,borderRadius:12,background:'#FFF8EE',
              border:'0',boxShadow:'0 4px 8px -2px rgba(70,42,92,.2), inset 0 -2px 3px rgba(70,42,92,.12), inset 0 2px 2px rgba(255,255,255,.85)',
              display:'flex',alignItems:'center',justifyContent:'center',fontSize:16,fontWeight:700,
            }}>{c}</div>
          ))}
        </div>
        {/* product puff */}
        <div style={{position:'absolute',top:60,left:'50%',transform:'translateX(-50%)'}} className="float">
          <Puff w={200} h={170} hue="tomato"/>
        </div>
        <FloorShadow w={220} style={{position:'absolute',bottom:20,left:'50%',marginLeft:-110}}/>
        {/* circle label */}
        <div className="spin-slow" style={{
          position:'absolute',top:30,right:16,
          width:80,height:80,
        }}>
          <svg viewBox="0 0 100 100" style={{width:'100%',height:'100%'}}>
            <defs><path id="c" d="M50,50 m-38,0 a38,38 0 1,1 76,0 a38,38 0 1,1 -76,0"/></defs>
            <circle cx="50" cy="50" r="46" fill="#FFC94D" stroke="#0E0B1F" strokeWidth="2.5"/>
            <text fontSize="8" fontFamily="JetBrains Mono" fontWeight="700" fill="#0E0B1F">
              <textPath href="#c">ส่งฟรี · FREE DELIVERY · ส่งฟรี · FREE · </textPath>
            </text>
            <circle cx="50" cy="50" r="14" fill="#0E0B1F"/>
            <text x="50" y="55" textAnchor="middle" fontSize="16" fill="#FFC94D">★</text>
          </svg>
        </div>
      </div>

      {/* body */}
      <div style={{padding:'14px 16px 20px'}}>
        <div style={{display:'flex',alignItems:'baseline',justifyContent:'space-between'}}>
          <div className="mono" style={{fontSize:10,color:'#6E6A85',letterSpacing:'.15em'}}>KHAO SOI · KITCHEN</div>
          <div style={{fontSize:11,fontWeight:700,color:'#FF3E6C'}}>★ 4.9 (214)</div>
        </div>
        <h1 className="display" style={{fontSize:24,margin:'4px 0 8px',lineHeight:1.1}}>
          ข้าวซอยไก่สูตรเชียงใหม่
        </h1>
        <p style={{margin:0,color:'#2A2640',fontSize:13,lineHeight:1.5}}>
          ข้าวซอยแท้จากเชียงใหม่ น้ำข้นเข้มข้น ไก่นุ่มเปื่อย มาพร้อมเครื่องเคียงครบ.
        </p>

        {/* portions */}
        <div style={{margin:'16px 0 12px'}}>
          <div className="mono" style={{fontSize:10,color:'#6E6A85',letterSpacing:'.15em',marginBottom:8}}>ขนาด · SIZE</div>
          <div style={{display:'flex',gap:8}}>
            {[
              {l:'เล็ก',s:'฿55'},
              {l:'กลาง',s:'฿75',on:true},
              {l:'ใหญ่',s:'฿95'},
            ].map((p,i)=>(
              <div key={i} style={{
                flex:1,padding:'10px 6px',borderRadius:14,textAlign:'center',
                border:'0',
                background: p.on ? '#FF3E6C':'#fff',color:p.on?'#fff':'#0E0B1F',
                boxShadow: p.on ? '0 4px 8px -2px rgba(70,42,92,.2), inset 0 -2px 3px rgba(70,42,92,.12), inset 0 2px 2px rgba(255,255,255,.85)':'none',
              }}>
                <div style={{fontWeight:800,fontSize:13}}>{p.l}</div>
                <div className="mono" style={{fontSize:11,marginTop:2,opacity:.9}}>{p.s}</div>
              </div>
            ))}
          </div>
        </div>

        {/* addons */}
        <div className="mono" style={{fontSize:10,color:'#6E6A85',letterSpacing:'.15em',margin:'8px 0'}}>เพิ่มเติม · ADD-ONS</div>
        <div style={{display:'flex',flexDirection:'column',gap:8}}>
          {[
            {l:'ไข่ต้ม',p:'+฿10',on:true},
            {l:'ผักดองเพิ่ม',p:'+฿5'},
            {l:'น้ำพริกผัดเพิ่ม',p:'+฿15'},
          ].map((a,i)=>(
            <div key={i} className="chunk" style={{
              padding:'10px 12px',display:'flex',alignItems:'center',gap:10,
              boxShadow:'0 4px 8px -2px rgba(70,42,92,.2), inset 0 -2px 3px rgba(70,42,92,.12), inset 0 2px 2px rgba(255,255,255,.85)',
              background:a.on?'#FFF0C7':'#fff',
            }}>
              <div style={{
                width:22,height:22,borderRadius:7,border:'0',
                background:a.on?'#0E0B1F':'#fff',color:'#FFC94D',
                display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900,fontSize:14,
              }}>{a.on?'✓':''}</div>
              <div style={{flex:1,fontWeight:600,fontSize:13}}>{a.l}</div>
              <div className="mono" style={{fontSize:12}}>{a.p}</div>
            </div>
          ))}
        </div>

        {/* seller */}
        <div className="chunk" style={{margin:'16px 0',padding:12,display:'flex',alignItems:'center',gap:10,background:'#fff'}}>
          <div style={{
            width:42,height:42,borderRadius:12,background:'#FFC94D',
            border:'0',display:'flex',alignItems:'center',justifyContent:'center',
            fontWeight:900,
          }}>ป</div>
          <div style={{flex:1}}>
            <div style={{fontWeight:700,fontSize:13}}>ครัวยายปราณี</div>
            <div className="mono" style={{fontSize:10,color:'#6E6A85'}}>ขาย 1,240 จาน · ตอบเร็ว</div>
          </div>
          <button className="btn ghost" style={{padding:'6px 12px',fontSize:11}}>💬 แชท</button>
        </div>

        {/* Affiliate callout */}
        <div className="chunk" style={{
          padding:12,background:'#00D4B4',display:'flex',alignItems:'center',gap:10,
          marginBottom:80,
        }}>
          <div style={{width:38,height:38,flexShrink:0}}><Coin size={38}/></div>
          <div style={{flex:1}}>
            <div style={{fontWeight:800,fontSize:12}}>แชร์แล้วได้ ฿6 ต่อออเดอร์</div>
            <div style={{fontSize:11,color:'#003028'}}>คัดลอกลิงก์ · Tier Silver 8.5%</div>
          </div>
          <button className="btn" style={{padding:'6px 10px',fontSize:11}}>↗ แชร์</button>
        </div>
      </div>

      {/* sticky CTA */}
      <div style={{
        position:'sticky',bottom:0,background:'#FFF8EE',
        borderTop:'1px solid rgba(70,42,92,.12)',padding:'10px 14px',
        display:'flex',alignItems:'center',gap:10,
      }}>
        <div>
          <div className="mono" style={{fontSize:10,color:'#6E6A85'}}>TOTAL</div>
          <div className="display" style={{fontSize:22}}>฿85</div>
        </div>
        <button className="btn pink" style={{flex:1,padding:'14px',fontSize:14}}>
          ใส่ตะกร้า · Add to bag
        </button>
      </div>
    </div>
  );
}

function Shop(){
  return (
    <div style={{minHeight:'100%',background:'#FFF8EE'}}>
      {/* cover */}
      <div style={{
        height:180,background:'linear-gradient(160deg,#6B4BFF,#FF3E6C)',
        position:'relative',overflow:'hidden',borderBottom:'1px solid rgba(70,42,92,.12)',
      }}>
        <div style={{position:'absolute',top:14,left:14,right:14,display:'flex',justifyContent:'space-between'}}>
          {['←','⋯'].map((c,i)=>(
            <div key={i} style={{
              width:38,height:38,borderRadius:12,background:'#FFF8EE',
              border:'0',boxShadow:'0 4px 8px -2px rgba(70,42,92,.2), inset 0 -2px 3px rgba(70,42,92,.12), inset 0 2px 2px rgba(255,255,255,.85)',
              display:'flex',alignItems:'center',justifyContent:'center',fontSize:14,fontWeight:700,
            }}>{c}</div>
          ))}
        </div>
        <div style={{position:'absolute',right:-30,top:-20, transform:'rotate(12deg)', opacity:.9}}>
          <IsoStall w={240} h={200}/>
        </div>
      </div>
      {/* overlap card */}
      <div style={{padding:'0 16px',marginTop:-40,position:'relative'}}>
        <div className="chunk" style={{background:'#fff',padding:16,display:'flex',gap:12,alignItems:'flex-end'}}>
          <div style={{
            width:80,height:80,borderRadius:20,background:'#FFC94D',
            border:'0',flexShrink:0,
            display:'flex',alignItems:'center',justifyContent:'center',
            fontSize:30,fontWeight:900,fontFamily:'Space Grotesk', marginTop:-36,
            boxShadow:'0 4px 8px -2px rgba(70,42,92,.2), inset 0 -2px 3px rgba(70,42,92,.12), inset 0 2px 2px rgba(255,255,255,.85)',
          }}>ป</div>
          <div style={{flex:1,minWidth:0}}>
            <div className="mono" style={{fontSize:10,color:'#6E6A85',letterSpacing:'.15em'}}>VERIFIED SELLER · LV 4</div>
            <div style={{fontSize:17,fontWeight:900,marginTop:2}}>ครัวยายปราณี</div>
            <div style={{fontSize:11,color:'#2A2640',marginTop:2}}>★ 4.9 · 1,240 คำสั่งซื้อ · ตอบใน 3 นาที</div>
          </div>
        </div>
      </div>

      {/* stats row */}
      <div style={{padding:'14px 16px 0',display:'grid',gridTemplateColumns:'repeat(3,1fr)',gap:8}}>
        {[
          {l:'ตามแล้ว',v:'842'},
          {l:'สินค้า',v:'38'},
          {l:'ตอบรีวิว',v:'98%'},
        ].map((s,i)=>(
          <div key={i} style={{
            border:'0',borderRadius:14,padding:'10px 8px',
            background:'#FFF0C7',textAlign:'center',
          }}>
            <div className="display" style={{fontSize:18}}>{s.v}</div>
            <div style={{fontSize:10,color:'#6E6A85',fontWeight:600}}>{s.l}</div>
          </div>
        ))}
      </div>

      {/* CTA row */}
      <div style={{display:'flex',gap:8,padding:'12px 16px'}}>
        <button className="btn pink" style={{flex:1}}>＋ ติดตาม</button>
        <button className="btn ghost" style={{flex:1}}>💬 แชท</button>
      </div>

      {/* Tabs */}
      <div style={{padding:'4px 16px 0',display:'flex',gap:8}}>
        {['สินค้า','รีวิว','โปรโมชัน'].map((t,i)=>(
          <div key={t} style={{
            padding:'8px 14px',borderRadius:999,
            border:'0',
            background:i===0?'#0E0B1F':'#fff',color:i===0?'#FFC94D':'#0E0B1F',
            fontSize:12,fontWeight:700,boxShadow:i===0?'0 4px 8px -2px rgba(70,42,92,.2), inset 0 -2px 3px rgba(70,42,92,.12), inset 0 2px 2px rgba(255,255,255,.85)':'none',
          }}>{t}</div>
        ))}
      </div>

      {/* product grid */}
      <div style={{padding:'12px 16px 30px',display:'grid',gridTemplateColumns:'1fr 1fr',gap:10}}>
        {[
          {n:'ข้าวซอยไก่',p:'฿75',c:'tomato'},
          {n:'แกงเหลือง',p:'฿85',c:'mango'},
          {n:'ขนมจีนน้ำยา',p:'฿70',c:'leaf'},
          {n:'ผัดไทยกุ้งสด',p:'฿90',c:'pink'},
        ].map((p,i)=>(
          <div key={i} className="chunk" style={{padding:0,overflow:'hidden'}}>
            <div style={{
              height:110,background:i%2?'#DFFAF3':'#FFE3EB',
              display:'flex',alignItems:'center',justifyContent:'center',
              borderBottom:'1px solid rgba(70,42,92,.12)',position:'relative',
            }}>
              <Puff w={100} h={70} hue={p.c}/>
            </div>
            <div style={{padding:'8px 10px 10px'}}>
              <div style={{fontWeight:700,fontSize:12}}>{p.n}</div>
              <div style={{display:'flex',justifyContent:'space-between',alignItems:'center',marginTop:4}}>
                <span className="display" style={{fontSize:14}}>{p.p}</span>
                <div style={{
                  width:26,height:26,borderRadius:8,background:'#FF3E6C',border:'0',
                  display:'flex',alignItems:'center',justifyContent:'center',color:'#fff',fontWeight:900,fontSize:14,
                }}>＋</div>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

Object.assign(window, {Onboarding, Home, Product, Shop});
