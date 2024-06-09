
const log4js = require('log4js');
log4js.configure({
	appenders: {
		access: {
			type: 'dateFile',
			filename: 'storage/logs/access.log',
			pattern: '-yyyy-MM-dd.log',
		},
		error: {
			type: 'dateFile',
			filename: 'storage/logs/error.log',
			pattern: '-yyyy-MM-dd.log',
		}
	},
	categories: {
		default: { appenders: ["access"], level: log4js.levels.INFO },
		error: { appenders: ["error"], level: log4js.levels.ERROR }
	}
});

module.exports = {
	async access(ctx, next) {
		const stime = Date.now();
		await next()
		const ms = Date.now() - stime;
		log4js.getLogger('access').info(`[${ctx.method}] ${ctx.url} - ${ms}ms\n\t\trequestParam: ${JSON.stringify(ctx.request.body)}\n\t\tresponseBody： ${JSON.stringify(ctx.body)}`)
	},
	error(message) {
		log4js.getLogger('error').error(`
================================================================================\n
${message}\n
================================================================================\n
		`)
	}
}