//we will handle request and responses
// and then hit the services layer

const UsersService = require("../services/users_services");

const stripe = require("stripe")(process.env.STRIPE_S_KEY);

exports.register = async (req, res, next) => {
  try {
    // we are getting the email and the password from the request body.
    const { email, password } = req.body;

    // sending the email and password to the service layer
    //awaiting its response
    const response = await UsersService.registerUser(email, password);
    res.status(200).json(response);
    //res.json({ status: true, success: "User registered successfully" });
  } catch (error) {
    res.status(400).json({
      status: false,
      message: "Error in registering the user in",
      error: error.message,
    });
  }
};

// check this one
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
  } catch (error) {
    res.status(400).json({
      status: false,
      message: "Error in logging in",
      error: error.message,
    });
  }
};

exports.addProduct = async (req, res, next) => {
  try {
    const { id, productName, price, description, image, rating, category } =
      req.body;
    const response = await UsersService.addProduct(
      id,
      productName,
      price,
      description,
      image,
      rating,
      category
    );
    res.status(200).json(response);
  } catch (error) {
    res.status(400).json({
      status: false,
      message: "Error in adding the item to wishlist",
      error: error.message,
    });
  }
};

exports.getProducts = async (req, res, next) => {
  try {
    const response = await UsersService.getProducts();
    res.status(200).json(response);
  } catch (error) {
    res.status(400).json({
      status: false,
      message: "Error in adding the item to wishlist",
      error: error.message,
    });
  }
};

exports.addWishlist = async (req, res, next) => {
  try {
    const { userId, products } = req.body;
    const response = await UsersService.addWishlist(userId, products);
    res.status(200).json(response);
  } catch (error) {
    res.status(400).json({
      status: false,
      message: "Error in adding the item to wishlist",
      error: error.message,
    });
  }
};
exports.getWishlist = async (req, res, next) => {
  try {
    const { userId } = req.params;
    const response = await UsersService.getWishlist(userId);
    res.status(200).json(response);
  } catch (error) {
    res.status(400).json({
      status: false,
      message: "Error in getting the wishlist items",
      error: error.message,
    });
  }
};

exports.deleteWishlist = async (req, res, next) => {
  try {
    const userId = req.params.userId;
    const productId = req.params.productId;
    const response = await UsersService.deleteWishlist(userId, productId);
    res.status(200).json(response);
  } catch (error) {
    res.status(400).json({
      status: false,
      message: "Error in deleting an item from wishlist",
      error: error.message,
    });
  }
};

exports.addToCart = async (req, res, next) => {
  try {
    const userId = req.body.userId;
    const products = req.body.products;
    const response = await UsersService.addToCart(userId, products);
    res.status(200).json(response);
  } catch (error) {
    res.status(400).json({
      status: false,
      message: "Error in adding item to cart",
      error: error.message,
    });
  }
};

exports.getCart = async (req, res, next) => {
  try {
    const { userId } = req.params;
    const response = await UsersService.getCart(userId);
    res.status(200).json(response);
  } catch (error) {
    res.status(400).json({
      status: false,
      message: "Error in accessing cart items",
      error: error.message,
    });
  }
};

exports.deleteCart = async (req, res, next) => {
  try {
    const userId = req.params.userId;
    const productId = req.params.productId;
    const response = await UsersService.deleteCart(userId, productId);
    res.status(200).json(response);
  } catch (error) {
    res.status(400).json({
      status: false,
      message: "Unable to delete cart item",
      error: error.message,
    });
  }
};

exports.clearCart = async (req, res, next) => {
  try {
    const userId = req.params.userId;
    const response = await UsersService.clearCart(userId);
    res.status(200).json(response);
  } catch (error) {
    res.status(400).json({
      status: false,
      message: "Failed to clear the cart",
      error: error.message,
    });
  }
};

