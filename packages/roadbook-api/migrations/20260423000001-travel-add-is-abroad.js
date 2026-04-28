'use strict';
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.addColumn('Travels', 'isAbroad', {
      type: Sequelize.BOOLEAN,
      allowNull: false,
      defaultValue: false,
    });
  },
  async down(queryInterface) {
    await queryInterface.removeColumn('Travels', 'isAbroad');
  },
};
