const app = require("./app");
const http = require("http");
const jwt = require("jsonwebtoken");
const { Server } = require("socket.io");
const connection = require("./config/database");
const { MessageModel, ProductModel } = require("./model/user_model");

const server = http.createServer(app);

const io = new Server(server, {
  cors: {
    origin: "*", // restrict later
    methods: ["GET", "POST"],
  },
});

io.use((socket, next) => {
  try {
    const token = socket.handshake.auth.token;
    if (!token) {
      return next(new Error("No token provided"));
    }
    const decoded = jwt.verify(token, "secretkey");
    socket.user = decoded; // {_id, email}
    next();
  } catch (err) {
    next(new Error("Unauthorized"));
  }
});

io.on("connection", (socket) => {
  console.log("Socket connected:", socket.user._id);

  // Join conversation room
  socket.on("join_conversation", ({ conversationId }) => {
    socket.join(conversationId);
    console.log(
      `User ${socket.user._id} joined conversation ${conversationId}`
    );
  });

  socket.on("share_product", async ({ conversationId, productId }) => {
    const product = await ProductModel.findOne({ id: productId });
    if (!product) {
      return socket.emit("error", {
        message: "Product not found",
      });
    }
    const message = await MessageModel.create({
      conversationId,
      sender: socket.user._id,
      product: {
        id: product.id,
        productName: product.productName,
        price: product.price,
        description: product.description,
        image: product.image,
        rating: product.rating,
        category: product.category,
      },
    });
    io.to(conversationId).emit("new_message", message);
  });

  socket.on("react_product", async ({ messageId, reaction }) => {
    const message = await MessageModel.findById(messageId);
    if (!message) return;

    await MessageModel.findByIdAndUpdate(messageId, {
      $addToSet: {
        [`reactions.${reaction}`]: socket.user._id,
      },
    });

    io.to(message.conversationId.toString()).emit("reaction_update", {
      messageId,
      reaction,
      userId: socket.user._id,
    });
  });

  socket.on("disconnect", () => {
    console.log("Socket disconnected:", socket.user._id);
  });
});

const port = 3000;

app.get("/", (req, res) => {
  res.send("Backend for E-com app");
});

server.listen(port, "0.0.0.0", async () => {
  console.log(`Server running on port ${port}`);
  await connection("ecomdb");
});
