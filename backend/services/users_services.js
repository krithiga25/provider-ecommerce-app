// the DB CRUD operations will be performed here
const createUserModel = require("../model/user_model");
const jwt = require("jsonwebtoken");

async function getUsersModel() {
  const UserModel = await createUserModel("ecomdb");
  return UserModel;
}

class UsersService {
  //we will call this function and then get the email and password
  static async registerUser(email, password) {
    // we will pass the email and password to the usermodel object created.
    try {
      //in the user model class we have the scheme, which is the template for creating a new document.
      // so like everytime the user is created, the document will be created.
      const UserModel = await getUsersModel();
      const createUser = new UserModel({ email, password });
      return await createUser.save();
    } catch (err) {
      throw err;
    }
  }

  static async checkUser(email) {
    try {
      const UserModel = await getUsersModel();
      return await UserModel.findOne({ email });
    } catch (e) {
      throw e;
    }
  }

  static async generateToken(tokenData, secretKey, jwt_expiry) {
      return jwt.sign(tokenData,secretKey, {expiresIn: jwt_expiry});
  }
}

module.exports = UsersService;
