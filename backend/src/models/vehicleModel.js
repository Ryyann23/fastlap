const { query } = require("../config/database");

async function createVehicle({ userId, name, type, speed, capacity, weight }) {
  const result = await query(
    `INSERT INTO vehicles (user_id, name, type, speed, capacity, weight, is_selected) 
     VALUES ($1, $2, $3, $4, $5, $6, false) 
     RETURNING *`,
    [userId, name, type, speed, capacity, weight],
  );

  return result.rows[0];
}

async function getVehiclesByUserId(userId) {
  const result = await query(
    "SELECT * FROM vehicles WHERE user_id = $1 ORDER BY created_at DESC",
    [userId],
  );

  return result.rows;
}

async function findVehicleById(id) {
  const result = await query("SELECT * FROM vehicles WHERE id = $1", [id]);

  return result.rows[0];
}

async function updateVehicle(id, { name, type, speed, capacity, weight }) {
  const result = await query(
    `UPDATE vehicles 
     SET name = COALESCE($2, name), 
         type = COALESCE($3, type), 
         speed = COALESCE($4, speed),
         capacity = COALESCE($5, capacity),
         weight = COALESCE($6, weight),
         updated_at = NOW()
     WHERE id = $1 
     RETURNING *`,
    [id, name, type, speed, capacity, weight],
  );

  return result.rows[0];
}

async function deleteVehicle(id) {
  const result = await query(
    "DELETE FROM vehicles WHERE id = $1 RETURNING id",
    [id],
  );

  return result.rows[0];
}

async function selectVehicle(userId, vehicleId) {
  await query("UPDATE vehicles SET is_selected = false WHERE user_id = $1", [
    userId,
  ]);

  const result = await query(
    "UPDATE vehicles SET is_selected = true WHERE id = $1 AND user_id = $2 RETURNING *",
    [vehicleId, userId],
  );

  return result.rows[0];
}

async function getSelectedVehicle(userId) {
  const result = await query(
    "SELECT * FROM vehicles WHERE user_id = $1 AND is_selected = true",
    [userId],
  );

  return result.rows[0];
}

module.exports = {
  createVehicle,
  getVehiclesByUserId,
  findVehicleById,
  updateVehicle,
  deleteVehicle,
  selectVehicle,
  getSelectedVehicle,
};
