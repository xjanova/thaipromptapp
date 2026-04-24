// Thaiprompt — Seller App (multi-screen with nav)
// Screens: Dashboard, Orders, OrderDetail, Products, ProductEdit, Promotions, Reports, Withdraw

function SellerApp({initial='dash'}={}){
  const [screen, setScreen] = React.useState(initial);
  const [orderId, setOrderId] = React.useState('TP-2041');
  const [productId, setProductId] = React.useState(null);
  const go = (s, opts={}) => {
    if(opts.orderId) setOrderId(opts.orderId);
    if(opts.productId!==undefined) setProductId(opts.productId);
    setScreen(s);
  };
  const V = {dash:SellerDashV2, orders:SellerOrders, orderDetail:SellerOrderDetail,
    products:SellerProducts, productEdit:SellerProductEdit, promos:SellerPromos,
    reports:SellerReports, withdraw:SellerWithdraw}[screen] || SellerDashV2;
  return (
    <div style={{display:'flex',flexDirection:'column',minHeight:'100%',background:'#FFF8EE'}}>
      <div style={{flex:1,minHeight:0}}>
        <V go={go} orderId={orderId} productId={productId}/>
      </div>
      <SellerNav screen={screen} go={go}/>
    </div>
  );
}

function SellerNav({screen, go}){
  const items = [
    {id:'dash',l:'แดช',icon:'dash'},
    {id:'orders',l:'ออเดอร์',icon:'orders',b:3},
    {id:'products',l:'สินค้า',icon:'products'},
    {id:'reports',l:'รายงาน',icon:'reports'},
    {id:'withdraw',l:'เงิน',icon:'withdraw'},
  ];
  return <window.AppTabBar items={items} screen={screen} go={go} accent="#FF7A3A" accentText="#fff"/>;
}
function SellerHeader({title, sub, go, back}){
  return (
    <div style={{padding:'14px 16px 10px',background:'linear-gradient(160deg,#FFC94D,#FF7A3A)',color:'#2A1F3D',display:'flex',alignItems:'center',gap:10}}>
      {back && <button onClick={()=>go(back)} style={{width:34,height:34,borderRadius:12,border:0,background:'rgba(255,255,255,.9)',fontWeight:900,cursor:'pointer',fontFamily:'inherit',boxShadow:'var(--clay-sm)'}}>←</button>}
      <div style={{flex:1}}>
        {sub && <div className="mono" style={{fontSize:9,letterSpacing:'.18em',opacity:.7}}>{sub}</div>}
        <div style={{fontWeight:900,fontSize:16}}>{title}</div>
      </div>
    </div>
  );
}

