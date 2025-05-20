const db = require("../models");
const spider = require("../helper/spider");
const { omit } = require("lodash");
const { Op } = require("sequelize");

class ScheduleService {

	async list(id) {
		try {
			return await db.Schedule.findAll({
				where: {
					tId: id,
				},
				order: [["startTime"]],
			});
		} catch (e) {
			console.error(e);
			throw "获取失败";
		}
	}

	async add(uid, data) {
		try {
			let travel = await db.Travel.findByPk(data.tId);
			if (!await travel.hasUser(uid, { through: { where: { role: { [Op.in]: ["edit", "manage"] } } } })) throw "您无权限添加行程"
			if (travel) {
				let schedule = await db.Schedule.create(omit(data, ["tId"]));
				await travel.addSchedule(schedule)
				return schedule
			}
		} catch (e) {
			console.error(e);
			throw "添加失败";
		}
	}

	async clone(uid, id) {
		try {
			let schedule = await db.Schedule.findByPk(id, { raw: true });
			let travel = await db.Travel.findByPk(schedule.tId);
			if (!await travel.hasUser(uid, { through: { where: { role: { [Op.in]: ["edit", "manage"] } } } })) throw "您无权限克隆行程"
			if (schedule) {
				return await db.Schedule.create(omit(schedule, ["id"]));
			} else {
				throw "未找到需要克隆的行程"
			}
		} catch (e) {
			console.error(e);
			throw "克隆失败";
		}
	}

	async set(uid, data) {
		try {
			let schedule = await db.Schedule.findByPk(data.id);
			let travel = await db.Travel.findByPk(schedule.tId);
			if (!await travel.hasUser(uid, { through: { where: { role: { [Op.in]: ["edit", "manage"] } } } })) throw "您无权限修改行程"
			if (schedule) {
				return await schedule.update(omit(data, ["id"]));
			}
		} catch (e) {
			console.error(e);
			throw "保存失败";
		}
	}

	// 通过合集获取地点
	// pullDianpingCollect(tId, id, isSkip) {
	// 	return new Promise(async (resolve) => {
	// 		let referer = "https://h5.dianping.com/";
	// 		let collectUrl = `https://mapi.dianping.com/mapi/collect/getfavoralbumdetail.bin?nextstart=&type=0&albumid=${id}&mapi_cacheType=0&`
	// 		let agent = undefined;
	// 		try {
	// 			agent = await spider.getProxy()
	// 		} catch (e) { }
	// 		let collect = await spider.asyncRequest(collectUrl, referer, agent);
	// 		if (collect.records && collect.records.length) {
	// 			let promiseArr = []
	// 			collect.records.forEach(record => {
	// 				record.collectItemList && record.collectItemList.forEach((item) => {
	// 					promiseArr.push((async () => {
	// 						let data = {
	// 							tId,
	// 							name: item.title,
	// 							cover: item.image,
	// 							dianpingUUID: item.favorCore && item.favorCore.bizUuid || "",
	// 							isHotel: false,
	// 							screenshots: '',
	// 							notes: '',
	// 							address: "",
	// 							coordinate: `${item.lng},${item.lat}`,
	// 						}
	// 						return await this.add(data, isSkip);
	// 					})())
	// 				})
	// 			})
	// 			Promise.allSettled(promiseArr).then((results) => {
	// 				resolve(results.reduce((resCount, result) => {
	// 					if (result.status == "fulfilled") {
	// 						resCount['success']++;
	// 					}
	// 					return resCount;
	// 				}, { all: promiseArr.length, success: 0 }))
	// 			})
	// 		}
	// 	})
	// }

	async remove(uid, data) {
		try {
			let schedule = await db.Schedule.findByPk(data.id);
			let travel = await db.Travel.findByPk(schedule.tId);
			if (!await travel.hasUser(uid, { through: { where: { role: { [Op.in]: ["edit", "manage"] } } } })) throw "您无权限删除行程"
			await schedule.destroy();
		} catch (e) {
			console.error(e);
			throw "删除失败";
		}
	}
}

module.exports = new ScheduleService();
