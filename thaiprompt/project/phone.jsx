// Stylized Android-ish phone frame for Thaiprompt
function Phone({children, tone='paper', label, width=360, height=740, style={}}){
  const bg = {
    paper:'#FFF8EE', dark:'#0E0B1F', pink:'#FFE3EB', mint:'#DFFAF3', mango:'#FFF0C7',
  }[tone] || tone;
  return (
    <div style={{display:'flex',flexDirection:'column',alignItems:'center',gap:10, ...style}}>
      <div style={{
        width, height,
        borderRadius:48,
        padding:10,
        background:'linear-gradient(160deg,#F6EADB,#E8DCC8)',
        boxShadow:'0 30px 60px -20px rgba(70,42,92,.35), 0 6px 14px rgba(70,42,92,.12), inset 0 -6px 10px rgba(70,42,92,.18), inset 0 4px 6px rgba(255,255,255,.9)',
        position:'relative',
      }}>
        <div style={{
          position:'absolute',top:14,left:'50%',transform:'translateX(-50%)',
          width:18,height:18,borderRadius:'50%',background:'#000',
          boxShadow:'inset 0 0 0 2px #1a1a1a', zIndex:10,
        }}/>
        <div style={{
          width:'100%',height:'100%',
          borderRadius:38,overflow:'hidden',
          background:bg,position:'relative',
          boxShadow:'inset 0 2px 4px rgba(70,42,92,.15)',
        }}>
          <StatusBar tone={tone}/>
          <div className="phone-scroll" style={{height:'calc(100% - 28px)',overflow:'auto'}}>
            {children}
          </div>
        </div>
      </div>
      {label && <div style={{
        fontFamily:'JetBrains Mono,monospace',fontSize:11,
        color:'#6E6A85',letterSpacing:'.1em',textTransform:'uppercase',
      }}>{label}</div>}
    </div>
  );
}

function StatusBar({tone='paper'}){
  const dark = tone==='dark';
  const c = dark ? '#fff' : '#0E0B1F';
  return (
    <div style={{
      height:28,display:'flex',alignItems:'center',justifyContent:'space-between',
      padding:'0 20px',fontFamily:'JetBrains Mono,monospace',fontSize:11,
      color:c, fontWeight:600,
    }}>
      <span>9:30</span>
      <div style={{display:'flex',gap:4,alignItems:'center'}}>
        <svg width="14" height="10" viewBox="0 0 14 10"><path d="M1 9 Q7 -1 13 9" stroke={c} strokeWidth="1.5" fill="none"/></svg>
        <svg width="12" height="10" viewBox="0 0 12 10"><rect x="1" y="5" width="2" height="4" fill={c}/><rect x="4" y="3" width="2" height="6" fill={c}/><rect x="7" y="1" width="2" height="8" fill={c}/></svg>
        <div style={{width:20,height:10,border:`1.5px solid ${c}`,borderRadius:2,padding:1,display:'flex'}}>
          <div style={{flex:1,background:c,borderRadius:1}}/>
        </div>
      </div>
    </div>
  );
}

