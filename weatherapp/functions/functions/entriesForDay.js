const functions = require("firebase-functions");
const admin = require("firebase-admin");

exports.entriesForDay = functions.https.onRequest(async (req, res) => {
  try {
    const {day} = req.query;
    console.log("day:", day);
    if (!day) {
      return res.status(400).send("Provide a day in the format of YYYY-MM-DD");
    }

    const snapshot = await admin.database().
        ref("sensor_readings").once("value");
    const readings = snapshot.val();

    if (!readings) {
      return res.status(404).send("No sensor readings found");
    }
    console.log("aici", readings);
    const filteredData = [];
    Object.keys(readings).forEach((key) => {
      const reading = readings[key];
      const timestampmilisec = parseInt(key, 10);
      const correctedTimestamp = timestampmilisec.toString()
          .length === 10 ?
          timestampmilisec * 1000 :
          timestampmilisec;
      console.log("correctedTimestamp", correctedTimestamp);

      const readingDate = new Date(correctedTimestamp)
          .toISOString().split("T")[0];
      console.log("readingDate", readingDate);

      if (readingDate === day) {
        filteredData.push({id: key, ...reading});
      }
    });

    if (filteredData.length === 0) {
      return res.status(404).send("No readings found for that day");
    }

    filteredData.sort((a, b) => parseInt(b.timestamp) - parseInt(a.timestamp));

    return res.status(200).json(filteredData);
  } catch (error) {
    console.error("Error fetching sensor readings:", error);
    res.status(500).send("Internal Server Error");
  }
});
