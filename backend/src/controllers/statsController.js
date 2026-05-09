const deliveryModel = require("../models/deliveryModel");

async function getDeliveryStats(req, res) {
  try {
    const stats = await deliveryModel.getUserStats(req.user.userId);
    res.json(stats);
  } catch (error) {
    console.error("Erro ao buscar estatísticas:", error.message);
    res.status(500).json({ error: "Erro ao buscar estatísticas" });
  }
}

async function getRouteStats(req, res) {
  try {
    const stats = await deliveryModel.getRouteStats(req.user.userId);
    res.json(stats);
  } catch (error) {
    console.error("Erro ao buscar estatísticas de rotas:", error.message);
    res.status(500).json({ error: "Erro ao buscar estatísticas de rotas" });
  }
}

async function getHistory(req, res) {
  try {
    const limit = parseInt(req.query.limit) || 50;
    const history = await deliveryModel.getDeliveryHistory(
      req.user.userId,
      limit,
    );
    res.json(history);
  } catch (error) {
    console.error("Erro ao buscar histórico:", error.message);
    res.status(500).json({ error: "Erro ao buscar histórico" });
  }
}

async function createDelivery(req, res) {
  try {
    const { routeId, status, distance, duration } = req.body;

    const delivery = await deliveryModel.createDelivery({
      userId: req.user.userId,
      routeId,
      status,
      distance,
      duration,
    });

    res.status(201).json({
      message: "Entrega registrada com sucesso",
      delivery,
    });
  } catch (error) {
    console.error("Erro ao criar entrega:", error.message);
    res.status(500).json({ error: "Erro ao criar entrega" });
  }
}

async function updateDeliveryStatus(req, res) {
  try {
    const { id } = req.params;
    const { status } = req.body;

    if (!status) {
      return res.status(400).json({ error: "Status é obrigatório" });
    }

    const validStatuses = ["in_progress", "completed", "cancelled"];
    if (!validStatuses.includes(status)) {
      return res.status(400).json({ error: "Status inválido" });
    }

    const delivery = await deliveryModel.updateDeliveryStatus(id, status);

    res.json({
      message: "Status atualizado com sucesso",
      delivery,
    });
  } catch (error) {
    console.error("Erro ao atualizar entrega:", error.message);
    res.status(500).json({ error: "Erro ao atualizar entrega" });
  }
}

module.exports = {
  getDeliveryStats,
  getRouteStats,
  getHistory,
  createDelivery,
  updateDeliveryStatus,
};
