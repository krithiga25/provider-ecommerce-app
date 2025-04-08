// the DB CRUD operations will be performed here
const {
  UserModel,
  ProductModel,
  WishlistModel,
  CartModel,
  OrderModel,
} = require("../model/user_model");

require("dotenv").config();

const jwt = require("jsonwebtoken");
const mongoose = require("mongoose");
const stripe = require("stripe")(process.env.STRIPE_S_KEY);

function tokenizeSearchQuery(searchQuery) {
  const tokens = searchQuery.split(" ");
  return tokens.map((token) => token.toLowerCase());
}

function rankProducts(products, tokens) {
  return products
    .map((product) => {
      const productNameWords = product.productName.toLowerCase().split(" ");
      const descriptionWords = product.description.toLowerCase().split(" ");
      const allWords = productNameWords.concat(descriptionWords);
      const matchingTokens = allWords.filter((word) => tokens.includes(word));
      return { product, score: matchingTokens.length };
    })
    .sort((a, b) => b.score - a.score);
}

class UsersService {
  //we will call this function and then get the email and password
  static async registerUser(email, password) {
    // we will pass the email and password to the usermodel object created.
    try {
      // creating a new document in the users collection.
      // we are using the model that we created.
      const createUser = new UserModel({ email, password});
      await createUser.save();
      return { status: true, success: "User registered successfully" };
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

  static async addProduct(
    id,
    productName,
    price,
    description,
    image,
    rating,
    category
  ) {
    try {
      const product = new ProductModel({
        id,
        productName,
        price,
        description,
        image,
        rating,
        category,
      });
      await product.save();
      return {
        status: true,
        message: "Product added successfully",
      };
    } catch (err) {
      throw err;
    }
  }

  static async getProducts() {
    try {
      // category based
      //  const products = await ProductModel.find({ category: 'electronics' })
      const products = await ProductModel.find();
      return {
        status: true,
        message: "Products received successfully",
        products: products,
      };
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

      return {
        status: true,
        message: "Products added to wishlist",
      };
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
      return {
        status: true,
        message: "Wishlist items received successfully",
        products: productsList,
      };
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
      return { status: true, message: "Product deleted from wishlist" };
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
                products: {
                  product: productId,
                  quantity: product.quantity,
                  //size: product.size,
                },
              },
            }
          );
        }
      }
      return { status: true, message: "Product added to cart" };
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
      return {
        status: true,
        message: "Deleted the product from cart successfully",
        products: productsList,
      };
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
      return {
        status: true,
        message: "Deleted the product from cart successfully",
      };
    } catch (err) {
      throw err;
    }
  }

  static async clearCart(email) {
    try {
      const user = await UserModel.findOne({ email: email });
      const userId = user._id;
      console.log(userId);
      await CartModel.updateOne({ userId }, { $set: { products: [] } });
      return {
        status: true,
        message: "Cleared the cart successfully",
      };
    } catch (err) {
      throw err;
    }
  }

  static async moveToCart(email, id) {
    try {
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
      return {
        status: true,
        message: "Moved to cart successfully",
      };
    } catch (error) {
      throw error;
    }
  }

  static async moveToWishlist(email, id) {
    try {
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
      return {
        status: true,
        message: "Moved to wishlist successfully",
      };
    } catch (error) {
      throw error;
    }
  }

  static async payment(paymentDetails) {
    try {
      const { email, name, amount } = paymentDetails;
      let customer;
      const customers = await stripe.customers.list({
        email: email,
      });
      customer = customers.data.find((customer) => customer.email === email);
      if (customer == undefined) {
        console.log("new customer");
        customer = await stripe.customers.create({
          email: email,
          name: name,
        });
      }

      const ephemeralKey = await stripe.ephemeralKeys.create(
        { customer: customer.id },
        { apiVersion: "2023-10-16" }
      );
      const paymentIntent = await stripe.paymentIntents.create({
        amount: amount * 100,
        currency: "inr",
        customer: customer.id,
        description: "Your transaction description here",
        automatic_payment_methods: {
          enabled: true,
        },
      });

      return {
        paymentIntent: paymentIntent.client_secret,
        ephemeralKey: ephemeralKey.secret,
        customer: customer.id,
        publishableKey: process.env.PUBLISH_KEY,
        // "pk_test_51QvBubL4gE1upbxJftPvLWy2vQBXi1ciQwgS4eaZBQY9iV9m49N5BtSIK84nc9R7ruiHQau2GFm8fkmx7kNLmRZk00ZGZaIetJ",
      };
    } catch (error) {
      throw error;
    }
  }
  // Tokenize search query function
  static async search(searchDetails) {
    try {
      console.log(searchDetails);
      const tokens = tokenizeSearchQuery(searchDetails);
      const products = await ProductModel.find({
        $or: [
          { productName: { $regex: tokens.join("|"), $options: "i" } },
          { description: { $regex: tokens.join("|"), $options: "i" } },
        ],
      });
      const rankedProducts = rankProducts(products, tokens);
      return {
        status: true,
        message: "Search results received",
        searchResults: rankedProducts,
      };
    } catch (error) {
      throw error;
    }
  }

  static async createOrder(orderDetails) {
    try {
      const user = await UserModel.findOne({ email: orderDetails.email });
      const userId = user._id;
      if (user) {
        const products = await Promise.all(
          orderDetails.products.map(async (product) => {
            const productDoc = await ProductModel.findOne({
              id: product.product,
            });
            //console.log(productDoc.productName);
            const productId = new mongoose.Types.ObjectId(productDoc._id);
            if (productDoc) {
              return {
                product: {
                  productName: productDoc.productName,
                  image: productDoc.image,
                },
                quantity: product.quantity,
                price: product.quantity * productDoc.price,
              };
            } else {
              throw new Error(`Product not found: ${product.product}`);
            }
          })
        );
        const order = new OrderModel({
          userId,
          orderId: orderDetails.orderId,
          products,
          subtotal: orderDetails.subtotal,
          tax: orderDetails.tax,
          total: orderDetails.total,
          paymentMethod: orderDetails.paymentMethod,
          paymentStatus: orderDetails.paymentStatus,
          orderStatus: orderDetails.orderStatus,
          shippingAddress: orderDetails.shippingAddress,
        });
        await order.save();
        return {
          status: true,
          message: "Order placed",
          orderDetails: order,
        };
      }
    } catch (error) {
      throw error;
    }
  }

  static async getOrders(userId) {
    try {
      const user = await UserModel.findOne({ email: userId });
      const userID = user._id;
      if (user) {
        const orders = await OrderModel.find({ userId: userID });
        //console.log(orders);
        return {
          status: true,
          message: "Orders received successfully",
          orders: orders,
        };
      } else {
        return {
          status: false,
          message: "No orders found for this user.",
        };
      }
    } catch (error) {
      throw error;
    }
  }

  // static async getCategoryProducts(categoryName) {
  //   try {
  //     const products = await ProductModel.find({ category: categoryName });
  //     return {
  //       status: true,
  //       message: "Products received successfully",
  //       products: products,
  //     };
  //   } catch (error) {
  //     throw error;
  //   }
  // }
}
module.exports = UsersService;
