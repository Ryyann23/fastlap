const express = require("express");
const router = express.Router();
const vehicleController = require("../controllers/vehicleController");
const { authenticateToken } = require("../middleware/authMiddleware");

router.use(authenticateToken);

router.get("/", vehicleController.getVehicles);
router.get("/selected", vehicleController.getSelectedVehicle);
router.post("/", vehicleController.createVehicle);
router.get("/:id", vehicleController.getVehicle);
router.put("/:id", vehicleController.updateVehicle);
router.delete("/:id", vehicleController.deleteVehicle);
router.put("/:id/select", vehicleController.selectVehicle);

module.exports = router;
