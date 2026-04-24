// Extra screens for Seller / Rider / Admin
function SellerEditProduct({go}){
  return (
    <div style={{background:'#FFF8EE',minHeight:'100%'}}>
      <div style={{padding:'14px 16px',display:'flex',alignItems:'center',gap:10}}>
        <button onClick={()=>go&&go('products')} style={{width:34,height:34,borderRadius:12,border:0,background:'#fff',fontWeight:900,cursor:'pointer',fontFamily:'inherit',boxShadow:'var(--clay-sm)'}}>←</button>
        <div style={{flex:1}}>
          <div className="mono" style={{fontSize:9,letterSpacing:'.18em',color:'#6E6A85'}}>EDIT PRODUCT</div>
          <div style={{fontWeight:900,fontSize:16}}>แก้ไขสินค้า</div>
        </div>
        <button className="btn mango" style={{padding:'8px 14px',fontSize:12}}>บันทึก</button>
      </div>

      <div style={{padding:'0 16px',display:'flex',flexDirection:'column',gap:12}}>
        <div className="chunk" style={{padding:14}}>
          <div className="mono" style={{fontSize:10,letterSpacing:'.15em',color:'#6E6A85'}}>รูปสินค้า · 3 รูป</div>
          <div style={{display:'grid',gridTemplateColumns:'repeat(4,1fr)',gap:8,marginTop:8}}>
            {['#FF3E6C','#FFC94D','#00D4B4',null].map((c,i)=>(
              <div key={i} style={{aspectRatio:'1/1',borderRadius:14,background:c||'rgba(14,11,31,.06)',display:'flex',alignItems:'center',justifyContent:'center',color:c?'#fff':'#6E6A85',fontSize:c?20:24,boxShadow:c?'var(--clay-sm)':'none',border:c?'none':'2px dashed rgba(14,11,31,.2)'}}>
                {c?'🍜':'+'}
              </div>
            ))}
          </div>
        </div>

        {[
          {l:'ชื่อสินค้า',v:'ข้าวซอยไก่ (กลาง)'},
          {l:'คำอธิบาย',v:'สูตรครัวยายปราณี · ไก่นุ่ม เครื่องแกงโฮมเมด',t:true},
          {l:'ราคา',v:'85',prefix:'฿'},
          {l:'สต็อก',v:'24'},
        ].map((f,i)=>(
          <div key={i} className="chunk" style={{padding:12}}>
            <div className="mono" style={{fontSize:10,letterSpacing:'.15em',color:'#6E6A85',marginBottom:4}}>{f.l.toUpperCase()}</div>
            <div style={{display:'flex',alignItems:'center',gap:6,padding:'8px 10px',borderRadius:10,background:'#FFF8EE',boxShadow:'inset 0 2px 4px rgba(70,42,92,.08)'}}>
              {f.prefix && <span className="display" style={{fontSize:18,color:'#FF3E6C'}}>{f.prefix}</span>}
              {f.t ? <textarea defaultValue={f.v} style={{flex:1,border:0,outline:'none',background:'transparent',fontFamily:'inherit',fontSize:13,fontWeight:600,resize:'none',minHeight:40}}/> : <input defaultValue={f.v} style={{flex:1,border:0,outline:'none',background:'transparent',fontFamily:'inherit',fontSize:14,fontWeight:700}}/>}
            </div>
          </div>
        ))}

        <div className="chunk" style={{padding:12}}>
          <div className="mono" style={{fontSize:10,letterSpacing:'.15em',color:'#6E6A85',marginBottom:6}}>ตัวเลือกเพิ่ม (ADD-ONS)</div>
          {[{n:'ไข่ต้ม',p:10},{n:'พิเศษเนื้อ',p:20},{n:'ไม่ใส่ผัก',p:0}].map((a,i)=>(
            <div key={i} style={{display:'flex',alignItems:'center',gap:8,padding:'8px 0',borderTop:i?'1px dashed rgba(14,11,31,.1)':'none'}}>
              <span style={{width:22,height:22,borderRadius:7,background:'#FFC94D',color:'#2A1F3D',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900,fontSize:11,boxShadow:'var(--clay-sm)'}}>✓</span>
              <div style={{flex:1,fontSize:12,fontWeight:700}}>{a.n}</div>
              <div className="mono" style={{fontSize:11,color:'#6E6A85'}}>+฿{a.p}</div>
              <span style={{color:'#8A7FA3',fontSize:16}}>✎</span>
            </div>
          ))}
          <button className="btn ghost" style={{marginTop:10,padding:'8px 14px',fontSize:11,width:'100%'}}>+ เพิ่มตัวเลือก</button>
        </div>

        <div className="chunk" style={{padding:12,display:'flex',alignItems:'center',gap:10,marginBottom:14}}>
          <div style={{flex:1}}>
            <div style={{fontWeight:800,fontSize:13}}>เปิดขายทันที</div>
            <div style={{fontSize:11,color:'#6E6A85'}}>แสดงในหน้า Home ของลูกค้า</div>
          </div>
          <div style={{width:50,height:28,borderRadius:999,background:'#00D4B4',padding:2,display:'flex',justifyContent:'flex-end',boxShadow:'var(--clay-sm)'}}>
            <div style={{width:24,height:24,borderRadius:'50%',background:'#fff',boxShadow:'var(--clay-sm)'}}/>
          </div>
        </div>
      </div>
    </div>
  );
}

