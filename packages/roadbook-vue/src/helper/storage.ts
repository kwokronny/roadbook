class LocalStorage {
  private namespace: string = "";
  private _sep = "-";

  constructor(namespace: string) {
    this.namespace = namespace;
  }

  private storage() {
    return window.localStorage;
  }

  public has(name: String): boolean {
    let key = [this.namespace, name].join(this._sep);
    return !!this.storage().getItem(key);
  }

  public get(name: string) {
    let key = [this.namespace, name].join(this._sep);
    let value = this.storage().getItem(key);
    if (value) {
      try {
        return JSON.parse(value);
      } catch (e) {
        return value;
      }
    }
    return new Error(`not found storage key is :${name} `);
  }

  public set(name: string, value: any) {
    if (!value) return new Error("Invalid parameters to set");
    let key = [this.namespace, name].join(this._sep);
    try {
      value = JSON.stringify(value);
    } catch { }
    this.storage().setItem(key, value);
  }

  public remove(name: string) {
    if (this.has(name)) {
      let key = [this.namespace, name].join(this._sep);
      this.storage().removeItem(key);
    }
  }
}

export default new LocalStorage("roadbook");
