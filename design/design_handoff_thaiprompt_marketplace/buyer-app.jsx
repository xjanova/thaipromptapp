// BuyerApp: wraps existing Home/Product/Shop/Cart/Tracking/Chat/Wallet/Affiliate/Profile with navigation
function BuyerApp(){
  const [screen, setScreen] = React.useState('home');
  const go = (s)=>setScreen(s);
  const V = {
    home: Home, product: Product, shop: Shop, cart: Cart, tracking: Tracking,
    chat: Chat, wallet: Wallet, affiliate: Affiliate, profile: Profile,
    search: BuyerSearch, categories: BuyerCategories, orders: BuyerOrders,
    address: BuyerAddress, coupons: BuyerCoupons, noti: BuyerNoti,
    checkout: CkAddress, paid: BuyerPaid, review: BuyerReview,
    ckAddress: CkAddress, ckPayment: CkPayment, ckQR: CkQR, ckReceipt: CkReceipt
  }[screen] || Home;
  const hideTab = ['product','shop','cart','tracking','chat','search','address','coupons','noti','categories','orders','checkout','paid','review','ckAddress','ckPayment','ckQR','ckReceipt'].includes(screen);
  return (
    <div style={{display:'flex',flexDirection:'column',minHeight:'100%'}}>
      <div style={{flex:1,minHeight:0}}><V go={go}/></div>
      {!hideTab && <BuyerTab screen={screen} go={go}/>}
    </div>
  );
}

function TabIcon({name, active}){
  const s = {width:22,height:22,fill:'none',stroke:'currentColor',strokeWidth:active?2.4:2,strokeLinecap:'round',strokeLinejoin:'round'};
  switch(name){
    case 'home': return (<svg viewBox="0 0 24 24" style={s}><path d="M3 11.5 12 4l9 7.5"/><path d="M5 10v9a1 1 0 0 0 1 1h4v-6h4v6h4a1 1 0 0 0 1-1v-9"/></svg>);
    case 'categories': return (<svg viewBox="0 0 24 24" style={s}><rect x="3.5" y="3.5" width="7" height="7" rx="1.8"/><rect x="13.5" y="3.5" width="7" height="7" rx="1.8"/><rect x="3.5" y="13.5" width="7" height="7" rx="1.8"/><rect x="13.5" y="13.5" width="7" height="7" rx="1.8"/></svg>);
    case 'orders': case 'bag': return (<svg viewBox="0 0 24 24" style={s}><path d="M5 7h14l-1.2 11.2a2 2 0 0 1-2 1.8H8.2a2 2 0 0 1-2-1.8L5 7Z"/><path d="M9 7V5.5A2.5 2.5 0 0 1 11.5 3h1A2.5 2.5 0 0 1 15 5.5V7"/><path d="M9 12h6"/></svg>);
    case 'wallet': return (<svg viewBox="0 0 24 24" style={s}><path d="M3.5 8a2 2 0 0 1 2-2H18a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H5.5a2 2 0 0 1-2-2V8Z"/><path d="M3.5 10h17"/><circle cx="16.5" cy="14.5" r="1.2" fill="currentColor" stroke="none"/></svg>);
    case 'profile': return (<svg viewBox="0 0 24 24" style={s}><circle cx="12" cy="8.5" r="3.5"/><path d="M5 20c1.2-3.6 4-5.5 7-5.5s5.8 1.9 7 5.5"/></svg>);
    case 'dash': return (<svg viewBox="0 0 24 24" style={s}><path d="M4 13v6a1 1 0 0 0 1 1h4v-5h6v5h4a1 1 0 0 0 1-1v-6"/><path d="M3 12 12 4l9 8"/></svg>);
    case 'products': return (<svg viewBox="0 0 24 24" style={s}><path d="m12 3 8 4.5v9L12 21l-8-4.5v-9L12 3Z"/><path d="m4 7.5 8 4.5 8-4.5"/><path d="M12 12v9"/></svg>);
    case 'reports': return (<svg viewBox="0 0 24 24" style={s}><path d="M4 20V9"/><path d="M10 20V5"/><path d="M16 20v-8"/><path d="M3 20h18"/></svg>);
    case 'jobs': return (<svg viewBox="0 0 24 24" style={s}><path d="M4 6h16"/><path d="M4 12h16"/><path d="M4 18h10"/></svg>);
    case 'bike': return (<svg viewBox="0 0 24 24" style={s}><circle cx="6" cy="17" r="3"/><circle cx="18" cy="17" r="3"/><path d="m8 17 3-7h4l3 7"/><path d="M11 10 9 6H6"/></svg>);
    case 'earnings': return (<svg viewBox="0 0 24 24" style={s}><circle cx="12" cy="12" r="8.5"/><path d="M9.5 9h4.25a1.75 1.75 0 0 1 0 3.5H9.5"/><path d="M9.5 12.5h4.75a1.75 1.75 0 0 1 0 3.5H9.5"/><path d="M9.5 7.5v9"/></svg>);
    case 'tree': return (<svg viewBox="0 0 24 24" style={s}><circle cx="12" cy="5" r="2.2"/><circle cx="6" cy="18" r="2.2"/><circle cx="12" cy="18" r="2.2"/><circle cx="18" cy="18" r="2.2"/><path d="M12 7.2v4m0 0H6v4.6m6-4.6v4.6m0-4.6h6v4.6"/></svg>);
    case 'invite': return (<svg viewBox="0 0 24 24" style={s}><circle cx="9" cy="8.5" r="3.2"/><path d="M3 19c.8-3 3.2-4.8 6-4.8s5.2 1.8 6 4.8"/><path d="M17 7v5m2.5-2.5h-5"/></svg>);
    case 'withdraw': return (<svg viewBox="0 0 24 24" style={s}><path d="M3.5 8a2 2 0 0 1 2-2H18a2 2 0 0 1 2 2v9a2 2 0 0 1-2 2H5.5a2 2 0 0 1-2-2V8Z"/><path d="M12 10v6"/><path d="m9.5 13.5 2.5 2.5 2.5-2.5"/></svg>);
    default: return (<svg viewBox="0 0 24 24" style={s}><circle cx="12" cy="12" r="3"/></svg>);
  }
}

