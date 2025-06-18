# 开始安装
## 申请高德开放平台 SDK


[**高德开放平台**](https://lbs.amap.com/)

打开高德开放平台申请账号，并实名认证通过后

进入控制台→应用管理，点击新建应用

![Image](/images/image_21584f1f-4186-807b-bece-fb3a376a8dbc.png)


填写完成创建应用后，点击应用右上角 **添加Key** 

![Image](/images/image_21584f1f-4186-80ad-b662-c3d15be10773.png)


输入 Key名称，并选择Web端(JS API)，可选输入域名白名单，限制使用应用的网域

![Image](/images/image_21584f1f-4186-8064-b3dd-d853b955400e.png)


将创建成功的 Key 与 安全密钥 复制保管

![Image](/images/image_21584f1f-4186-80c6-9c4f-c7242101ff51.png)


## Docker


### 环境变量


| 变量 | 默认值 | 描述 |
| --- | --- | --- |
| AMAP_KEY |   | 高德地图应用Key |
| AMAP_SECRET |   | 高德地图应用Secret |
| DB_DIALECT | sqlite | 数据库驱动，[参考文档](https://sequelize.org/docs/v6/other-topics/dialect-specific-things/) |
| DB_HOSTNAME | localhost | 数据库host，DB_DIALECT 为 sqlite 时可不填 |
| DB_PORT | 3306 | 数据库端口，DB_DIALECT 为 sqlite 时可不填 |
| DB_NAME | roadbook | 数据库名，DB_DIALECT 为 sqlite 时可不填 |
| DB_USERNAME | root | 数据库用户名，DB_DIALECT 为 sqlite 时可不填 |
| DB_PASSWORD |   | 数据库密码，DB_DIALECT 为 sqlite 时可不填 |


```bash 
docker run -d \
  --name=roadbook-api \
  -e AMAP_KEY=🚨高德地图Key \
  -e AMAP_SECRET=🚨高德地图Secret \
  -v 🚨storage挂载:/app/storage \
  -p 🚨端口:3000 \
  --restart unless-stopped \
  ghcr.io/kwokronny/roadbook-api
```


```yaml docker-compose.yml
version: "3.5"
services:
  roadbook:
    container_name: roadbook
    image: ghcr.io/kwokronny/roadbook:latest
    restart: unless-stopped
    environment:
	    AMAP_KEY: 🚨高德地图Key
      AMAP_SECRET: 🚨高德地图Secret
      DB_DIALECT: mysql
      DB_HOSTNAME: roadbook_db
      DB_PORT: 3306
      DB_NAME: roadbook
      DB_USERNAME: root
      DB_PASSWORD: 🚨mysql密码
    volumes:
      - 🚨端口:/app/storage/
    ports:
	    3000
	    
	roadbook_db:
    image: mysql:5.7
    container_name: roadbook_db
    restart: unless-stopped
    volumes:
      - ./mysql:/var/lib/mysql
    environment:
      MYSQL_ROOT_PASSWORD: 🚨mysql密码
```

