const express = require("express");
const router = express.Router();
const statsController = require("../controllers/statsController");
const { authenticateToken } = require("../middleware/authMiddleware");

router.use(authenticateToken);

router.get("/deliveries", statsController.getDeliveryStats);
router.get("/routes", statsController.getRouteStats);
router.get("/history", statsController.getHistory);
router.post("/deliveries", statsController.createDelivery);
router.put("/deliveries/:id", statsController.updateDeliveryStatus);

module.exports = router;
