const db = require("../models");
const JWT = require("jsonwebtoken");
const { Op } = require("sequelize");
const config = require("../config/config");

class TravelService {
  async page(uid, data) {
    try {
      return await db.Travel.findAndCountAll({
        include: [
          { model: db.User, attributes: ["id", "username", "avatar", "name"], where: { id: uid } },
        ],
        where: {
          name: {
            [Op.like]: `%${data.name}%`,
          },
        },
        order: [["startDate", "DESC"]],
        limit: data.pageSize,
        offset: (data.page - 1) * data.pageSize,
      });
    } catch (e) {
      console.error(e);
      throw "获取失败";
    }
  }

  async detail(id, uid) {
    try {
      const travel = await db.Travel.findByPk(id, {
        include: [
          {
            model: db.User,
            attributes: ["id", "username", "name", "avatar"],
          },
        ],
      })
      if (travel && (travel.public || (uid && travel.hasUser(uid)))) return travel
      else throw "旅程不存在";
    } catch (e) {
      console.error(e);
      throw "获取失败";
    }
  }

  async setEquip(data) {
    try {
      let travel = await db.Travel.findByPk(data.id)
      if (travel) {
        if (!await travel.hasUser(uid, { through: { where: { role: "edit" } } })) throw "您无权限修改旅程信息"
        await travel.update({ equip: data.equip })
      }
    } catch (e) {
      throw "获取失败";
    }
  }

  async save(uid, data) {
    try {
      let travel = await db.Travel.findByPk(data.id);
      // 旅程是否已存在
      if (travel) {
        if (!await travel.hasUser(uid, { through: { where: { role: "manage" } } })) throw "您无权限修改旅程信息"
        travel = await travel.update(data);
      } else {
        travel = await db.Travel.create(data);
      }
      // 将当前uid添加为旅程管理者
      let user = await db.User.findByPk(uid);
      await travel.addUser(user, { through: { role: "manage" } });
      return travel
    } catch (e) {
      throw e || "保存失败";
    }
  }

  async invite(uid, data) {
    try {
      let travel = await db.Travel.findByPk(data.id);
      // 旅程是否已存在
      if (travel) {
        if (!await travel.hasUser(uid, { through: { where: { role: "manage" } } })) throw "您无权限邀请协作者"
        return JWT.sign({ id: data.id }, config.sercet, { expiresIn: '7d' })
      } else {
        throw "旅程不存在";
      }
    } catch (e) {
      throw e;
    }
  }

  async accept(uid, data) {
    try {
      if (data.token && JWT.verify(data.token, config.sercet, { expiresIn: '7d' })) {
        let tokenData = JWT.decode(data.token, config.sercet)
        let travel = await db.Travel.findByPk(tokenData.id);
        // 旅程是否已存在
        if (travel) {
          if (await travel.hasUser(uid)) return travel.id
          let user = await db.User.findByPk(uid);
          await travel.addUser(user, { through: { role: 'view' } });
          return travel.id
        }
      } else {
        throw "token不存在"
      }
    } catch (e) {
      throw e || "验证失败";
    }
  }

  async setRole(uid, data) {
    try {
      let travel = await db.Travel.findByPk(data.id);
      // 旅程是否已存在
      if (travel && data.uid) {
        if (!await travel.hasUser(uid, { through: { where: { role: "manage" } } })) throw "您无权限修改旅程信息"
        // 编辑用户权限
        let user = await travel.getUsers({ where: { id: data.uid } })
        if (user && user.id !== uid) {
          if (data.role === 'delete') {
            await travel.removeUser(user[0])
          } else {
            await user[0].UserTravel.update({ role: data.role })
          }
        }
      }
    } catch (e) {
      throw e || "保存失败";
    }
  }

  async remove(uid, id) {
    try {
      await db.Travel.destroy({
        where: { id },
        include: [
          {
            model: db.User,
            where: { id: uid },
            through: { where: { role: "manage" } },
          },
        ],
      });
    } catch (e) {
      console.error(e);
      throw "删除失败";
    }
  }
}

module.exports = new TravelService();
