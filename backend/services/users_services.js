// the DB CRUD operations will be performed here
const createUserModel = require("../model/user_model");

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
}

module.exports = UsersService;
