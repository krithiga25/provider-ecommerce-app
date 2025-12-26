const app = require("./app");

//run this to connect with mongo db
const connection = require("./config/database");

const port = 3000;

app.get("/", (req, res) => {
  res.send("Backend for E-com app");
});

app.listen(port, "0.0.0.0", async () => {
  console.log(`Server running on port ${port}`);
  await connection("ecomdb");
});
