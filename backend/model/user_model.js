const mongoose = require("mongoose");
const db = require("../config/database");
const bcrypt = require("bcrypt");

// schema is imported from the mongoose.
const { Schema } = mongoose;

//creating a new schema called userSchema
// it will have the following documents in the collection.
const userSchema = new Schema({
  email: {
    type: String,
    lowercase: true,
    required: true,
    unique: true,
  },
  password: {
    type: String,
    required: true,
  },
});

//encrypting the password
userSchema.pre("save", async function () {
  try {
    var user = this;
    const salt = await bcrypt.genSalt(10);
    const hashpass = await bcrypt.hash(user.password, salt);
    user.password = hashpass;
  } catch (error) {
    throw error;
  }
});

// the db here is the connection function in the database file,
// that db will be calling the built in model function in the node
//const UserModel = db.model("users", userSchema);

//exporting the user model which is going to be used for registering the users in the schema.
//module.exports = UserModel;

async function createUserModel(dbName) {
  await db(dbName);
  const UserModel = mongoose.model("users", userSchema);
  return UserModel;
}
userSchema.methods.comparePassword = async function (userPassword) {
  try {
    const isMatch = await bcrypt.compare(userPassword, this.password);
    return isMatch;
  } catch (e) {
    throw e;
  }
};
module.exports = createUserModel;
