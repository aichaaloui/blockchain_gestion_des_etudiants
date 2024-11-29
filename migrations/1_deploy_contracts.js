// 1_deploy_contract.js
const Attendance = artifacts.require("Attendance");

module.exports = function(deployer) {
  deployer.deploy(Attendance);
};
