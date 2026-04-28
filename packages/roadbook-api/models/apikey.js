'use strict';
const { Model } = require('sequelize');

module.exports = (sequelize, DataTypes) => {
  class ApiKey extends Model {
    static associate(models) {
      this.belongsTo(models.User, { foreignKey: 'uId' });
    }
  }
  ApiKey.init({
    id: {
      type: DataTypes.INTEGER,
      allowNull: false,
      autoIncrement: true,
      primaryKey: true,
    },
    uId: {
      type: DataTypes.INTEGER,
      allowNull: false,
    },
    key: {
      type: DataTypes.STRING,
      allowNull: false,
      unique: true,
    },
    name: {
      type: DataTypes.STRING,
      allowNull: false,
    },
    lastUsedAt: DataTypes.DATE,
    createdAt: DataTypes.DATE,
  }, {
    sequelize,
    timestamps: false,
    modelName: 'ApiKey',
  });
  return ApiKey;
};
