import dayjs from "dayjs";

type DateType = string | number | Date | dayjs.Dayjs | null | undefined;
export const DateUtil = {
  travelDate(startDate: DateType, endDate: DateType) {
    let diffStart = dayjs().diff(startDate, "day");
    let diffEnd = dayjs().diff(endDate, "day");
    return diffStart >= 0
      ? diffEnd <= 0
        ? `旅程第 ${dayjs().diff(startDate, "day") + 1} 天`
        : `${this.dateRangeFm(startDate, endDate)}`
      : dayjs().isSame(startDate, "month")
      ? `${dayjs(startDate).fromNow(true)}后出发`
      : `出发日期：${this.dateFm(startDate)}`;
  },

  dateRangeFm(startDate: DateType, endDate: DateType) {
    if (dayjs(startDate).isSame(endDate, "day")) {
      return this.dateFm(startDate);
    } else if (dayjs(startDate).isSame(endDate, "year")) {
      return `${this.dateFm(startDate)} - ${dayjs(endDate).format("M.D")}`;
    } else {
      return `${this.dateFm(startDate)} - ${this.dateFm(endDate)}`;
    }
  },

  isBetween(date: DateType, limitDate: { minDate: string; maxDate: string }) {
    return dayjs(date).isBetween(
      limitDate.minDate,
      limitDate.maxDate,
      null,
      "[]"
    );
  },

  timeFm(date: DateType) {
    return dayjs(date).format("HH:mm");
  },

  dateFm(date: DateType) {
    return dayjs(date).format("YYYY.M.D");
  },

  dateWeekFm(date: DateType) {
    return dayjs(date).format("YYYY.M.D. ddd");
  },
};

export const objectUtil = {
  pickBy<T>(
    object: T,
    condition: (v: T[keyof T]) => boolean
  ): Record<string, any> {
    const obj: Record<string, any> = {};
    for (const key in object) {
      if (
        (typeof condition === "string" && object[key] === condition) ||
        (typeof condition == "function" && condition(object[key]))
      ) {
        obj[key] = object[key];
      }
    }
    return obj;
  },

  omitBy<T>(
    object: T,
    condition: (v: T[keyof T]) => boolean
  ): Record<string, any> {
    const obj: Record<string, any> = {};
    for (const key in object) {
      if (
        (typeof condition === "string" && object[key] !== condition) ||
        (typeof condition == "function" && !condition(object[key]))
      ) {
        obj[key] = object[key];
      }
    }
    return obj;
  },

  omitEmpty<T>(object: T) {
    return this.omitBy(object, (v) => v === undefined || v === null);
  },
};

export function debounce(
  this: any,
  func: Function,
  wait: number = 1000,
  immediate?: boolean
) {
  var timeout: NodeJS.Timeout | null;
  var context = this,
    args = arguments;
  return function () {
    timeout !== null && clearTimeout(timeout);
    timeout = setTimeout(function () {
      timeout = null;
      if (!immediate) func.apply(context, args);
    }, wait);
    if (immediate && !timeout) func.apply(context, args);
  };
}

export function throttle(func: Function, timeFrame: number) {
  var lastTime = 0;
  return function (this: any) {
    let now = Date.now();
    if (now - lastTime >= timeFrame) {
      func.apply(this, ...arguments);
      lastTime = now;
    }
  };
}

export function copy(text: string): Promise<void> {
  return new Promise((resolve, reject) => {
    if (window.navigator.clipboard) {
      try {
        window.navigator.clipboard.writeText(text);
        resolve();
      } catch (e) {
        reject();
      }
    } else {
      reject();
    }
  });
}

export function share(data: { title: string; url: string }): Promise<void> {
  return new Promise((resolve, reject) => {
    if (window.navigator.share) {
      window.navigator.share(data);
      resolve();
    } else {
      reject();
    }
  });
}

export type Platform = "pc" | "ios" | "android";
export function getPlatform(): Platform {
  const userAgent = navigator.userAgent;
  let platform: Platform = "pc";
  if (userAgent.indexOf("Android") > -1 || userAgent.indexOf("Adr") > -1) {
    platform = "android";
  } else if (!!userAgent.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/)) {
    platform = "ios";
  }
  return platform;
}

export function parseNotes(notes: string) {
  const linkRegex = /(((http|https):\/\/)[^\s]+)/g;
  const phoneRegex = /([+0-9\-]{4,})/g;
  return notes
    .replace(/<[\s\S]*?>/g, "")
    .replace(
      linkRegex,
      '<a href="$1" target="_blank" ref="noreferrer noopener">$1</a>'
    )
    .replace(phoneRegex, '<a href="tel:$1">$1</a>')
    .replace(/(\n|\r)/g, "<br>");
}
