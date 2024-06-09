import { type RuleItem } from "async-validator";

/**
 * 可统一管理校验规则，方便管理与应用校验规则，且保持统一
 */
export const ruleColl = {
  username: {
    pattern: /^[a-zA-Z0-9-_]{2,16}$/,
    message: "用户名由2~16个大小写字母或数字组成",
  },
  password: {
    pattern: /^[a-zA-Z0-9_!@#$%^&*`~()-+=]{6,16}$/,
    message: "密码由6~16个大小写字母、数字、特殊符号组成",
  },
  strMax: (max: number): RuleItem => ({
    max,
    type: "string",
    message: `最大${max}个字符`,
  }),
};
