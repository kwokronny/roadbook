import dayjs from "dayjs";
import "dayjs/locale/zh-cn";
import relativeTime from "dayjs/plugin/relativeTime";
import isBetween from "dayjs/plugin/isBetween";

dayjs.locale("zh-cn"); // 使用本地化语言
dayjs.extend(relativeTime);
dayjs.extend(isBetween);
