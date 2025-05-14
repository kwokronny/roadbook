import { roleType, trafficType } from "../helper/enum";
import api, { IRes, IReqPage, IResPage } from "./instance";
import { IUser } from "./user";

export interface IReqTravelPage extends IReqPage {
  name?: string;
  status?: string;
}

export interface ITravel {
  id?: number;
  name: string;
  description?: string;
  startDate: string;
  endDate: string;
  public: boolean;
  sort?: number;
  Users?: Array<Required<IUser> & { UserTravel: { role: roleType } }>;
  Schedules?: ISchedule[];
  userIds?: number[];
  equip?: string;
  city?: string[];
}

export interface ISchedule {
  id?: number;
  tId?: number;
  name: string;
  coordinate: string;
  address: string;
  cover?: string;
  dianpingUUID?: string;
  dianpingShopId?: string;
  startTime?: string;
  endTime?: string;
  isHotel?: boolean;
  traffic?: trafficType;
  screenshots?: string;
  notes?: string;
}

export interface IBatchSechedule {
  pIds: number[];
  tId: number;
}

export interface ISetEquip {
  id: number;
  equip: string;
}

export interface IResPullCollect {
  all: number;
  success: number;
}

export interface IReqPullCollect {
  tId: number;
  url: string;
  isSkip: boolean;
}

export interface IReqSetToken {
  id: number;
  uid: number;
  role: roleType | "delete";
}

export const travelApi = {
  page(data: IReqTravelPage): Promise<IRes<IResPage<ITravel>>> {
    return api.post("/travel/page", data);
  },

  detail(id: number): Promise<IRes<Required<ITravel> & { city: string }>> {
    return api.post("/travel/detail", { id });
  },

  save(data: ITravel): Promise<IRes<ITravel & { city: string }>> {
    if (data.Users) {
      data.userIds = data.Users.reduce((p, t) => {
        t && t.id && p.push(t.id);
        return p;
      }, [] as number[]);
    }
    return api.post("/travel/save", data);
  },

  invite(id: number): Promise<IRes<string>> {
    return api.post("/travel/invite", { id });
  },

  accept(token: string): Promise<IRes<number>> {
    return api.post(
      "/travel/accept",
      { token },
      { headers: { passthrough: true } }
    );
  },

  setRole(data: IReqSetToken): Promise<IRes<void>> {
    return api.post("/travel/set_role", data);
  },

  remove(id: number): Promise<IRes<ITravel>> {
    return api.post("/travel/remove", { id });
  },

  schedule(id: number): Promise<IRes<ISchedule[]>> {
    return api.post("/travel/schedule/list", { id });
  },

  setEquip(data: ISetEquip): Promise<IRes<void>> {
    return api.post("/travel/equip/set", data);
  },

  addSchedule(data: ISchedule): Promise<IRes<ISchedule>> {
    return api.post("/travel/schedule/add", data);
  },

  pullCollect(data: IReqPullCollect): Promise<IRes<IResPullCollect>> {
    return api.post("/travel/schedule/pull_collect", data);
  },

  updateSchedule(data: Partial<ISchedule>): Promise<IRes<void>> {
    return api.post("/travel/schedule/update", data);
  },

  removeSchedule(id: number): Promise<IRes<void>> {
    return api.post("/travel/schedule/remove", { id });
  },

  cloneSchedule(id: number): Promise<IRes<ISchedule>> {
    return api.post("/travel/schedule/clone", { id });
  },
};
