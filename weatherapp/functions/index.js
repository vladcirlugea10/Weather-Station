const admin = require("firebase-admin");
const {dailyMaximums} = require("./functions/dailyMaximums");
const {getNewestEntry} = require("./functions/newestEntry");
const {getLastSevenDays} = require("./functions/lastSevenDays");
const {entriesForDay} = require("./functions/entriesForDay");

admin.initializeApp();

exports.dailyMaximums = dailyMaximums;
exports.getNewestEntry = getNewestEntry;
exports.getLastSevenDays = getLastSevenDays;
exports.getEntriesForDay = entriesForDay;