function SellerPromoBuilder({go}){
  return (
    <div style={{background:'#FFF8EE',minHeight:'100%'}}>
      <div style={{padding:'14px 16px',display:'flex',alignItems:'center',gap:10}}>
        <button onClick={()=>go&&go('promos')} style={{width:34,height:34,borderRadius:12,border:0,background:'#fff',fontWeight:900,cursor:'pointer',fontFamily:'inherit',boxShadow:'var(--clay-sm)'}}>←</button>
        <div style={{flex:1}}>
          <div className="mono" style={{fontSize:9,letterSpacing:'.18em',color:'#6E6A85'}}>NEW PROMOTION</div>
          <div style={{fontWeight:900,fontSize:16}}>สร้างโปรโมชั่น</div>
        </div>
      </div>

      <div style={{padding:'0 16px',display:'flex',flexDirection:'column',gap:12}}>
        <div style={{padding:16,borderRadius:22,background:'linear-gradient(135deg,#FF3E6C,#FFC94D)',color:'#fff',boxShadow:'var(--clay)'}}>
          <div className="mono" style={{fontSize:10,letterSpacing:'.2em',opacity:.85}}>PREVIEW</div>
          <div className="display" style={{fontSize:28,lineHeight:1}}>ลด 15%</div>
          <div style={{fontSize:12,marginTop:2}}>ทุกเมนูข้าว · หมดเขต 30 เม.ย.</div>
          <div style={{marginTop:8,padding:'6px 10px',background:'rgba(0,0,0,.2)',borderRadius:10,fontSize:10,display:'inline-block'}}>โค้ด <b className="mono">RICE15</b></div>
        </div>

        <div className="chunk" style={{padding:14}}>
          <div className="mono" style={{fontSize:10,letterSpacing:'.15em',color:'#6E6A85',marginBottom:8}}>ประเภท</div>
          <div style={{display:'grid',gridTemplateColumns:'repeat(4,1fr)',gap:6}}>
            {[{i:'%',l:'ลด %',on:true,c:'#FF3E6C'},{i:'฿',l:'ลด ฿',c:'#FFC94D'},{i:'🚚',l:'ส่งฟรี',c:'#00D4B4'},{i:'1+1',l:'ซื้อ 1 แถม 1',c:'#6B4BFF'}].map(t=>(
              <div key={t.l} style={{padding:'10px 6px',borderRadius:14,background:t.on?t.c:'#fff',color:t.on?'#fff':'#0E0B1F',boxShadow:'var(--clay-sm)',textAlign:'center'}}>
                <div style={{fontSize:16,fontWeight:900}}>{t.i}</div>
                <div style={{fontSize:9,fontWeight:700,marginTop:2}}>{t.l}</div>
              </div>
            ))}
          </div>
        </div>

        <div className="chunk" style={{padding:14}}>
          <div className="mono" style={{fontSize:10,letterSpacing:'.15em',color:'#6E6A85',marginBottom:6}}>เปอร์เซ็นต์ส่วนลด</div>
          <div style={{display:'flex',alignItems:'baseline',gap:6}}>
            <span className="display" style={{fontSize:36,color:'#FF3E6C'}}>15</span>
            <span className="display" style={{fontSize:22,color:'#FF3E6C'}}>%</span>
          </div>
          <div style={{marginTop:8,height:8,borderRadius:999,background:'rgba(14,11,31,.08)',position:'relative'}}>
            <div style={{width:'30%',height:'100%',borderRadius:999,background:'linear-gradient(90deg,#FFC94D,#FF3E6C)'}}/>
            <div style={{position:'absolute',left:'30%',top:-4,width:16,height:16,borderRadius:'50%',background:'#fff',boxShadow:'var(--clay)'}}/>
          </div>
          <div style={{display:'flex',justifyContent:'space-between',marginTop:4,fontSize:9,color:'#6E6A85'}}>
            <span>5%</span><span>25%</span><span>50%</span>
          </div>
        </div>

        <div className="chunk" style={{padding:14}}>
          <div className="mono" style={{fontSize:10,letterSpacing:'.15em',color:'#6E6A85',marginBottom:6}}>ช่วงเวลา</div>
          <div style={{display:'grid',gridTemplateColumns:'1fr 1fr',gap:8}}>
            {[{l:'เริ่ม',v:'15 เม.ย. · 00:00'},{l:'สิ้นสุด',v:'30 เม.ย. · 23:59'}].map(d=>(
              <div key={d.l} style={{padding:10,borderRadius:12,background:'#FFF8EE',boxShadow:'inset 0 2px 4px rgba(70,42,92,.08)'}}>
                <div className="mono" style={{fontSize:9,color:'#6E6A85'}}>{d.l}</div>
                <div style={{fontWeight:700,fontSize:12,marginTop:2}}>{d.v}</div>
              </div>
            ))}
          </div>
        </div>

        <div className="chunk" style={{padding:14}}>
          <div className="mono" style={{fontSize:10,letterSpacing:'.15em',color:'#6E6A85',marginBottom:6}}>ใช้ได้กับ</div>
          <div style={{display:'flex',flexWrap:'wrap',gap:6}}>
            {[{l:'ทุกสินค้า',on:true},{l:'เฉพาะหมวด'},{l:'เลือกสินค้า'}].map(o=>(
              <span key={o.l} style={{padding:'7px 12px',borderRadius:999,background:o.on?'#0E0B1F':'#fff',color:o.on?'#FFC94D':'#0E0B1F',fontWeight:700,fontSize:11,boxShadow:'var(--clay-sm)'}}>{o.l}</span>
            ))}
          </div>
        </div>

        <button className="btn pink" style={{marginBottom:14,padding:14,fontSize:14}}>เริ่มโปรโมชั่น</button>
      </div>
    </div>
  );
}

