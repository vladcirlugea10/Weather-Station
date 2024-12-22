const functions = require("firebase-functions");
const admin = require("firebase-admin");

exports.dailyMaximums = functions.https.onRequest(async (req, res) => {
  try {
    const {day} = req.query;

    if (!day) {
      return res.status(400).send("Provide a day in the format of YYYY-MM-DD");
    }

    const snapshot = await admin.database().
        ref("sensor_readings").once("value");
    const readings = snapshot.val();

    if (!readings) {
      return res.status(404).send("No sensor readings found");
    }

    const dayStart = new Date(`${day}T00:00:00Z`).getTime();
    const dayEnd = new Date(`${day}T23:59:59Z`).getTime();

    let minTemp = Infinity;
    let maxTemp = -Infinity;

    Object.entries(readings).forEach(([Timestamp, data]) => {
      const time = parseInt(Timestamp, 10);
      if (time >= dayStart && time <= dayEnd &&
        data.temperature !== undefined) {
        const temp = data.temperature;
        if (temp < minTemp) {
          minTemp = temp;
        }
        if (temp > maxTemp) {
          maxTemp = temp;
        }
      }
    });

    if (minTemp === Infinity || maxTemp === -Infinity) {
      return res.status(404).send("No readings found for that day");
    }

    res.send({
      day,
      minTemperature: minTemp,
      maxTemperature: maxTemp,
    });
  } catch (error) {
    console.log(error);
    res.status(500).send(error.message);
  }
});