function AppTabBar({items, screen, go, accent='#FFC94D', accentText='#0E0B1F', onDark=false}){
  return (
    <div style={{position:'sticky',bottom:0,padding:'10px 12px 16px',background: onDark ? 'linear-gradient(to top, rgba(14,11,31,.9) 55%, rgba(14,11,31,0))' : 'linear-gradient(to top, #FFF8EE 55%, rgba(255,248,238,0))', zIndex:5}}>
      <div style={{display:'flex',alignItems:'center',gap:4,padding:6,background:'#0E0B1F',borderRadius:22,boxShadow:'0 10px 28px -10px rgba(14,11,31,.55), inset 0 0 0 1px rgba(255,255,255,.06)'}}>
        {items.map(it=>{
          const on = screen===it.id;
          return (
            <button key={it.id} onClick={()=>go(it.id)} style={{
              position:'relative',
              flex: on ? '1 1 auto' : '0 0 auto',
              minWidth: on ? 0 : 46,
              height:46,
              border:0,
              background: on ? accent : 'transparent',
              color: on ? accentText : 'rgba(255,255,255,.78)',
              borderRadius:16,
              display:'flex',alignItems:'center',justifyContent:'center',gap:7,
              padding: on ? '0 16px' : 0,
              cursor:'pointer',
              fontFamily:'inherit',
              fontWeight:800,
              fontSize:12,
              letterSpacing:'.01em',
              transition:'all .28s cubic-bezier(.5,1.4,.5,1)',
              boxShadow: on ? `0 10px 18px -8px ${accent}99` : 'none',
            }}>
              <TabIcon name={it.icon||it.id} active={on}/>
              {on && <span style={{whiteSpace:'nowrap'}}>{it.l}</span>}
              {it.b && <span style={{position:'absolute',top:4,right:on?10:6,background:'#FF3E6C',color:'#fff',borderRadius:999,fontSize:9,minWidth:14,height:14,padding:'0 4px',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:800,border:'2px solid #0E0B1F',boxSizing:'content-box'}}>{it.b}</span>}
            </button>
          );
        })}
      </div>
    </div>
  );
}

window.AppTabBar = AppTabBar;
window.TabIcon = TabIcon;

function BuyerTab({screen, go}){
  const items = [
    {id:'home',l:'หน้าแรก'},
    {id:'categories',l:'หมวด'},
    {id:'orders',l:'ออเดอร์'},
    {id:'wallet',l:'Wallet'},
    {id:'profile',l:'ฉัน'},
  ];
  return <AppTabBar items={items} screen={screen} go={go} accent="#FFC94D" accentText="#0E0B1F"/>;
}

function BuyerHeader({title,sub,go,back='home'}){
  return (
    <div style={{padding:'14px 16px',display:'flex',alignItems:'center',gap:10,background:'#FFF8EE',}}>
      <button onClick={()=>go(back)} style={{width:34,height:34,borderRadius:12,background:'#fff',fontWeight:900,cursor:'pointer',fontFamily:'inherit'}}>←</button>
      <div style={{flex:1}}>
        {sub && <div className="mono" style={{fontSize:9,letterSpacing:'.18em',color:'#6E6A85'}}>{sub}</div>}
        <div style={{fontWeight:900,fontSize:16}}>{title}</div>
      </div>
    </div>
  );
}

function BuyerSearch({go}){
  const hot = ['ข้าวซอย','ส้มตำ','ขนมเปี๊ยะ','หมูทอด','น้ำพริก','ปลาร้า'];
  const recent = ['ร้านครัวยายปราณี','ลุงโต ก๋วยเตี๋ยว','ขนมไทยนิดา'];
  return (
    <div style={{background:'#FFF8EE',minHeight:'100%'}}>
      <div style={{padding:'14px 16px',display:'flex',alignItems:'center',gap:8,background:'#FFC94D'}}>
        <button onClick={()=>go('home')} style={{width:34,height:34,borderRadius:12,background:'#fff',fontWeight:900,fontFamily:'inherit',cursor:'pointer'}}>←</button>
        <div style={{flex:1,display:'flex',alignItems:'center',gap:8,padding:'10px 12px',background:'#fff',borderRadius:14,boxShadow:'var(--clay-sm)'}}>
          <span style={{fontSize:14}}>🔍</span>
          <input placeholder="ค้นหาร้าน · สินค้า · ของอร่อย" style={{flex:1,border:0,outline:'none',fontFamily:'inherit',fontSize:13,background:'transparent'}}/>
        </div>
      </div>

      <H th="ยอดนิยม" en="Hot searches"/>
      <div style={{padding:'0 16px',display:'flex',flexWrap:'wrap',gap:6}}>
        {hot.map((t,i)=>(
          <span key={t} style={{padding:'7px 12px',borderRadius:999,background:i<2?'#FF3E6C':'#fff',color:i<2?'#fff':'#0E0B1F',fontWeight:700,fontSize:11,boxShadow:'var(--clay-sm)'}}>
            {i<2 && '🔥 '}{t}
          </span>
        ))}
      </div>

      <H th="ค้นล่าสุด" en="Recent"/>
      <div style={{padding:'0 16px 20px',display:'flex',flexDirection:'column',gap:6}}>
        {recent.map(r=>(
          <div key={r} style={{padding:'10px 12px',borderRadius:14,background:'#fff',display:'flex',alignItems:'center',gap:10,boxShadow:'var(--clay-sm)'}}>
            <span style={{fontSize:13,color:'#6E6A85'}}>↺</span>
            <div style={{flex:1,fontSize:12,fontWeight:600}}>{r}</div>
            <span style={{fontSize:18,color:'#6E6A85'}}>↖</span>
          </div>
        ))}
      </div>
    </div>
  );
}

