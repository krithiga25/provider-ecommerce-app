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
