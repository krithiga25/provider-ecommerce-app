// the DB CRUD operations will be performed here
const {
  UserModel,
  ProductModel,
  WishlistModel,
} = require("../model/user_model");
const jwt = require("jsonwebtoken");

class UsersService {
  //we will call this function and then get the email and password
  static async registerUser(email, password) {
    // we will pass the email and password to the usermodel object created.
    try {
      // creating a new document in the users collection.
      // we are using the model that we created.
      const createUser = new UserModel({ email, password });
      return await createUser.save();
    } catch (err) {
      throw err;
    }
  }

  static async addProduct(id, productName, price, description) {
    try {
      const product = new ProductModel({ id, productName, price, description });
      return await product.save();
    } catch (err) {
      throw err;
    }
  }

  static async getProducts() {
    try {
      // category based
      //  const products = await ProductModel.find({ category: 'electronics' })
      const products = await ProductModel.find();
      return products;
    } catch (err) {
      throw err;
    }
  }

  static async addWishlist(email, ids) {
    try {
      //we need to reterive the user's email and find relevant object id and the productname and find relevant object id
      // Check if the wishlist exists
      const user = await UserModel.findOne({ email });
      const userId = user._id;
      let wishlist = await WishlistModel.findOne({ userId });
      if (!wishlist) {
        wishlist = new WishlistModel({ userId, products: [] });
        await wishlist.save();
      }
  
      // Loop through each product ID and add it to the wishlist
      for (const id of ids) {
        const product = await ProductModel.findOne({ id });
        const productId = product._id;
        await WishlistModel.updateOne(
          { userId },
          { $addToSet: { products: productId } } // Store only productId
        );
      }
  
      return { success: true, message: "Products added to wishlist" };
    } catch (err) {
      throw err;
    }
  }

  static async checkUser(email) {
    try {
      return await UserModel.findOne({ email });
    } catch (e) {
      throw e;
    }
  }

  static async generateToken(tokenData, secretKey, jwt_expiry) {
    return jwt.sign(tokenData, secretKey, { expiresIn: jwt_expiry });
  }
}

module.exports = UsersService;
