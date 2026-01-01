const router = require("express").Router();

const controller = require("../controller/users_controller");
const authMiddleware = require("../middleware/auth_middleware");

router.post("/registration", controller.register);

router.post("/login", controller.login);

router.post("/addproduct", controller.addProduct);

router.get("/products", controller.getProducts);

router.post("/wishlist", controller.addWishlist);

router.get("/wishlist/:userId", controller.getWishlist);

router.delete("/wishlist/:userId/:productId", controller.deleteWishlist);

router.post("/cart", controller.addToCart);

router.get("/cart/:userId", controller.getCart);

router.delete("/cart/:userId/:productId", controller.deleteCart);

router.delete("/clearcart/:userId", controller.clearCart);

//payment api:
router.post("/createpayment", controller.payment);

//search:
router.get("/search/:searchItem", controller.search);

//orders:
router.get("/orders/:userId", controller.getOrders);

//create order:
router.post("/createorder", controller.createOrder);

//update user address:
router.post("/updateaddress", controller.updateAddress);

//update the status of the order:
router.put("/updatestatus/:ordId", controller.updateStatus);

router.get("/getaddress/:userId", controller.getAddress);

router.post("/ask", controller.askAI);

router.post("/friends/connect", authMiddleware, controller.connectFriend);

router.post("/friends/accept", authMiddleware, controller.acceptFriendRequest);

router.get("/friends/requests", authMiddleware, controller.getFriendRequests);

router.get("/friends/conversation/:conversationId", controller.getConversation);

router.get("/friends/conversationIds", authMiddleware, controller.getConversationIds);

module.exports = router;
