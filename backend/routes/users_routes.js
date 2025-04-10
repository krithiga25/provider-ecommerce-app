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

router.delete("/clearcart/:userId", controller.clearCart);

//move to cart from the wishlist
//router.patch('/cart/:userId/:productId', controller.moveToCart);  //not neccessary

//move to wishlist from the cart
//router.patch('/wishlist/:userId/:productId', controller.moveToWishlist);  //not neccessary

//payment api:
router.post("/createpayment", controller.payment);

//search:
router.get("/search/:searchItem", controller.search);

//get category products:
//router.get('/category/:categoryName', controller.getCategoryProducts);

//new payment
//router.post("/newpayment", controller.newPayment);

//orders:
router.get("/orders/:userId", controller.getOrders);

//create order:
router.post("/createorder", controller.createOrder);

//update user address:
router.post("/updateaddress", controller.updateAddress);

//update the status of the order:
router.put("/updatestatus/:ordId", controller.updateStatus);

module.exports = router;