function RiderSOS({go}){
  return (
    <div style={{background:'linear-gradient(180deg,#2A1F3D,#6B0F2E)',minHeight:'100%',color:'#fff'}}>
      <div style={{padding:'14px 16px',display:'flex',alignItems:'center',gap:10}}>
        <button onClick={()=>go&&go('profile')} style={{width:34,height:34,borderRadius:12,border:0,background:'rgba(255,255,255,.12)',color:'#fff',fontWeight:900,cursor:'pointer',fontFamily:'inherit'}}>←</button>
        <div style={{flex:1}}>
          <div className="mono" style={{fontSize:9,letterSpacing:'.18em',opacity:.6}}>EMERGENCY</div>
          <div style={{fontWeight:900,fontSize:16}}>SOS · ฉุกเฉิน</div>
        </div>
      </div>

      <div style={{padding:'10px 16px 0',textAlign:'center'}}>
        <div style={{position:'relative',width:200,height:200,margin:'10px auto'}}>
          <div style={{position:'absolute',inset:0,borderRadius:'50%',background:'#FF3E6C',animation:'pulse-ring 1.6s infinite',opacity:.4}}/>
          <div style={{position:'absolute',inset:20,borderRadius:'50%',background:'#FF3E6C',animation:'pulse-ring 1.6s infinite .3s',opacity:.5}}/>
          <button style={{position:'absolute',inset:40,borderRadius:'50%',background:'linear-gradient(160deg,#FF3E6C,#A81E47)',color:'#fff',border:0,boxShadow:'var(--clay-lg)',cursor:'pointer',fontFamily:'inherit'}}>
            <div className="display" style={{fontSize:28,letterSpacing:'.1em'}}>SOS</div>
            <div style={{fontSize:10,fontWeight:700,opacity:.9}}>กดค้าง 3 วิ</div>
          </button>
        </div>
        <div style={{fontSize:12,opacity:.8,maxWidth:260,margin:'0 auto'}}>ระบบจะแจ้งเจ้าหน้าที่ Thaiprompt + ส่งตำแหน่งปัจจุบันให้ผู้ติดต่อฉุกเฉิน 3 คน</div>
      </div>

      <div style={{padding:'18px 16px 0'}}>
        <div className="mono" style={{fontSize:10,letterSpacing:'.15em',opacity:.6,marginBottom:8}}>ติดต่อเร่งด่วน</div>
        <div style={{display:'flex',flexDirection:'column',gap:8}}>
          {[{n:'เจ้าหน้าที่ Thaiprompt',d:'24 ชม.',c:'#FFC94D',i:'☎'},{n:'1669 · การแพทย์ฉุกเฉิน',d:'สพฉ.',c:'#FF3E6C',i:'+'},{n:'191 · ตำรวจ',d:'แจ้งเหตุ',c:'#6B4BFF',i:'◉'},{n:'199 · ดับเพลิง',d:'สายด่วน',c:'#FF7A3A',i:'🔥'}].map((c,i)=>(
            <div key={i} style={{padding:12,borderRadius:16,background:'rgba(255,255,255,.08)',display:'flex',alignItems:'center',gap:10}}>
              <div style={{width:38,height:38,borderRadius:12,background:c.c,color:'#2A1F3D',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900,fontSize:16,boxShadow:'var(--clay-sm)'}}>{c.i}</div>
              <div style={{flex:1}}>
                <div style={{fontWeight:800,fontSize:13}}>{c.n}</div>
                <div className="mono" style={{fontSize:10,opacity:.6}}>{c.d}</div>
              </div>
              <button style={{border:0,padding:'6px 14px',borderRadius:999,background:'#00D4B4',color:'#2A1F3D',fontWeight:800,fontSize:11,cursor:'pointer',fontFamily:'inherit'}}>โทร</button>
            </div>
          ))}
        </div>
      </div>

      <div style={{padding:'14px 16px 20px'}}>
        <div className="mono" style={{fontSize:10,letterSpacing:'.15em',opacity:.6,marginBottom:8}}>สถานะปัจจุบัน</div>
        <div style={{padding:12,borderRadius:16,background:'rgba(255,255,255,.08)'}}>
          <div style={{display:'flex',alignItems:'center',gap:10}}>
            <span style={{width:10,height:10,borderRadius:'50%',background:'#00D4B4'}}/>
            <div style={{flex:1,fontWeight:700,fontSize:12}}>ตำแหน่งถูกแชร์อัตโนมัติ</div>
          </div>
          <div className="mono" style={{fontSize:10,opacity:.7,marginTop:4}}>13.7563° N, 100.5018° E · สุขุมวิท 24</div>
        </div>
      </div>
    </div>
  );
}

