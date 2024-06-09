import api, { IRes } from "./instance";

export interface IReqUserLogin {
  username: string;
  password: string;
}

export interface IResUserLogin {
  token: string;
  user: IUser;
}

export interface IReqUserRegister {
  username: string;
  password: string;
  confirmPassword: string;
}

export interface IReqUserList {
  keyword?: string;
}
export interface IUser {
  id?: number;
  username: string;
  avatar?: string;
  name?: string;
}

export interface IReqUserModifyPassword {
  oldPassword: string;
  password: string;
  confirmPassword: string;
}

export namespace userApi {
  export const login = (data: IReqUserLogin): Promise<IRes<IResUserLogin>> => {
    return api.post("/user/login", data);
  };

  export const register = (
    data: IReqUserRegister
  ): Promise<IRes<IResUserLogin>> => {
    return api.post("/user/register", data);
  };

  export const list = (data: IReqUserList): Promise<IRes<IUser[]>> => {
    return api.post("/user/list", data);
  };

  export const detail = (): Promise<IRes<IUser>> => {
    return api.post("/user/detail");
  };

  export const update = (
    data: Pick<IUser, "name" | "avatar" | "id">
  ): Promise<IRes<IUser>> => {
    return api.post("/user/update", data);
  };

  export const modifyPassword = (
    data: IReqUserModifyPassword
  ): Promise<IRes<void>> => {
    return api.post("/user/password/modify", data);
  };
}
