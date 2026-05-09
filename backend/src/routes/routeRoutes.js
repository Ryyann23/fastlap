const express = require("express");
const router = express.Router();
const routeController = require("../controllers/routeController");
const { authenticateToken } = require("../middleware/authMiddleware");

router.use(authenticateToken);

router.get("/", routeController.getRoutes);
router.get("/history", routeController.getRouteHistory);
router.post("/", routeController.createRoute);
router.get("/:id", routeController.getRoute);
router.put("/:id", routeController.updateRoute);
router.delete("/:id", routeController.deleteRoute);
router.post("/:id/pois", routeController.addPoiToRoute);
router.delete("/:id/pois/:poiId", routeController.removePoiFromRoute);

module.exports = router;
