const admin = require("firebase-admin");
const {dailyMaximums} = require("./functions/dailyMaximums");
const {getNewestEntry} = require("./functions/newestEntry");

admin.initializeApp();

exports.dailyMaximums = dailyMaximums;
exports.getNewestEntry = getNewestEntry;
