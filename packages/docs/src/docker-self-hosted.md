# Untitled


## Docker


```bash 
docker run -d \
  --name=roadbook-api \
  -e AMAP_KEY=🚨高德地图Secret \
  -e AMAP_SECRET=🚨高德地图Secret \
  -v 🚨storage挂载:/app/storage \
  -p 🚨端口:3000 \
  --restart unless-stopped \
  ghcr.io/kwokronny/roadbook-api
```


## 环境变量


| Column 1 | Column 2 | Column 3 |
| --- | --- | --- |
| 变量 | 默认值 | 描述 |
| AMAP_KEY |   | 高德地图应用Key |
| AMAP_SECRET |   | 高德地图应用Secret |
| DB_DIALECT | sqlite | 数据库驱动，[参考文档](https://sequelize.org/docs/v6/other-topics/dialect-specific-things/) |
| DB_HOSTNAME | localhost | 数据库host，DB_DIALECT 为 sqlite 时可不填 |
| DB_PORT | 3306 | 数据库端口，DB_DIALECT 为 sqlite 时可不填 |
| DB_NAME | roadbook | 数据库名，DB_DIALECT 为 sqlite 时可不填 |
| DB_USERNAME | root | 数据库用户名，DB_DIALECT 为 sqlite 时可不填 |
| DB_PASSWORD |   | 数据库密码，DB_DIALECT 为 sqlite 时可不填 |


## Docker compose


## mysql 示例 


```yaml 
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

