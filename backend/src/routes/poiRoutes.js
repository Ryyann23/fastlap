const express = require("express");
const router = express.Router();
const poiController = require("../controllers/poiController");
const { authenticateToken } = require("../middleware/authMiddleware");

router.use(authenticateToken);

router.get("/", poiController.getPois);
router.get("/nearby", poiController.getNearbyPois);
router.post("/", poiController.createPoi);
router.get("/:id", poiController.getPoi);
router.put("/:id", poiController.updatePoi);
router.delete("/:id", poiController.deletePoi);

module.exports = router;
