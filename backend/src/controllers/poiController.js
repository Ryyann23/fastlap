const poiModel = require("../models/poiModel");

async function getPois(req, res) {
  try {
    const { category } = req.query;

    let pois;
    if (category) {
      pois = await poiModel.getPoisByCategory(req.user.userId, category);
    } else {
      pois = await poiModel.getPoisByUserId(req.user.userId);
    }

    res.json(pois);
  } catch (error) {
    console.error("Erro ao listar POIs:", error.message);
    res.status(500).json({ error: "Erro ao listar POIs" });
  }
}

async function getNearbyPois(req, res) {
  try {
    const { lat, lng, radius } = req.query;

    if (!lat || !lng) {
      return res
        .status(400)
        .json({ error: "Latitude e longitude são obrigatórios" });
    }

    const pois = await poiModel.getNearbyPois(
      req.user.userId,
      parseFloat(lat),
      parseFloat(lng),
      parseFloat(radius) || 5,
    );

    res.json(pois);
  } catch (error) {
    console.error("Erro ao buscar POIs próximos:", error.message);
    res.status(500).json({ error: "Erro ao buscar POIs próximos" });
  }
}

async function createPoi(req, res) {
  try {
    const { name, category, address, latitude, longitude, notes } = req.body;

    if (!name || !category) {
      return res
        .status(400)
        .json({ error: "Nome e categoria são obrigatórios" });
    }

    const poi = await poiModel.createPoi({
      userId: req.user.userId,
      name,
      category,
      address,
      latitude,
      longitude,
      notes,
    });

    res.status(201).json({
      message: "POI criado com sucesso",
      poi,
    });
  } catch (error) {
    console.error("Erro ao criar POI:", error.message);
    res.status(500).json({ error: "Erro ao criar POI" });
  }
}

async function getPoi(req, res) {
  try {
    const { id } = req.params;
    const poi = await poiModel.findPoiById(id);

    if (!poi) {
      return res.status(404).json({ error: "POI não encontrado" });
    }

    if (poi.user_id !== req.user.userId) {
      return res.status(403).json({ error: "Acesso negado" });
    }

    res.json(poi);
  } catch (error) {
    console.error("Erro ao buscar POI:", error.message);
    res.status(500).json({ error: "Erro ao buscar POI" });
  }
}

async function updatePoi(req, res) {
  try {
    const { id } = req.params;
    const { name, category, address, latitude, longitude, notes } = req.body;

    const existingPoi = await poiModel.findPoiById(id);

    if (!existingPoi) {
      return res.status(404).json({ error: "POI não encontrado" });
    }

    if (existingPoi.user_id !== req.user.userId) {
      return res.status(403).json({ error: "Acesso negado" });
    }

    const poi = await poiModel.updatePoi(id, {
      name,
      category,
      address,
      latitude,
      longitude,
      notes,
    });

    res.json({
      message: "POI atualizado com sucesso",
      poi,
    });
  } catch (error) {
    console.error("Erro ao atualizar POI:", error.message);
    res.status(500).json({ error: "Erro ao atualizar POI" });
  }
}

async function deletePoi(req, res) {
  try {
    const { id } = req.params;

    const existingPoi = await poiModel.findPoiById(id);

    if (!existingPoi) {
      return res.status(404).json({ error: "POI não encontrado" });
    }

    if (existingPoi.user_id !== req.user.userId) {
      return res.status(403).json({ error: "Acesso negado" });
    }

    await poiModel.deletePoi(id);

    res.json({ message: "POI deletado com sucesso" });
  } catch (error) {
    console.error("Erro ao deletar POI:", error.message);
    res.status(500).json({ error: "Erro ao deletar POI" });
  }
}

module.exports = {
  getPois,
  getNearbyPois,
  createPoi,
  getPoi,
  updatePoi,
  deletePoi,
};
