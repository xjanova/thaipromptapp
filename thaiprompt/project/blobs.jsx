// Realistic 3D blob / puffy renders. Pure CSS radial gradients + shadows.
// Replace with real renders later.

function Blob3D({size=120, hue='pink', style={}, shine=true}) {
  const palette = {
    pink:   {a:'#FFDCE6', b:'#FF3E6C', c:'#8A0030'},
    mint:   {a:'#E3FFF8', b:'#00D4B4', c:'#006B5A'},
    mango:  {a:'#FFF3C7', b:'#FFC94D', c:'#7A5200'},
    purple: {a:'#EAE3FF', b:'#6B4BFF', c:'#2C1D8A'},
    sky:    {a:'#E0F3FF', b:'#5EC9FF', c:'#0A5A85'},
    tomato: {a:'#FFE3D6', b:'#FF7A3A', c:'#8A2A00'},
  }[hue] || {a:'#fff', b:'#999', c:'#333'};
  return (
    <div style={{
      width:size, height:size, borderRadius:'50%',
      background:`radial-gradient(circle at 32% 28%, ${palette.a} 0%, ${palette.b} 42%, ${palette.c} 100%)`,
      boxShadow:`inset -${size*0.12}px -${size*0.14}px ${size*0.2}px rgba(0,0,0,.35), 0 ${size*0.18}px ${size*0.14}px -${size*0.1}px rgba(0,0,0,.35)`,
      position:'relative', ...style
    }}>
      {shine && <div style={{
        position:'absolute', top:'12%', left:'18%', width:'32%', height:'20%',
        borderRadius:'50%', background:'rgba(255,255,255,.7)', filter:'blur(3px)',
      }}/>}
    </div>
  );
}

// Stylized "puffy" product – a squish capsule
function Puff({w=140,h=110,hue='pink',label='',style={}}){
  const palette = {
    pink:   ['#FFDCE6','#FF3E6C','#8A0030'],
    mint:   ['#E3FFF8','#00D4B4','#006B5A'],
    mango:  ['#FFF3C7','#FFC94D','#7A5200'],
    purple: ['#EAE3FF','#6B4BFF','#2C1D8A'],
    tomato: ['#FFE3D6','#FF7A3A','#8A2A00'],
    leaf:   ['#E5F8D5','#79C24A','#2E5A12'],
  }[hue] || ['#fff','#999','#333'];
  return (
    <div style={{width:w,height:h, position:'relative', ...style}}>
      <div style={{
        position:'absolute',inset:0, borderRadius:'50% / 45%',
        background:`radial-gradient(ellipse at 30% 25%, ${palette[0]} 0%, ${palette[1]} 50%, ${palette[2]} 100%)`,
        boxShadow:`inset -10px -14px 20px rgba(0,0,0,.35), 0 16px 10px -6px rgba(0,0,0,.25)`,
      }}/>
      <div style={{
        position:'absolute',top:'12%',left:'20%',width:'30%',height:'22%',
        borderRadius:'50%',background:'rgba(255,255,255,.7)',filter:'blur(4px)',
      }}/>
      {label && <div style={{
        position:'absolute',bottom:-22,left:0,right:0,textAlign:'center',
        fontFamily:'JetBrains Mono,monospace',fontSize:10,color:'#0E0B1F',
      }}>{label}</div>}
    </div>
  );
}

// Floor shadow ellipse
function FloorShadow({w=160, style={}}){
  return <div style={{
    width:w,height:w*0.18,borderRadius:'50%',
    background:'radial-gradient(ellipse,rgba(0,0,0,.35),transparent 65%)',
    filter:'blur(2px)',
    ...style,
  }}/>
}

