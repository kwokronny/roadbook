// packages/roadbook-api/controller/apikey.js
const Router = require('koa-router');
const ApiKeyService = require('../service/apikey');
const { ajaxReturn } = require('../helper/util');

class ApiKeyController {
  async create(ctx) {
    try {
      await ctx.verifyParams({
        name: { type: 'string', max: 50 },
      });
      ctx.body = ajaxReturn(await ApiKeyService.create(ctx.state.user.id, ctx.request.body));
    } catch (e) {
      ctx.body = ajaxReturn(e, 500);
    }
  }

  async list(ctx) {
    try {
      ctx.body = ajaxReturn(await ApiKeyService.list(ctx.state.user.id));
    } catch (e) {
      ctx.body = ajaxReturn(e, 500);
    }
  }

  async remove(ctx) {
    try {
      await ctx.verifyParams({
        id: { type: 'int' },
      });
      await ApiKeyService.remove(ctx.state.user.id, ctx.request.body.id);
      ctx.body = ajaxReturn(null);
    } catch (e) {
      ctx.body = ajaxReturn(e, 500);
    }
  }
}

module.exports = (router) => {
  let route = new Router();
  let controller = new ApiKeyController();
  route.post('/apikey/create', controller.create);
  route.post('/apikey/list', controller.list);
  route.post('/apikey/remove', controller.remove);

  router.use('/user', route.routes(), route.allowedMethods());
};