function BuyerCategories({go}){
  const cats = [
    {i:'🍜',n:'อาหาร',c:'#FF3E6C',num:240},
    {i:'🍰',n:'ขนม',c:'#FFC94D',num:182},
    {i:'🥤',n:'เครื่องดื่ม',c:'#00D4B4',num:98},
    {i:'🧺',n:'หัตถกรรม',c:'#6B4BFF',num:64},
    {i:'👗',n:'แฟชั่น',c:'#FF7A3A',num:120},
    {i:'🌿',n:'เกษตร',c:'#2F7A5F',num:56},
    {i:'🧴',n:'ความงาม',c:'#E4405F',num:42},
    {i:'📚',n:'ของใช้',c:'#C9B8FF',num:88},
  ];
  return (
    <div style={{background:'#FFF8EE',minHeight:'100%'}}>
      <BuyerHeader title="หมวดสินค้าทั้งหมด" sub="CATEGORIES" go={go}/>
      <div style={{padding:'14px 16px',display:'grid',gridTemplateColumns:'1fr 1fr',gap:10}}>
        {cats.map(c=>(
          <div key={c.n} onClick={()=>go('home')} style={{padding:14,borderRadius:18,background:c.c,boxShadow:'var(--clay)',cursor:'pointer',color:c.c==='#FFC94D'?'#0E0B1F':'#fff'}}>
            <div style={{fontSize:30}}>{c.i}</div>
            <div style={{fontWeight:900,fontSize:14,marginTop:4}}>{c.n}</div>
            <div className="mono" style={{fontSize:10,opacity:.85}}>{c.num} ร้าน</div>
          </div>
        ))}
      </div>
    </div>
  );
}

