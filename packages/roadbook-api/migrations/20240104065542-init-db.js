'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('Users', {
      id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
      },
      username: {
        type: Sequelize.STRING,
        allowNull: false,
        unique: true,
      },
      password: {
        type: Sequelize.STRING,
        allowNull: false,
      },
      name: Sequelize.STRING,
      avatar: Sequelize.STRING,
    });

    await queryInterface.createTable('Travels', {
      id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
      },
      name: Sequelize.STRING, // 旅程名称
      startDate: Sequelize.STRING, // 旅程起始时间
      endDate: Sequelize.STRING, // 旅程结束时间
      equip: Sequelize.TEXT, // 装备清单
      public: Sequelize.BOOLEAN,
    });

    await queryInterface.createTable('UserTravels', {
      id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
      },
      uId: Sequelize.INTEGER,
      tId: Sequelize.INTEGER,
      role: Sequelize.ENUM("view", "edit", "manage")
    });

    await queryInterface.createTable('Schedules', {
      id: {
        type: Sequelize.INTEGER,
        allowNull: false,
        autoIncrement: true,
        primaryKey: true,
      },
      tId: Sequelize.INTEGER,
      name: Sequelize.STRING, // 目的地名称
      cover: Sequelize.STRING, // 封面
      coordinate: Sequelize.STRING, // 导航坐标
      address: Sequelize.STRING, // 地址
      dianpingUUID: Sequelize.STRING, // 点评商铺UUID
      isHotel: Sequelize.BOOLEAN,
      startTime: Sequelize.STRING,
      endTime: Sequelize.STRING,
      traffic: Sequelize.STRING, //交通方式
      screenshots: Sequelize.STRING,
      notes: Sequelize.STRING,
    });
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.dropTable('Users');
    await queryInterface.dropTable('Travels');
    await queryInterface.dropTable('UserTravels');
    await queryInterface.dropTable('Schedules');
  }
};
