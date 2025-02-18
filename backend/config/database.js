const moongoose = require("mongoose");

const connection = moongoose
  .createConnection(
    'mongodb://krithigaperu25:"Mimiluna1234"@ecom-cluster.jwkny.mongodb.net/?retryWrites=true&w=majority&appName=ecom-cluster'
  )
  .on("open,", () => console.log("database is connected"))
  .on("error", (err) => console.log(err));

module.exports = connection;
