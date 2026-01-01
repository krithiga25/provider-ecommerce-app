const {
    FriendConnectionModel, UserModel, ConversationModel, MessageModel
} = require("../model/user_model");

class FriendsService {
    static async sendFriendRequest(userId, friendCode) {
        console.log(userId);
        const receiver = await UserModel.findOne({ uniqueCode: friendCode });

        if (!receiver) throw new Error("User not found");

        if (receiver._id.toString() === userId) {
            throw new Error("Cannot add yourself");
        }
        const existing = await FriendConnectionModel.findOne({
            $or: [
                { requester: userId, receiver: receiver._id },
                { requester: receiver._id, receiver: userId }
            ]
        });
        if (existing) {
            throw new Error("Friend request already exists");
        }
        console.log(userId, receiver._id);
        await FriendConnectionModel.create({
            requester: userId,
            receiver: receiver._id
        });
        return {
            status: true,
            message: "Friend request sent"
        };
    };
    static async acceptFriendRequest(req, res) {
        try {
            const { requestId } = req.body;
            const receiverId = req.user._id;
            let newConversation;

            const request = await FriendConnectionModel.findById(requestId);
            if (!request) throw new Error("Request not found");

            if (request.receiver.toString() !== receiverId) {
                throw new Error("Not authorized");
            }
            request.status = "accepted";
            console.log(request.requester, request.receiver);
            await request.save();
            // Check if conversation already exists
            const existingConversation = await ConversationModel.findOne({
                participants: { $all: [request.requester, request.receiver] },
            });
            if (!existingConversation) {
                newConversation = await ConversationModel.create({
                    participants: [request.requester, request.receiver],
                });
            }
            res.status(200).json({
                status: true,
                message: "Friend request accepted",
                conversationId: existingConversation ? existingConversation._id : newConversation._id,
            });
        } catch (error) {
            res.status(400).json({ status: false, message: error.message });
        }
    };
    static async getPendingRequests(receiverId) {
        try {
            const requests = await FriendConnectionModel.find({
                receiver: receiverId,
                status: "pending",
            })
                .populate("requester", "_id userName email")
                .sort({ createdAt: -1 });

            return requests;
        } catch (error) {
            throw error;
        }
    };
    static async getConversationIds(req, res) {
        try {
            const userId = req.user._id;
            const conversations = await ConversationModel.find({
                participants: userId,
            })
                .populate("participants", "_id userName email")
                .populate("lastMessageAt")
                .sort({ updatedAt: -1 });

            return conversations;
        } catch (err) {
            throw err;
        }
    };
    static async getConversation(conversationId) {
        const messages = await MessageModel.find({
            conversationId,
        })
            .sort({ createdAt: 1 });
        return messages;
    }
}

module.exports = FriendsService;