// === Dashboard ===
function SellerDashV2({go}){
  const hours = [12,28,45,38,52,62,48,35];
  return (
    <div>
      <div style={{padding:'14px 16px',background:'linear-gradient(160deg,#FFC94D,#FF7A3A)',color:'#2A1F3D'}}>
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
          <div className="display" style={{fontSize:22}}>฿3,820</div>
          <div style={{fontSize:11,color:'#00D4B4',fontWeight:700}}>↑ 18%</div>
        </div>
        <div className="chunk" style={{padding:12,background:'#2A1F3D',color:'#fff',cursor:'pointer'}} onClick={()=>go('orders')}>
          <div className="mono" style={{fontSize:9,opacity:.7,letterSpacing:'.15em'}}>รอจัดส่ง</div>
          <div className="display" style={{fontSize:22}}>7</div>
          <div style={{fontSize:11,color:'#FFC94D',fontWeight:700}}>⚡ 2 ด่วน →</div>
        </div>
      </div>

      <div style={{padding:'10px 16px 0'}}>
        <div className="chunk" style={{padding:14,background:'#fff'}}>
          <div style={{display:'flex',justifyContent:'space-between',alignItems:'baseline'}}>
            <div style={{fontWeight:800,fontSize:13}}>ยอดขาย 8 ชม.ล่าสุด</div>
            <button onClick={()=>go('reports')} className="mono" style={{fontSize:10,color:'#FF7A3A',border:0,background:'transparent',cursor:'pointer',fontWeight:700}}>ดูเพิ่ม →</button>
          </div>
          <div style={{display:'flex',alignItems:'flex-end',gap:5,height:70,marginTop:10}}>
            {hours.map((v,i)=>(
              <div key={i} style={{flex:1,height:`${v}%`,borderRadius:8,
                background:i===5?'linear-gradient(180deg,#FF3E6C,#8A0030)':'linear-gradient(180deg,#FFC94D,#7A5200)',
                boxShadow:'inset 0 -3px 4px rgba(0,0,0,.2), inset 0 2px 2px rgba(255,255,255,.4)'}}/>
            ))}
          </div>
        </div>
      </div>

      {/* quick actions */}
      <div style={{padding:'14px 16px 0',display:'grid',gridTemplateColumns:'repeat(4,1fr)',gap:8}}>
        {[{l:'เพิ่มสินค้า',i:'＋',c:'#00D4B4',s:'productEdit'},{l:'โปรโมชัน',i:'%',c:'#FF3E6C',s:'promos'},{l:'แชท',i:'💬',c:'#6B4BFF'},{l:'ถอน',i:'↓',c:'#FFC94D',s:'withdraw'}].map(a=>(
          <button key={a.l} onClick={()=>a.s && go(a.s, a.l==='เพิ่มสินค้า'?{productId:null}:{})} style={{border:0,background:'transparent',cursor:'pointer',padding:0,fontFamily:'inherit'}}>
            <div style={{width:44,height:44,borderRadius:14,background:a.c,color:'#2A1F3D',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900,fontSize:18,margin:'0 auto',boxShadow:'var(--clay-sm)'}}>{a.i}</div>
            <div style={{fontSize:10,fontWeight:700,marginTop:4}}>{a.l}</div>
          </button>
        ))}
      </div>

      <H th="ออเดอร์ใหม่" en="New orders" action="ทั้งหมด"/>
      <div style={{padding:'0 16px 20px',display:'flex',flexDirection:'column',gap:8}}>
        {[
          {id:'TP-2041',n:'ข้าวซอยไก่ x2, ไข่ต้ม',s:'ใหม่!',c:'#FF3E6C',t:'1 นาที',p:170},
          {id:'TP-2040',n:'แกงเหลือง x1',s:'กำลังทำ',c:'#FFC94D',t:'8 นาที',p:85},
        ].map(o=>(
          <div key={o.id} onClick={()=>go('orderDetail',{orderId:o.id})} className="chunk" style={{padding:12,background:'#fff',cursor:'pointer'}}>
            <div style={{display:'flex',alignItems:'center',gap:8}}>
              <div className="mono" style={{fontSize:11,fontWeight:700}}>#{o.id}</div>
              <div style={{flex:1}}/>
              <div className="chip" style={{background:o.c,color:'#fff',fontSize:10,padding:'3px 8px'}}>{o.s}</div>
            </div>
            <div style={{fontWeight:700,fontSize:13,margin:'6px 0 2px'}}>{o.n}</div>
            <div style={{display:'flex',justifyContent:'space-between',alignItems:'baseline'}}>
              <span className="mono" style={{fontSize:10,color:'#8A7FA3'}}>{o.t}</span>
              <span className="display" style={{fontSize:16}}>฿{o.p}</span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

// === Orders list ===
function SellerOrders({go}){
  const tabs = ['ทั้งหมด','ใหม่','กำลังทำ','ส่งแล้ว'];
  const [tab, setTab] = React.useState(0);
  const orders = [
    {id:'TP-2041',n:'ข้าวซอยไก่ x2, ไข่ต้ม',s:'ใหม่',c:'#FF3E6C',t:'1 นาที',p:170,cust:'สมพร'},
    {id:'TP-2040',n:'แกงเหลือง x1, ผัดไทย x1',s:'กำลังทำ',c:'#FFC94D',t:'8 นาที',p:175,cust:'ฟ้า'},
    {id:'TP-2039',n:'ขนมจีน x3',s:'รอไรเดอร์',c:'#6B4BFF',t:'12 นาที',p:210,cust:'ตุ๊ก'},
    {id:'TP-2038',n:'ข้าวซอยไก่ x1',s:'ส่งแล้ว',c:'#00D4B4',t:'45 นาที',p:75,cust:'มานะ'},
    {id:'TP-2037',n:'แกงเหลือง x2',s:'ส่งแล้ว',c:'#00D4B4',t:'1 ชม',p:170,cust:'พลอย'},
  ];
  return (
    <div>
      <SellerHeader title="ออเดอร์ทั้งหมด" sub="ORDERS" go={go}/>
      <div style={{padding:'10px 16px 0',display:'flex',gap:6,overflowX:'auto'}} className="phone-scroll">
        {tabs.map((t,i)=>(
          <button key={t} onClick={()=>setTab(i)} style={{
            border:0,padding:'7px 14px',borderRadius:999,whiteSpace:'nowrap',cursor:'pointer',fontFamily:'inherit',
            background: i===tab?'#2A1F3D':'#fff', color: i===tab?'#FFC94D':'#4B3E66',
            fontSize:12,fontWeight:700,boxShadow: i===tab?'var(--clay-sm)':'none',
          }}>{t}</button>
        ))}
      </div>
      <div style={{padding:'12px 16px 20px',display:'flex',flexDirection:'column',gap:8}}>
        {orders.map(o=>(
          <div key={o.id} onClick={()=>go('orderDetail',{orderId:o.id})} className="chunk" style={{padding:12,background:'#fff',cursor:'pointer'}}>
            <div style={{display:'flex',alignItems:'center',gap:8}}>
              <div className="mono" style={{fontSize:11,fontWeight:700}}>#{o.id}</div>
              <div style={{flex:1}}/>
              <div className="chip" style={{background:o.c,color:'#fff',fontSize:10,padding:'3px 8px'}}>{o.s}</div>
            </div>
            <div style={{fontWeight:700,fontSize:13,margin:'6px 0 2px'}}>{o.n}</div>
            <div style={{display:'flex',justifyContent:'space-between',alignItems:'baseline',fontSize:11}}>
              <span className="mono" style={{color:'#8A7FA3'}}>👤 {o.cust} · {o.t}</span>
              <span className="display" style={{fontSize:16}}>฿{o.p}</span>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

// === Order detail ===
function SellerOrderDetail({go, orderId}){
  return (
    <div>
      <SellerHeader title={`#${orderId}`} sub="ORDER DETAIL" go={go} back="orders"/>
      <div style={{padding:'14px 16px'}}>
        <div className="chunk" style={{padding:14,background:'#FF3E6C',color:'#fff'}}>
          <div className="mono" style={{fontSize:10,letterSpacing:'.15em',opacity:.85}}>ORDER NEW · 1 นาทีที่แล้ว</div>
          <div style={{fontWeight:900,fontSize:20,marginTop:4}}>รอยืนยันออเดอร์</div>
          <div style={{display:'flex',gap:8,marginTop:12}}>
            <button className="btn" style={{flex:1,background:'#fff',color:'#FF3E6C',fontSize:13,padding:'12px'}}>✓ รับออเดอร์</button>
            <button className="btn ghost" style={{background:'rgba(0,0,0,.2)',color:'#fff',padding:'12px 16px',fontSize:13}}>ปฏิเสธ</button>
          </div>
        </div>
      </div>

      <div style={{padding:'0 16px',display:'flex',flexDirection:'column',gap:10}}>
        <div className="chunk" style={{padding:12,background:'#fff'}}>
          <div className="mono" style={{fontSize:9,color:'#8A7FA3',letterSpacing:'.15em'}}>ลูกค้า</div>
          <div style={{display:'flex',alignItems:'center',gap:10,marginTop:6}}>
            <div style={{width:38,height:38,borderRadius:12,background:'#FFC94D',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900,boxShadow:'var(--clay-sm)'}}>ส</div>
            <div style={{flex:1}}>
              <div style={{fontWeight:700,fontSize:13}}>คุณสมพร · Lv.12</div>
              <div className="mono" style={{fontSize:10,color:'#8A7FA3'}}>ซ.สุขุมวิท 24 · 1.2km</div>
            </div>
            <button className="btn ghost" style={{padding:'6px 10px',fontSize:11}}>💬</button>
          </div>
        </div>

        <div className="chunk" style={{padding:12,background:'#fff'}}>
          <div className="mono" style={{fontSize:9,color:'#8A7FA3',letterSpacing:'.15em',marginBottom:8}}>รายการ</div>
          {[{n:'ข้าวซอยไก่ (กลาง)',q:2,p:150,note:'ไม่เผ็ด'},{n:'ไข่ต้มเพิ่ม',q:2,p:20,note:''}].map((it,i)=>(
            <div key={i} style={{display:'flex',gap:10,alignItems:'flex-start',padding:'6px 0',borderTop:i?'1px dashed rgba(70,42,92,.12)':'none'}}>
              <div className="mono" style={{fontSize:11,fontWeight:700,color:'#FF3E6C'}}>×{it.q}</div>
              <div style={{flex:1}}>
                <div style={{fontWeight:700,fontSize:13}}>{it.n}</div>
                {it.note && <div style={{fontSize:11,color:'#FF3E6C',fontStyle:'italic',marginTop:2}}>หมายเหตุ: {it.note}</div>}
              </div>
              <div className="display" style={{fontSize:13}}>฿{it.p}</div>
            </div>
          ))}
          <div style={{height:1,background:'#2A1F3D',margin:'8px 0'}}/>
          <div style={{display:'flex',justifyContent:'space-between',fontSize:11,color:'#8A7FA3',padding:'2px 0'}}><span>ยอดรวม</span><span className="mono">฿170</span></div>
          <div style={{display:'flex',justifyContent:'space-between',fontSize:11,color:'#8A7FA3',padding:'2px 0'}}><span>ค่าคอมแพลตฟอร์ม 8%</span><span className="mono">-฿13.60</span></div>
          <div style={{display:'flex',justifyContent:'space-between',alignItems:'baseline',marginTop:6}}>
            <span style={{fontWeight:900,fontSize:14}}>ร้านได้รับ</span>
            <span className="display" style={{fontSize:22,color:'#00D4B4'}}>฿156.40</span>
          </div>
        </div>

        <div className="chunk" style={{padding:12,background:'#FFF0C7'}}>
          <div className="mono" style={{fontSize:9,color:'#8A7FA3',letterSpacing:'.15em'}}>การจ่าย</div>
          <div style={{display:'flex',alignItems:'center',gap:8,marginTop:4}}>
            <div style={{width:28,height:28,borderRadius:8,background:'#00D4B4',color:'#fff',display:'flex',alignItems:'center',justifyContent:'center',fontSize:14}}>✓</div>
            <div style={{fontSize:12,fontWeight:700}}>จ่ายด้วย Wallet · สำเร็จแล้ว</div>
          </div>
        </div>
      </div>

      <div style={{height:30}}/>
    </div>
  );
}

// === Products list ===
function SellerProducts({go}){
  const prods = [
    {id:1,n:'ข้าวซอยไก่',p:85,st:42,hue:'tomato',on:true,sold:142},
    {id:2,n:'แกงเหลือง',p:85,st:18,hue:'mango',on:true,sold:88},
    {id:3,n:'ผัดไทยกุ้ง',p:90,st:0,hue:'pink',on:false,sold:56},
    {id:4,n:'ขนมจีนน้ำยา',p:70,st:12,hue:'leaf',on:true,sold:34},
  ];
  return (
    <div>
      <SellerHeader title="สินค้าของร้าน" sub="PRODUCTS · 38 รายการ" go={go}/>
      <div style={{padding:'10px 16px 0',display:'flex',gap:8}}>
        <div className="chunk" style={{flex:1,padding:'8px 12px',background:'#fff',display:'flex',alignItems:'center',gap:6}}>
          <span style={{fontSize:13}}>⌕</span>
          <span style={{flex:1,fontSize:12,color:'#8A7FA3'}}>ค้นหาสินค้า...</span>
        </div>
        <button onClick={()=>go('productEdit',{productId:null})} className="btn" style={{background:'#FF7A3A',color:'#fff',padding:'8px 14px',fontSize:12}}>＋ เพิ่ม</button>
      </div>

      <div style={{padding:'12px 16px 20px',display:'grid',gridTemplateColumns:'1fr 1fr',gap:10}}>
        {prods.map(p=>(
          <div key={p.id} onClick={()=>go('productEdit',{productId:p.id})} className="chunk" style={{padding:0,overflow:'hidden',background:'#fff',cursor:'pointer'}}>
            <div style={{height:80,background:p.hue==='tomato'?'#FFE3EB':p.hue==='mango'?'#FFF0C7':p.hue==='leaf'?'#DFFAF3':'#FFE3EB',display:'flex',alignItems:'center',justifyContent:'center',position:'relative'}}>
              <Puff w={60} h={44} hue={p.hue}/>
              {!p.on && <div style={{position:'absolute',inset:0,background:'rgba(42,31,61,.7)',display:'flex',alignItems:'center',justifyContent:'center',color:'#fff',fontWeight:800,fontSize:11}}>หมด</div>}
              <div style={{position:'absolute',top:6,right:6,background:p.on?'#00D4B4':'#8A7FA3',color:'#fff',fontSize:9,fontWeight:800,padding:'2px 7px',borderRadius:999}}>{p.on?'เปิดขาย':'ปิด'}</div>
            </div>
            <div style={{padding:'8px 10px'}}>
              <div style={{fontWeight:700,fontSize:12}}>{p.n}</div>
              <div style={{display:'flex',justifyContent:'space-between',alignItems:'baseline',marginTop:2}}>
                <span className="display" style={{fontSize:14}}>฿{p.p}</span>
                <span className="mono" style={{fontSize:9,color:'#8A7FA3'}}>ขาย {p.sold}</span>
              </div>
              <div className="mono" style={{fontSize:9,color:p.st<10?'#FF3E6C':'#8A7FA3',marginTop:2,fontWeight:700}}>STOCK: {p.st}</div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

// === Product edit ===
function SellerProductEdit({go, productId}){
  const isNew = !productId;
  return (
    <div>
      <SellerHeader title={isNew?'เพิ่มสินค้าใหม่':'แก้ไขสินค้า'} sub={isNew?'NEW PRODUCT':'EDIT'} go={go} back="products"/>
      <div style={{padding:'14px 16px',display:'flex',flexDirection:'column',gap:12}}>
        {/* image upload */}
        <div style={{display:'grid',gridTemplateColumns:'1fr 1fr 1fr',gap:8}}>
          {[0,1,2].map(i=>(
            <div key={i} className="chunk" style={{
              aspectRatio:'1',background:i===0?'#FFE3EB':'#fff',display:'flex',alignItems:'center',justifyContent:'center',
              border: i===0?'none':'2px dashed rgba(70,42,92,.25)',boxShadow:i===0?'var(--clay-sm)':'none',
              position:'relative',
            }}>
              {i===0 ? <Puff w={60} h={44} hue="tomato"/> : <div style={{fontSize:24,color:'#8A7FA3'}}>＋</div>}
              {i===0 && <div style={{position:'absolute',top:4,left:4,background:'#2A1F3D',color:'#FFC94D',fontSize:9,padding:'2px 6px',borderRadius:6,fontWeight:800}}>หลัก</div>}
            </div>
          ))}
        </div>

        <Field label="ชื่อสินค้า" value={isNew?'':'ข้าวซอยไก่สูตรเชียงใหม่'} />
        <Field label="รายละเอียด" value={isNew?'':'น้ำข้นเข้มข้น ไก่นุ่มเปื่อย มาพร้อมเครื่องเคียงครบ'} multi/>
        <div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:10}}>
          <Field label="ราคา (฿)" value={isNew?'':'85'} mono/>
          <Field label="สต็อก" value={isNew?'':'42'} mono/>
        </div>

        <div>
          <div className="mono" style={{fontSize:9,color:'#8A7FA3',letterSpacing:'.15em',marginBottom:6}}>หมวด</div>
          <div style={{display:'flex',gap:6,flexWrap:'wrap'}}>
            {['อาหาร','ของหวาน','เครื่องดื่ม','ผักผลไม้'].map((c,i)=>(
              <span key={c} style={{padding:'6px 12px',borderRadius:999,background:i===0?'#2A1F3D':'#fff',color:i===0?'#FFC94D':'#4B3E66',fontSize:11,fontWeight:700,boxShadow:'var(--clay-sm)'}}>{c}</span>
            ))}
          </div>
        </div>

        <div>
          <div className="mono" style={{fontSize:9,color:'#8A7FA3',letterSpacing:'.15em',marginBottom:6}}>ตัวเลือกเพิ่มเติม (add-ons)</div>
          <div style={{display:'flex',flexDirection:'column',gap:6}}>
            {[{l:'ไข่ต้ม',p:10},{l:'ผักดองเพิ่ม',p:5},{l:'น้ำพริกเพิ่ม',p:15}].map((a,i)=>(
              <div key={i} className="chunk" style={{padding:'8px 10px',background:'#fff',display:'flex',alignItems:'center',gap:8}}>
                <input readOnly value={a.l} style={{flex:1,border:0,outline:'none',background:'transparent',fontSize:12,fontWeight:600,color:'#2A1F3D',fontFamily:'inherit'}}/>
                <div className="mono" style={{fontSize:11,color:'#8A7FA3'}}>+฿</div>
                <input readOnly value={a.p} style={{width:40,border:0,outline:'none',background:'transparent',fontSize:12,fontWeight:700,textAlign:'right',fontFamily:'JetBrains Mono'}}/>
                <span style={{color:'#FF3E6C',fontSize:16,cursor:'pointer'}}>×</span>
              </div>
            ))}
            <button style={{padding:'8px',borderRadius:14,border:'2px dashed rgba(70,42,92,.25)',background:'transparent',color:'#8A7FA3',fontSize:12,fontWeight:700,cursor:'pointer',fontFamily:'inherit'}}>＋ เพิ่ม add-on</button>
          </div>
        </div>

        <div className="chunk" style={{padding:12,background:'#DFFAF3',display:'flex',alignItems:'center',gap:8}}>
          <div style={{fontWeight:700,fontSize:13,flex:1}}>เปิดขาย (visible to buyers)</div>
          <div style={{width:40,height:22,borderRadius:999,background:'#00D4B4',position:'relative',boxShadow:'var(--clay-sm)'}}>
            <div style={{position:'absolute',top:2,right:2,width:18,height:18,borderRadius:'50%',background:'#fff'}}/>
          </div>
        </div>

        <div style={{display:'flex',gap:8,marginTop:4}}>
          {!isNew && <button className="btn ghost" style={{padding:'12px 14px',fontSize:12,color:'#FF3E6C'}}>🗑 ลบ</button>}
          <button onClick={()=>go('products')} className="btn" style={{flex:1,background:'#FF7A3A',color:'#fff',padding:'12px',fontSize:14}}>บันทึกสินค้า</button>
        </div>
      </div>
      <div style={{height:30}}/>
    </div>
  );
}

function Field({label,value,multi,mono}){
  return (
    <div>
      <div className="mono" style={{fontSize:9,color:'#8A7FA3',letterSpacing:'.15em',marginBottom:4}}>{label.toUpperCase()}</div>
      <div className="chunk" style={{padding:'10px 12px',background:'#fff',minHeight:multi?70:'auto'}}>
        <span style={{fontSize:13,fontFamily:mono?'JetBrains Mono':'inherit',color:value?'#2A1F3D':'#8A7FA3'}}>{value || `ใส่${label}...`}</span>
      </div>
    </div>
  );
}

// === Promotions ===
function SellerPromos({go}){
  return (
    <div>
      <SellerHeader title="โปรโมชัน" sub="PROMOTIONS" go={go}/>
      <div style={{padding:'14px 16px'}}>
        <div className="chunk" style={{padding:14,background:'linear-gradient(140deg,#FF3E6C,#6B4BFF)',color:'#fff'}}>
          <div className="mono" style={{fontSize:10,opacity:.85,letterSpacing:'.15em'}}>ACTIVE · 2 โปร</div>
          <div style={{fontWeight:900,fontSize:18,marginTop:4}}>เพิ่มยอดขาย 34%</div>
          <div style={{fontSize:11,opacity:.9}}>โปรกระตุ้นได้ผลดีที่สุดในเดือนนี้</div>
        </div>
      </div>

      <div style={{padding:'0 16px',display:'flex',flexDirection:'column',gap:10}}>
        {[
          {n:'ลด 20% เมื่อซื้อ 2 ชิ้น',t:'ส่วนลด%',c:'#FF3E6C',use:'42/100',on:true},
          {n:'ส่งฟรีทุกออเดอร์',t:'ส่งฟรี',c:'#00D4B4',use:'88/∞',on:true},
          {n:'SONGKRAN30',t:'โค้ดลด ฿30',c:'#FFC94D',use:'0/50',on:false},
        ].map((p,i)=>(
          <div key={i} className="chunk" style={{padding:12,background:'#fff',display:'flex',gap:10,alignItems:'center'}}>
            <div style={{width:48,height:48,borderRadius:14,background:p.c,color:'#fff',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900,fontSize:18,boxShadow:'var(--clay-sm)'}}>%</div>
            <div style={{flex:1}}>
              <div style={{fontWeight:700,fontSize:13}}>{p.n}</div>
              <div className="mono" style={{fontSize:10,color:'#8A7FA3'}}>{p.t} · ใช้ {p.use}</div>
            </div>
            <div style={{width:36,height:20,borderRadius:999,background:p.on?'#00D4B4':'#D0C8DC',position:'relative'}}>
              <div style={{position:'absolute',top:1,[p.on?'right':'left']:1,width:18,height:18,borderRadius:'50%',background:'#fff',boxShadow:'var(--clay-sm)'}}/>
            </div>
          </div>
        ))}
        <button className="btn" style={{background:'#2A1F3D',color:'#FFC94D',padding:'12px',fontSize:13,marginTop:6}}>＋ สร้างโปรใหม่</button>
      </div>
      <div style={{height:30}}/>
    </div>
  );
}

// === Reports ===
function SellerReports({go}){
  const months = [45,62,58,80,72,95];
  return (
    <div>
      <SellerHeader title="รายงานยอดขาย" sub="REPORTS" go={go}/>
      <div style={{padding:'14px 16px',display:'grid',gridTemplateColumns:'1fr 1fr',gap:10}}>
        <div className="chunk" style={{padding:12,background:'#2A1F3D',color:'#fff'}}>
          <div className="mono" style={{fontSize:9,opacity:.7,letterSpacing:'.15em'}}>เดือนนี้</div>
          <div className="display" style={{fontSize:22}}>฿48,240</div>
          <div style={{fontSize:10,color:'#00D4B4',fontWeight:700}}>↑ 22%</div>
        </div>
        <div className="chunk" style={{padding:12,background:'#FFC94D'}}>
          <div className="mono" style={{fontSize:9,color:'#4B3E66',letterSpacing:'.15em'}}>ออเดอร์</div>
          <div className="display" style={{fontSize:22}}>312</div>
          <div style={{fontSize:10,color:'#7A5200',fontWeight:700}}>เฉลี่ย 10/วัน</div>
        </div>
      </div>

      <div style={{padding:'0 16px'}}>
        <div className="chunk" style={{padding:14,background:'#fff',marginTop:10}}>
          <div style={{fontWeight:800,fontSize:13,marginBottom:10}}>ยอดขาย 6 เดือน</div>
          <svg viewBox="0 0 320 120" style={{width:'100%',height:120}}>
            <path d={`M 10 ${120-months[0]} ${months.map((m,i)=>`L ${10+i*62} ${120-m}`).join(' ')}`} stroke="#FF7A3A" strokeWidth="3" fill="none" strokeLinecap="round" strokeLinejoin="round"/>
            <path d={`M 10 ${120-months[0]} ${months.map((m,i)=>`L ${10+i*62} ${120-m}`).join(' ')} L ${10+(months.length-1)*62} 120 L 10 120 Z`} fill="url(#grad1)" opacity=".3"/>
            <defs><linearGradient id="grad1" x1="0" x2="0" y1="0" y2="1"><stop offset="0" stopColor="#FF7A3A"/><stop offset="1" stopColor="#FF7A3A" stopOpacity="0"/></linearGradient></defs>
            {months.map((m,i)=>(
              <circle key={i} cx={10+i*62} cy={120-m} r="5" fill="#fff" stroke="#FF7A3A" strokeWidth="3"/>
            ))}
            {['พ.ย.','ธ.ค.','ม.ค.','ก.พ.','มี.ค.','เม.ย.'].map((l,i)=>(
              <text key={i} x={10+i*62} y="118" textAnchor="middle" fontSize="9" fontFamily="JetBrains Mono" fill="#8A7FA3">{l}</text>
            ))}
          </svg>
        </div>
      </div>

      <H th="สินค้าขายดี" en="Top selling"/>
      <div style={{padding:'0 16px 20px',display:'flex',flexDirection:'column',gap:8}}>
        {[
          {n:'ข้าวซอยไก่',q:142,r:12070,hue:'tomato'},
          {n:'แกงเหลือง',q:88,r:7480,hue:'mango'},
          {n:'ผัดไทยกุ้ง',q:56,r:5040,hue:'pink'},
        ].map((p,i)=>(
          <div key={i} className="chunk" style={{padding:10,background:'#fff',display:'flex',alignItems:'center',gap:10}}>
            <div style={{width:40,height:40,borderRadius:12,background:'#FFE3EB',display:'flex',alignItems:'center',justifyContent:'center'}}>
              <Puff w={30} h={22} hue={p.hue}/>
            </div>
            <div style={{flex:1}}>
              <div style={{fontWeight:700,fontSize:13}}>{p.n}</div>
              <div className="mono" style={{fontSize:10,color:'#8A7FA3'}}>ขาย {p.q} จาน</div>
            </div>
            <div className="display" style={{fontSize:15,color:'#00D4B4'}}>฿{p.r.toLocaleString()}</div>
          </div>
        ))}
      </div>
    </div>
  );
}

// === Withdraw ===
function SellerWithdraw({go}){
  return (
    <div>
      <SellerHeader title="ถอนเงินเข้าบัญชี" sub="WITHDRAW" go={go}/>
      <div style={{padding:'14px 16px'}}>
        <div className="chunk" style={{padding:16,background:'linear-gradient(135deg,#00D4B4,#6B4BFF)',color:'#fff'}}>
          <div className="mono" style={{fontSize:10,opacity:.85,letterSpacing:'.15em'}}>ยอดคงเหลือ · ถอนได้</div>
          <div className="display" style={{fontSize:34,margin:'4px 0'}}>฿8,420.60</div>
          <div style={{fontSize:11,opacity:.85}}>รอเคลียร์ (2 วัน): ฿1,240</div>
        </div>
      </div>

      <div style={{padding:'0 16px'}}>
        <div className="chunk" style={{padding:12,background:'#fff'}}>
          <div className="mono" style={{fontSize:9,color:'#8A7FA3',letterSpacing:'.15em'}}>บัญชีรับเงิน</div>
          <div style={{display:'flex',alignItems:'center',gap:10,marginTop:6}}>
            <div style={{width:42,height:42,borderRadius:12,background:'#FFC94D',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900,fontSize:12,color:'#2A1F3D',boxShadow:'var(--clay-sm)'}}>SCB</div>
            <div style={{flex:1}}>
              <div style={{fontWeight:700,fontSize:13}}>ไทยพาณิชย์ · xxx-x-x4821</div>
              <div className="mono" style={{fontSize:10,color:'#8A7FA3'}}>นาง ปราณี ใจดี</div>
            </div>
            <span style={{color:'#FF7A3A',fontSize:11,fontWeight:700}}>เปลี่ยน</span>
          </div>
        </div>
      </div>

      <div style={{padding:'12px 16px 0'}}>
        <div className="mono" style={{fontSize:9,color:'#8A7FA3',letterSpacing:'.15em',marginBottom:6}}>จำนวนเงิน</div>
        <div className="chunk" style={{padding:16,background:'#FFF0C7',textAlign:'center'}}>
          <div className="display" style={{fontSize:34,color:'#2A1F3D'}}>฿5,000</div>
          <div style={{display:'flex',gap:6,justifyContent:'center',marginTop:10}}>
            {['1000','3000','ทั้งหมด'].map(q=>(
              <span key={q} style={{padding:'5px 12px',borderRadius:999,background:'#fff',fontSize:11,fontWeight:700,boxShadow:'var(--clay-sm)'}}>{q}</span>
            ))}
          </div>
        </div>
      </div>

      <div style={{padding:'14px 16px'}}>
        <button className="btn" style={{width:'100%',background:'#FF7A3A',color:'#fff',padding:'14px',fontSize:14}}>ถอนเข้า SCB</button>
        <div className="mono" style={{fontSize:10,color:'#8A7FA3',textAlign:'center',marginTop:6}}>ถึงบัญชีใน 15-30 นาที · ฟรีวันละ 3 ครั้ง</div>
      </div>

      <H th="ประวัติการถอน" en="History"/>
      <div style={{padding:'0 16px 20px',display:'flex',flexDirection:'column',gap:8}}>
        {[{d:'18 เม.ย. 10:24',a:3000,s:'สำเร็จ',c:'#00D4B4'},{d:'12 เม.ย. 14:10',a:5000,s:'สำเร็จ',c:'#00D4B4'},{d:'5 เม.ย. 09:00',a:2000,s:'สำเร็จ',c:'#00D4B4'}].map((h,i)=>(
          <div key={i} className="chunk" style={{padding:'10px 12px',background:'#fff',display:'flex',alignItems:'center',gap:10}}>
            <div style={{width:32,height:32,borderRadius:10,background:'#DFFAF3',display:'flex',alignItems:'center',justifyContent:'center',color:'#00D4B4',fontWeight:900}}>↓</div>
            <div style={{flex:1}}>
              <div style={{fontWeight:700,fontSize:12}}>ถอนเข้า SCB</div>
              <div className="mono" style={{fontSize:10,color:'#8A7FA3'}}>{h.d} · {h.s}</div>
            </div>
            <div className="display" style={{fontSize:15}}>฿{h.a.toLocaleString()}</div>
          </div>
        ))}
      </div>
    </div>
  );
}

Object.assign(window, {SellerApp});
