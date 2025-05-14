const Router = require("koa-router");
const { ajaxReturn, pageWrapper } = require("../helper/util");
const TravelService = require("../service/travel");
const ScheduleService = require("../service/schedule");

class TravelController {
  async page(ctx, next) {
    try {
      await ctx.verifyParams({
        pageSize: { type: "int", required: false },
        page: { type: "int", required: false },
        name: { type: "string", allowEmpty: true }
      });
      let { rows, count } = await TravelService.page(ctx.state.user.id, ctx.request.body);
      ctx.body = ajaxReturn(
        pageWrapper(
          rows,
          ctx.request.body.page,
          ctx.request.body.pageSize,
          count
        )
      );
    } catch (e) {
      ctx.body = ajaxReturn(e, 500);
    }
  }

  async save(ctx, next) {
    try {
      await ctx.verifyParams({
        id: { type: "int", required: false },
        name: "string",
        description: { type: "string", required: false, allowEmpty: true },
        startDate: { type: "dateTime", required: true },
        endDate: { type: "dateTime", required: true },
        equip: { type: "string", required: false, allowEmpty: true },
        city: { type: "string", required: false, allowEmpty: true },
        public: { type: "boolean", required: true }
      });
      ctx.body = ajaxReturn(await TravelService.save(ctx.state.user.id, ctx.request.body));
    } catch (e) {
      ctx.body = ajaxReturn(e, 500);
    }
  }

  async remove(ctx, next) {
    try {
      await ctx.verifyParams({
        id: "int",
      });
      ctx.body = ajaxReturn(await TravelService.remove(ctx.state.user.id, ctx.request.body.id));
    } catch (e) {
      ctx.body = ajaxReturn(e, 500);
    }
  }

  async detail(ctx, next) {
    try {
      await ctx.verifyParams({
        id: "int",
      });
      let travel = await TravelService.detail(ctx.request.body.id, ctx.state.user?.id);
      ctx.body = ajaxReturn(travel);
    } catch (e) {
      ctx.body = ajaxReturn(e, 500);
    }
  }

  async setEquip(ctx, next) {
    try {
      await ctx.verifyParams({
        id: "int",
        equip: "string"
      });
      ctx.body = ajaxReturn(await TravelService.setEquip(ctx.request.body));
    } catch (e) {
      ctx.body = ajaxReturn(e, 500);
    }
  }

  async invite(ctx, next) {
    try {
      await ctx.verifyParams({
        id: "int",
      });
      ctx.body = ajaxReturn(await TravelService.invite(ctx.state.user.id, ctx.request.body));
    } catch (e) {
      ctx.body = ajaxReturn(e, 500);
    }
  }

  async accept(ctx, next) {
    try {
      await ctx.verifyParams({
        token: "string",
      });
      ctx.body = ajaxReturn(await TravelService.accept(ctx.state.user.id, ctx.request.body));
    } catch (e) {
      ctx.body = ajaxReturn(e, 500);
    }
  }

  async setRole(ctx, next) {
    try {
      await ctx.verifyParams({
        id: { type: "int", required: false },
        uid: { type: "int", required: false },
        role: {
          type: "enum",
          values: ["edit", "view", "manage", "delete"],
          required: false,
        },
      });
      ctx.body = ajaxReturn(await TravelService.setRole(ctx.state.user.id, ctx.request.body));
    } catch (e) {
      ctx.body = ajaxReturn(e, 500);
    }
  }

  async schedule(ctx, next) {
    try {
      await ctx.verifyParams({
        id: "int",
      });
      let travel = await TravelService.detail(ctx.request.body.id, ctx.state.user?.id)
      if (travel) {
        let schedule = await ScheduleService.list(ctx.request.body.id);
        ctx.body = ajaxReturn(schedule);
      }
    } catch (e) {
      ctx.body = ajaxReturn(e, 500);
    }
  }

  async addSchedule(ctx) {
    try {
      await ctx.verifyParams({
        tId: "int",
        name: "string",
        coordinate: "string",
        address: { type: "string", allowEmpty: true, required: false },
        isHotel: { type: "boolean", required: true },
        startTime: { type: "dateTime", required: false },
        endTime: { type: "dateTime", required: false },
        traffic: {
          type: "enum",
          values: ["car", "taxi", "walk", "bus", "train", "ship", "ride", "plane"],
          required: false,
        },
        screenshots: { type: "string", allowEmpty: true, required: false },
        notes: { type: "string", allowEmpty: true, required: false },
      });
      ctx.body = ajaxReturn(
        await ScheduleService.add(ctx.request.body)
      );
    } catch (e) {
      ctx.body = ajaxReturn(e, 500);
    }
  }

  async pullCollect(ctx, next) {
    try {
      let data = ctx.request.body
      let url = new URL(data.url.match(/(http(|s):\/\/[^\s]+)/g)[0]);
      if (url && url.hostname.indexOf("dianping.com") > -1 && data.tId) {
        let albumId = url.searchParams.get("albumId")
        let res = await ScheduleService.pullDianpingCollect(data.tId, albumId, data.isSkip);
        ctx.body = ajaxReturn(Object.assign(res))
      } else {
        ctx.body = ajaxReturn("URL传参错误", 500);
      }
    } catch (e) {
      ctx.body = ajaxReturn("拉取失败，请再试几次", 500);
    }
  }

  async setSchedule(ctx) {
    try {
      let data = ctx.request.body
      await ctx.verifyParams({
        id: "int",
        name: { type: "string", required: false },
        coordinate: { type: "string", required: false },
        address: { type: "string", allowEmpty: true, required: false },
        isHotel: { type: "boolean", required: false },
        startTime: { type: "dateTime", required: false },
        endTime: { type: "dateTime", required: false },
        traffic: {
          type: "enum",
          values: ["car", "taxi", "walk", "bus", "train", "ship", "ride", "plane"],
          required: false,
        },
        screenshots: { type: "string", allowEmpty: true, required: false },
        notes: { type: "string", allowEmpty: true, required: false },
      });
      ctx.body = ajaxReturn(
        await ScheduleService.set(data)
      );
    } catch (e) {
      ctx.body = ajaxReturn(e, 500);
    }
  }

  async cloneSchedule(ctx) {
    try {
      let data = ctx.request.body
      await ctx.verifyParams({
        id: "int",
      });
      ctx.body = ajaxReturn(
        await ScheduleService.clone(data.id)
      );
    } catch (e) {
      ctx.body = ajaxReturn(e, 500);
    }
  }

  async removeSchedule(ctx) {
    try {
      await ctx.verifyParams({
        id: "int",
      });
      ctx.body = ajaxReturn(
        await ScheduleService.remove(ctx.request.body)
      );
    } catch (e) {
      ctx.body = ajaxReturn(e, 500);
    }
  }
}

module.exports = (router) => {
  let route = new Router();
  let controller = new TravelController();
  route.post("/page", controller.page);
  route.post("/detail", controller.detail);
  route.post("/save", controller.save);
  route.post("/invite", controller.invite);
  route.post("/accept", controller.accept);
  route.post("/set_role", controller.setRole);
  route.post("/remove", controller.remove);
  route.post("/equip/set", controller.setEquip);
  route.post("/schedule/list", controller.schedule);
  route.post("/schedule/add", controller.addSchedule);
  route.post("/schedule/clone", controller.cloneSchedule);
  route.post("/schedule/update", controller.setSchedule);
  route.post("/schedule/remove", controller.removeSchedule);
  route.post("/schedule/pull_collect", controller.pullCollect);

  router.use("/travel", route.routes(), route.allowedMethods());
};
