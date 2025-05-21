import Axios, { AxiosInstance } from "axios";
import router from "@/plugins/router";
import { useStore } from "@/store";
// import { toastInstance } from "maz-ui";

export interface IRes<T> {
  code: number;
  data: T;
  msg: string;
}
export interface IReqPage {
  page: number;
  pageSize?: number;
}
export interface IResPage<T> {
  record: T[];
  page: number;
  pageSize: number;
  total: number;
}

// 创建请求实例
const instance: AxiosInstance = Axios.create({
  baseURL: "/api",
  headers: {
    "Content-Type": "application/json",
  },
});

// 设置实例请求拦截
instance.interceptors.request.use(
  (config) => {
    const { token } = useStore();
    if (token) {
      config.headers.Authorization = "Bearer " + token;
    }
    return config;
  },
  (error) => {
    throw new Error(error);
  }
);

// 设置实例响应拦截
instance.interceptors.response.use(
  (response) => {
    let ret = response.data;
    if (ret.code !== 200 && !response.config.headers.passthrough) {
      if (ret.code === 401) {
        router.push("/signin");
      }
      // const toast = useToast();
      // toast.error(ret.msg);
      return Promise.reject(ret);
    }
    return ret;
  },
  (error) => {
    throw error;
  }
);

export default instance;
