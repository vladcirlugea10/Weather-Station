const functions = require("firebase-functions");
const admin = require("firebase-admin");

exports.getLastSevenDays = functions.https.onRequest(async (req, res) => {
  try {
    const db = admin.database();
    const ref = db.ref("sensor_readings");

    const snapshot = await ref.once("value");
    const data = snapshot.val();

    if (!data) {
      return res.status(404).send("No sensor readings found");
    }

    const now = Date.now();
    const sevenDaysAgo = now - 7 * 24 * 60 * 60 * 1000;

    const filteredData = Object.entries(data)
        .filter(([timestamp]) => parseInt(timestamp, 10) >= sevenDaysAgo)
        .reduce((acc, [timestamp, entry]) => {
          const dateKey = new Date(parseInt(timestamp, 10))
              .toISOString().split("T")[0];
          if (!acc[dateKey]) {
            acc[dateKey] = {
              date: dateKey,
              temperature: [],
              pressure: [],
              humidity: [],
              rainPercentage: [],
            };
          }

          acc[dateKey].temperature.push(entry.temperature || 0);
          acc[dateKey].pressure.push(entry.pressure || 0);
          acc[dateKey].humidity.push(entry.humidity || 0);
          acc[dateKey].rainPercentage.push(entry.rainPercentage || 0);

          return acc;
        }, {});

    const summaries = Object.values(filteredData).map((dayData) => {
      const max = (arr) => (arr.length ? Math.max(...arr) : 0);
      const average = (arr) => (arr.length ?
         arr.reduce((sum, val) => sum + val, 0) / arr.length : 0);
      return {
        day: dayData.date,
        temperature: average(dayData.temperature).toFixed(1),
        pressure: max(dayData.pressure).toFixed(1),
        humidity: max(dayData.humidity).toFixed(1),
        rainPercentage: max(dayData.rainPercentage).toFixed(1),
      };
    });

    res.json(summaries);
  } catch (error) {
    console.error("Error fetching sensor readings:", error);
    res.status(500).send("Internal Server Error");
  }
});