function RiderShift({go}){
  const slots = [
    {t:'06:00 - 10:00',l:'เช้า',s:'ว่าง',c:'#00D4B4',bonus:'+฿50'},
    {t:'10:00 - 14:00',l:'กลางวัน',s:'ว่าง',c:'#FFC94D'},
    {t:'14:00 - 18:00',l:'บ่าย',s:'เต็ม',c:'#6E6A85'},
    {t:'18:00 - 22:00',l:'เย็น',s:'ฮอต',c:'#FF3E6C',bonus:'+฿100'},
    {t:'22:00 - 02:00',l:'ดึก',s:'ว่าง',c:'#6B4BFF',bonus:'+฿80'},
  ];
  return (
    <div style={{background:'#2A1F3D',minHeight:'100%',color:'#fff'}}>
      <div style={{padding:'14px 16px',display:'flex',alignItems:'center',gap:10}}>
        <button onClick={()=>go&&go('dash')} style={{width:34,height:34,borderRadius:12,border:0,background:'rgba(255,255,255,.1)',color:'#fff',fontWeight:900,cursor:'pointer',fontFamily:'inherit'}}>←</button>
        <div style={{flex:1}}>
          <div className="mono" style={{fontSize:9,letterSpacing:'.18em',opacity:.6}}>SHIFT SCHEDULE</div>
          <div style={{fontWeight:900,fontSize:16}}>จองกะทำงาน · พรุ่งนี้</div>
        </div>
      </div>

      <div style={{padding:'0 16px 10px',display:'flex',gap:6,overflowX:'auto'}}>
        {['จ.15','อ.16','พ.17','พฤ.18','ศ.19','ส.20','อา.21'].map((d,i)=>(
          <div key={d} style={{padding:'8px 12px',borderRadius:14,background:i===1?'#FFC94D':'rgba(255,255,255,.08)',color:i===1?'#2A1F3D':'#fff',fontSize:11,fontWeight:700,flexShrink:0,textAlign:'center'}}>
            <div style={{fontSize:9,opacity:.7}}>{d.split('.')[0]}</div>
            <div style={{fontSize:14}}>{d.split('.')[1]}</div>
          </div>
        ))}
      </div>

      <div style={{padding:'10px 16px 20px',display:'flex',flexDirection:'column',gap:10}}>
        {slots.map((s,i)=>(
          <div key={i} style={{padding:14,borderRadius:18,background:s.s==='เต็ม'?'rgba(255,255,255,.05)':'rgba(255,255,255,.1)',display:'flex',alignItems:'center',gap:12,opacity:s.s==='เต็ม'?.55:1}}>
            <div style={{width:50,height:50,borderRadius:16,background:s.c,color:'#2A1F3D',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900,boxShadow:'var(--clay-sm)',fontSize:10,flexDirection:'column'}}>
              <div style={{fontSize:14}}>●</div>
              <div style={{fontSize:8,marginTop:1}}>{s.l}</div>
            </div>
            <div style={{flex:1,minWidth:0}}>
              <div className="mono" style={{fontSize:11,fontWeight:700}}>{s.t}</div>
              <div style={{fontSize:11,opacity:.8,marginTop:2}}>
                {s.s==='เต็ม'?'ไม่มีช่องว่าง':`${['8/12','3/12','','2/12','6/12'][i]} ไรเดอร์ · คาดการณ์ 18-24 งาน`}
              </div>
              {s.bonus && <div style={{marginTop:4,display:'inline-block',padding:'2px 8px',borderRadius:6,background:s.c,color:'#2A1F3D',fontSize:10,fontWeight:800}}>{s.bonus} โบนัส</div>}
            </div>
            <button disabled={s.s==='เต็ม'} style={{border:0,padding:'8px 14px',borderRadius:999,background:s.s==='เต็ม'?'rgba(255,255,255,.08)':'#FFC94D',color:s.s==='เต็ม'?'#6E6A85':'#2A1F3D',fontWeight:800,fontSize:11,cursor:s.s==='เต็ม'?'not-allowed':'pointer',fontFamily:'inherit',boxShadow:s.s==='เต็ม'?'none':'var(--clay-sm)'}}>
              {s.s==='เต็ม'?'เต็ม':'จอง'}
            </button>
          </div>
        ))}
      </div>
    </div>
  );
}

