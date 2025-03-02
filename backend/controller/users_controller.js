//we will handle request and responses
// and then hit the services layer

const UsersService = require("../services/users_services");
const stripe = require("stripe")(
  "sk_test_51QvBubL4gE1upbxJIoEnTIhPLlHL7kaPPWMFyQ3dL7YiWXu9acLqAWXKdQCCpvauqO6uVvevze1c0o2xsk73IGOI00ZWuncfi8"
);

exports.register = async (req, res, next) => {
  try {
    // we are getting the email and the password from the request body.
    const { email, password } = req.body;

    // sending the email and password to the service layer
    //awaiting its response
    const successRes = await UsersService.registerUser(email, password);

    res.json({ status: true, success: "User registered successfully" });
  } catch (err) {
    throw err;
  }
};

exports.login = async (req, res, next) => {
  try {
    // we are getting the email and the password from the request body.
    const { email, password } = req.body;
    //checks for the user.
    const user = await UsersService.checkUser(email);

    if (!user) {
      throw new Error("User not found");
    }

    //if user found check for the password
    const isMatch = await user.comparePassword(password);
    if (isMatch == false) {
      throw new Error("Password invalid");
    }

    //saving the user's id and the email in a variable
    let tokenData = { _id: user._id, email: user.email };

    //generating a token based on the data, and secretkey
    const token = await UsersService.generateToken(
      tokenData,
      "secretkey",
      "1d"
    );

    //sending the reponse with token
    res.status(200).json({ status: true, token: token });
  } catch (err) {
    throw err;
  }
};
exports.addProduct = async (req, res, next) => {
  try {
    const { id, productName, price, description, image, rating, category } = req.body;
    const successRes = await UsersService.addProduct(
      id,
      productName,
      price,
      description,
      image,
      rating,
      category
    );

    res.json({ status: true, success: "Product added successfully" });
  } catch (err) {
    throw err;
  }
};

// controller for getting the products.
exports.getProducts = async (req, res, next) => {
  try {
    const successRes = await UsersService.getProducts();
    res.json({
      status: true,
      success: "Products received successfully",
      products: successRes,
    });
  } catch (err) {
    throw err;
  }
};

exports.addWishlist = async (req, res, next) => {
  try {
    const { userId, products } = req.body;
    const successRes = await UsersService.addWishlist(userId, products);
    res.json({
      status: true,
      success: "Added to wishlist",
    });
  } catch (err) {
    throw err;
  }
};
exports.getWishlist = async (req, res, next) => {
  try {
    const { userId } = req.params;
    console.log(userId);
    const successRes = await UsersService.getWishlist(userId);
    res.json({
      status: true,
      success: "wish list received successfully",
      products: successRes,
    });
  } catch (err) {
    throw err;
  }
};

exports.deleteWishlist = async (req, res, next) => {
  try {
    const userId = req.params.userId;
    const productId = req.params.productId;
    console.log(req.params);
    //console.log(userId);
    const successRes = await UsersService.deleteWishlist(userId, productId);
    res.json({
      status: true,
      success: "wish list item deleted successfully",
      //products: successRes,
    });
  } catch (err) {
    throw err;
  }
};

exports.addToCart = async (req, res, next) => {
  try {
    const userId = req.body.userId;
    const products = req.body.products;
    console.log(req.body);
    console.log(userId);
    console.log(products);
    const successRes = await UsersService.addToCart(userId, products);
    res.json({
      status: true,
      success: "Added to cart",
    });
  } catch (err) {
    throw err;
  }
};

exports.getCart = async (req, res, next) => {
  try {
    const { userId } = req.params;
    console.log(userId);
    const successRes = await UsersService.getCart(userId);
    res.json({
      status: true,
      success: "cart received successfully",
      products: successRes,
    });
  } catch (err) {
    throw err;
  }
};

exports.deleteCart = async (req, res, next) => {
  try {
    const userId = req.params.userId;
    const productId = req.params.productId;
    console.log(req.params);
    //console.log(userId);
    const successRes = await UsersService.deleteCart(userId, productId);
    res.json({
      status: true,
      success: "cart item deleted successfully",
      //products: successRes,
    });
  } catch (err) {
    throw err;
  }
};

exports.moveToCart = async (req, res, next) => {
  try {
    const userId = req.params.userId;
    const productId = req.params.productId;
    console.log(req.params);
    //console.log(userId);
    const successRes = await UsersService.moveToCart(userId, productId);
    res.json({
      status: true,
      success: "Moved to cart successfully",
      //products: successRes,
    });
  } catch (err) {
    throw err;
  }
};

exports.moveToWishlist = async (req, res, next) => {
  try {
    const userId = req.params.userId;
    const productId = req.params.productId;
    console.log(req.params);
    //console.log(userId);
    const successRes = await UsersService.moveToWishlist(userId, productId);
    res.json({
      status: true,
      success: "Moved to wishlist successfully",
      //products: successRes,
    });
  } catch (err) {
    throw err;
  }
};

exports.paymentSheet = async (req, res) => {
  try {
    console.log("strip");
    const { email, name, amount } = req.body;
    console.log(email);
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
    //const amountInCents = stripe.convertAmountToInteger("100.00", "inr");
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount*100, // amount should be the current cart - total
      currency: "inr",
      customer: customer.id,
      description: "Your transaction description here",
      automatic_payment_methods: {
        enabled: true,
      },
    });

    res.json({
      paymentIntent: paymentIntent.client_secret,
      ephemeralKey: ephemeralKey.secret,
      customer: customer.id,
      publishableKey:
        "pk_test_51QvBubL4gE1upbxJftPvLWy2vQBXi1ciQwgS4eaZBQY9iV9m49N5BtSIK84nc9R7ruiHQau2GFm8fkmx7kNLmRZk00ZGZaIetJ",
    });
  } catch (error) {
    console.log(error);
    return res.json({ error: true, message: error.message, data: null });
  }
};
