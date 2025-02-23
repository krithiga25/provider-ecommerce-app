// this will contain the API, gets activated 
// this will call the controller
const router = require('express').Router();

const controller = require('../controller/users_controller');

// calling the register method in the controller to register the user, whenever it is the registration page
router.post('/registration', controller.register);
router.post('/login',controller.login );
router.post('/addproduct', controller.addProduct);

//crete a get method to get all the products. 
router.get('/products', controller.getProducts);

router.post('/wishlist', controller.addWishlist);

router.get('/wishlist/:userId', controller.getWishlist);

router.delete('/wishlist/:userId/:productId', controller.deleteWishlist);

module.exports = router;