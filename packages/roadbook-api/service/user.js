const db = require("../models");
const JWT = require("jsonwebtoken");
const config = require("../config/config");
const { pick } = require("lodash");
const { Op } = require("sequelize");

class UserService {
  async list(data) {
    try {
      return await db.User.findAll({
        attributes: ["avatar", "username", "name", "id"],
        where: {
          [Op.or]: {
            name: {
              [Op.like]: `%${data.keyword}%`,
            },
            username: {
              [Op.like]: `%${data.keyword}%`,
            },
          },
        },
      });
    } catch (e) {
      throw "未获取到用户";
    }
  }

  async detail(id) {
    try {
      return await db.User.findByPk(id, {
        attributes: ["avatar", "username", "name", "id"],
      });
    } catch (e) {
      throw "未找到用户";
    }
  }

  async update(uid, data) {
    try {
      let user = await db.User.findByPk(uid);
      delete data.password
      user.update(data);
    } catch (e) {
      throw "未找到用户";
    }
  }

  async login(data) {
    try {
      console.log(data)
      let user = await db.User.findOne({ where: { username: data.username } });
      if (user) {
        if (user.password === data.password) {
          let userInfo = pick(user, ["username", "avatar", "name", "id"]);
          return {
            token: JWT.sign(userInfo, config.sercet, { expiresIn: '30d' }),
            user: userInfo,
          };
        }
      }
      throw "用户不存在或密码错误";
    } catch (e) {
      throw "登录失败";
    }
  }

  async register(data) {
    try {
      const user = await db.User.create(data);
      let userInfo = pick(user, ["username", "avatar", "name", "id"]);
      return {
        token: JWT.sign(userInfo, config.sercet, { expiresIn: '30d' }),
        user: userInfo,
      };
    } catch (e) {
      throw "注册失败";
    }
  }

  async modifyPassword(uid, data) {
    try {
      let user = await db.User.findByPk(uid);
      if (user.password == data.oldPassword) {
        await user.update({ password: data.password })
      } else {
        throw "原密码错误";
      }
    } catch (e) {
      throw e || "修改密码失败";
    }
  }
}

module.exports = new UserService();
