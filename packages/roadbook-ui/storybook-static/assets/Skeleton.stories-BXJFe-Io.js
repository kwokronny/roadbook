import{j as a}from"./jsx-runtime-Cf8x2fCZ.js";import{c as w}from"./index-1evVQkiP.js";import{c as j}from"./utils-BLSKlp9E.js";import{G as v}from"./glass-card-C7Z9wDaH.js";import"./index-yBjzXJbu.js";const k=w("animate-shimmer",{variants:{variant:{text:"h-3 rounded-[6px]",avatar:"rounded-full",image:"rounded-card-inner",tag:"rounded-pill h-5"}},defaultVariants:{variant:"text"}});function e({variant:N,className:g,style:h,...f}){return a.jsx("div",{className:j(k({variant:N}),g),style:{background:"linear-gradient(120deg, var(--bone-base) 25%, var(--bone-shimmer) 50%, var(--bone-base) 75%)",backgroundSize:"200% 100%",...h},...f})}e.__docgenInfo={description:"",methods:[],displayName:"Skeleton",composes:["VariantProps"]};const G={title:"Base/Skeleton",component:e,argTypes:{variant:{control:"select",options:["text","avatar","image","tag"]}}},s={render:()=>a.jsxs("div",{className:"flex flex-col gap-4 max-w-xs",children:[a.jsxs("div",{className:"flex flex-col gap-2",children:[a.jsx("span",{className:"text-[11px] text-ink-tertiary",children:"text"}),a.jsx(e,{variant:"text",className:"w-[140px]"}),a.jsx(e,{variant:"text",className:"w-[100px]"})]}),a.jsxs("div",{className:"flex flex-col gap-2",children:[a.jsx("span",{className:"text-[11px] text-ink-tertiary",children:"avatar"}),a.jsx(e,{variant:"avatar",className:"w-11 h-11"})]}),a.jsxs("div",{className:"flex flex-col gap-2",children:[a.jsx("span",{className:"text-[11px] text-ink-tertiary",children:"image"}),a.jsx(e,{variant:"image",className:"w-[52px] h-[52px]"})]}),a.jsxs("div",{className:"flex flex-col gap-2",children:[a.jsx("span",{className:"text-[11px] text-ink-tertiary",children:"tag"}),a.jsx(e,{variant:"tag",className:"w-[48px]"})]})]})},t={render:()=>a.jsxs(v,{className:"p-card-pad max-w-xs",children:[a.jsxs("div",{className:"flex justify-between items-start mb-2",children:[a.jsx(e,{variant:"text",className:"w-[140px] h-4"}),a.jsx(e,{variant:"tag",className:"w-[52px]"})]}),a.jsx(e,{variant:"text",className:"w-[100px] h-3 mb-3"}),a.jsxs("div",{className:"flex gap-1 mb-3",children:[a.jsx(e,{variant:"tag",className:"w-[48px]"}),a.jsx(e,{variant:"tag",className:"w-[48px]"})]}),a.jsx("div",{className:"border-t border-dashed border-[rgba(28,28,30,0.08)] pt-2",children:a.jsxs("div",{className:"flex gap-1",children:[a.jsx(e,{variant:"avatar",className:"w-5 h-5"}),a.jsx(e,{variant:"avatar",className:"w-5 h-5"}),a.jsx(e,{variant:"avatar",className:"w-5 h-5"})]})})]})},r={render:()=>a.jsx(v,{className:"p-3 max-w-xs",children:a.jsxs("div",{className:"flex gap-2.5",children:[a.jsx(e,{variant:"image",className:"w-12 h-12"}),a.jsxs("div",{className:"flex-1 flex flex-col gap-1.5",children:[a.jsx(e,{variant:"tag",className:"w-[40px]"}),a.jsx(e,{variant:"text",className:"w-[120px] h-4"}),a.jsx(e,{variant:"text",className:"w-[80px] h-3"})]})]})})};var n,l,x;s.parameters={...s.parameters,docs:{...(n=s.parameters)==null?void 0:n.docs,source:{originalSource:`{
  render: () => <div className="flex flex-col gap-4 max-w-xs">
      <div className="flex flex-col gap-2">
        <span className="text-[11px] text-ink-tertiary">text</span>
        <Skeleton variant="text" className="w-[140px]" />
        <Skeleton variant="text" className="w-[100px]" />
      </div>
      <div className="flex flex-col gap-2">
        <span className="text-[11px] text-ink-tertiary">avatar</span>
        <Skeleton variant="avatar" className="w-11 h-11" />
      </div>
      <div className="flex flex-col gap-2">
        <span className="text-[11px] text-ink-tertiary">image</span>
        <Skeleton variant="image" className="w-[52px] h-[52px]" />
      </div>
      <div className="flex flex-col gap-2">
        <span className="text-[11px] text-ink-tertiary">tag</span>
        <Skeleton variant="tag" className="w-[48px]" />
      </div>
    </div>
}`,...(x=(l=s.parameters)==null?void 0:l.docs)==null?void 0:x.source}}};var i,c,m;t.parameters={...t.parameters,docs:{...(i=t.parameters)==null?void 0:i.docs,source:{originalSource:`{
  render: () => <GlassCard className="p-card-pad max-w-xs">
      <div className="flex justify-between items-start mb-2">
        <Skeleton variant="text" className="w-[140px] h-4" />
        <Skeleton variant="tag" className="w-[52px]" />
      </div>
      <Skeleton variant="text" className="w-[100px] h-3 mb-3" />
      <div className="flex gap-1 mb-3">
        <Skeleton variant="tag" className="w-[48px]" />
        <Skeleton variant="tag" className="w-[48px]" />
      </div>
      <div className="border-t border-dashed border-[rgba(28,28,30,0.08)] pt-2">
        <div className="flex gap-1">
          <Skeleton variant="avatar" className="w-5 h-5" />
          <Skeleton variant="avatar" className="w-5 h-5" />
          <Skeleton variant="avatar" className="w-5 h-5" />
        </div>
      </div>
    </GlassCard>
}`,...(m=(c=t.parameters)==null?void 0:c.docs)==null?void 0:m.source}}};var d,o,p;r.parameters={...r.parameters,docs:{...(d=r.parameters)==null?void 0:d.docs,source:{originalSource:`{
  render: () => <GlassCard className="p-3 max-w-xs">
      <div className="flex gap-2.5">
        <Skeleton variant="image" className="w-12 h-12" />
        <div className="flex-1 flex flex-col gap-1.5">
          <Skeleton variant="tag" className="w-[40px]" />
          <Skeleton variant="text" className="w-[120px] h-4" />
          <Skeleton variant="text" className="w-[80px] h-3" />
        </div>
      </div>
    </GlassCard>
}`,...(p=(o=r.parameters)==null?void 0:o.docs)==null?void 0:p.source}}};const V=["Variants","TravelCardSkeleton","ScheduleCardSkeleton"];export{r as ScheduleCardSkeleton,t as TravelCardSkeleton,s as Variants,V as __namedExportsOrder,G as default};