// Custom glyph icons — simple, premium line/filled marks
function NavIcon({name, active}){
  const stroke = active? '#fff' : '#2A1F3D';
  const fill   = active? '#fff' : 'none';
  const sw = 2;
  const common = {width:22,height:22,viewBox:'0 0 24 24',fill:'none',stroke,strokeWidth:sw,strokeLinecap:'round',strokeLinejoin:'round'};
  switch(name){
    case 'menu': return (<svg {...common}><path d="M4 6h16M4 12h16M4 18h10"/><circle cx="19" cy="18" r="1.5" fill={stroke}/></svg>);
    case 'wallet':  return (<svg {...common}><rect x="3" y="6" width="18" height="13" rx="3"/><path d="M3 10h18"/><circle cx="17" cy="14.5" r="1.3" fill={stroke}/></svg>);
    case 'affiliate': return (<svg {...common}><circle cx="7" cy="8" r="2.5"/><circle cx="17" cy="8" r="2.5"/><circle cx="12" cy="17" r="2.5"/><path d="M8.6 9.7l2.8 5M15.4 9.7l-2.8 5"/></svg>);
    case 'me':      return (<svg {...common}><circle cx="12" cy="8" r="3.5"/><path d="M5 20c1.5-3.5 4.2-5 7-5s5.5 1.5 7 5"/></svg>);
    case 'home':    return (<svg width="26" height="26" viewBox="0 0 24 24" fill="none" stroke={stroke} strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round"><path d="M3 11.5 12 4l9 7.5"/><path d="M5.5 10v9h13v-9" fill={fill==='none'?'none':'rgba(255,255,255,.15)'}/><path d="M10 19v-4.5h4V19"/></svg>);
    default: return null;
  }
}

// Premium bottom dock — floating, curved notch around a big raised center Home button
function TabBar({active='home', onChange}){
  const sides = [
    {id:'menu',     label:'เมนู'},
    {id:'wallet',   label:'Wallet'},
    // center: home
    {id:'affiliate',label:'แนะนำ'},
    {id:'me',       label:'ฉัน'},
  ];
  return (
    <div style={{
      position:'sticky',bottom:0,left:0,right:0,
      padding:'0 14px 14px',
      pointerEvents:'none',
      zIndex:5,
    }}>
      <div style={{position:'relative',pointerEvents:'auto'}}>
        {/* SVG dock with notch */}
        <svg viewBox="0 0 340 82" preserveAspectRatio="none" style={{
          width:'100%', height:82, display:'block',
          filter:'drop-shadow(0 14px 20px rgba(70,42,92,.28)) drop-shadow(0 4px 6px rgba(70,42,92,.15))',
        }}>
          <defs>
            <linearGradient id="dockG" x1="0" x2="0" y1="0" y2="1">
              <stop offset="0" stopColor="#FFFDF7"/>
              <stop offset="1" stopColor="#F3E7CF"/>
            </linearGradient>
            <linearGradient id="dockTop" x1="0" x2="0" y1="0" y2="1">
              <stop offset="0" stopColor="rgba(255,255,255,.95)"/>
              <stop offset="1" stopColor="rgba(255,255,255,0)"/>
            </linearGradient>
          </defs>
          {/* dock shape: rounded ends, curved notch for FAB */}
          <path d="
            M 28 12
            Q 14 12 14 30
            L 14 64
            Q 14 78 28 78
            L 312 78
            Q 326 78 326 64
            L 326 30
            Q 326 12 312 12
            L 210 12
            Q 200 12 196 20
            Q 186 38 170 38
            Q 154 38 144 20
            Q 140 12 130 12
            Z"
            fill="url(#dockG)"/>
          {/* top highlight */}
          <path d="
            M 28 12
            Q 14 12 14 30
            L 14 34
            Q 14 16 28 16
            L 130 16
            Q 140 16 144 24
            Q 154 42 170 42
            Q 186 42 196 24
            Q 200 16 210 16
            L 312 16
            Q 326 16 326 34
            L 326 30
            Q 326 12 312 12
            L 210 12
            Q 200 12 196 20
            Q 186 38 170 38
            Q 154 38 144 20
            Q 140 12 130 12
            Z"
            fill="url(#dockTop)" opacity=".9"/>
          {/* inner bottom shadow */}
          <path d="M 22 72 L 318 72" stroke="rgba(70,42,92,.1)" strokeWidth="2" fill="none"/>
        </svg>

        {/* Buttons layer */}
        <div style={{
          position:'absolute',inset:0,display:'flex',alignItems:'stretch',
          padding:'0 8px',
        }}>
          <DockBtn label={sides[0].label} id={sides[0].id} active={active===sides[0].id} onClick={onChange}/>
          <DockBtn label={sides[1].label} id={sides[1].id} active={active===sides[1].id} onClick={onChange}/>
          <div style={{width:88}}/>{/* notch gap */}
          <DockBtn label={sides[2].label} id={sides[2].id} active={active===sides[2].id} onClick={onChange}/>
          <DockBtn label={sides[3].label} id={sides[3].id} active={active===sides[3].id} onClick={onChange}/>
        </div>

        {/* Center raised Home FAB */}
        <button onClick={()=>onChange && onChange('home')} style={{
          position:'absolute', left:'50%', top:-18, transform:'translateX(-50%)',
          width:72, height:72, borderRadius:'50%',
          border:0, cursor:'pointer', padding:0,
          background: active==='home'
            ? 'radial-gradient(circle at 32% 28%, #FFC99C 0%, #FF7A3A 45%, #C7502D 100%)'
            : 'radial-gradient(circle at 32% 28%, #FFF1D9 0%, #FFC94D 55%, #C9851B 100%)',
          boxShadow: active==='home'
            ? '0 14px 24px -6px rgba(199,80,45,.55), 0 4px 8px rgba(0,0,0,.15), inset 0 -8px 12px rgba(0,0,0,.22), inset 0 6px 8px rgba(255,255,255,.55)'
            : '0 14px 24px -6px rgba(201,133,27,.55), 0 4px 8px rgba(0,0,0,.15), inset 0 -8px 12px rgba(0,0,0,.22), inset 0 6px 8px rgba(255,255,255,.65)',
          display:'flex',alignItems:'center',justifyContent:'center',
          color: active==='home' ? '#fff' : '#2A1F3D',
        }}>
          {/* inner ring for depth */}
          <div style={{
            position:'absolute',inset:6,borderRadius:'50%',
            background:'radial-gradient(circle at 38% 34%, rgba(255,255,255,.5), transparent 55%)',
            pointerEvents:'none',
          }}/>
          <NavIcon name="home" active={active==='home'}/>
          {/* Home label chip under */}
          <div style={{
            position:'absolute',bottom:-22,left:'50%',transform:'translateX(-50%)',
            fontSize:10,fontWeight:800,color:'#2A1F3D',
            letterSpacing:'.02em',whiteSpace:'nowrap',
          }}>หน้าแรก</div>
        </button>
      </div>
    </div>
  );
}

function DockBtn({id,label,active,onClick}){
  return (
    <button onClick={()=>onClick && onClick(id)} style={{
      flex:1,border:0,background:'transparent',cursor:'pointer',padding:0,
      display:'flex',flexDirection:'column',alignItems:'center',justifyContent:'center',
      gap:3,fontFamily:'inherit',
      color: active?'#fff':'#2A1F3D',
      position:'relative',
    }}>
      <div style={{
        width:42,height:42,borderRadius:14,
        display:'flex',alignItems:'center',justifyContent:'center',
        background: active
          ? 'linear-gradient(160deg,#FF5983,#C7502D)'
          : 'transparent',
        boxShadow: active
          ? '0 8px 14px -4px rgba(199,80,45,.5), inset 0 -3px 5px rgba(0,0,0,.2), inset 0 3px 3px rgba(255,255,255,.35)'
          : 'none',
      }}>
        <NavIcon name={id} active={active}/>
      </div>
      <div style={{fontSize:10,fontWeight:700,color: active?'#C7502D':'#4B3E66'}}>{label}</div>
    </button>
  );
}

// Section header with Thai/EN
function H({th,en,action,style={}}){
  return (
    <div style={{display:'flex',alignItems:'baseline',justifyContent:'space-between',margin:'18px 16px 10px',...style}}>
      <div>
        <div style={{fontFamily:'Space Grotesk',fontWeight:700,fontSize:18,color:'#0E0B1F',letterSpacing:'-.01em'}}>{th}</div>
        {en && <div className="mono" style={{fontSize:10,color:'#6E6A85',textTransform:'uppercase',letterSpacing:'.15em'}}>{en}</div>}
      </div>
      {action && <button style={{
        border:0,background:'transparent',color:'#FF3E6C',
        font:'600 12px "IBM Plex Sans Thai"',cursor:'pointer',
      }}>{action} →</button>}
    </div>
  );
}

Object.assign(window, {Phone, StatusBar, TabBar, H});
