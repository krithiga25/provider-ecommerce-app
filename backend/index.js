const app = require("./app");

//run this to connect with mongo db
const connection = require("./config/database");

const port = 3000;

app.get("/", (req, res) => {
  res.send("Backend for E-com app");
});

app.listen(3000, async () => {
  console.log("Server started on port 3000");
  await connection("ecomdb");
});
