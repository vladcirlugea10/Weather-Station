const functions = require("firebase-functions");
const admin = require("firebase-admin");

exports.getHourlyAverages = functions.https.onRequest(async (req, res) => {
  try {
    const {day} = req.query;
    if (!day) {
      return res.status(400).send("Provide a day in the format of YYYY-MM-DD");
    }

    const snapshot = await admin.database()
        .ref("sensor_readings").once("value");
    const readings = snapshot.val();

    if (!readings) {
      return res.status(404).send("No sensor readings found");
    }

    const hourlyData = {};

    Object.keys(readings).forEach((key) => {
      const timestampMilisec = parseInt(key, 10);
      const correctedTimestamp = key.length === 10 ?
        timestampMilisec * 1000 :
        timestampMilisec;
      const readingDate = new Date(correctedTimestamp).
          toISOString().split("T")[0];

      if (readingDate === day) {
        const hour = new Date(correctedTimestamp).getHours();
        const reading = readings[key];

        if (!hourlyData[hour]) {
          hourlyData[hour] = {
            temperatureSum: 0,
            humiditySum: 0,
            pressureSum: 0,
            rainSum: 0,
            count: 0,
          };
        }

        hourlyData[hour].temperatureSum += reading.temperature || 0;
        hourlyData[hour].humiditySum += reading.humidity || 0;
        hourlyData[hour].pressureSum += reading.pressure || 0;
        hourlyData[hour].rainSum += reading.rainPercentage || 0;
        hourlyData[hour].count += 1;
      }
    });

    const averages = Object.keys(hourlyData).map((hour) => {
      const data = hourlyData[hour];
      return {
        hour: parseInt(hour, 10),
        temperature: (data.temperatureSum / data.count).toFixed(2),
        humidity: (data.humiditySum / data.count).toFixed(2),
        pressure: (data.pressureSum / data.count).toFixed(2),
        rain: (data.rainSum / data.count).toFixed(2),
      };
    });

    if (averages.length === 0) {
      return res.status(404).send("No readings found for that day");
    }

    averages.sort((a, b) => a.hour - b.hour);

    return res.status(200).json(averages);
  } catch (error) {
    console.error("Error fetching sensor readings:", error);
    res.status(500).send("Internal Server Error");
  }
});