function AdminBanner({go}){
  const banners = [
    {n:'สงกรานต์ Fest 2025',s:'ใช้งานอยู่',imp:48200,clicks:3180,ctr:'6.6%',c:'#FF3E6C'},
    {n:'เปิดตัว MLM Gold',s:'รอเวลา',imp:0,clicks:0,ctr:'—',c:'#FFC94D'},
    {n:'ส่งฟรี 48 ชม.',s:'หยุด',imp:12800,clicks:620,ctr:'4.8%',c:'#6E6A85'},
  ];
  return (
    <div style={{background:'#FFF8EE',minHeight:'100%'}}>
      <div style={{padding:'14px 16px',display:'flex',alignItems:'center',gap:10}}>
        <div style={{width:34,height:34,borderRadius:12,background:'#0E0B1F',color:'#FFC94D',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900,fontSize:16,boxShadow:'var(--clay-sm)'}}>◎</div>
        <div style={{flex:1}}>
          <div className="mono" style={{fontSize:9,letterSpacing:'.18em',color:'#6E6A85'}}>THAIPROMPT.ONLINE · ADMIN</div>
          <div style={{fontWeight:900,fontSize:16}}>แบนเนอร์โฆษณา Remote</div>
        </div>
        <div style={{padding:'4px 10px',borderRadius:999,background:'#00D4B4',color:'#fff',fontSize:10,fontWeight:800}}>● LIVE</div>
      </div>

      <div style={{padding:'0 16px 14px'}}>
        <div style={{padding:14,borderRadius:20,background:'linear-gradient(135deg,#6B4BFF,#FF3E6C 60%,#FFC94D)',color:'#fff',boxShadow:'var(--clay)'}}>
          <div className="mono" style={{fontSize:10,letterSpacing:'.2em',opacity:.85}}>DEVICES REACHED · TODAY</div>
          <div className="display" style={{fontSize:30,lineHeight:1}}>142,380</div>
          <div style={{display:'flex',gap:10,marginTop:8,fontSize:11,fontWeight:700}}>
            <span>📱 Buyer 98K</span><span>🛵 Rider 28K</span><span>🏪 Seller 16K</span>
          </div>
        </div>
      </div>

      <H th="แบนเนอร์ที่กำลังรัน" en="Active campaigns"/>
      <div style={{padding:'0 16px',display:'flex',flexDirection:'column',gap:10}}>
        {banners.map((b,i)=>(
          <div key={i} className="chunk" style={{padding:12,display:'flex',gap:10,alignItems:'center'}}>
            <div style={{width:54,height:54,borderRadius:14,background:b.c,color:'#fff',display:'flex',alignItems:'center',justifyContent:'center',fontWeight:900,boxShadow:'var(--clay-sm)',fontSize:20}}>▦</div>
            <div style={{flex:1,minWidth:0}}>
              <div style={{fontWeight:800,fontSize:13}}>{b.n}</div>
              <div className="mono" style={{fontSize:10,color:'#6E6A85',marginTop:2}}>แสดง {b.imp.toLocaleString()} · คลิก {b.clicks.toLocaleString()} · CTR {b.ctr}</div>
            </div>
            <div style={{padding:'4px 10px',borderRadius:999,background:b.s==='ใช้งานอยู่'?'#00D4B4':b.s==='รอเวลา'?'#FFC94D':'rgba(14,11,31,.1)',color:b.s==='หยุด'?'#6E6A85':'#fff',fontSize:10,fontWeight:800}}>{b.s}</div>
          </div>
        ))}
      </div>

      <H th="กำหนดเป้าหมาย · Remote config" en="Targeting"/>
      <div style={{padding:'0 16px 20px',display:'flex',flexDirection:'column',gap:10}}>
        <div className="chunk" style={{padding:12}}>
          <div className="mono" style={{fontSize:10,letterSpacing:'.15em',color:'#6E6A85',marginBottom:6}}>ผู้ใช้กลุ่มเป้าหมาย</div>
          <div style={{display:'flex',flexWrap:'wrap',gap:6}}>
            {[{l:'Buyer',on:true,c:'#FF3E6C'},{l:'Seller',on:true,c:'#FF7A3A'},{l:'Rider',c:'#2A1F3D'},{l:'MLM',on:true,c:'#6B4BFF'}].map(t=>(
              <span key={t.l} style={{padding:'6px 12px',borderRadius:999,background:t.on?t.c:'#fff',color:t.on?'#fff':'#0E0B1F',fontWeight:700,fontSize:11,boxShadow:'var(--clay-sm)'}}>{t.on?'✓ ':''}{t.l}</span>
            ))}
          </div>
        </div>
        <div className="chunk" style={{padding:12}}>
          <div className="mono" style={{fontSize:10,letterSpacing:'.15em',color:'#6E6A85',marginBottom:6}}>เขตพื้นที่</div>
          <div style={{display:'flex',flexWrap:'wrap',gap:6}}>
            {['กรุงเทพ','เชียงใหม่','ภูเก็ต','ขอนแก่น','อุดร','หาดใหญ่'].map((l,i)=>(
              <span key={l} style={{padding:'6px 12px',borderRadius:999,background:i<3?'#FFC94D':'#fff',fontWeight:700,fontSize:11,boxShadow:'var(--clay-sm)'}}>{i<3?'✓ ':''}{l}</span>
            ))}
          </div>
        </div>
        <button className="btn" style={{background:'linear-gradient(135deg,#FF3E6C,#FFC94D)',color:'#fff',padding:14,fontSize:13}}>+ สร้างแคมเปญใหม่</button>
      </div>
    </div>
  );
}

Object.assign(window, {SellerEditProduct, SellerPromoBuilder, RiderSOS, RiderShift, AdminBanner});
