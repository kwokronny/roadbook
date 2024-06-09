import api, { IRes } from "./instance";

export namespace commonApi {
  export const upload = (data: FormData): Promise<IRes<string[]>> => {
    return api.post("/upload", data, {
      headers: {
        "Content-Type": "multipart/form-data",
      },
    });
  };
}
