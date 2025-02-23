//we will handle request and responses
// and then hit the services layer

const UsersService = require("../services/users_services");

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
    const { id, productName, price, description } = req.body;
    const successRes = await UsersService.addProduct(
      id,
      productName,
      price,
      description
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
    // console.log(req.body);
    // console.log(products);
    // console.log(userId);
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
    const  userId  = req.params.userId;
    const  productId  = req.params.productId;
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
