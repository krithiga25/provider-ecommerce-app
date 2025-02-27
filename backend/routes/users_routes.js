// this will contain the API, gets activated
// this will call the controller
const router = require("express").Router();

const controller = require("../controller/users_controller");

// calling the register method in the controller to register the user, whenever it is the registration page
router.post("/registration", controller.register);
router.post("/login", controller.login);
router.post("/addproduct", controller.addProduct);

//crete a get method to get all the products.
router.get("/products", controller.getProducts);

router.post("/wishlist", controller.addWishlist);

router.get("/wishlist/:userId", controller.getWishlist);

router.delete("/wishlist/:userId/:productId", controller.deleteWishlist);

router.post("/cart", controller.addToCart);

router.get("/cart/:userId", controller.getCart);

router.delete("/cart/:userId/:productId", controller.deleteCart);

//move to cart from the wishlist
//router.patch('/cart/:userId/:productId', controller.moveToCart);  //not neccessary

//move to wishlist from the cart
//router.patch('/wishlist/:userId/:productId', controller.moveToWishlist);  //not neccessary

//payment api:
router.post("/createpayment", controller.paymentSheet);

module.exports = router;
