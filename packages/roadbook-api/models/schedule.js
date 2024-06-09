'use strict';
const { Model } = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Schedule extends Model {
    static associate(models) {
      models.Travel.hasMany(this, { foreignKey: "tId" });
    }
  }
  Schedule.init({
    id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      autoIncrement: true,
      primaryKey: true,
    },
    cover: DataTypes.STRING, // 封面
    name: DataTypes.STRING, // 行程名称
    coordinate: DataTypes.STRING, //坐标经纬度【高德】
    address: DataTypes.STRING, // 地址
    dianpingUUID: DataTypes.STRING, //点评uuid
    isHotel: DataTypes.BOOLEAN, // 是否为酒店日程
    startTime: DataTypes.STRING, // 出发时间
    endTime: DataTypes.STRING, // 离店时间，当日程为酒店时有效
    traffic: DataTypes.STRING, //交通方式
    screenshots: DataTypes.STRING, // 票据截图
    notes: DataTypes.STRING // 攻略
  }, {
    sequelize,
    timestamps: false,
    modelName: 'Schedule',
  });
  return Schedule;
};