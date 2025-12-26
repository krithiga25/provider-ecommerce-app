const mongoose = require("mongoose");
const db = require("../config/database");
const bcrypt = require("bcrypt");

// schema is imported from the mongoose.
const { Schema } = mongoose;

//creating a new schema called userSchema
// it will have the following documents in the collection.
const userSchema = new Schema({
  email: {
    type: String,
    lowercase: true,
    required: true,
    unique: true,
  },
  password: {
    type: String,
    required: true,
  },
  uniqueCode: {
    type: String,
    unique: true
  },
  address: {
    type: {
      shippingAddress: {
        name: { type: String },
        address: { type: String },
        city: { type: String },
        state: { type: String },
        zip: { type: String },
        country: { type: String },
      },
    },
    default: {
      shippingAddress: {
        name: "Default Name",
        address: "Default Address",
        city: "Default City",
        state: "Default State",
        zip: "Default Zip",
        country: "Default Country",
      },
    },
  },
});

//prodcut schema:
const productSchema = new Schema({
  id: {
    type: String,
    required: true,
    unique: true,
  },
  productName: {
    type: String,
    required: true,
  },
  //need to change it to double
  price: {
    type: Number,
    required: true,
  },
  description: String,
  image: String,
  rating: {
    type: Number,
    required: true,
    min: 1,
    max: 5,
  },
  category: String,
});

//wishlist schema:
const wishlistSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "users" },
    products: [{ type: mongoose.Schema.Types.ObjectId, ref: "products" }],
  },
  {
    timestamps: true,
  }
);

//cart schema:
const cartSchema = new mongoose.Schema(
  {
    userId: { type: mongoose.Schema.Types.ObjectId, ref: "users" },
    products: [
      {
        product: { type: mongoose.Schema.Types.ObjectId, ref: "products" },
        quantity: Number,
        //size: String,
      },
    ],
  },
  {
    timestamps: true,
  }
);

const orderSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: "users" },
  orderId: { type: String, required: true, unique: true },
  products: [
    {
      product: {
        type: {
          productName: { type: String },
          image: { type: String },
        },
      },
      quantity: { type: Number, required: true },
      price: { type: Number },
    },
  ],
  subtotal: { type: Number, required: true },
  tax: { type: Number, required: true },
  total: { type: Number, required: true },
  paymentMethod: { type: String, required: true },
  paymentStatus: {
    type: String,
    required: true,
    enum: ["pending", "paid", "failed"],
  },
  orderStatus: {
    type: String,
    required: true,
    enum: ["processing", "transit", "delivered", "cancelled"],
  },
  shippingAddress: {
    type: {
      name: String,
      address: String,
      city: String,
      state: String,
      zip: String,
      country: String,
    },
  },
  //include delivery date.
  deliveryDate: {
    type: Date,
    default: () => {
      const date = new Date();
      date.setHours(0, 0, 0, 0);
      date.setDate(date.getDate() + 4);
      return date;
    },
  },
  createdAt: { type: Date, default: Date.now },
  updatedAt: { type: Date, default: Date.now },
});

//encrypting the password
userSchema.pre("save", async function () {
  try {
    const user = this;
    if (!user.uniqueCode) {
      user.uniqueCode = Math.random()
        .toString(36)
        .substring(2, 8)
        .toUpperCase();
    }
    if (!user.isModified("password")) return;
    const salt = await bcrypt.genSalt(10);
    const hashpass = await bcrypt.hash(user.password, salt);
    user.password = hashpass;
  } catch (error) {
    throw error;
  }
});

userSchema.methods.comparePassword = async function (userPassword) {
  try {
    const isMatch = await bcrypt.compare(userPassword, this.password);
    return isMatch;
  } catch (e) {
    throw e;
  }
};

const friendConnectionSchema = new mongoose.Schema(
  {
    requester: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "users",
      required: true
    },
    receiver: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "users",
      required: true
    },
    status: {
      type: String,
      enum: ["pending", "accepted"],
      default: "pending"
    }
  },
  { timestamps: true }
);

const conversationSchema = new Schema(
  {
    participants: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: "users",
        required: true,
      },
    ],
    lastMessageAt: {
      type: Date,
      default: Date.now,
    },
  },
  { timestamps: true }
);

conversationSchema.index({ participants: 1 });

const messageSchema = new Schema(
  {
    conversationId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Conversation",
      required: true,
    },
    sender: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "users",
      required: true,
    },
    productId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "products",
      required: true,
    },
    reactions: {
      heart: [{ type: mongoose.Schema.Types.ObjectId, ref: "users" }],
      thumbsUp: [{ type: mongoose.Schema.Types.ObjectId, ref: "users" }],
      thumbsDown: [{ type: mongoose.Schema.Types.ObjectId, ref: "users" }],
    },
  },
  { timestamps: true }
);

const ConversationModel = mongoose.model("Conversation", friendConnectionSchema);

const FriendConnectionModel = mongoose.model("FriendConnection", friendConnectionSchema);

const MessageModel = mongoose.model("Message", messageSchema);

const UserModel = mongoose.model("users", userSchema);

const ProductModel = mongoose.model("products", productSchema);

const WishlistModel = mongoose.model("wishlist", wishlistSchema);

const CartModel = mongoose.model("cart", cartSchema);

const OrderModel = mongoose.model("Order", orderSchema);

module.exports = {
  UserModel,
  ProductModel,
  WishlistModel,
  CartModel,
  OrderModel,
  FriendConnectionModel,
  ConversationModel,
};

// io.use((socket, next) => {
//   const token = socket.handshake.auth.token;
//   const decoded = jwt.verify(token, SECRET);
//   socket.user = decoded;
//   next();
// });

// Conversation.create({
//   participants: [userA, userB]
// });