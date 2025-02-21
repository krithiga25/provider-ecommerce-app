const mongoose = require("mongoose");

require("dotenv").config();

const connection = async (dbName) => {
  try {
    const connectionString = `${process.env.MONGO_URL}${dbName}?retryWrites=true&w=majority&appName=ClusterApp`;
    await mongoose.connect(connectionString, {});
    console.log("Database is connected");
  } catch (err) {
    console.error("Error connecting to the database:", err);
    process.exit(1);
  }
};

module.exports = connection;

//mongodb+srv://krithiperu2002:Shiroboy123@clusterapp.bbvbt.mongodb.net/?retryWrites=true&w=majority&appName=ClusterApp
