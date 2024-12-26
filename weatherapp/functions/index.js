const admin = require("firebase-admin");
const {dailyMaximums} = require("./functions/dailyMaximums");

admin.initializeApp();

exports.dailyMaximums = dailyMaximums;
