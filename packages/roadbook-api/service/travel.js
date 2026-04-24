const db = require("../models");
const JWT = require("jsonwebtoken");
const { Op } = require("sequelize");
const config = require("../config/config");

class TravelService {
  async discover(data) {
    try {
      const where = { public: true };
      if (data.keyword) {
        where.name = { [Op.like]: `%${data.keyword}%` };
      } else if (data.city) {
        where.city = { [Op.like]: `%${data.city}%` };
      }
      const pageSize = Math.min(data.pageSize || 20, 100);
      const page = data.page || 1;
      const result = await db.Travel.findAndCountAll({
        where,
        distinct: true,
        include: [
          {
            model: db.User,
            attributes: ['id', 'username', 'name', 'avatar'],
            through: { where: { role: 'manage' }, attributes: [] },
            required: true,
          },
        ],
        order: [['id', 'DESC']],
        limit: pageSize,
        offset: (page - 1) * pageSize,
      });
      return {
        total: result.count,
        list: result.rows.map((t) => ({
          id: t.id,
          name: t.name,
          city: t.city,
          startDate: t.startDate,
          endDate: t.endDate,
          viewCount: t.viewCount,
          owner: t.Users && t.Users[0]
            ? { id: t.Users[0].id, username: t.Users[0].username, name: t.Users[0].name, avatar: t.Users[0].avatar }
            : null,
        })),
      };
    } catch (e) {
      console.error('[travel.discover]', e);
      throw '获取失败';
    }
  }

  async page(uid, data) {
    try {
      const qg = db.sequelize.dialect.queryGenerator;
      const table = qg.quoteIdentifier('UserTravels');
      const tIdCol = qg.quoteIdentifier('tId');
      const uIdCol = qg.quoteIdentifier('uId');
      return await db.Travel.findAndCountAll({
        distinct: true,
        include: [
          { model: db.User, attributes: ["id", "username", "avatar", "name"] },
        ],
        where: {
          name: { [Op.like]: `%${data.name}%` },
          id: {
            [Op.in]: db.sequelize.literal(
              `(SELECT ${tIdCol} FROM ${table} WHERE ${uIdCol} = ${parseInt(uid, 10)})`,
            ),
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

  async detail(uid, id) {
    try {
      const travel = await db.Travel.findByPk(id, {
        include: [
          {
            model: db.User,
            attributes: ["id", "username", "name", "avatar"],
          },
        ],
      })
      if (travel && travel.public && !uid) {
        travel.increment('viewCount').catch(() => {});
      }
      if (travel && (travel.public || (uid && travel.hasUser(uid)))) return travel
      else throw "旅程不存在";
    } catch (e) {
      console.error(e);
      throw "获取失败";
    }
  }

  async setEquip(uid, data) {
    try {
      let travel = await db.Travel.findByPk(data.id)
      if (travel) {
        if (!await travel.hasUser(uid, { through: { where: { role: { [Op.in]: ["edit", "manage"] } } } })) throw "您无权限修改旅程信息"
        await travel.update({ equip: data.equip })
      } else {
        throw "旅程不存在"
      }
    } catch (e) {
      console.error(e)
      throw "设置失败";
    }
  }

  async save(uid, data) {
    try {
      let travel = await db.Travel.findByPk(data.id);
      // 旅程是否已存在
      if (travel) {
        const authorized = await travel.getUsers({
          where: { id: uid },
          through: { where: { role: { [Op.in]: ["edit", "manage"] } } },
        });
        if (!authorized.length) throw "您无权限修改旅程信息";
        travel = await travel.update(data);
      } else {
        travel = await db.Travel.create(data);
        // 将当前uid添加为旅程管理者（仅创建时）
        let user = await db.User.findByPk(uid);
        await travel.addUser(user, { through: { role: "manage" } });
      }
      return travel
    } catch (e) {
      console.error('[travel.save]', e);
      throw typeof e === 'string' ? e : "保存失败";
    }
  }

  async invite(uid, data) {
    try {
      let travel = await db.Travel.findByPk(data.id);
      // 旅程是否已存在
      if (travel) {
        if (!await travel.hasUser(uid, { through: { where: { role: { [Op.in]: ["edit", "manage"] } } } })) throw "您无权限邀请协作者"
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
        if (!await travel.hasUser(uid, { through: { where: { role: "manage" } } })) throw "您无权限修改用户角色"
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
      const travel = await db.Travel.findOne({
        where: { id },
        include: [
          {
            model: db.User,
            where: { id: uid },
            through: { where: { role: "manage" } },
          },
        ],
      });
      if (!travel) throw "无权删除或旅程不存在";
      await travel.destroy();
    } catch (e) {
      console.error(e);
      throw e || "删除失败";
    }
  }
}

module.exports = new TravelService();
