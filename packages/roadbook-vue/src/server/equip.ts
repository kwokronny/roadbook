export interface IEquipList {
  name: string;
  list: IEquip[];
}

export interface IEquip {
  name: string;
  list: string[];
}

export const equipApi = {
  cache: [],
  list(): Promise<IEquipList[]> {
    return new Promise((resolve, reject) => {
      if (this.cache.length) {
        resolve(this.cache);
      } else {
        fetch(
          "/equip.json"
        )
          .then((res) => {
            resolve(res.json());
          })
          .catch((e) => {
            reject(e);
          });
      }
    });
  },
};
