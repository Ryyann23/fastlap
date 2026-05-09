const routeModel = require("../models/routeModel");

async function getRoutes(req, res) {
  try {
    const routes = await routeModel.getRoutesByUserId(req.user.userId);
    res.json(routes);
  } catch (error) {
    console.error("Erro ao listar rotas:", error.message);
    res.status(500).json({ error: "Erro ao listar rotas" });
  }
}

async function getRouteHistory(req, res) {
  try {
    const limit = parseInt(req.query.limit) || 20;
    const routes = await routeModel.getRouteHistory(req.user.userId, limit);
    res.json(routes);
  } catch (error) {
    console.error("Erro ao buscar histórico:", error.message);
    res.status(500).json({ error: "Erro ao buscar histórico" });
  }
}

async function createRoute(req, res) {
  try {
    const {
      vehicleId,
      name,
      startAddress,
      endAddress,
      distance,
      estimatedTime,
      startLat,
      startLng,
      endLat,
      endLng,
    } = req.body;

    if (
      !name ||
      !startAddress ||
      !endAddress ||
      distance === undefined ||
      estimatedTime === undefined
    ) {
      return res.status(400).json({
        error:
          "Nome, endereço de início, endereço de destino, distância e tempo estimado são obrigatórios",
      });
    }

    const route = await routeModel.createRoute({
      userId: req.user.userId,
      vehicleId,
      name,
      startAddress,
      endAddress,
      distance,
      estimatedTime,
      startLat,
      startLng,
      endLat,
      endLng,
    });

    res.status(201).json({
      message: "Rota criada com sucesso",
      route,
    });
  } catch (error) {
    console.error("Erro ao criar rota:", error.message);
    res.status(500).json({ error: "Erro ao criar rota" });
  }
}

async function getRoute(req, res) {
  try {
    const { id } = req.params;
    const route = await routeModel.findRouteById(id);

    if (!route) {
      return res.status(404).json({ error: "Rota não encontrada" });
    }

    if (route.user_id !== req.user.userId) {
      return res.status(403).json({ error: "Acesso negado" });
    }

    const pois = await routeModel.getRoutePois(id);

    res.json({
      ...route,
      pois,
    });
  } catch (error) {
    console.error("Erro ao buscar rota:", error.message);
    res.status(500).json({ error: "Erro ao buscar rota" });
  }
}

async function updateRoute(req, res) {
  try {
    const { id } = req.params;
    const {
      name,
      vehicleId,
      startAddress,
      endAddress,
      distance,
      estimatedTime,
      startLat,
      startLng,
      endLat,
      endLng,
    } = req.body;

    const existingRoute = await routeModel.findRouteById(id);

    if (!existingRoute) {
      return res.status(404).json({ error: "Rota não encontrada" });
    }

    if (existingRoute.user_id !== req.user.userId) {
      return res.status(403).json({ error: "Acesso negado" });
    }

    const route = await routeModel.updateRoute(id, {
      name,
      vehicleId,
      startAddress,
      endAddress,
      distance,
      estimatedTime,
      startLat,
      startLng,
      endLat,
      endLng,
    });

    res.json({
      message: "Rota atualizada com sucesso",
      route,
    });
  } catch (error) {
    console.error("Erro ao atualizar rota:", error.message);
    res.status(500).json({ error: "Erro ao atualizar rota" });
  }
}

async function deleteRoute(req, res) {
  try {
    const { id } = req.params;

    const existingRoute = await routeModel.findRouteById(id);

    if (!existingRoute) {
      return res.status(404).json({ error: "Rota não encontrada" });
    }

    if (existingRoute.user_id !== req.user.userId) {
      return res.status(403).json({ error: "Acesso negado" });
    }

    await routeModel.deleteRoute(id);

    res.json({ message: "Rota deletada com sucesso" });
  } catch (error) {
    console.error("Erro ao deletar rota:", error.message);
    res.status(500).json({ error: "Erro ao deletar rota" });
  }
}

async function addPoiToRoute(req, res) {
  try {
    const { id } = req.params;
    const { poiId, orderIndex } = req.body;

    const existingRoute = await routeModel.findRouteById(id);

    if (!existingRoute) {
      return res.status(404).json({ error: "Rota não encontrada" });
    }

    if (existingRoute.user_id !== req.user.userId) {
      return res.status(403).json({ error: "Acesso negado" });
    }

    if (!poiId) {
      return res.status(400).json({ error: "POI ID é obrigatório" });
    }

    const routePoi = await routeModel.addPoiToRoute(id, poiId, orderIndex || 0);

    res.status(201).json({
      message: "POI adicionado à rota com sucesso",
      routePoi,
    });
  } catch (error) {
    console.error("Erro ao adicionar POI à rota:", error.message);
    res.status(500).json({ error: "Erro ao adicionar POI à rota" });
  }
}

async function removePoiFromRoute(req, res) {
  try {
    const { id, poiId } = req.params;

    const existingRoute = await routeModel.findRouteById(id);

    if (!existingRoute) {
      return res.status(404).json({ error: "Rota não encontrada" });
    }

    if (existingRoute.user_id !== req.user.userId) {
      return res.status(403).json({ error: "Acesso negado" });
    }

    await routeModel.removePoiFromRoute(id, poiId);

    res.json({ message: "POI removido da rota com sucesso" });
  } catch (error) {
    console.error("Erro ao remover POI da rota:", error.message);
    res.status(500).json({ error: "Erro ao remover POI da rota" });
  }
}

module.exports = {
  getRoutes,
  getRouteHistory,
  createRoute,
  getRoute,
  updateRoute,
  deleteRoute,
  addPoiToRoute,
  removePoiFromRoute,
};
