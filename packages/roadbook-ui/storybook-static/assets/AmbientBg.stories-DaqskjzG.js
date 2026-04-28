import{j as t}from"./jsx-runtime-Cf8x2fCZ.js";import{c as l}from"./utils-BLSKlp9E.js";import"./index-yBjzXJbu.js";const c=[{color:"rgba(245,210,170,0.18)",size:350,top:"-5%",right:"-5%",delay:"0s"},{color:"rgba(255,180,140,0.12)",size:300,bottom:"5%",left:"-5%",delay:"-10s"},{color:"rgba(245,224,176,0.13)",size:260,bottom:"30%",right:"10%",delay:"-18s"}];function i({className:a}){return t.jsx("div",{className:l("fixed inset-0 z-0 overflow-hidden pointer-events-none",a),children:c.map((e,d)=>t.jsx("div",{className:"absolute rounded-full animate-drift",style:{width:e.size,height:e.size,background:e.color,filter:"blur(80px)",top:e.top,right:e.right,bottom:e.bottom,left:e.left,animationDelay:e.delay}},d))})}i.__docgenInfo={description:"",methods:[],displayName:"AmbientBg",props:{className:{required:!1,tsType:{name:"string"},description:""}}};const f={title:"Base/AmbientBg",component:i},n={render:()=>t.jsxs("div",{style:{position:"relative",height:400,borderRadius:20,overflow:"hidden",background:"var(--canvas)"},children:[t.jsx(i,{}),t.jsx("div",{style:{position:"relative",zIndex:1,padding:40,fontSize:34,fontWeight:200},children:"小肥路书"})]})};var o,s,r;n.parameters={...n.parameters,docs:{...(o=n.parameters)==null?void 0:o.docs,source:{originalSource:`{
  render: () => <div style={{
    position: 'relative',
    height: 400,
    borderRadius: 20,
    overflow: 'hidden',
    background: 'var(--canvas)'
  }}>
      <AmbientBg />
      <div style={{
      position: 'relative',
      zIndex: 1,
      padding: 40,
      fontSize: 34,
      fontWeight: 200
    }}>
        小肥路书
      </div>
    </div>
}`,...(r=(s=n.parameters)==null?void 0:s.docs)==null?void 0:r.source}}};const h=["Default"];export{n as Default,h as __namedExportsOrder,f as default};
