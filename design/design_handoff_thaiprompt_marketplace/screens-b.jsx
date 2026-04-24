// Thaiprompt — Screens part 2: Wallet, Affiliate, Cart, Tracking, Chat

function Wallet(){
  const spend = [20,35,18,42,28,55,38]; // last 7 days
  const max = Math.max(...spend);
  return (
    <div style={{background:'#0E0B1F',minHeight:'100%',color:'#fff',position:'relative',overflow:'hidden'}}>
      {/* ambient */}
      <div style={{position:'absolute',top:-40,right:-60,width:200,height:200,borderRadius:'50%',background:'radial-gradient(circle,#FF3E6C,transparent 70%)',opacity:.5,filter:'blur(10px)'}}/>
      <div style={{position:'absolute',top:120,left:-80,width:200,height:200,borderRadius:'50%',background:'radial-gradient(circle,#6B4BFF,transparent 70%)',opacity:.5,filter:'blur(10px)'}}/>

      <div style={{padding:'16px 16px 0',display:'flex',justifyContent:'space-between',alignItems:'center',position:'relative'}}>
        <div>
          <div className="mono" style={{fontSize:10,letterSpacing:'.15em',opacity:.6}}>MY WALLET</div>
          <div style={{fontSize:16,fontWeight:700}}>กระเป๋าของฉัน</div>
        </div>
        <div style={{
          width:38,height:38,borderRadius:12,background:'#FFC94D',color:'#0E0B1F',
          display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900,
          border:'0',boxShadow:'0 4px 8px -2px rgba(70,42,92,.2), inset 0 -2px 3px rgba(70,42,92,.12), inset 0 2px 2px rgba(255,255,255,.85)',
        }}>⚙</div>
      </div>

      {/* BIG balance card */}
      <div style={{padding:'14px 16px 0',position:'relative'}}>
        <div style={{
          borderRadius:22,padding:18,position:'relative',overflow:'hidden',
          background:'linear-gradient(135deg,#FF3E6C 0%,#FF7A3A 50%,#FFC94D 100%)',
          border:'0',boxShadow:'0 4px 8px -2px rgba(70,42,92,.2), inset 0 -2px 3px rgba(70,42,92,.12), inset 0 2px 2px rgba(255,255,255,.85)',
          color:'#0E0B1F',
        }}>
          {/* shine */}
          <div style={{
            position:'absolute',top:0,left:0,width:'40%',height:'100%',
            background:'linear-gradient(90deg,transparent,rgba(255,255,255,.5),transparent)',
            animation:'shine 3s ease-in-out infinite',
          }}/>
          <div style={{display:'flex',justifyContent:'space-between',alignItems:'start'}}>
            <div>
              <div className="mono" style={{fontSize:9,letterSpacing:'.2em',opacity:.8}}>BALANCE</div>
              <div style={{display:'flex',alignItems:'baseline',gap:4,margin:'4px 0'}}>
                <span className="display" style={{fontSize:38,lineHeight:1}}>฿2,481</span>
                <span style={{fontSize:14,fontWeight:700}}>.50</span>
              </div>
              <div style={{fontSize:11,fontWeight:600}}>≈ 2,481 Promptpay THB</div>
            </div>
            {/* chip */}
            <div style={{width:44,height:34,background:'linear-gradient(135deg,#FFD98C,#8B5A1B)',borderRadius:6,border:'0',position:'relative'}}>
              <div style={{position:'absolute',inset:6,border:'1px solid rgba(0,0,0,.4)',borderRadius:3}}/>
            </div>
          </div>
          {/* coins */}
          <div style={{display:'flex',alignItems:'center',gap:8,marginTop:14,padding:'8px 10px',background:'rgba(14,11,31,.15)',borderRadius:12,border:'1.5px solid rgba(14,11,31,.3)'}}>
            <Coin size={30}/>
            <div style={{flex:1}}>
              <div style={{fontSize:11,fontWeight:700}}>Cashback Coins</div>
              <div className="mono" style={{fontSize:10,opacity:.8}}>1 coin = ฿1</div>
            </div>
            <div className="display" style={{fontSize:20}}>284</div>
          </div>
        </div>
      </div>

      {/* action row */}
      <div style={{padding:'14px 16px',display:'grid',gridTemplateColumns:'repeat(4,1fr)',gap:8}}>
        {[
          {l:'เติมเงิน',i:'⬆',c:'#00D4B4'},
          {l:'ถอน',i:'⬇',c:'#FFC94D'},
          {l:'โอน',i:'⇌',c:'#FF3E6C'},
          {l:'สแกน',i:'⎙',c:'#6B4BFF'},
        ].map(a=>(
          <div key={a.l} style={{textAlign:'center'}}>
            <div style={{
              width:52,height:52,borderRadius:16,background:a.c,color:'#0E0B1F',
              display:'flex',alignItems:'center',justifyContent:'center',
              fontSize:20,fontWeight:900,margin:'0 auto 6px',
              border:'0',boxShadow:'0 4px 8px -2px rgba(70,42,92,.2), inset 0 -2px 3px rgba(70,42,92,.12), inset 0 2px 2px rgba(255,255,255,.85)',
            }}>{a.i}</div>
            <div style={{fontSize:11,fontWeight:700}}>{a.l}</div>
          </div>
        ))}
      </div>

      {/* Top-up QR mini */}
      <div style={{padding:'0 16px 10px'}}>
        <div className="chunk" style={{background:'#FFF8EE',color:'#0E0B1F',padding:14}}>
          <div style={{display:'flex',alignItems:'center',gap:12}}>
            {/* fake QR */}
            <div style={{
              width:64,height:64,padding:4,background:'#fff',borderRadius:10,
              border:'0',flexShrink:0,
            }}>
              <svg viewBox="0 0 60 60" style={{width:'100%',height:'100%'}}>
                {Array.from({length:64}).map((_,i)=>{
                  const x=i%8, y=Math.floor(i/8);
                  const seed=(x*31 + y*17 + 7)%7;
                  return seed<3? <rect key={i} x={x*7} y={y*7} width="6" height="6" fill="#0E0B1F"/> : null;
                })}
                <rect x="0" y="0" width="18" height="18" fill="#fff" stroke="#0E0B1F" strokeWidth="2"/>
                <rect x="4" y="4" width="10" height="10" fill="#0E0B1F"/>
                <rect x="42" y="0" width="18" height="18" fill="#fff" stroke="#0E0B1F" strokeWidth="2"/>
                <rect x="46" y="4" width="10" height="10" fill="#0E0B1F"/>
                <rect x="0" y="42" width="18" height="18" fill="#fff" stroke="#0E0B1F" strokeWidth="2"/>
                <rect x="4" y="46" width="10" height="10" fill="#0E0B1F"/>
              </svg>
            </div>
            <div style={{flex:1}}>
              <div className="mono" style={{fontSize:9,color:'#6E6A85',letterSpacing:'.15em'}}>PROMPTPAY · TH0066</div>
              <div style={{fontWeight:800,fontSize:14,marginTop:2}}>เติมเร็วผ่าน QR</div>
              <div style={{fontSize:11,color:'#2A2640'}}>สแกน → รับเงินใน 2 วิ</div>
            </div>
            <button className="btn pink" style={{padding:'8px 12px',fontSize:11}}>เติม</button>
          </div>
        </div>
      </div>

      {/* Analytics chart */}
      <div style={{padding:'0 16px 10px'}}>
        <div className="chunk" style={{background:'#FFF8EE',color:'#0E0B1F',padding:14}}>
          <div style={{display:'flex',justifyContent:'space-between',alignItems:'baseline'}}>
            <div>
              <div className="mono" style={{fontSize:9,color:'#6E6A85',letterSpacing:'.15em'}}>THIS WEEK</div>
              <div style={{fontWeight:800,fontSize:15}}>ใช้จ่าย ฿236</div>
            </div>
            <div style={{fontSize:11,fontWeight:700,color:'#00D4B4'}}>↓ 12% vs last</div>
          </div>
          <div style={{display:'flex',alignItems:'flex-end',gap:6,height:80,marginTop:12}}>
            {spend.map((v,i)=>(
              <div key={i} style={{flex:1,display:'flex',flexDirection:'column',alignItems:'center',gap:4}}>
                <div style={{
                  width:'100%',height:`${(v/max)*72}px`,
                  borderRadius:8,border:'0',
                  background: i===5?'#FF3E6C':'#FFC94D',
                  boxShadow: i===5?'0 4px 8px -2px rgba(70,42,92,.2), inset 0 -2px 3px rgba(70,42,92,.12), inset 0 2px 2px rgba(255,255,255,.85)':'none',
                }}/>
                <div className="mono" style={{fontSize:9,color:'#6E6A85'}}>{'จ.อ.พ.พฤ.ศ.ส.อา'.split('.')[i]}</div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* History */}
      <div style={{padding:'8px 16px 20px'}}>
        <div style={{display:'flex',alignItems:'center',justifyContent:'space-between',marginBottom:8}}>
          <div style={{fontWeight:800,fontSize:14}}>ประวัติ</div>
          <div className="mono" style={{fontSize:10,color:'rgba(255,255,255,.6)'}}>ALL →</div>
        </div>
        <div style={{display:'flex',flexDirection:'column',gap:8}}>
          {[
            {t:'ครัวยายปราณี',d:'เมื่อกี้',a:'-฿85',c:'#FF3E6C',i:'◉'},
            {t:'เติมจาก PromptPay',d:'10:20',a:'+฿500',c:'#00D4B4',i:'⬆'},
            {t:'Affiliate: คุณฝน',d:'เมื่อวาน',a:'+฿28',c:'#FFC94D',i:'◇'},
            {t:'น้องฟ้า ขนมไทย',d:'เมื่อวาน',a:'-฿120',c:'#FF3E6C',i:'◉'},
          ].map((t,i)=>(
            <div key={i} style={{
              display:'flex',alignItems:'center',gap:10,padding:'10px 12px',
              borderRadius:14,background:'rgba(255,255,255,.06)',
              border:'1.5px solid rgba(255,255,255,.12)',
            }}>
              <div style={{
                width:36,height:36,borderRadius:10,background:t.c,color:'#0E0B1F',
                display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900,
                border:'0',
              }}>{t.i}</div>
              <div style={{flex:1}}>
                <div style={{fontWeight:700,fontSize:13}}>{t.t}</div>
                <div className="mono" style={{fontSize:10,opacity:.6}}>{t.d}</div>
              </div>
              <div className="display" style={{fontSize:15,color:t.a.startsWith('+')?'#00D4B4':'#fff'}}>{t.a}</div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}

function Affiliate(){
  return (
    <div style={{minHeight:'100%',background:'#FFF8EE',position:'relative'}}>
      {/* hero */}
      <div style={{
        background:'linear-gradient(160deg,#6B4BFF,#FF3E6C 110%)',
        padding:'18px 16px 40px',color:'#fff',position:'relative',overflow:'hidden',
        borderBottom:'1px solid rgba(70,42,92,.12)',
      }}>
        <div style={{display:'flex',alignItems:'center',gap:8}}>
          <div className="mono" style={{fontSize:10,letterSpacing:'.18em',opacity:.8}}>AFFILIATE · ระบบแนะนำ</div>
        </div>
        <h1 className="display" style={{fontSize:26,margin:'6px 0 8px',lineHeight:1.05}}>
          แชร์ → เพื่อนซื้อ → รับเงิน
        </h1>

        {/* Tier card */}
        <div style={{
          marginTop:10,padding:14,borderRadius:18,background:'rgba(255,255,255,.12)',
          border:'1.5px solid rgba(255,255,255,.3)',backdropFilter:'blur(10px)',
          display:'flex',alignItems:'center',gap:12,
        }}>
          <div style={{position:'relative'}}>
            <Coin size={54} label="🥈"/>
            <div style={{position:'absolute',inset:-6,borderRadius:'50%',border:'2px dashed rgba(255,255,255,.5)'}} className="spin-slow"/>
          </div>
          <div style={{flex:1}}>
            <div style={{fontWeight:900,fontSize:15}}>Silver Tier</div>
            <div style={{fontSize:11,opacity:.9}}>8.5% ต่อออเดอร์ · อีก 24 ครั้งเลื่อน Gold</div>
            <div style={{marginTop:8,height:8,borderRadius:4,background:'rgba(0,0,0,.25)',overflow:'hidden',position:'relative'}}>
              <div style={{width:'68%',height:'100%',background:'#FFC94D',borderRadius:4}}/>
            </div>
          </div>
        </div>
      </div>

      {/* Earnings card (overlap) */}
      <div style={{padding:'0 16px',marginTop:-24,position:'relative'}}>
        <div className="chunk grain" style={{background:'#FFF8EE',padding:16}}>
          <div className="mono" style={{fontSize:10,color:'#6E6A85',letterSpacing:'.15em'}}>EARNINGS · APR 2026</div>
          <div style={{display:'flex',alignItems:'baseline',gap:6,margin:'4px 0 10px'}}>
            <span className="display" style={{fontSize:34,color:'#0E0B1F'}}>฿1,820</span>
            <span style={{fontSize:12,fontWeight:700,color:'#00D4B4'}}>↑ 32%</span>
          </div>
          <div style={{display:'grid',gridTemplateColumns:'repeat(3,1fr)',gap:6}}>
            {[
              {l:'คลิก',v:'1,240',c:'#FFC94D'},
              {l:'ซื้อ',v:'98',c:'#FF3E6C'},
              {l:'Conv',v:'7.9%',c:'#00D4B4'},
            ].map((s,i)=>(
              <div key={i} style={{
                padding:'8px 4px',borderRadius:12,background:s.c,textAlign:'center',
                border:'0',
              }}>
                <div className="display" style={{fontSize:16}}>{s.v}</div>
                <div className="mono" style={{fontSize:9,color:'#0E0B1F',opacity:.8}}>{s.l}</div>
              </div>
            ))}
          </div>
        </div>
      </div>

      {/* Share link / tabs */}
      <div style={{padding:'14px 16px 0'}}>
        <div className="chunk" style={{background:'#0E0B1F',color:'#fff',padding:'12px 14px',display:'flex',alignItems:'center',gap:10}}>
          <span className="mono" style={{fontSize:11,flex:1,overflow:'hidden',textOverflow:'ellipsis',whiteSpace:'nowrap'}}>tp.app/@somporn/khaosoi</span>
          <button style={{
            background:'#FFC94D',color:'#0E0B1F',border:'0',
            borderRadius:999,padding:'6px 12px',fontWeight:800,fontSize:11,cursor:'pointer',
            fontFamily:'inherit',
          }}>คัดลอก</button>
        </div>
        <div style={{display:'flex',gap:8,marginTop:10}}>
          {['ลิงก์ทั้งหมด','เพื่อนที่ชวน','Tier'].map((t,i)=>(
            <div key={t} style={{
              padding:'8px 12px',borderRadius:999,
              border:'0',
              background:i===0?'#FF3E6C':'#fff',color:i===0?'#fff':'#0E0B1F',
              fontSize:11,fontWeight:700,boxShadow:i===0?'0 4px 8px -2px rgba(70,42,92,.2), inset 0 -2px 3px rgba(70,42,92,.12), inset 0 2px 2px rgba(255,255,255,.85)':'none',
            }}>{t}</div>
          ))}
        </div>
      </div>

      {/* Top products */}
      <H th="สินค้าทำเงินสูงสุด" en="Top earning links"/>
      <div style={{padding:'0 16px 14px',display:'flex',flexDirection:'column',gap:10}}>
        {[
          {n:'ข้าวซอยไก่ · ครัวยายปราณี',c:74,e:524,hue:'tomato',pct:'8.5%'},
          {n:'ผักออแกนิก · ฟาร์มดอยคำ',c:42,e:318,hue:'leaf',pct:'8.5%'},
          {n:'ขนมเทียน · น้องฟ้า',c:28,e:196,hue:'mango',pct:'8.5%'},
        ].map((l,i)=>(
          <div key={i} className="chunk" style={{padding:10,display:'flex',alignItems:'center',gap:10,background:'#fff'}}>
            <div style={{
              width:56,height:56,borderRadius:14,
              background:i%2?'#FFE3EB':'#FFF0C7',
              border:'0',flexShrink:0,
              display:'flex',alignItems:'center',justifyContent:'center',
            }}>
              <Puff w={44} h={34} hue={l.hue}/>
            </div>
            <div style={{flex:1,minWidth:0}}>
              <div style={{fontWeight:700,fontSize:12}}>{l.n}</div>
              <div className="mono" style={{fontSize:10,color:'#6E6A85',marginTop:2}}>{l.c} clicks · {l.pct} commission</div>
            </div>
            <div style={{textAlign:'right'}}>
              <div className="display" style={{fontSize:15}}>฿{l.e}</div>
              <div className="mono" style={{fontSize:9,color:'#00D4B4'}}>EARNED</div>
            </div>
          </div>
        ))}
      </div>

      {/* Invite friends */}
      <H th="ชวนเพื่อน" en="Invite & earn ฿50"/>
      <div style={{padding:'0 16px 30px'}}>
        <div className="chunk" style={{background:'#FFC94D',padding:16,position:'relative',overflow:'hidden'}}>
          <div style={{display:'flex',alignItems:'center',gap:10}}>
            <div style={{display:'flex'}}>
              {['#FF3E6C','#00D4B4','#6B4BFF'].map((c,i)=>(
                <div key={i} style={{
                  width:34,height:34,borderRadius:'50%',background:c,
                  border:'0',marginLeft:i?-10:0,
                  display:'flex',alignItems:'center',justifyContent:'center',
                  color:'#fff',fontWeight:800,fontSize:13,
                }}>{['ฝ','ต','ส'][i]}</div>
              ))}
              <div style={{
                width:34,height:34,borderRadius:'50%',background:'#0E0B1F',color:'#FFC94D',
                border:'0',marginLeft:-10,
                display:'flex',alignItems:'center',justifyContent:'center',fontSize:11,fontWeight:800,
              }}>+9</div>
            </div>
            <div style={{flex:1}}>
              <div style={{fontWeight:800,fontSize:13}}>ชวนแล้ว 12 คน</div>
              <div style={{fontSize:11,color:'#0E0B1F'}}>ชวนอีก 3 คน → เลื่อน Gold</div>
            </div>
          </div>
          <button className="btn" style={{width:'100%',marginTop:12,fontSize:13}}>↗ แชร์ลิงก์ชวน</button>
        </div>
      </div>
    </div>
  );
}

function Cart(){
  const items = [
    {n:'ข้าวซอยไก่ (กลาง)',p:85,q:1,hue:'tomato',s:'ครัวยายปราณี'},
    {n:'ผักบุ้งไฟแดง',p:60,q:2,hue:'leaf',s:'ป้าสม ผักสด'},
    {n:'ขนมเทียน 5 ลูก',p:45,q:1,hue:'mango',s:'น้องฟ้า ขนมไทย'},
  ];
  const sub = items.reduce((a,b)=>a+b.p*b.q,0);
  return (
    <div style={{background:'#FFF8EE',minHeight:'100%'}}>
      <div style={{padding:'12px 16px 8px'}}>
        <div className="mono" style={{fontSize:10,color:'#6E6A85',letterSpacing:'.15em'}}>ตะกร้า · CART</div>
        <div style={{fontWeight:900,fontSize:22}}>ของในตะกร้า <span style={{color:'#FF3E6C'}}>({items.length})</span></div>
      </div>

      <div style={{padding:'0 16px',display:'flex',flexDirection:'column',gap:10}}>
        {items.map((it,i)=>(
          <div key={i} className="chunk" style={{padding:10,display:'flex',gap:10,background:'#fff',alignItems:'center'}}>
            <div style={{
              width:64,height:64,borderRadius:14,
              background:['#FFE3EB','#DFFAF3','#FFF0C7'][i%3],
              border:'0',flexShrink:0,
              display:'flex',alignItems:'center',justifyContent:'center',
            }}>
              <Puff w={54} h={40} hue={it.hue}/>
            </div>
            <div style={{flex:1,minWidth:0}}>
              <div style={{fontWeight:800,fontSize:13}}>{it.n}</div>
              <div className="mono" style={{fontSize:10,color:'#6E6A85'}}>{it.s}</div>
              <div className="display" style={{fontSize:15,marginTop:4}}>฿{it.p}</div>
            </div>
            <div style={{
              display:'flex',alignItems:'center',gap:6,border:'0',
              borderRadius:999,padding:2,background:'#FFF0C7',
            }}>
              <div style={{width:26,height:26,borderRadius:'50%',background:'#fff',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900}}>−</div>
              <span className="mono" style={{fontSize:13,fontWeight:700,minWidth:12,textAlign:'center'}}>{it.q}</span>
              <div style={{width:26,height:26,borderRadius:'50%',background:'#0E0B1F',color:'#FFC94D',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900}}>+</div>
            </div>
          </div>
        ))}
      </div>

      {/* Coins promo */}
      <div style={{padding:'14px 16px 0'}}>
        <div className="chunk" style={{padding:12,background:'#0E0B1F',color:'#fff',display:'flex',alignItems:'center',gap:10}}>
          <Coin size={38}/>
          <div style={{flex:1}}>
            <div style={{fontWeight:800,fontSize:13}}>ใช้ Coins ลด ฿28</div>
            <div className="mono" style={{fontSize:10,opacity:.7}}>284 coins · 1 coin = ฿1</div>
          </div>
          <div style={{
            width:40,height:22,borderRadius:999,background:'#00D4B4',
            border:'0',position:'relative',
          }}>
            <div style={{
              position:'absolute',top:1,right:1,width:16,height:16,borderRadius:'50%',
              background:'#fff',border:'0',
            }}/>
          </div>
        </div>
      </div>

      {/* Delivery */}
      <div style={{padding:'10px 16px 0'}}>
        <div className="chunk" style={{padding:12,background:'#fff'}}>
          <div className="mono" style={{fontSize:10,color:'#6E6A85',letterSpacing:'.15em'}}>จัดส่ง</div>
          <div style={{display:'flex',alignItems:'center',gap:8,marginTop:4}}>
            <div style={{width:32,height:32,borderRadius:10,background:'#FFC94D',border:'0',display:'flex',alignItems:'center',justifyContent:'center',fontSize:14}}>🛵</div>
            <div style={{flex:1}}>
              <div style={{fontWeight:700,fontSize:13}}>ส่งโดยไรเดอร์ชุมชน · 15-25 นาที</div>
              <div className="mono" style={{fontSize:10,color:'#6E6A85'}}>ซ.สุขุมวิท 24 · 1.2km</div>
            </div>
            <div className="display" style={{fontSize:14,color:'#00D4B4'}}>฿0</div>
          </div>
        </div>
      </div>

      {/* Summary */}
      <div style={{padding:'14px 16px 100px'}}>
        <div className="chunk" style={{padding:14,background:'#FFF0C7'}}>
          {[
            ['ราคาสินค้า','฿'+sub],
            ['ค่าจัดส่ง','฿0'],
            ['ส่วนลด Coins','-฿28'],
          ].map(([k,v],i)=>(
            <div key={i} style={{display:'flex',justifyContent:'space-between',padding:'4px 0',fontSize:13,fontWeight:600,color:'#2A2640'}}>
              <span>{k}</span><span className="mono">{v}</span>
            </div>
          ))}
          <div style={{height:1,background:'#0E0B1F',margin:'8px 0'}}/>
          <div style={{display:'flex',justifyContent:'space-between',alignItems:'baseline'}}>
            <span style={{fontWeight:900,fontSize:15}}>ทั้งหมด</span>
            <span className="display" style={{fontSize:24}}>฿{sub-28}</span>
          </div>
        </div>
      </div>

      {/* sticky pay */}
      <div style={{
        position:'sticky',bottom:0,background:'#FFF8EE',
        borderTop:'1px solid rgba(70,42,92,.12)',padding:'10px 14px',
        display:'flex',gap:10,alignItems:'center',
      }}>
        <div>
          <div className="mono" style={{fontSize:10,color:'#6E6A85'}}>WALLET</div>
          <div style={{fontWeight:700,fontSize:13}}>฿2,481.50</div>
        </div>
        <button className="btn pink" style={{flex:1,padding:'14px',fontSize:14}}>จ่ายด้วย Wallet</button>
      </div>
    </div>
  );
}

function Tracking(){
  const steps = [
    {t:'รับออเดอร์',d:'09:42',done:true},
    {t:'ร้านกำลังทำ',d:'09:44',done:true},
    {t:'ไรเดอร์รับของ',d:'09:58',active:true},
    {t:'กำลังส่ง',d:'—'},
    {t:'ถึงแล้ว',d:'—'},
  ];
  return (
    <div style={{background:'#FFF8EE',minHeight:'100%'}}>
      {/* Map hero */}
      <div style={{
        height:260,position:'relative',overflow:'hidden',
        background:'linear-gradient(180deg,#DFFAF3 0%,#FFE3EB 100%)',
        borderBottom:'1px solid rgba(70,42,92,.12)',
      }}>
        {/* dotted grid */}
        <div className="dots" style={{position:'absolute',inset:0,opacity:.5}}/>
        {/* roads */}
        <svg viewBox="0 0 360 260" style={{position:'absolute',inset:0,width:'100%',height:'100%'}}>
          <path d="M-10 200 Q 80 140 180 160 T 380 100" stroke="#0E0B1F" strokeWidth="20" fill="none" opacity=".08"/>
          <path d="M-10 200 Q 80 140 180 160 T 380 100" stroke="#fff" strokeWidth="14" fill="none"/>
          <path d="M-10 200 Q 80 140 180 160 T 380 100" stroke="#0E0B1F" strokeWidth="2" strokeDasharray="8 6" fill="none"/>
          {/* building blocks */}
          {[
            {x:30,y:80,c:'#FFC94D'},{x:70,y:60,c:'#FF3E6C'},
            {x:240,y:50,c:'#6B4BFF'},{x:290,y:80,c:'#00D4B4'},
            {x:60,y:220,c:'#FF7A3A'},{x:260,y:220,c:'#FFC94D'},
          ].map((b,i)=>(
            <rect key={i} x={b.x} y={b.y} width="28" height="28" rx="5" fill={b.c} stroke="#0E0B1F" strokeWidth="1.5"/>
          ))}
        </svg>
        {/* rider blob */}
        <div style={{position:'absolute',left:'42%',top:'45%'}} className="float">
          <div style={{position:'relative'}}>
            <div style={{
              position:'absolute',inset:-8,borderRadius:'50%',background:'#FF3E6C',
              animation:'pulse-ring 1.6s ease-out infinite',opacity:.4,
            }}/>
            <div style={{
              width:48,height:48,borderRadius:'50%',background:'#FF3E6C',
              border:'0',display:'flex',alignItems:'center',justifyContent:'center',
              fontSize:22,boxShadow:'0 4px 8px -2px rgba(70,42,92,.2), inset 0 -2px 3px rgba(70,42,92,.12), inset 0 2px 2px rgba(255,255,255,.85)',
            }}>🛵</div>
          </div>
        </div>
        {/* destination pin */}
        <div style={{position:'absolute',right:'12%',top:'24%'}}>
          <div style={{
            width:44,height:44,borderRadius:'50% 50% 50% 0',transform:'rotate(-45deg)',
            background:'#0E0B1F',border:'3px solid #FFC94D',
            display:'flex',alignItems:'center',justifyContent:'center',
          }}>
            <div style={{transform:'rotate(45deg)',color:'#FFC94D',fontWeight:900}}>🏠</div>
          </div>
        </div>
        {/* ETA badge */}
        <div style={{position:'absolute',top:16,left:16,right:16,display:'flex',justifyContent:'space-between'}}>
          <div style={{
            width:38,height:38,borderRadius:12,background:'#FFF8EE',
            border:'0',boxShadow:'0 4px 8px -2px rgba(70,42,92,.2), inset 0 -2px 3px rgba(70,42,92,.12), inset 0 2px 2px rgba(255,255,255,.85)',
            display:'flex',alignItems:'center',justifyContent:'center',fontWeight:700,
          }}>←</div>
          <div className="chunk" style={{padding:'6px 12px',background:'#FFC94D',fontSize:12,fontWeight:800,display:'flex',alignItems:'center',gap:6}}>
            <span style={{width:6,height:6,borderRadius:'50%',background:'#FF3E6C',animation:'pulse-ring 1.4s infinite'}}/>
            ถึงใน 8 นาที
          </div>
        </div>
      </div>

      {/* driver card */}
      <div style={{padding:'14px 16px 0'}}>
        <div className="chunk" style={{padding:12,display:'flex',alignItems:'center',gap:10,background:'#fff'}}>
          <div style={{
            width:50,height:50,borderRadius:14,background:'#6B4BFF',color:'#fff',
            border:'0',display:'flex',alignItems:'center',justifyContent:'center',
            fontWeight:900,fontFamily:'Space Grotesk',
          }}>ว</div>
          <div style={{flex:1}}>
            <div style={{fontWeight:800,fontSize:13}}>วิชัย · Rider</div>
            <div className="mono" style={{fontSize:10,color:'#6E6A85'}}>★ 4.8 · Honda Wave · กข-1482</div>
          </div>
          <button className="btn ghost" style={{padding:'8px 10px',fontSize:11}}>📞</button>
          <button className="btn pink" style={{padding:'8px 10px',fontSize:11}}>💬</button>
        </div>
      </div>

      {/* Timeline */}
      <div style={{padding:'14px 16px'}}>
        <div className="chunk" style={{padding:14,background:'#FFF0C7'}}>
          <div className="mono" style={{fontSize:10,color:'#6E6A85',letterSpacing:'.15em',marginBottom:10}}>ORDER #TP-2018 · สถานะ</div>
          <div style={{display:'flex',flexDirection:'column',gap:12,position:'relative'}}>
            {steps.map((s,i)=>(
              <div key={i} style={{display:'flex',alignItems:'center',gap:12,position:'relative'}}>
                <div style={{
                  width:28,height:28,borderRadius:'50%',flexShrink:0,
                  background: s.done?'#00D4B4': s.active?'#FF3E6C':'#fff',
                  color: s.done||s.active?'#fff':'#6E6A85',
                  border:'0',
                  display:'flex',alignItems:'center',justifyContent:'center',
                  fontWeight:900,fontSize:13, zIndex:2,
                  boxShadow: s.active?'0 0 0 4px rgba(255,62,108,.3)':'none',
                }}>{s.done?'✓':i+1}</div>
                {i<steps.length-1 && (
                  <div style={{
                    position:'absolute',left:13,top:28,width:2,height:24,
                    background: s.done?'#00D4B4':'rgba(14,11,31,.15)',
                  }}/>
                )}
                <div style={{flex:1}}>
                  <div style={{fontWeight: s.active?800:600, fontSize:13}}>{s.t}</div>
                </div>
                <div className="mono" style={{fontSize:11,color:'#6E6A85'}}>{s.d}</div>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}

function Chat(){
  const msgs = [
    {s:'them',t:'สวัสดีค่ะ วันนี้ข้าวซอยเหลือ 8 ชาม นะคะ',ts:'09:30'},
    {s:'me',t:'ข้าวซอยไก่กลาง 1 ที่ เอาไข่ต้มด้วยนะคะ 🙏',ts:'09:31'},
    {s:'them',t:'ได้เลยค่ะ ไข่ต้มบวก 10 บาท รวม 85 บาทค่ะ',ts:'09:31'},
    {s:'me',t:'โอเคค่ะ รับด้วย Wallet ได้มั้ย',ts:'09:32'},
    {s:'them',t:'ได้ค่ะ กดสั่งในแอปได้เลย ส่งฟรีด้วยนะคะ 🛵',ts:'09:32', attach:true},
  ];
  return (
    <div style={{background:'#FFF8EE',minHeight:'100%',display:'flex',flexDirection:'column'}}>
      {/* header */}
      <div style={{
        padding:'10px 14px',borderBottom:'1px solid rgba(70,42,92,.12)',
        display:'flex',alignItems:'center',gap:10,background:'#FFC94D',
      }}>
        <div style={{width:34,height:34,display:'flex',alignItems:'center',justifyContent:'center',fontSize:16,fontWeight:700}}>←</div>
        <div style={{
          width:38,height:38,borderRadius:12,background:'#FF3E6C',color:'#fff',
          border:'0',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900,
        }}>ป</div>
        <div style={{flex:1}}>
          <div style={{fontWeight:800,fontSize:13}}>ครัวยายปราณี</div>
          <div style={{fontSize:10,color:'#2A2640'}}><span style={{width:6,height:6,borderRadius:'50%',background:'#00D4B4',display:'inline-block',marginRight:4}}/>ออนไลน์ · ตอบเร็ว</div>
        </div>
        <div style={{fontSize:18}}>📞</div>
      </div>

      {/* messages */}
      <div style={{flex:1,padding:'16px 14px',display:'flex',flexDirection:'column',gap:10}} className="dots">
        <div style={{textAlign:'center',fontSize:10,color:'#6E6A85',fontFamily:'JetBrains Mono',margin:'4px 0 8px'}}>วันนี้ · 19 เม.ย.</div>
        {msgs.map((m,i)=>(
          <div key={i} style={{display:'flex',justifyContent:m.s==='me'?'flex-end':'flex-start'}}>
            <div style={{maxWidth:'76%'}}>
              <div style={{
                padding:'10px 14px',borderRadius:18,
                border:'0',
                background:m.s==='me'?'#FF3E6C':'#fff',
                color:m.s==='me'?'#fff':'#0E0B1F',
                boxShadow: m.s==='me'?'0 4px 8px -2px rgba(70,42,92,.2), inset 0 -2px 3px rgba(70,42,92,.12), inset 0 2px 2px rgba(255,255,255,.85)':'0 4px 8px -2px rgba(70,42,92,.2), inset 0 -2px 3px rgba(70,42,92,.12), inset 0 2px 2px rgba(255,255,255,.85)',
                fontSize:13,lineHeight:1.45,
                borderBottomRightRadius: m.s==='me'?6:18,
                borderBottomLeftRadius: m.s==='me'?18:6,
              }}>{m.t}</div>
              {m.attach && (
                <div className="chunk" style={{
                  marginTop:6,padding:8,background:'#fff',display:'flex',alignItems:'center',gap:8,
                  boxShadow:'0 4px 8px -2px rgba(70,42,92,.2), inset 0 -2px 3px rgba(70,42,92,.12), inset 0 2px 2px rgba(255,255,255,.85)',
                }}>
                  <div style={{width:40,height:40,borderRadius:10,background:'#FFE3EB',border:'0',display:'flex',alignItems:'center',justifyContent:'center'}}>
                    <Puff w={32} h={24} hue="tomato"/>
                  </div>
                  <div style={{flex:1}}>
                    <div style={{fontSize:11,fontWeight:800}}>ข้าวซอยไก่ + ไข่</div>
                    <div className="mono" style={{fontSize:10,color:'#6E6A85'}}>฿85 · ส่งฟรี</div>
                  </div>
                  <button className="btn pink" style={{padding:'6px 10px',fontSize:10}}>สั่ง</button>
                </div>
              )}
              <div className="mono" style={{fontSize:9,color:'#6E6A85',marginTop:3,textAlign:m.s==='me'?'right':'left'}}>{m.ts}</div>
            </div>
          </div>
        ))}
      </div>

      {/* composer */}
      <div style={{
        padding:'10px 12px',borderTop:'1px solid rgba(70,42,92,.12)',
        display:'flex',alignItems:'center',gap:8,background:'#FFF8EE',
      }}>
        <div style={{
          width:36,height:36,borderRadius:12,background:'#FFC94D',border:'0',
          display:'flex',alignItems:'center',justifyContent:'center',fontSize:16,
        }}>＋</div>
        <div className="chunk" style={{flex:1,padding:'8px 12px',boxShadow:'0 4px 8px -2px rgba(70,42,92,.2), inset 0 -2px 3px rgba(70,42,92,.12), inset 0 2px 2px rgba(255,255,255,.85)',display:'flex',alignItems:'center',gap:6}}>
          <span style={{fontSize:13,color:'#6E6A85',flex:1}}>พิมพ์ข้อความ...</span>
          <span style={{fontSize:16}}>😊</span>
        </div>
        <div style={{
          width:36,height:36,borderRadius:12,background:'#FF3E6C',border:'0',
          display:'flex',alignItems:'center',justifyContent:'center',color:'#fff',fontSize:16,
        }}>➤</div>
      </div>
    </div>
  );
}

Object.assign(window, {Wallet, Affiliate, Cart, Tracking, Chat});
