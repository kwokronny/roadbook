module.exports = {
  development: {
    dialect: "sqlite",
    storage: "./storage/db/roadbook.sqlite",
    dialectOptions: {
      dateStrings: true,
      typeCast: true,
      charset: "utf8mb4",
      collate: "utf8mb4_general_ci",
    }
  },
  production: {
    dialect: process.env.DB_DIALECT || 'sqlite',
    storage: process.env.DB_FILE || "./storage/db/roadbook.sqlite",
    host: process.env.DB_HOSTNAME || 'localhost',
    port: process.env.DB_PORT || 3306,
    database: process.env.DB_NAME || 'roadbook',
    username: process.env.DB_USERNAME || 'root',
    password: process.env.DB_PASSWORD,
    dialectOptions: {
      dateStrings: true,
      typeCast: true,
      charset: "utf8mb4",
      collate: "utf8mb4_general_ci",
    }
  }
};