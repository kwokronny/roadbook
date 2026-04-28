import{j as s}from"./jsx-runtime-Cf8x2fCZ.js";import{r as i,o as z}from"./index-BioFo8Zg.js";import{c as F}from"./index-1evVQkiP.js";import{c as H}from"./utils-BLSKlp9E.js";import"./index-yBjzXJbu.js";function b(r,e){if(typeof r=="function")return r(e);r!=null&&(r.current=e)}function Y(...r){return e=>{let o=!1;const n=r.map(t=>{const a=b(t,e);return!o&&typeof a=="function"&&(o=!0),a});if(o)return()=>{for(let t=0;t<n.length;t++){const a=n[t];typeof a=="function"?a():b(r[t],null)}}}}var Z=Symbol.for("react.lazy"),y=z[" use ".trim().toString()];function q(r){return typeof r=="object"&&r!==null&&"then"in r}function O(r){return r!=null&&typeof r=="object"&&"$$typeof"in r&&r.$$typeof===Z&&"_payload"in r&&q(r._payload)}function J(r){const e=M(r),o=i.forwardRef((n,t)=>{let{children:a,...p}=n;O(a)&&typeof y=="function"&&(a=y(a._payload));const c=i.Children.toArray(a),d=c.find(U);if(d){const u=d.props.children,$=c.map(k=>k===d?i.Children.count(u)>1?i.Children.only(null):i.isValidElement(u)?u.props.children:null:k);return s.jsx(e,{...p,ref:t,children:i.isValidElement(u)?i.cloneElement(u,void 0,$):null})}return s.jsx(e,{...p,ref:t,children:a})});return o.displayName=`${r}.Slot`,o}var K=J("Slot");function M(r){const e=i.forwardRef((o,n)=>{let{children:t,...a}=o;if(O(t)&&typeof y=="function"&&(t=y(t._payload)),i.isValidElement(t)){const p=rr(t),c=X(a,t.props);return t.type!==i.Fragment&&(c.ref=n?Y(n,p):p),i.cloneElement(t,c)}return i.Children.count(t)>1?i.Children.only(null):null});return e.displayName=`${r}.SlotClone`,e}var Q=Symbol("radix.slottable");function U(r){return i.isValidElement(r)&&typeof r.type=="function"&&"__radixId"in r.type&&r.type.__radixId===Q}function X(r,e){const o={...e};for(const n in e){const t=r[n],a=e[n];/^on[A-Z]/.test(n)?t&&a?o[n]=(...c)=>{const d=a(...c);return t(...c),d}:t&&(o[n]=t):n==="style"?o[n]={...t,...a}:n==="className"&&(o[n]=[t,a].filter(Boolean).join(" "))}return{...r,...o}}function rr(r){var n,t;let e=(n=Object.getOwnPropertyDescriptor(r.props,"ref"))==null?void 0:n.get,o=e&&"isReactWarning"in e&&e.isReactWarning;return o?r.ref:(e=(t=Object.getOwnPropertyDescriptor(r,"ref"))==null?void 0:t.get,o=e&&"isReactWarning"in e&&e.isReactWarning,o?r.props.ref:r.props.ref||r.ref)}const tr=F("inline-flex items-center justify-center gap-1.5 font-normal transition-transform active:scale-[0.92] ease-spring duration-[400ms] cursor-pointer select-none",{variants:{variant:{"dark-pill":"bg-dark text-white hover:bg-dark-hover rounded-pill text-[15px] px-5 h-11",coral:"bg-coral text-white rounded-pill text-[15px] px-5 h-11 shadow-[0_2px_8px_rgba(255,107,61,0.25)]",glass:"bg-frost text-ink backdrop-blur-[24px] backdrop-saturate-[1.4] border border-frost-border rounded-pill text-[15px] px-5 h-11",ghost:"bg-transparent text-ink-secondary border border-[rgba(28,28,30,0.12)] rounded-pill text-[15px] px-5 h-11","dark-circle":"bg-dark text-white rounded-full w-9 h-9 p-0","coral-circle":"bg-coral text-white rounded-full w-9 h-9 p-0 shadow-[0_2px_8px_rgba(255,107,61,0.25)]"}},defaultVariants:{variant:"dark-pill"}});function l({variant:r,className:e,asChild:o,children:n,...t}){const a=o?K:"button";return s.jsx(a,{className:H(tr({variant:r}),e),...t,children:n})}l.__docgenInfo={description:"",methods:[],displayName:"Button",props:{asChild:{required:!1,tsType:{name:"boolean"},description:""}},composes:["VariantProps"]};const ir={title:"Base/Button",component:l,argTypes:{variant:{control:"select",options:["dark-pill","coral","glass","ghost","dark-circle","coral-circle"]}}},f={args:{variant:"dark-pill",children:"登录 →"}},h={args:{variant:"coral",children:"导航前往"}},m={args:{variant:"glass",children:"Glass Button"}},g={args:{variant:"ghost",children:"添加分类"}},x={render:()=>s.jsxs("div",{className:"flex gap-3 items-center",children:[s.jsx(l,{variant:"dark-circle",children:"‹"}),s.jsx(l,{variant:"dark-circle",children:"＋"}),s.jsx(l,{variant:"coral-circle",children:s.jsx("svg",{width:"16",height:"16",viewBox:"0 0 24 24",fill:"none",stroke:"white",strokeWidth:"2.5",strokeLinecap:"round",strokeLinejoin:"round",children:s.jsx("polygon",{points:"3 11 22 2 13 21 11 13 3 11"})})})]})},v={render:()=>s.jsxs("div",{className:"flex flex-wrap gap-3 items-center",children:[s.jsx(l,{variant:"dark-pill",children:"Dark Pill →"}),s.jsx(l,{variant:"coral",children:"Coral"}),s.jsx(l,{variant:"glass",children:"Glass"}),s.jsx(l,{variant:"ghost",children:"Ghost"}),s.jsx(l,{variant:"dark-circle",children:"‹"}),s.jsx(l,{variant:"coral-circle",children:"⛩"})]})};var B,j,C;f.parameters={...f.parameters,docs:{...(B=f.parameters)==null?void 0:B.docs,source:{originalSource:`{
  args: {
    variant: 'dark-pill',
    children: '登录 →'
  }
}`,...(C=(j=f.parameters)==null?void 0:j.docs)==null?void 0:C.source}}};var _,S,w;h.parameters={...h.parameters,docs:{...(_=h.parameters)==null?void 0:_.docs,source:{originalSource:`{
  args: {
    variant: 'coral',
    children: '导航前往'
  }
}`,...(w=(S=h.parameters)==null?void 0:S.docs)==null?void 0:w.source}}};var E,P,R;m.parameters={...m.parameters,docs:{...(E=m.parameters)==null?void 0:E.docs,source:{originalSource:`{
  args: {
    variant: 'glass',
    children: 'Glass Button'
  }
}`,...(R=(P=m.parameters)==null?void 0:P.docs)==null?void 0:R.source}}};var V,G,N;g.parameters={...g.parameters,docs:{...(V=g.parameters)==null?void 0:V.docs,source:{originalSource:`{
  args: {
    variant: 'ghost',
    children: '添加分类'
  }
}`,...(N=(G=g.parameters)==null?void 0:G.docs)==null?void 0:N.source}}};var L,A,D;x.parameters={...x.parameters,docs:{...(L=x.parameters)==null?void 0:L.docs,source:{originalSource:`{
  render: () => <div className="flex gap-3 items-center">
      <Button variant="dark-circle">‹</Button>
      <Button variant="dark-circle">＋</Button>
      <Button variant="coral-circle">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="white" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><polygon points="3 11 22 2 13 21 11 13 3 11" /></svg>
      </Button>
    </div>
}`,...(D=(A=x.parameters)==null?void 0:A.docs)==null?void 0:D.source}}};var T,W,I;v.parameters={...v.parameters,docs:{...(T=v.parameters)==null?void 0:T.docs,source:{originalSource:`{
  render: () => <div className="flex flex-wrap gap-3 items-center">
      <Button variant="dark-pill">Dark Pill →</Button>
      <Button variant="coral">Coral</Button>
      <Button variant="glass">Glass</Button>
      <Button variant="ghost">Ghost</Button>
      <Button variant="dark-circle">‹</Button>
      <Button variant="coral-circle">⛩</Button>
    </div>
}`,...(I=(W=v.parameters)==null?void 0:W.docs)==null?void 0:I.source}}};const lr=["DarkPill","Coral","Glass","Ghost","CircleButtons","AllVariants"];export{v as AllVariants,x as CircleButtons,h as Coral,f as DarkPill,g as Ghost,m as Glass,lr as __namedExportsOrder,ir as default};
