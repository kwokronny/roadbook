class IEnum<T extends { label: string; value: string | number }> {
  private _enums: T[] = [];
  private _maps: Record<string, T> = {};
  constructor(enums: T[]) {
    this._enums = enums;
    this._maps = enums.reduce((prev, curr) => {
      prev[`${curr.value}`] = curr;
      return prev;
    }, {} as Record<string, T>);
  }

  public getArray(): T[] {
    return this._enums;
  }

  public getMap(): Record<string, T> {
    return this._maps;
  }

  public get(key: string): T {
    return this._maps[key];
  }
}

export type roleType = "manage" | "view" | "edit" | "delete";

export const roleTypeEnum = new IEnum<{
  label: string;
  value: roleType;
  className?: string;
}>([
  { label: "可管理", value: "manage" },
  { label: "可编辑", value: "edit" },
  { label: "可观察", value: "view" },
  { label: "删除", value: "delete", className: "text-c_danger" },
]);

export type trafficStatus = "traving" | "over" | "ready";

export const trafficStatusEnum = new IEnum<{
  label: string;
  color: string;
  value: trafficStatus;
  icon: string;
}>([
  { label: "旅程中", color: "var(--maz-color-success-alpha-05)", value: "traving", icon: "sun" },
  { label: "旅程结束", color: "var(--maz-color-bg-lighter)", value: "over", icon: "sun" },
  { label: "旅程准备中", color: "var(--maz-color-warning-alpha-05)", value: "ready", icon: "sun" },
]);

export type trafficType = "car" | "taxi" | "ride" | "walk" | "bus";
// | "train"
// | "ship"
// | "plane";

export const trafficTypeEnum = new IEnum<{
  label: string;
  mapMode: string;
  value: trafficType;
  icon: string;
}>([
  { label: "驾车", mapMode: "car", value: "car", icon: "solar/car" },
  { label: "打车", mapMode: "taxi", value: "taxi", icon: "solar/taxi" },
  { label: "公交", mapMode: "bus", value: "bus", icon: "solar/bus" },
  { label: "步行", mapMode: "walk", value: "walk", icon: "solar/walk" },
  { label: "骑行", mapMode: "ride", value: "ride", icon: "solar/ride" },
  // { label: "动车", mapMode: "train", value: "train", icon: "solar/train" },
  // { label: "轮渡", mapMode: "ship", value: "ship", icon: "solar/ship" },
  // { label: "飞机", mapMode: "plane", value: "plane", icon: "solar/plane" },
]);
