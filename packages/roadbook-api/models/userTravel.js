'use strict';
const { Model } = require('sequelize');
module.exports = (sequelize, DataTypes) => {
  class UserTravel extends Model { }
  UserTravel.init({
    role: DataTypes.ENUM("view", "edit", "manage")
  }, {
    sequelize,
    timestamps: false,
    modelName: 'UserTravel',
  });
  return UserTravel;
};