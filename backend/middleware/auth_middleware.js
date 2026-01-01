const jwt = require("jsonwebtoken");

module.exports = async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;
        if (!authHeader) {
            return res.status(401).json({
                status: false,
                message: "Authorization header missing",
            });
        }
        const token = authHeader.split(" ")[1];
        if (!token) {
            return res.status(401).json({
                status: false,
                message: "Token missing",
            });
        }
        const decoded = jwt.verify(token, "secretkey");
        req.user = {
            _id: decoded._id,
            email: decoded.email,
        };
        next();
    } catch (error) {
        return res.status(401).json({
            status: false,
            message: "Invalid or expired token",
        });
    }
};