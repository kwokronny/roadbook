import{j as e}from"./jsx-runtime-Cf8x2fCZ.js";import{T as a}from"./time-badge-CxrVOmkS.js";import"./index-yBjzXJbu.js";import"./index-1evVQkiP.js";import"./utils-BLSKlp9E.js";const S={title:"Base/TimeBadge",component:a,argTypes:{variant:{control:"select",options:["poi","hotel","unplanned"]},editable:{control:"boolean"}}},t={args:{variant:"poi",time:"11:30",editable:!0}},r={args:{variant:"hotel",time:"入住 15:00",editable:!0}},n={args:{variant:"unplanned",time:"待规划"}},i={render:()=>e.jsxs("div",{className:"flex flex-wrap gap-3 items-center",children:[e.jsx(a,{variant:"poi",time:"01:00",editable:!0}),e.jsx(a,{variant:"poi",time:"11:30",editable:!0}),e.jsx(a,{variant:"hotel",time:"入住 02:00",editable:!0}),e.jsx(a,{variant:"hotel",time:"退房 11:00",editable:!0}),e.jsx(a,{variant:"unplanned",time:"待规划"})]})};var s,o,m;t.parameters={...t.parameters,docs:{...(s=t.parameters)==null?void 0:s.docs,source:{originalSource:`{
  args: {
    variant: 'poi',
    time: '11:30',
    editable: true
  }
}`,...(m=(o=t.parameters)==null?void 0:o.docs)==null?void 0:m.source}}};var l,d,p;r.parameters={...r.parameters,docs:{...(l=r.parameters)==null?void 0:l.docs,source:{originalSource:`{
  args: {
    variant: 'hotel',
    time: '入住 15:00',
    editable: true
  }
}`,...(p=(d=r.parameters)==null?void 0:d.docs)==null?void 0:p.source}}};var c,u,g;n.parameters={...n.parameters,docs:{...(c=n.parameters)==null?void 0:c.docs,source:{originalSource:`{
  args: {
    variant: 'unplanned',
    time: '待规划'
  }
}`,...(g=(u=n.parameters)==null?void 0:u.docs)==null?void 0:g.source}}};var v,b,x;i.parameters={...i.parameters,docs:{...(v=i.parameters)==null?void 0:v.docs,source:{originalSource:`{
  render: () => <div className="flex flex-wrap gap-3 items-center">
      <TimeBadge variant="poi" time="01:00" editable />
      <TimeBadge variant="poi" time="11:30" editable />
      <TimeBadge variant="hotel" time="入住 02:00" editable />
      <TimeBadge variant="hotel" time="退房 11:00" editable />
      <TimeBadge variant="unplanned" time="待规划" />
    </div>
}`,...(x=(b=i.parameters)==null?void 0:b.docs)==null?void 0:x.source}}};const O=["POI","Hotel","Unplanned","AllVariants"];export{i as AllVariants,r as Hotel,t as POI,n as Unplanned,O as __namedExportsOrder,S as default};