// exports.moveToCart = async (req, res, next) => {
//   try {
//     const userId = req.params.userId;
//     const productId = req.params.productId;
//     const response = await UsersService.moveToCart(userId, productId);
//     res.status(200).json(response);
//   } catch (error) {
//     res.status(400).json({
//       status: false,
//       message: "Unable to move to wishlist",
//       error: error.message,
//     });
//   }
// };

// exports.moveToWishlist = async (req, res, next) => {
//   try {
//     const userId = req.params.userId;
//     const productId = req.params.productId;
//     const response = await UsersService.moveToWishlist(userId, productId);
//     res.status(200).json(response);
//   } catch (error) {
//     res.status(400).json({
//       status: false,
//       message: "Unable to move to wishlist",
//       error: error.message,
//     });
//   }
// };

exports.payment = async (req, res) => {
  try {
    const paymentResponse = await UsersService.payment(req.body);
    res.status(200).json(paymentResponse);
  } catch (error) {
    res
      .status(400)
      .json({ status: false, message: "Payment failed", error: error.message });
  }
};

exports.paymentSheet = async (req, res) => {
  try {
    const { email, name, amount } = req.body;

    // Create Customer if Not Exists
    let customer;
    const customers = await stripe.customers.list({ email: email });
    customer = customers.data.find((c) => c.email === email);
    if (!customer) {
      customer = await stripe.customers.create({ email: email, name: name });
    }

    // Create Payment Intent
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount * 100, // Convert to cents
      currency: "inr",
      customer: customer.id,
      payment_method_types: ["card"],
      confirmation_method: "manual",
      confirm: false,
    });

    res.json({
      paymentIntent: paymentIntent.client_secret,
    });
  } catch (error) {
    res.json({ error: true, message: error.message });
  }
};

exports.search = async (req, res) => {
  try {
    const searchResponse = await UsersService.search(req.params.searchItem);
    res.status(200).json(searchResponse);
  } catch (error) {
    res
      .status(400)
      .json({ status: false, message: "Search failed", error: error.message });
  }
};

exports.createOrder = async (req, res) => {
  try {
    const orderResponse = await UsersService.createOrder(req.body);
    res.status(200).json(orderResponse);
  } catch (error) {
    res.status(400).json({
      status: false,
      message: "Failed to create order",
      error: error.message,
    });
  }
};

exports.getOrders = async (req, res) => {
  try {
    const orderResponse = await UsersService.getOrders(req.params.userId);
    res.status(200).json(orderResponse);
  } catch (error) {
    res.status(400).json({
      status: false,
      message: "Failed to get orders",
      error: error.message,
    });
  }
};

exports.newPayment = async (req, res) => {
  console.log("hi");
  try {
    const { email, name, amount, cardNumber, expMonth, expYear, cvc } =
      req.body;

    // 1️⃣ Create a Token from Card Details
    const token = await stripe.tokens.create({
      card: {
        number: cardNumber,
        exp_month: expMonth,
        exp_year: expYear,
        cvc: cvc,
      },
    });

    console.log("token", token);

    // 2️⃣ Create a Payment Method using the Token
    const paymentMethod = await stripe.paymentMethods.create({
      type: "card",
      card: { token: token.id },
      billing_details: { name, email },
    });

    // 2️⃣ Create a Payment Intent and attach Payment Method
    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount * 100, // Convert to smallest currency unit
      currency: "inr",
      payment_method: paymentMethod.id,
      confirm: true, // Immediate confirmation
      description: "E-commerce Payment",
    });

    // 3️⃣ Return the final payment status
    res.json({
      success: true,
      status: paymentIntent.status,
    });
  } catch (error) {
    res.status(500).json({ success: false, error: error.message });
  }
};

// exports.getCategoryProducts = async (req, res) => {
//   try {
//     const response = await UsersService.getCategoryProducts(
//       req.params.categoryName
//     );
//     res.status(200).json(response);
//   } catch (error) {
//     res.status(400).json({
//       status: false,
//       message: "Can't get category",
//       error: error.message,
//     });
//   }
// };
