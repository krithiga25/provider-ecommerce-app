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

    res.json({status:true, success:"User registered successfully"});
  } catch (err) {
    throw err;
  }
};
