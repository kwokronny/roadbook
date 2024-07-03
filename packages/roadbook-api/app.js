const fs = require("fs");
const Koa = require("koa");
const Router = require("koa-router");
const Static = require("koa-static")
const path = require("path");
const helmet = require("koa-helmet");
const parameter = require("koa-parameter");
const bodyparser = require("koa-bodyparser");
const send = require("koa-send");
const jwt = require("koa-jwt");
const { koaBody } = require("koa-body");
const { ajaxReturn } = require("./helper/util");
const config = require("./config/config");
const logger = require("./helper/logger");

const app = new Koa();

parameter(app);

app.use(logger.access)
// .use(helmet())
//   .use(cros())

let router = new Router();

//#region API
let apiRouter = new Router();
apiRouter
  .use(bodyparser({ enableTypes: ["json"] }))
  .use(jwt({ secret: config.sercet, passthrough: true }))
  .use(function (ctx, next) {
    if (ctx.url.match(/^\/api\/(user\/(login|register)|travel\/(detail|schedule\/list))$/)) {
      return next()
    }
    if (ctx.state.user === undefined) {
      ctx.status = 200;
      ctx.body = ajaxReturn("未登录", 401);
    } else {
      return next()
    }
  })

let controllers = fs.readdirSync("./controller");
controllers.forEach((controller) => {
  require(`./controller/${controller}`)(apiRouter);
});

apiRouter.post(
  "/upload",
  koaBody({
    multipart: true,
    formidable: {
      uploadDir: config.uploadDir,
      keepExtensions: true,
      filename: () => {
        return `${Math.random().toString(36).substring(2, 20)}`;
      },
      maxFileSize: 1024 * 500
    },
  }),
  (ctx, next) => {
    const files = ctx.request.files.file;
    const urls = []
    if (files.length) {
      files.forEach((file) => {
        const basename = path.basename(file.filepath);
        urls.push(`/public/uploads/${basename}`);
      })
    } else {
      const basename = path.basename(files.filepath);
      urls.push(`/public/uploads/${basename}`);
    }
    ctx.body = ajaxReturn(urls);
  }
);
//#endregion
router.use('/api', apiRouter.routes(), apiRouter.allowedMethods())
//#endregion


var proxy = require('koa-better-http-proxy');

router.get("/public/uploads/(.*)", (ctx) => send(ctx, '/storage' + ctx.path));
if (process.env.NODE_ENV === 'development') {
  router.get('/(.*)', proxy('http://127.0.0.1:6847'))
} else {
  router.get('/(.*)', Static('./views'))
}

function proxyReqPathResolver(ctx) {
  return `${ctx.url.replace('/_AMapService', '')}&jscode=${process.env.AMAP_SECRET}`
}

router.use('/_AMapService/(.*)', proxy('https://restapi.amap.com/', {
  proxyReqPathResolver
}));
router.all('/_AMapService/v4/map/styles(.*)', proxy('https://webapi.amap.com/v4/map/styles', {
  proxyReqPathResolver
}));
router.all('/_AMapService/v3/vectormap(.*)', proxy('https://fmap01.amap.com/v3/vectormap', {
  proxyReqPathResolver
}));

app.use(router.routes()).use(router.allowedMethods());
app.listen(3000);