// Tiny coin (for affiliate)
function Coin({size=44, label='฿'}){
  return (
    <div style={{
      width:size,height:size,borderRadius:'50%',position:'relative',
      background:'radial-gradient(circle at 32% 28%, #FFF3C7 0%, #FFC94D 50%, #7A5200 100%)',
      boxShadow:'inset -3px -5px 6px rgba(0,0,0,.35), 0 6px 6px -3px rgba(0,0,0,.3)',
      display:'flex',alignItems:'center',justifyContent:'center',
      color:'#5A3A00',fontWeight:900,fontFamily:'Space Grotesk,sans-serif',fontSize:size*0.45,
    }}>{label}
      <div style={{position:'absolute',inset:'6%',borderRadius:'50%',border:'1.5px dashed rgba(255,255,255,.6)'}}/>
    </div>
  );
}

// Isometric market stall illustration
function IsoStall({w=260,h=200,style={}}){
  return (
    <svg viewBox="0 0 260 200" width={w} height={h} style={style}>
      <defs>
        <linearGradient id="roof1" x1="0" x2="0" y1="0" y2="1">
          <stop offset="0" stopColor="#FF3E6C"/><stop offset="1" stopColor="#B30040"/>
        </linearGradient>
        <linearGradient id="roof2" x1="0" x2="1" y1="0" y2="0">
          <stop offset="0" stopColor="#FFF"/><stop offset="1" stopColor="#FFD6D6"/>
        </linearGradient>
        <linearGradient id="wood" x1="0" x2="0" y1="0" y2="1">
          <stop offset="0" stopColor="#E6A23B"/><stop offset="1" stopColor="#8B5A1B"/>
        </linearGradient>
        <radialGradient id="shad"><stop offset="0" stopColor="rgba(0,0,0,.4)"/><stop offset="1" stopColor="transparent"/></radialGradient>
      </defs>
      {/* ground shadow */}
      <ellipse cx="130" cy="178" rx="110" ry="14" fill="url(#shad)"/>
      {/* posts */}
      <rect x="52" y="78" width="5" height="92" fill="#3a2510"/>
      <rect x="203" y="78" width="5" height="92" fill="#3a2510"/>
      {/* canopy stripes */}
      <path d="M40 84 L220 84 L210 58 L50 58 Z" fill="url(#roof1)"/>
      <g>
        {[0,1,2,3,4,5,6].map(i=>(
          <path key={i} d={`M${50+i*24} 58 L${74+i*24} 58 L${70+i*24} 84 L${46+i*24} 84 Z`} fill={i%2?'#FFF':'#FF3E6C'} />
        ))}
      </g>
      {/* pennant flag */}
      <path d="M130 58 L130 36 L150 42 Z" fill="#FFC94D" stroke="#0E0B1F" strokeWidth="1.5"/>
      <line x1="130" y1="36" x2="130" y2="28" stroke="#0E0B1F" strokeWidth="1.5"/>
      {/* counter */}
      <polygon points="50,108 210,108 220,128 40,128" fill="url(#wood)" stroke="#0E0B1F" strokeWidth="1.5"/>
      <polygon points="40,128 220,128 220,160 40,160" fill="#B97024" stroke="#0E0B1F" strokeWidth="1.5"/>
      {/* fruits */}
      <circle cx="80" cy="100" r="10" fill="#FF3E6C" stroke="#0E0B1F" strokeWidth="1.2"/>
      <circle cx="104" cy="96" r="10" fill="#79C24A" stroke="#0E0B1F" strokeWidth="1.2"/>
      <circle cx="128" cy="100" r="10" fill="#FFC94D" stroke="#0E0B1F" strokeWidth="1.2"/>
      <circle cx="152" cy="96" r="10" fill="#FF7A3A" stroke="#0E0B1F" strokeWidth="1.2"/>
      <circle cx="176" cy="100" r="10" fill="#6B4BFF" stroke="#0E0B1F" strokeWidth="1.2"/>
      {/* sign */}
      <rect x="96" y="138" width="68" height="18" rx="4" fill="#FFF8EE" stroke="#0E0B1F" strokeWidth="1.5"/>
      <text x="130" y="151" textAnchor="middle" fontSize="11" fontFamily="Space Grotesk" fontWeight="700" fill="#0E0B1F">ตลาดไทย</text>
    </svg>
  );
}

Object.assign(window, { Blob3D, Puff, FloorShadow, Coin, IsoStall });
