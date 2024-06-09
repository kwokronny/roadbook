const Router = require("koa-router");
const UserService = require("../service/user");
const { ajaxReturn } = require("../helper/util");

class UserController {
  async list(ctx, next) {
    try {
      await ctx.verifyParams({
        keyword: { type: "string", required: false, allowEmpty: true },
      });
      ctx.body = ajaxReturn(await UserService.list(ctx.request.body));
    } catch (e) {
      ctx.body = ajaxReturn(e, 500);
    }
  }

  async detail(ctx, next) {
    try {
      ctx.body = ajaxReturn(await UserService.detail(ctx.state.user.id));
    } catch (e) {
      ctx.body = ajaxReturn(e, 500);
    }
  }

  async update(ctx, next) {
    try {
      ctx.body = ajaxReturn(
        await UserService.update(ctx.state.user.id, ctx.request.body)
      );
    } catch (e) {
      ctx.body = ajaxReturn(e, 500);
    }
  }

  async login(ctx, next) {
    try {
      await ctx.verifyParams({
        username: { type: "string", max: 16 },
        password: { type: "string", max: 50 },
      });
      ctx.body = ajaxReturn(await UserService.login(ctx.request.body));
    } catch (e) {
      ctx.body = ajaxReturn(e, 500);
    }
  }

  async register(ctx, next) {
    try {
      await ctx.verifyParams({
        username: { type: "string", max: 16 },
        password: { type: "string", max: 50 },
      });
      ctx.body = ajaxReturn(await UserService.register(ctx.request.body));
    } catch (e) {
      ctx.body = ajaxReturn(e, 500);
    }
  }

  async modifyPassword(ctx, next) {
    try {
      await ctx.verifyParams({
        oldPassword: "string",
        password: "string",
      });
      let body = ctx.request.body;
      ctx.body = ajaxReturn(await UserService.modifyPassword(ctx.state.user.id, body));
    } catch (e) {
      ctx.body = ajaxReturn(e, 500);
    }
  }
}

module.exports = (router) => {
  let route = new Router();
  let controller = new UserController();
  route.post("/list", controller.list);
  route.post("/detail", controller.detail);
  route.post("/update", controller.update);
  route.post("/login", controller.login);
  route.post("/register", controller.register);
  route.post("/password/modify", controller.modifyPassword);

  router.use("/user", route.routes(), route.allowedMethods());
};
