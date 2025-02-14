const admin = require("firebase-admin");
const {dailyMaximums} = require("./functions/dailyMaximums");
const {getNewestEntry} = require("./functions/newestEntry");
const {getLastSevenDays} = require("./functions/lastSevenDays");
const {getHourlyAverages} = require("./functions/entriesForDay");

admin.initializeApp();

exports.dailyMaximums = dailyMaximums;
exports.getNewestEntry = getNewestEntry;
exports.getLastSevenDays = getLastSevenDays;
exports.getHourlyAverages = getHourlyAverages;
