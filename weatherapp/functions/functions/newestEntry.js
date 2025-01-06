const functions = require("firebase-functions");
const admin = require("firebase-admin");

exports.getNewestEntry = functions.https.onRequest(async (req, res) => {
  try {
    const dbRef = admin.database().ref("sensor_readings");

    const snapshot = await dbRef.orderByKey().limitToLast(1).once("value");

    if (!snapshot.exists()) {
      return res.status(404).send({message: "No sensor readings found"});
    }

    const newestEntry = snapshot.val();

    return res.status(200).json({data: newestEntry});
  } catch (error) {
    console.log(error);
    return res.status(500).send({message: error.message});
  }
});
