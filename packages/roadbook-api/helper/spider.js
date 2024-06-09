const request = require("request");
const fs = require("fs");
const config = require("../config/config");
const path = require("path");
const util = require("./util");
const HttpsProxyAgent = require('https-proxy-agent');
const logger = require("./logger")

const userAgents = [
	'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.0.12) Gecko/20070731 Ubuntu/dapper-security Firefox/1.5.0.12',
	'Mozilla/4.0 (compatible; MSIE 7.0; Windows NT 6.0; Acoo Browser; SLCC1; .NET CLR 2.0.50727; Media Center PC 5.0; .NET CLR 3.0.04506)',
	'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.56 Safari/535.11',
	'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_7_3) AppleWebKit/535.20 (KHTML, like Gecko) Chrome/19.0.1036.7 Safari/535.20',
	'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.8) Gecko Fedora/1.9.0.8-1.fc10 Kazehakase/0.5.6',
	'Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.1 (KHTML, like Gecko) Chrome/21.0.1180.71 Safari/537.1 LBBROWSER',
	'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Win64; x64; Trident/5.0; .NET CLR 3.5.30729; .NET CLR 3.0.30729; .NET CLR 2.0.50727; Media Center PC 6.0) ,Lynx/2.8.5rel.1 libwww-FM/2.14 SSL-MM/1.4.1 GNUTLS/1.2.9',
	'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; .NET CLR 1.1.4322; .NET CLR 2.0.50727)',
	'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C; .NET4.0E; QQBrowser/7.0.3698.400)',
	'Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; SV1; QQDownload 732; .NET4.0C; .NET4.0E)',
	'Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:2.0b13pre) Gecko/20110307 Firefox/4.0b13pre',
	'Opera/9.80 (Macintosh; Intel Mac OS X 10.6.8; U; fr) Presto/2.9.168 Version/11.52',
	'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.8.0.12) Gecko/20070731 Ubuntu/dapper-security Firefox/1.5.0.12',
	'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C; .NET4.0E; LBBROWSER)',
	'Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.8) Gecko Fedora/1.9.0.8-1.fc10 Kazehakase/0.5.6',
	'Mozilla/5.0 (X11; U; Linux; en-US) AppleWebKit/527+ (KHTML, like Gecko, Safari/419.3) Arora/0.6',
	'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C; .NET4.0E; QQBrowser/7.0.3698.400)',
	'Opera/9.25 (Windows NT 5.1; U; en), Lynx/2.8.5rel.1 libwww-FM/2.14 SSL-MM/1.4.1 GNUTLS/1.2.9',
	'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/61.0.3163.100 Safari/537.36'
]


function validProxy(agent) {
	return new Promise((resolve, reject) => {
		console.log("验证代理开始")
		request({ url: "http://icanhazip.com/", agent, timeout: 1000 }, function (error, res) {
			if (!error && res.statusCode == 200) {
				console.log("验证代理成功")
				resolve()
			}
			console.log("验证代理失败")
			reject()
		})
	})
}

let proxyTmpStorage = path.resolve(__dirname, "/storage/proxy.tmp")

function getProxy(times = 1, cache = true) {
	return new Promise((resolve) => {
		console.log("检查代理缓存")
		if (cache && fs.existsSync(proxyTmpStorage)) {
			let proxyUrl = fs.readFileSync(proxyTmpStorage, { encoding: "utf-8" });
			console.log("获取代理缓存")
			if (proxyUrl) {
				let agent = new HttpsProxyAgent(proxyUrl)
				console.log("验证代理缓存")
				validProxy(agent).then(() => {
					console.log("验证通过，返回代理缓存")
					resolve(agent)
				}).catch(() => {
					console.log("验证失败，删除代理缓存")
					fs.rmSync(proxyTmpStorage)
				})
			}
		}
		console.log("获取一个代理")
		request.get("http://demo.spiderpy.cn/get", {}, function (error, response) {
			if (error) {
				console.log("获取代理失败")
				return resolve()
			}
			console.log("获取代理结果：" + response.body)
			let data = util.parseJSON(response.body);
			if (!data) resolve()
			proxyUrl = `http${data.https ? 's' : ''}://${data.proxy}`
			console.log("实例化代理：" + proxyUrl)
			let agent = new HttpsProxyAgent(proxyUrl)
			console.log("验证代理")
			validProxy(agent).then(() => {
				console.log("代理验证通过，开始写入缓存")
				fs.writeFile(proxyTmpStorage, proxyUrl, { encoding: "utf-8" })
				console.log("返回代理")
				resolve(agent)
			}).catch(() => {
				if (times <= 1) {
					console.log(`代理验证未通过，重新获取新的代理：${times}`)
					times++;
					getProxy(times, cache).then((agent) => {
						resolve(agent)
					})
				} else {
					resolve()
				}
			})
		});
	});
}

module.exports = {
	getProxy,
	asyncRequest(url, referer, agent, delay) {
		return new Promise((resolve, reject) => {
			setTimeout(async () => {
				requestInfo = {
					url,
					timeout: 10000,
					followRedirect: true,
					maxRedirects: 10,
					headers: {
						'Referer': referer,
						'User-Agent': userAgents[parseInt(Math.random() * userAgents.length)],
					},
				}
				if (agent) requestInfo.agent = agent
				request(requestInfo, function (error, response) {
					try {
						resolve(JSON.parse(response.body))
					} catch (e) {
						logger.error(`异步请求: ${error}`)
						console.error(error)
						reject("解析失败，请重试")
					}
				})
			}, delay);
		});
	},

	downloadImg(url, referer, agent) {
		return new Promise(async (resolve, reject) => {
			try {
				let ext = /^\.([A-Za-z0-9]{3,4})+/g.exec(path.extname(url))[1];
				let newFileName = `${Math.random().toString(36).substring(2, 20)}.${ext}`;
				let filePath = path.resolve(__dirname, `${config.uploadDir}/${newFileName}`);
				let requestInfo = {
					url,
					timeout: 10000,
					followRedirect: true,
					maxRedirects: 10,
					headers: {
						'Referer': referer,
						'User-Agent': userAgents[parseInt(Math.random() * userAgents.length)],
					},
				}
				if (agent) requestInfo.agent = agent
				request(requestInfo)
					.pipe(fs.createWriteStream(filePath))
					.on("close", function () {
						resolve(`/public/uploads/${newFileName}`);
					})
			} catch {
				reject();
			}
		})
	},
}