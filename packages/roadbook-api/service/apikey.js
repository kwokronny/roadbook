// packages/roadbook-api/service/apikey.js
const crypto = require('crypto');
const db = require('../models');

class ApiKeyService {
  generateKey() {
    return 'rb_' + crypto.randomBytes(24).toString('hex').slice(0, 32);
  }

  async create(uid, data) {
    try {
      const key = this.generateKey();
      const apiKey = await db.ApiKey.create({
        uId: uid,
        key,
        name: data.name,
        createdAt: new Date(),
      });
      return { id: apiKey.id, key, name: apiKey.name, createdAt: apiKey.createdAt };
    } catch (e) {
      console.error('[apikey.create]', e);
      throw '创建 API Key 失败';
    }
  }

  async list(uid) {
    try {
      const keys = await db.ApiKey.findAll({
        where: { uId: uid },
        attributes: ['id', 'key', 'name', 'lastUsedAt', 'createdAt'],
        order: [['createdAt', 'DESC']],
      });
      return keys.map(k => {
        const plain = k.get({ plain: true });
        plain.key = plain.key.slice(0, 7) + '...';
        return plain;
      });
    } catch (e) {
      console.error('[apikey.list]', e);
      throw '获取 API Key 列表失败';
    }
  }

  async remove(uid, id) {
    try {
      const count = await db.ApiKey.destroy({ where: { id, uId: uid } });
      if (count === 0) throw 'API Key 不存在';
    } catch (e) {
      throw e || '删除 API Key 失败';
    }
  }

  async findByKey(key) {
    const apiKey = await db.ApiKey.findOne({
      where: { key },
      include: [{ model: db.User, attributes: ['id', 'username', 'name', 'avatar'] }],
    });
    return apiKey;
  }
}

module.exports = new ApiKeyService();
