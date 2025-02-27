// the DB CRUD operations will be performed here
const {
  UserModel,
  ProductModel,
  WishlistModel,
  CartModel,
} = require("../model/user_model");
const jwt = require("jsonwebtoken");
const mongoose = require("mongoose");
const stripe = require("stripe")(
  "sk_test_51QvBubL4gE1upbxJIoEnTIhPLlHL7kaPPWMFyQ3dL7YiWXu9acLqAWXKdQCCpvauqO6uVvevze1c0o2xsk73IGOI00ZWuncfi8"
);

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
          { $addToSet: { products: productId } }
        );
      }

      return { success: true, message: "Products added to wishlist" };
    } catch (err) {
      throw err;
    }
  }

  static async getWishlist(email) {
    try {
      const user = await UserModel.findOne({ email });
      const userId = user._id;
      const wishlistProducts = await WishlistModel.find({ userId }, "products");
      const productsList = [];
      for (const wishlistProduct of wishlistProducts) {
        for (const productId of wishlistProduct.products) {
          const product = await ProductModel.findById(
            new mongoose.Types.ObjectId(productId)
          );
          productsList.push(product);
        }
      }

      console.log(productsList);
      return productsList;
    } catch (err) {
      throw err;
    }
  }

  static async deleteWishlist(email, id) {
    try {
      const user = await UserModel.findOne({ email: email });
      const userId = user._id;
      console.log(userId);
      //find only one based on what is give as the parameter,
      // find - will return all the doucments based on the given parameter.
      const product = await ProductModel.findOne({ id: id });
      const productId = product._id;
      console.log(productId);
      await WishlistModel.updateOne(
        { userId },
        { $pull: { products: productId } }
      );
    } catch (err) {
      throw err;
    }
  }
  static async addToCart(email, products) {
    try {
      const user = await UserModel.findOne({ email });
      const userId = user._id;
      let cartList = await CartModel.findOne({ userId });
      if (!cartList) {
        console.log("true");
        cartList = new CartModel({ userId, products: [] });
        await cartList.save();
      }
      for (const product of products) {
        const id = product.product;
        const productDoc = await ProductModel.findOne({ id });
        const productId = productDoc._id;
        console.log(product.quantity);
        const productExists = await CartModel.findOne({
          userId,
          "products.product": productId,
        });

        if (productExists) {
          await CartModel.updateOne(
            { userId, "products.product": productId },
            {
              $inc: { "products.$.quantity": 1 },
            }
          );
        } else {
          await CartModel.updateOne(
            { userId },
            {
              $push: {
                products: { product: productId, quantity: product.quantity },
              },
            }
          );
        }
      }
      return { success: true, message: "Product added to cart" };
    } catch (err) {
      throw err;
    }
  }

  static async getCart(email) {
    try {
      const user = await UserModel.findOne({ email });
      const userId = user._id;
      const cartProducts = await CartModel.find({ userId }, "products");
      console.log(cartProducts);
      const productsList = [];
      for (const cartProduct of cartProducts) {
        console.log(cartProduct);
        for (const productId of cartProduct.products) {
          console.log(productId);
          const product = await ProductModel.findById(
            new mongoose.Types.ObjectId(productId.product)
          );
          const productWithQuantity = {
            product,
            quantity: productId.quantity,
          };
          productsList.push(productWithQuantity);
        }
      }
      return productsList;
    } catch (err) {
      throw err;
    }
  }

  static async deleteCart(email, id) {
    try {
      const user = await UserModel.findOne({ email: email });
      const userId = user._id;
      const product = await ProductModel.findOne({ id: id });
      const productId = product._id;
      const cart = await CartModel.findOne({ userId });
      console.log(productId);
      const productInCart = cart.products.find((p) =>
        p.product.equals(productId)
      );
      //console.log(productInCart.quantity);
      const quantity = productInCart.quantity;

      if (quantity > 1) {
        await CartModel.updateOne(
          { userId, "products.product": productId },
          { $inc: { "products.$.quantity": -1 } }
        );
      } else {
        await CartModel.updateOne(
          { userId },
          { $pull: { products: { product: productId } } }
        );
      }
    } catch (err) {
      throw err;
    }
  }

  static async moveToCart(email, id) {
    const user = await UserModel.findOne({ email: email });
    const userId = user._id;
    const product = await ProductModel.findOne({ id: id });
    const productId = product._id;
    const wishlist = await WishlistModel.findOne({ userId });
    console.log(wishlist);
    //add the product to the cart:
    let cart = await CartModel.findOne({ userId });
    if (!cart) {
      // Create a new cart document if it doesn't exist
      cart = new CartModel({ userId, products: [] });
      await cart.save();
      cart.products.push({ product: productId, quantity: 1 });
      await cart.save();
    } else {
      await CartModel.updateOne(
        { userId },
        { $push: { products: { product: productId, quantity: 1 } } }
      );
    }
    //removing the product from this wishlist.
    await WishlistModel.updateOne(
      { userId },
      { $pull: { products: productId } }
    );
    return;
  }

  static async moveToWishlist(email, id) {
    const user = await UserModel.findOne({ email: email });
    const userId = user._id;
    const product = await ProductModel.findOne({ id: id });
    const productId = product._id;
    const cart = await CartModel.findOne({ userId });
    console.log(cart);
    if (cart) {
      await CartModel.updateOne(
        { userId },
        { $pull: { products: { product: productId } } }
      );
    }

    let wishlist = await WishlistModel.findOne({ userId });
    if (!wishlist) {
      wishlist = new WishlistModel({ userId, products: [] });
      await wishlist.save();
      wishlist.products.push(productId);
      await wishlist.save();
    } else {
      await WishlistModel.updateOne(
        { userId },
        { $push: { products: productId } }
      );
    }
    return;
  }

  static async createPayment(amount) {
    //console.log(createdUser);

    try {
      const session = await stripe.checkout.sessions.create({
        payment_method_types: ["card"],
        line_items: [
          {
            price_data: {
              currency: "usd",
              product_data: {
                name: "Total Order Payment",
              },
              unit_amount: amount * 100, // Convert to cents
            },
            quantity: 1,
          },
        ],
        mode: "payment",
        success_url: "http://localhost:3000/success",
        cancel_url: "http://localhost:3000/cancel",
      });
      return session.id;
    } catch (error) {
      return "payment failed";
    }
  }
}
module.exports = UsersService;
