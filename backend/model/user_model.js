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

//prodcut schema:
const productSchema = new Schema({
  id: {
    type: String,
    required: true,
    unique: true,
  },
  productName: {
    type: String,
    required: true,
  },
  //need to change it to double
  price: Number,
  description: String,
});

//wishlist schema:
const wishlistSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "users" },
    products: [{ type: mongoose.Schema.Types.ObjectId, ref: "products" }],
  },
  {
    timestamps: true,
  }
);

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

userSchema.methods.comparePassword = async function (userPassword) {
  try {
    const isMatch = await bcrypt.compare(userPassword, this.password);
    return isMatch;
  } catch (e) {
    throw e;
  }
};

const UserModel = mongoose.model("users", userSchema);

const ProductModel = mongoose.model("products", productSchema);

const WishlistModel = mongoose.model("wishlist", wishlistSchema);

module.exports = { UserModel, ProductModel, WishlistModel };