function BuyerOrders({go}){
  const orders = [
    {id:'#TP-8821',s:'ครัวยายปราณี',st:'กำลังส่ง',c:'#FFC94D',p:185,i:'🍜'},
    {id:'#TP-8815',s:'ขนมไทยนิดา',st:'ถึงแล้ว',c:'#00D4B4',p:120,i:'🍰'},
    {id:'#TP-8803',s:'ลุงโต ก๋วยเตี๋ยว',st:'รอรีวิว',c:'#FF3E6C',p:95,i:'🍜'},
    {id:'#TP-8790',s:'ร้านน้ำพริกป้าสม',st:'ส่งเรียบร้อย',c:'#6E6A85',p:140,i:'🌶'},
  ];
  return (
    <div style={{background:'#FFF8EE',minHeight:'100%'}}>
      <BuyerHeader title="ออเดอร์ของฉัน" sub="MY ORDERS" go={go}/>
      <div style={{padding:'10px 16px 0',display:'flex',gap:6}}>
        {['ทั้งหมด','กำลังมา','เสร็จแล้ว','ยกเลิก'].map((t,i)=>(
          <span key={t} style={{padding:'6px 12px',borderRadius:999,background:i===0?'#0E0B1F':'#fff',color:i===0?'#FFC94D':'#0E0B1F',fontWeight:700,fontSize:11}}>{t}</span>
        ))}
      </div>
      <div style={{padding:'14px 16px 20px',display:'flex',flexDirection:'column',gap:10}}>
        {orders.map(o=>(
          <div key={o.id} onClick={()=>go('tracking')} style={{padding:12,borderRadius:18,background:'#fff',boxShadow:'var(--clay)',cursor:'pointer'}}>
            <div style={{display:'flex',alignItems:'center',gap:10}}>
              <div style={{width:48,height:48,borderRadius:14,background:o.c,display:'flex',alignItems:'center',justifyContent:'center',fontSize:22,}}>{o.i}</div>
              <div style={{flex:1,minWidth:0}}>
                <div style={{fontWeight:800,fontSize:13}}>{o.s}</div>
                <div className="mono" style={{fontSize:10,color:'#6E6A85'}}>{o.id}</div>
              </div>
              <div style={{textAlign:'right'}}>
                <div className="display" style={{fontSize:16}}>฿{o.p}</div>
                <div style={{fontSize:9,fontWeight:800,padding:'2px 8px',borderRadius:999,background:o.c,color:o.c==='#FFC94D'?'#0E0B1F':'#fff',display:'inline-block',marginTop:2}}>{o.st}</div>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function BuyerAddress({go}){
  const addrs = [{n:'บ้าน',d:'ซ.สุขุมวิท 36 กรุงเทพ 10110',def:true,c:'#FFC94D'},{n:'ออฟฟิศ',d:'อาคารเอ็มไพร์ สาทร 10500',c:'#00D4B4'},{n:'บ้านแม่',d:'ซ.รามคำแหง 24 กรุงเทพ 10240',c:'#FF3E6C'}];
  return (
    <div style={{background:'#FFF8EE',minHeight:'100%'}}>
      <BuyerHeader title="ที่อยู่จัดส่ง" sub="ADDRESSES" go={go} back="profile"/>
      <div style={{padding:'14px 16px 20px',display:'flex',flexDirection:'column',gap:10}}>
        {addrs.map(a=>(
          <div key={a.n} style={{padding:14,borderRadius:18,background:'#fff',boxShadow:'var(--clay)',display:'flex',gap:10}}>
            <div style={{width:40,height:40,borderRadius:12,background:a.c,display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900}}>📍</div>
            <div style={{flex:1}}>
              <div style={{display:'flex',alignItems:'center',gap:6}}>
                <div style={{fontWeight:900,fontSize:14}}>{a.n}</div>
                {a.def && <span style={{fontSize:9,padding:'1px 6px',borderRadius:5,background:'#0E0B1F',color:'#FFC94D',fontWeight:800}}>ค่าเริ่มต้น</span>}
              </div>
              <div style={{fontSize:11,color:'#2A2640',marginTop:3}}>{a.d}</div>
            </div>
          </div>
        ))}
        <button className="btn" style={{background:'#0E0B1F',color:'#FFC94D',padding:'12px'}}>+ เพิ่มที่อยู่</button>
      </div>
    </div>
  );
}

function BuyerCoupons({go}){
  const cp = [{t:'ส่วนลด ฿50',d:'ขั้นต่ำ ฿200 · ใช้ได้ทุกร้าน',e:'หมด 30 เม.ย.',c:'#FF3E6C'},{t:'ส่งฟรี',d:'รัศมี 5 กม. · ไม่มีขั้นต่ำ',e:'หมด 25 เม.ย.',c:'#FFC94D'},{t:'ลด 15%',d:'ร้านอาหารเท่านั้น',e:'หมด 30 เม.ย.',c:'#00D4B4'}];
  return (
    <div style={{background:'#FFF8EE',minHeight:'100%'}}>
      <BuyerHeader title="คูปองของฉัน" sub="COUPONS" go={go} back="profile"/>
      <div style={{padding:'14px 16px 20px',display:'flex',flexDirection:'column',gap:10}}>
        {cp.map(c=>(
          <div key={c.t} style={{display:'flex',borderRadius:18,overflow:'hidden',boxShadow:'var(--clay)'}}>
            <div style={{width:90,background:c.c,color:c.c==='#FFC94D'?'#0E0B1F':'#fff',padding:12,display:'flex',flexDirection:'column',justifyContent:'center',textAlign:'center',borderRight:'1px dashed rgba(14,11,31,.2)',}}>
              <div className="display" style={{fontSize:18,lineHeight:1.1}}>{c.t}</div>
            </div>
            <div style={{flex:1,padding:12,background:'#fff'}}>
              <div style={{fontSize:12,fontWeight:700}}>{c.d}</div>
              <div className="mono" style={{fontSize:10,color:'#6E6A85',marginTop:3}}>{c.e}</div>
              <button className="btn" style={{marginTop:6,background:'#FFC94D',color:'#0E0B1F',padding:'5px 12px',fontSize:11}}>ใช้เลย</button>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

function BuyerNoti({go}){
  const n = [{t:'ออเดอร์ #TP-8821 ถึงแล้ว',d:'5 นาทีที่แล้ว',i:'📦',c:'#00D4B4'},{t:'คูปองใหม่! ลด ฿50',d:'30 นาทีที่แล้ว',i:'🎁',c:'#FF3E6C'},{t:'ร้านนิดา ลดราคา 3 รายการ',d:'2 ชม.',i:'🏷',c:'#FFC94D'},{t:'MLM: คุณได้คอม ฿64',d:'เช้า',i:'฿',c:'#6B4BFF'}];
  return (
    <div style={{background:'#FFF8EE',minHeight:'100%'}}>
      <BuyerHeader title="การแจ้งเตือน" sub="NOTIFICATIONS" go={go}/>
      <div style={{padding:'14px 16px 20px',display:'flex',flexDirection:'column',gap:8}}>
        {n.map((x,i)=>(
          <div key={i} style={{padding:12,borderRadius:14,background:'#fff',boxShadow:'var(--clay-sm)',display:'flex',gap:10,alignItems:'center'}}>
            <div style={{width:40,height:40,borderRadius:12,background:x.c,color:'#fff',display:'flex',alignItems:'center',justifyContent:'center',fontSize:18,}}>{x.i}</div>
            <div style={{flex:1}}>
              <div style={{fontWeight:800,fontSize:12}}>{x.t}</div>
              <div className="mono" style={{fontSize:10,color:'#6E6A85'}}>{x.d}</div>
            </div>
            {i<2 && <span style={{width:8,height:8,borderRadius:'50%',background:'#FF3E6C'}}/>}
          </div>
        ))}
      </div>
    </div>
  );
}

function BuyerCheckout({go}){
  return (
    <div style={{background:'#FFF8EE',minHeight:'100%'}}>
      <BuyerHeader title="ชำระเงิน" sub="CHECKOUT" go={go} back="cart"/>
      <div style={{padding:'14px 16px',display:'flex',flexDirection:'column',gap:10}}>
        <div className="chunk" style={{padding:14,display:'flex',gap:10,alignItems:'center'}}>
          <div style={{width:44,height:44,borderRadius:14,background:'#FFC94D',display:'flex',alignItems:'center',justifyContent:'center',boxShadow:'var(--clay-sm)',fontSize:20}}>📍</div>
          <div style={{flex:1}}>
            <div style={{fontWeight:800,fontSize:13}}>บ้าน · ค่าเริ่มต้น</div>
            <div style={{fontSize:11,color:'#6E6A85'}}>ซ.สุขุมวิท 36 กรุงเทพ 10110</div>
          </div>
          <span style={{color:'#8A7FA3'}}>›</span>
        </div>

        <div className="chunk" style={{padding:14}}>
          <div className="mono" style={{fontSize:10,letterSpacing:'.15em',color:'#6E6A85'}}>วิธีชำระเงิน</div>
          {[{n:'PromptPay',d:'xxx-xxx-4821',on:true,c:'#6B4BFF',i:'P'},{n:'บัตรเครดิต',d:'Visa •••• 2847',c:'#FF3E6C',i:'▭'},{n:'Thaiprompt Wallet',d:'คงเหลือ ฿2,480',c:'#FFC94D',i:'฿'},{n:'เก็บเงินปลายทาง',d:'COD · ค่าส่ง +฿10',c:'#00D4B4',i:'✋'}].map((p,i)=>(
            <div key={i} style={{padding:'10px 0',display:'flex',alignItems:'center',gap:10,borderTop:i?'1px dashed rgba(14,11,31,.1)':'none'}}>
              <div style={{width:36,height:36,borderRadius:12,background:p.c,color:'#fff',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900,boxShadow:'var(--clay-sm)'}}>{p.i}</div>
              <div style={{flex:1}}>
                <div style={{fontWeight:700,fontSize:12}}>{p.n}</div>
                <div style={{fontSize:10,color:'#6E6A85'}}>{p.d}</div>
              </div>
              <div style={{width:20,height:20,borderRadius:'50%',background:p.on?'#00D4B4':'transparent',boxShadow:'var(--clay-sm)',display:'flex',alignItems:'center',justifyContent:'center',color:'#fff',fontWeight:900,fontSize:11}}>{p.on && '✓'}</div>
            </div>
          ))}
        </div>

        <div className="chunk" style={{padding:14}}>
          <div className="mono" style={{fontSize:10,letterSpacing:'.15em',color:'#6E6A85',marginBottom:6}}>สรุปยอด</div>
          {[['ยอดรวม','฿185'],['ค่าส่ง','฿20'],['ใช้ Coins','-฿15'],['คูปอง ส่งฟรี','-฿20']].map((r,i)=>(
            <div key={i} style={{display:'flex',justifyContent:'space-between',padding:'4px 0',fontSize:12}}>
              <span style={{color:'#6E6A85'}}>{r[0]}</span><span style={{fontWeight:700}}>{r[1]}</span>
            </div>
          ))}
          <div style={{marginTop:8,paddingTop:8,borderTop:'1.5px dashed rgba(14,11,31,.15)',display:'flex',justifyContent:'space-between',alignItems:'baseline'}}>
            <span style={{fontWeight:800,fontSize:13}}>ต้องจ่าย</span>
            <span className="display" style={{fontSize:24,color:'#FF3E6C'}}>฿170</span>
          </div>
        </div>

        <button onClick={()=>go('paid')} className="btn pink" style={{padding:'14px',fontSize:14}}>ยืนยันสั่งซื้อ · ฿170</button>
      </div>
    </div>
  );
}

function BuyerPaid({go}){
  return (
    <div style={{background:'linear-gradient(160deg,#00D4B4,#FFC94D)',minHeight:'100%',display:'flex',flexDirection:'column',alignItems:'center',justifyContent:'center',padding:'40px 24px',color:'#2A1F3D',textAlign:'center'}}>
      <div style={{width:110,height:110,borderRadius:'50%',background:'#fff',display:'flex',alignItems:'center',justifyContent:'center',fontSize:54,boxShadow:'var(--clay-lg)',marginBottom:20}}>✓</div>
      <div className="mono" style={{fontSize:11,letterSpacing:'.2em',opacity:.7}}>PAYMENT SUCCESS</div>
      <div className="display" style={{fontSize:30,marginTop:4}}>ชำระเงินสำเร็จ</div>
      <div style={{fontSize:13,marginTop:4,opacity:.85}}>ออเดอร์ #TP-8821 · ฿170</div>
      <div style={{marginTop:20,padding:14,borderRadius:20,background:'rgba(255,255,255,.85)',backdropFilter:'blur(10px)',boxShadow:'var(--clay)',width:'100%',maxWidth:280}}>
        <div style={{fontSize:12,fontWeight:700}}>ครัวยายปราณี กำลังเตรียมของ</div>
        <div style={{fontSize:11,color:'#6E6A85',marginTop:2}}>ประมาณ 25-35 นาที · ส่งถึงบ้าน</div>
      </div>
      <div style={{display:'flex',gap:8,marginTop:20,width:'100%',maxWidth:280}}>
        <button onClick={()=>go('ckReceipt')} className="btn ghost" style={{flex:1,fontSize:12}}>ใบเสร็จ</button>
        <button onClick={()=>go('tracking')} className="btn pink" style={{flex:1,fontSize:12}}>ติดตามออเดอร์ →</button>
      </div>
    </div>
  );
}

function BuyerReview({go}){
  const [star, setStar] = React.useState(5);
  return (
    <div style={{background:'#FFF8EE',minHeight:'100%'}}>
      <BuyerHeader title="รีวิวออเดอร์" sub="REVIEW" go={go} back="orders"/>
      <div style={{padding:'14px 16px',display:'flex',flexDirection:'column',gap:12}}>
        <div className="chunk" style={{padding:14,textAlign:'center'}}>
          <div style={{width:60,height:60,borderRadius:18,background:'#FFC94D',margin:'0 auto',display:'flex',alignItems:'center',justifyContent:'center',fontSize:30,boxShadow:'var(--clay-sm)'}}>🍜</div>
          <div style={{fontWeight:900,fontSize:15,marginTop:8}}>ข้าวซอยไก่ · ครัวยายปราณี</div>
          <div style={{fontSize:11,color:'#6E6A85'}}>ออเดอร์ #TP-8790 · เมื่อวาน</div>
        </div>

        <div className="chunk" style={{padding:16,textAlign:'center'}}>
          <div className="mono" style={{fontSize:10,letterSpacing:'.15em',color:'#6E6A85'}}>ให้คะแนน</div>
          <div style={{display:'flex',justifyContent:'center',gap:6,marginTop:10}}>
            {[1,2,3,4,5].map(n=>(
              <button key={n} onClick={()=>setStar(n)} style={{border:0,background:'transparent',cursor:'pointer',fontSize:36,lineHeight:1,color:n<=star?'#FFC94D':'#E0D9C6',fontFamily:'inherit'}}>★</button>
            ))}
          </div>
          <div style={{fontSize:12,fontWeight:700,marginTop:8,color:'#FF3E6C'}}>{star===5?'ดีเยี่ยม!':star>=4?'ชอบมาก':star>=3?'ใช้ได้':'ปรับปรุงนะ'}</div>
        </div>

        <div className="chunk" style={{padding:14}}>
          <div className="mono" style={{fontSize:10,letterSpacing:'.15em',color:'#6E6A85'}}>แท็ก</div>
          <div style={{display:'flex',flexWrap:'wrap',gap:6,marginTop:8}}>
            {['อร่อย','ส่งเร็ว','บรรจุดี','คุ้มราคา','สะอาด','ไรเดอร์สุภาพ'].map((t,i)=>(
              <span key={t} style={{padding:'5px 11px',borderRadius:999,background:i<3?'#FFC94D':'#fff',boxShadow:'var(--clay-sm)',fontSize:10,fontWeight:700}}>✓ {t}</span>
            ))}
          </div>
        </div>

        <div className="chunk" style={{padding:14}}>
          <div className="mono" style={{fontSize:10,letterSpacing:'.15em',color:'#6E6A85',marginBottom:6}}>ข้อความถึงร้าน (ไม่บังคับ)</div>
          <textarea placeholder="ของอร่อย ส่งเร็วมากเลยค่ะ ขอบคุณมากนะคะ 🙏" style={{width:'100%',minHeight:60,border:0,outline:'none',resize:'none',fontFamily:'inherit',fontSize:12,padding:10,borderRadius:12,background:'#FFF8EE',boxShadow:'inset 0 2px 4px rgba(70,42,92,.1)'}}/>
        </div>

        <button onClick={()=>go('orders')} className="btn pink" style={{padding:'14px',fontSize:14}}>ส่งรีวิว</button>
      </div>
    </div>
  );
}

// ============= Checkout multi-step flow =============
function CkProgress({step}){
  const steps = ['ที่อยู่','วิธีจ่าย','ยืนยัน','สำเร็จ'];
  return (
    <div style={{padding:'10px 16px 4px',display:'flex',gap:4,alignItems:'center'}}>
      {steps.map((s,i)=>(
        <React.Fragment key={s}>
          <div style={{display:'flex',alignItems:'center',gap:6}}>
            <div style={{width:22,height:22,borderRadius:'50%',background:i<=step?'#FF3E6C':'rgba(14,11,31,.12)',color:i<=step?'#fff':'#6E6A85',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900,fontSize:11,boxShadow:i<=step?'var(--clay-sm)':'none'}}>{i<step?'✓':i+1}</div>
            <div style={{fontSize:10,fontWeight:700,color:i===step?'#0E0B1F':'#6E6A85'}}>{s}</div>
          </div>
          {i<steps.length-1 && <div style={{flex:1,height:2,background:i<step?'#FF3E6C':'rgba(14,11,31,.1)',borderRadius:1}}/>}
        </React.Fragment>
      ))}
    </div>
  );
}

function CkAddress({go}){
  const [sel, setSel] = React.useState(0);
  const addrs = [{n:'บ้าน',d:'ซ.สุขุมวิท 36 อาคาร B ชั้น 7 · 10110',c:'#FFC94D',i:'🏠',eta:'25 นาที'},{n:'ออฟฟิศ',d:'อาคารเอ็มไพร์ ชั้น 24 · สาทร 10500',c:'#00D4B4',i:'🏢',eta:'35 นาที'},{n:'บ้านแม่',d:'ซ.รามคำแหง 24 · 10240',c:'#FF3E6C',i:'💝',eta:'50 นาที'}];
  return (
    <div style={{background:'#FFF8EE',minHeight:'100%'}}>
      <BuyerHeader title="เลือกที่อยู่จัดส่ง" sub="CHECKOUT · STEP 1/4" go={go} back="cart"/>
      <CkProgress step={0}/>
      <div style={{padding:'10px 16px 0',display:'flex',flexDirection:'column',gap:10}}>
        {addrs.map((a,i)=>(
          <div key={i} onClick={()=>setSel(i)} className="chunk" style={{padding:14,display:'flex',gap:12,alignItems:'center',cursor:'pointer',outline:sel===i?'3px solid #FF3E6C':'none',outlineOffset:-1}}>
            <div style={{width:46,height:46,borderRadius:14,background:a.c,display:'flex',alignItems:'center',justifyContent:'center',fontSize:22,boxShadow:'var(--clay-sm)'}}>{a.i}</div>
            <div style={{flex:1,minWidth:0}}>
              <div style={{display:'flex',alignItems:'center',gap:6}}>
                <div style={{fontWeight:900,fontSize:14}}>{a.n}</div>
                <span className="mono" style={{fontSize:9,padding:'2px 7px',borderRadius:5,background:'#00D4B4',color:'#fff',fontWeight:800}}>{a.eta}</span>
              </div>
              <div style={{fontSize:11,color:'#2A2640',marginTop:2}}>{a.d}</div>
            </div>
            <div style={{width:22,height:22,borderRadius:'50%',background:sel===i?'#FF3E6C':'transparent',boxShadow:'var(--clay-sm)',display:'flex',alignItems:'center',justifyContent:'center',color:'#fff',fontWeight:900,fontSize:13}}>{sel===i && '✓'}</div>
          </div>
        ))}
        <button className="btn ghost" style={{padding:'10px',fontSize:12}}>+ เพิ่มที่อยู่ใหม่</button>
      </div>
      <div style={{padding:'16px',marginTop:10,position:'sticky',bottom:0,background:'rgba(255,248,238,.95)',backdropFilter:'blur(10px)'}}>
        <button onClick={()=>go('ckPayment')} className="btn pink" style={{width:'100%',padding:14,fontSize:14}}>ถัดไป · เลือกวิธีจ่าย →</button>
      </div>
    </div>
  );
}

function CkPayment({go}){
  const [sel, setSel] = React.useState(0);
  const methods = [
    {n:'PromptPay QR',d:'สแกนจ่ายทันที · xxx-xxx-4821',c:'#6B4BFF',i:'QR',tag:'แนะนำ'},
    {n:'Thaiprompt Wallet',d:'คงเหลือ ฿2,480',c:'#FFC94D',i:'฿',tag:'เร็วสุด'},
    {n:'บัตรเครดิต',d:'Visa ••• 2847',c:'#FF3E6C',i:'▭'},
    {n:'TrueMoney Wallet',d:'เชื่อมแล้ว',c:'#FF7A3A',i:'T'},
    {n:'เก็บเงินปลายทาง',d:'COD · ค่าส่ง +฿10',c:'#00D4B4',i:'✋'},
  ];
  return (
    <div style={{background:'#FFF8EE',minHeight:'100%'}}>
      <BuyerHeader title="เลือกวิธีชำระเงิน" sub="CHECKOUT · STEP 2/4" go={go} back="ckAddress"/>
      <CkProgress step={1}/>
      <div style={{padding:'10px 16px 0',display:'flex',flexDirection:'column',gap:8}}>
        {methods.map((m,i)=>(
          <div key={i} onClick={()=>setSel(i)} className="chunk" style={{padding:12,display:'flex',gap:10,alignItems:'center',cursor:'pointer',outline:sel===i?'3px solid #FF3E6C':'none',outlineOffset:-1}}>
            <div style={{width:42,height:42,borderRadius:12,background:m.c,color:'#fff',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900,fontSize:14,boxShadow:'var(--clay-sm)'}}>{m.i}</div>
            <div style={{flex:1}}>
              <div style={{display:'flex',alignItems:'center',gap:6}}>
                <div style={{fontWeight:800,fontSize:13}}>{m.n}</div>
                {m.tag && <span style={{fontSize:9,padding:'1px 6px',borderRadius:5,background:'#FFC94D',color:'#2A1F3D',fontWeight:800}}>{m.tag}</span>}
              </div>
              <div style={{fontSize:10,color:'#6E6A85',marginTop:1}}>{m.d}</div>
            </div>
            <div style={{width:22,height:22,borderRadius:'50%',background:sel===i?'#FF3E6C':'transparent',boxShadow:'var(--clay-sm)',display:'flex',alignItems:'center',justifyContent:'center',color:'#fff',fontWeight:900,fontSize:13}}>{sel===i && '✓'}</div>
          </div>
        ))}

        <div className="chunk" style={{padding:12,marginTop:6}}>
          <div className="mono" style={{fontSize:10,letterSpacing:'.15em',color:'#6E6A85',marginBottom:6}}>คูปอง & โค้ด</div>
          <div style={{display:'flex',gap:6}}>
            <input placeholder="กรอกโค้ดส่วนลด" style={{flex:1,padding:'8px 10px',border:0,borderRadius:10,background:'#FFF8EE',fontFamily:'inherit',fontSize:12,boxShadow:'inset 0 2px 4px rgba(70,42,92,.1)',outline:'none'}}/>
            <button className="btn ghost" style={{padding:'8px 14px',fontSize:11}}>ใช้</button>
          </div>
        </div>

        <div className="chunk" style={{padding:12}}>
          <div className="mono" style={{fontSize:10,letterSpacing:'.15em',color:'#6E6A85',marginBottom:4}}>สรุปยอด</div>
          {[['ยอดสินค้า','฿185'],['ค่าส่ง','฿20'],['ส่วนลด','-฿35']].map((r,i)=>(
            <div key={i} style={{display:'flex',justifyContent:'space-between',padding:'3px 0',fontSize:12}}><span style={{color:'#6E6A85'}}>{r[0]}</span><span style={{fontWeight:700}}>{r[1]}</span></div>
          ))}
          <div style={{marginTop:6,paddingTop:6,borderTop:'1.5px dashed rgba(14,11,31,.15)',display:'flex',justifyContent:'space-between',alignItems:'baseline'}}>
            <span style={{fontWeight:800,fontSize:13}}>ต้องจ่าย</span>
            <span className="display" style={{fontSize:24,color:'#FF3E6C'}}>฿170</span>
          </div>
        </div>
      </div>
      <div style={{padding:'16px',marginTop:10,position:'sticky',bottom:0,background:'rgba(255,248,238,.95)',backdropFilter:'blur(10px)'}}>
        <button onClick={()=>go(sel===0?'ckQR':'paid')} className="btn pink" style={{width:'100%',padding:14,fontSize:14}}>ยืนยันและจ่าย ฿170 →</button>
      </div>
    </div>
  );
}

function CkQR({go}){
  const [secs, setSecs] = React.useState(287);
  React.useEffect(()=>{
    const t = setInterval(()=>setSecs(s=>Math.max(0,s-1)),1000);
    return ()=>clearInterval(t);
  },[]);
  const mm = String(Math.floor(secs/60)).padStart(2,'0');
  const ss = String(secs%60).padStart(2,'0');
  return (
    <div style={{background:'#FFF8EE',minHeight:'100%'}}>
      <BuyerHeader title="สแกนเพื่อจ่าย" sub="PROMPTPAY QR · STEP 3/4" go={go} back="ckPayment"/>
      <CkProgress step={2}/>

      <div style={{padding:'14px 16px',display:'flex',flexDirection:'column',gap:10}}>
        <div className="chunk" style={{padding:20,textAlign:'center',background:'linear-gradient(180deg,#fff,#F1EBFF)'}}>
          <div style={{display:'flex',justifyContent:'center',alignItems:'center',gap:8,marginBottom:10}}>
            <div style={{width:32,height:32,borderRadius:10,background:'#6B4BFF',color:'#fff',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900,fontSize:14,boxShadow:'var(--clay-sm)'}}>P</div>
            <div className="display" style={{fontSize:18,color:'#6B4BFF',letterSpacing:'.05em'}}>PromptPay</div>
          </div>

          {/* Fake QR code */}
          <div style={{width:200,height:200,margin:'0 auto',borderRadius:20,background:'#fff',boxShadow:'var(--clay-lg)',padding:12,position:'relative'}}>
            <div style={{width:'100%',height:'100%',display:'grid',gridTemplateColumns:'repeat(14,1fr)',gap:1}}>
              {Array.from({length:196}).map((_,i)=>{
                const r = (i*31 + 7)%100;
                const corner = (i<30 && i%14<4) || (i<30 && i%14>=10) || (i>=168 && i%14<4);
                return <div key={i} style={{background:corner||r<55?'#0E0B1F':'transparent',borderRadius:1}}/>;
              })}
            </div>
            <div style={{position:'absolute',inset:'50% 50%',transform:'translate(-50%,-50%)',width:36,height:36,borderRadius:10,background:'#FF3E6C',color:'#fff',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900,boxShadow:'var(--clay-sm)'}}>฿</div>
          </div>

          <div className="display" style={{fontSize:30,marginTop:12,color:'#FF3E6C'}}>฿170.00</div>
          <div className="mono" style={{fontSize:10,color:'#6E6A85',letterSpacing:'.1em'}}>REF #TP-8821-9F4A</div>

          <div style={{marginTop:14,display:'inline-flex',alignItems:'center',gap:6,padding:'6px 14px',borderRadius:999,background:secs<60?'#FF3E6C':'#0E0B1F',color:'#fff',boxShadow:'var(--clay-sm)'}}>
            <span style={{width:6,height:6,borderRadius:'50%',background:'#FFC94D',animation:'pulse-ring 1.4s infinite'}}/>
            <span className="mono" style={{fontSize:11,fontWeight:700}}>รอการจ่าย · {mm}:{ss}</span>
          </div>
        </div>

        <div className="chunk" style={{padding:12}}>
          <div className="mono" style={{fontSize:10,letterSpacing:'.15em',color:'#6E6A85',marginBottom:6}}>วิธีสแกน</div>
          {['เปิดแอปธนาคาร/TrueMoney/ฯลฯ','เลือกเมนู "สแกน QR"','สแกนรหัสด้านบน และยืนยันการจ่าย'].map((t,i)=>(
            <div key={i} style={{display:'flex',gap:8,alignItems:'flex-start',padding:'4px 0',fontSize:11}}>
              <span style={{width:18,height:18,borderRadius:'50%',background:'#FFC94D',color:'#2A1F3D',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900,fontSize:10,flexShrink:0}}>{i+1}</span>
              <span>{t}</span>
            </div>
          ))}
        </div>

        <div style={{display:'flex',gap:8}}>
          <button className="btn ghost" style={{flex:1,padding:'10px',fontSize:12}}>📷 บันทึกรูป QR</button>
          <button onClick={()=>go('paid')} className="btn mint" style={{flex:1,padding:'10px',fontSize:12}}>ฉันจ่ายแล้ว ✓</button>
        </div>
      </div>
    </div>
  );
}

function CkReceipt({go}){
  return (
    <div style={{background:'#FFF8EE',minHeight:'100%'}}>
      <BuyerHeader title="ใบเสร็จ" sub="RECEIPT · #TP-8821" go={go} back="orders"/>
      <div style={{padding:'14px 16px',display:'flex',flexDirection:'column',gap:10}}>
        <div className="chunk" style={{padding:18,background:'#fff',position:'relative',overflow:'hidden'}}>
          <div style={{position:'absolute',top:0,left:0,right:0,height:6,background:'linear-gradient(90deg,#FF3E6C,#FFC94D,#00D4B4,#6B4BFF)'}}/>
          <div style={{display:'flex',justifyContent:'space-between',alignItems:'flex-start',marginTop:4}}>
            <div>
              <div style={{width:40,height:40,borderRadius:12,background:'#0E0B1F',color:'#FFC94D',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900,fontSize:20,boxShadow:'var(--clay-sm)'}}>T</div>
              <div className="display" style={{fontSize:16,marginTop:6}}>Thaiprompt</div>
              <div className="mono" style={{fontSize:9,color:'#6E6A85'}}>ใบเสร็จรับเงิน/ใบกำกับภาษี (อย่างย่อ)</div>
            </div>
            <div style={{textAlign:'right'}}>
              <div className="mono" style={{fontSize:9,color:'#6E6A85'}}>REF</div>
              <div className="display" style={{fontSize:14}}>#TP-8821</div>
              <div className="mono" style={{fontSize:9,color:'#6E6A85',marginTop:4}}>24 เม.ย. 26 · 09:42</div>
            </div>
          </div>

          <div style={{marginTop:14,padding:'10px 0',borderTop:'1.5px dashed rgba(14,11,31,.15)',borderBottom:'1.5px dashed rgba(14,11,31,.15)'}}>
            {[{n:'ข้าวซอยไก่ (กลาง)',q:1,p:85},{n:'+ ไข่ต้ม',q:1,p:10},{n:'น้ำอัญชัน',q:2,p:90}].map((x,i)=>(
              <div key={i} style={{display:'flex',justifyContent:'space-between',padding:'3px 0',fontSize:12}}>
                <span style={{flex:1}}>{x.n} <span className="mono" style={{color:'#6E6A85'}}>×{x.q}</span></span>
                <span style={{fontWeight:700}}>฿{x.p}</span>
              </div>
            ))}
          </div>

          {[['ยอดรวม','฿185'],['ค่าส่ง','฿20'],['ส่วนลด','-฿35']].map((r,i)=>(
            <div key={i} style={{display:'flex',justifyContent:'space-between',padding:'2px 0',fontSize:12}}>
              <span style={{color:'#6E6A85'}}>{r[0]}</span><span style={{fontWeight:700}}>{r[1]}</span>
            </div>
          ))}

          <div style={{marginTop:8,padding:'10px 12px',borderRadius:14,background:'#0E0B1F',color:'#FFC94D',display:'flex',justifyContent:'space-between',alignItems:'baseline',boxShadow:'var(--clay-sm)'}}>
            <span style={{fontWeight:700,fontSize:12}}>ยอดชำระ</span>
            <span className="display" style={{fontSize:22}}>฿170</span>
          </div>

          <div style={{marginTop:12,display:'flex',gap:8,fontSize:11}}>
            <div style={{flex:1,padding:10,borderRadius:12,background:'#DFFAF3'}}>
              <div className="mono" style={{fontSize:9,color:'#6E6A85'}}>จ่ายด้วย</div>
              <div style={{fontWeight:800,marginTop:2}}>PromptPay</div>
            </div>
            <div style={{flex:1,padding:10,borderRadius:12,background:'#FFE3EB'}}>
              <div className="mono" style={{fontSize:9,color:'#6E6A85'}}>ร้าน</div>
              <div style={{fontWeight:800,marginTop:2}}>ครัวยายปราณี</div>
            </div>
          </div>

          {/* barcode */}
          <div style={{marginTop:14,display:'flex',gap:1,height:40,justifyContent:'center'}}>
            {Array.from({length:60}).map((_,i)=>(
              <div key={i} style={{width:(i%3===0?3:1),height:'100%',background:'#0E0B1F',opacity:(i*17)%3===0?.3:1}}/>
            ))}
          </div>
          <div className="mono" style={{textAlign:'center',fontSize:9,color:'#6E6A85',marginTop:4}}>TP 8821 9F4A 2640 5891</div>
        </div>

        <div style={{display:'flex',gap:8}}>
          <button className="btn ghost" style={{flex:1,padding:'10px',fontSize:12}}>📥 ดาวน์โหลด</button>
          <button className="btn ghost" style={{flex:1,padding:'10px',fontSize:12}}>✉ ส่งอีเมล</button>
        </div>
      </div>
    </div>
  );
}

Object.assign(window, {BuyerApp, BuyerSearch, BuyerCategories, BuyerOrders, BuyerAddress, BuyerCoupons, BuyerNoti, BuyerCheckout, BuyerPaid, BuyerReview, CkAddress, CkPayment, CkQR, CkReceipt});
