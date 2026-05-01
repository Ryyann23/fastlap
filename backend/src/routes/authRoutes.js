const express = require("express");
const router = express.Router();
const authController = require("../controllers/authController");

router.post("/register", authController.register);
router.post("/login", authController.login);
router.post("/forgot-password", authController.forgotPassword);
router.post("/refresh", authController.refreshToken);

router.get(
  "/me",
  require("../middleware/authMiddleware").authenticateToken,
  authController.getMe,
);

router.post("/logout", authController.logout);

module.exports = router;
