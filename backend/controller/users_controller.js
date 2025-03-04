//we will handle request and responses
// and then hit the services layer

const UsersService = require("../services/users_services");

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
    res.status[200].json(paymentResponse);
  } catch (error) {
    res.status(400).json({ message: "Payment failed", error: error.message });
  }
};
