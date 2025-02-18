const app = require("./app");

//run this to connect with mongo db
const db = require("./config/database");
//run this to create the schema.
//const UserModel = require("./model/user_model");


const port = 3000;

app.get("/", (req, res) => {
  res.send("heeloo world");
});


app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
