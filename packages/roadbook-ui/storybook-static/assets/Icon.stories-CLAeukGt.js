import{j as e}from"./jsx-runtime-Cf8x2fCZ.js";import{I as t,i as v}from"./icon-gHkr6FUq.js";import"./index-yBjzXJbu.js";import"./utils-BLSKlp9E.js";const b={title:"Base/Icon",component:t,argTypes:{name:{control:"select",options:Object.keys(v)},size:{control:{type:"range",min:16,max:32,step:2}}}},r={args:{name:"navigate",size:24}},a={render:()=>e.jsx("div",{style:{display:"grid",gridTemplateColumns:"repeat(auto-fill, minmax(90px, 1fr))",gap:8},children:Object.keys(v).map(s=>e.jsxs("div",{style:{padding:"12px 8px",textAlign:"center",background:"var(--frost)",borderRadius:12,border:"1px solid var(--frost-border)"},children:[e.jsx(t,{name:s,size:24}),e.jsx("div",{style:{fontSize:10,color:"var(--ink-secondary)",marginTop:6},children:s})]},s))})},n={render:()=>e.jsx("div",{className:"flex gap-6 items-end",children:[16,18,20,24,28].map(s=>e.jsxs("div",{className:"flex flex-col items-center gap-2",children:[e.jsx(t,{name:"search",size:s}),e.jsxs("span",{className:"text-[10px] text-ink-tertiary",children:[s,"px"]})]},s))})};var i,o,c;r.parameters={...r.parameters,docs:{...(i=r.parameters)==null?void 0:i.docs,source:{originalSource:`{
  args: {
    name: 'navigate',
    size: 24
  }
}`,...(c=(o=r.parameters)==null?void 0:o.docs)==null?void 0:c.source}}};var d,p,l;a.parameters={...a.parameters,docs:{...(d=a.parameters)==null?void 0:d.docs,source:{originalSource:`{
  render: () => <div style={{
    display: 'grid',
    gridTemplateColumns: 'repeat(auto-fill, minmax(90px, 1fr))',
    gap: 8
  }}>
      {Object.keys(iconPaths).map(name => <div key={name} style={{
      padding: '12px 8px',
      textAlign: 'center',
      background: 'var(--frost)',
      borderRadius: 12,
      border: '1px solid var(--frost-border)'
    }}>
          <Icon name={name} size={24} />
          <div style={{
        fontSize: 10,
        color: 'var(--ink-secondary)',
        marginTop: 6
      }}>{name}</div>
        </div>)}
    </div>
}`,...(l=(p=a.parameters)==null?void 0:p.docs)==null?void 0:l.source}}};var m,x,g;n.parameters={...n.parameters,docs:{...(m=n.parameters)==null?void 0:m.docs,source:{originalSource:`{
  render: () => <div className="flex gap-6 items-end">
      {[16, 18, 20, 24, 28].map(s => <div key={s} className="flex flex-col items-center gap-2">
          <Icon name="search" size={s} />
          <span className="text-[10px] text-ink-tertiary">{s}px</span>
        </div>)}
    </div>
}`,...(g=(x=n.parameters)==null?void 0:x.docs)==null?void 0:g.source}}};const k=["Single","AllIcons","Sizes"];export{a as AllIcons,r as Single,n as Sizes,k as __namedExportsOrder,b as default};
