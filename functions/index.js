const functions = require("firebase-functions");
const cors = require("cors")({origin: true});
require("dotenv").config(); // .env 파일 로드

exports.getEnv = functions.https.onRequest((req, res) => {
  cors(req, res, () => {
    res.json({
      apiKey: process.env.API_KEY || "",
      authDomain: process.env.AUTH_DOMAIN || "",
      projectId: process.env.PROJECT_ID || "",
      storageBucket: process.env.STORAGE_BUCKET || "",
      messagingSenderId: process.env.MESSAGING_SENDER_ID || "",
      appId: process.env.APP_ID || "",
    });
  });
});
