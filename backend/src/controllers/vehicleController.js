const vehicleModel = require("../models/vehicleModel");

async function getVehicles(req, res) {
  try {
    const vehicles = await vehicleModel.getVehiclesByUserId(req.user.userId);
    res.json(vehicles);
  } catch (error) {
    console.error("Erro ao listar veículos:", error.message);
    res.status(500).json({ error: "Erro ao listar veículos" });
  }
}

async function getSelectedVehicle(req, res) {
  try {
    const vehicle = await vehicleModel.getSelectedVehicle(req.user.userId);
    res.json(vehicle || null);
  } catch (error) {
    console.error("Erro ao buscar veículo selecionado:", error.message);
    res.status(500).json({ error: "Erro ao buscar veículo selecionado" });
  }
}

async function createVehicle(req, res) {
  try {
    const { name, type, speed, capacity, weight } = req.body;

    if (
      !name ||
      !type ||
      speed === undefined ||
      capacity === undefined ||
      weight === undefined
    ) {
      return res.status(400).json({
        error: "Nome, tipo, velocidade, capacidade e peso são obrigatórios",
      });
    }

    const validTypes = ["moto", "carro", "caminhao"];
    if (!validTypes.includes(type.toLowerCase())) {
      return res.status(400).json({
        error: "Tipo inválido. Use: moto, carro ou caminhão",
      });
    }

    const vehicle = await vehicleModel.createVehicle({
      userId: req.user.userId,
      name,
      type: type.toLowerCase(),
      speed,
      capacity,
      weight,
    });

    res.status(201).json({
      message: "Veículo criado com sucesso",
      vehicle,
    });
  } catch (error) {
    console.error("Erro ao criar veículo:", error.message);
    res.status(500).json({ error: "Erro ao criar veículo" });
  }
}

async function getVehicle(req, res) {
  try {
    const { id } = req.params;
    const vehicle = await vehicleModel.findVehicleById(id);

    if (!vehicle) {
      return res.status(404).json({ error: "Veículo não encontrado" });
    }

    if (vehicle.user_id !== req.user.userId) {
      return res.status(403).json({ error: "Acesso negado" });
    }

    res.json(vehicle);
  } catch (error) {
    console.error("Erro ao buscar veículo:", error.message);
    res.status(500).json({ error: "Erro ao buscar veículo" });
  }
}

async function updateVehicle(req, res) {
  try {
    const { id } = req.params;
    const { name, type, speed, capacity, weight } = req.body;

    const existingVehicle = await vehicleModel.findVehicleById(id);

    if (!existingVehicle) {
      return res.status(404).json({ error: "Veículo não encontrado" });
    }

    if (existingVehicle.user_id !== req.user.userId) {
      return res.status(403).json({ error: "Acesso negado" });
    }

    const vehicle = await vehicleModel.updateVehicle(id, {
      name,
      type,
      speed,
      capacity,
      weight,
    });

    res.json({
      message: "Veículo atualizado com sucesso",
      vehicle,
    });
  } catch (error) {
    console.error("Erro ao atualizar veículo:", error.message);
    res.status(500).json({ error: "Erro ao atualizar veículo" });
  }
}

async function deleteVehicle(req, res) {
  try {
    const { id } = req.params;

    const existingVehicle = await vehicleModel.findVehicleById(id);

    if (!existingVehicle) {
      return res.status(404).json({ error: "Veículo não encontrado" });
    }

    if (existingVehicle.user_id !== req.user.userId) {
      return res.status(403).json({ error: "Acesso negado" });
    }

    await vehicleModel.deleteVehicle(id);

    res.json({ message: "Veículo deletado com sucesso" });
  } catch (error) {
    console.error("Erro ao deletar veículo:", error.message);
    res.status(500).json({ error: "Erro ao deletar veículo" });
  }
}

async function selectVehicle(req, res) {
  try {
    const { id } = req.params;

    const existingVehicle = await vehicleModel.findVehicleById(id);

    if (!existingVehicle) {
      return res.status(404).json({ error: "Veículo não encontrado" });
    }

    if (existingVehicle.user_id !== req.user.userId) {
      return res.status(403).json({ error: "Acesso negado" });
    }

    const vehicle = await vehicleModel.selectVehicle(req.user.userId, id);

    res.json({
      message: "Veículo selecionado com sucesso",
      vehicle,
    });
  } catch (error) {
    console.error("Erro ao selecionar veículo:", error.message);
    res.status(500).json({ error: "Erro ao selecionar veículo" });
  }
}

module.exports = {
  getVehicles,
  getSelectedVehicle,
  createVehicle,
  getVehicle,
  updateVehicle,
  deleteVehicle,
  selectVehicle,
};
