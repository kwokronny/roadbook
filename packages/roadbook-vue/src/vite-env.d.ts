/// <reference types="vite/client" />

declare module "md5";
declare module "compressorjs";

declare namespace AMap {
  class AutoComplete extends Autocomplete {}
}

declare interface Window {
  _AMapSecurityConfig: { serviceHost?: string; securityJsCode?: string };
}
