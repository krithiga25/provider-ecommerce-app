const express = require("express");

const body_parser = require("body-parser");

const userRouter = require("./routes/users_routes");

const app = express();

const cors = require("cors");

const whiteList = ["http://localhost:3000"];
const corsOption = {
  origin: (origin, callback) => {
    if (whiteList.indexOf(origin) !== -1 || !origin) {
      callback(null, true);
    } else {
      callback(new Error("Not allowed by CORS"));
    }
  },
  optionsSuccessStatus: 200,
};
app.use(cors(corsOption));

// after connecting to the mongo db,
// and then run the POST command with the email id and password from the extension of .router file.
app.use(body_parser.json());

app.use("/", userRouter);

module.exports = app;
