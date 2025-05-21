'use strict';
const {
  Model
} = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class Travel extends Model {
    static associate(models) {
      this.belongsToMany(models.User, { through: models.UserTravel, foreignKey: "tId" });
    }
  }
  Travel.init({
    id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      autoIncrement: true,
      primaryKey: true,
    },
    name: DataTypes.STRING, // 旅程名称
    startDate: DataTypes.STRING, // 旅程起始时间
    endDate: DataTypes.STRING, // 旅程结束时间
    equip: DataTypes.TEXT, // 装备
    city: DataTypes.STRING, // 城市
    public: DataTypes.BOOLEAN,
  }, {
    sequelize,
    timestamps: false,
    modelName: 'Travel',
  });
  return Travel;
};