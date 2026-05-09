const { query } = require("../config/database");

async function createRoute({
  userId,
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
}) {
  const result = await query(
    `INSERT INTO routes (user_id, vehicle_id, name, start_address, end_address, distance, estimated_time, start_lat, start_lng, end_lat, end_lng) 
     VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11) 
     RETURNING *`,
    [
      userId,
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
    ],
  );

  return result.rows[0];
}

async function getRoutesByUserId(userId) {
  const result = await query(
    `SELECT r.*, v.name as vehicle_name, v.type as vehicle_type 
     FROM routes r 
     LEFT JOIN vehicles v ON r.vehicle_id = v.id 
     WHERE r.user_id = $1 
     ORDER BY r.created_at DESC`,
    [userId],
  );

  return result.rows;
}

async function findRouteById(id) {
  const result = await query(
    `SELECT r.*, v.name as vehicle_name, v.type as vehicle_type 
     FROM routes r 
     LEFT JOIN vehicles v ON r.vehicle_id = v.id 
     WHERE r.id = $1`,
    [id],
  );

  return result.rows[0];
}

async function updateRoute(
  id,
  {
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
  },
) {
  const result = await query(
    `UPDATE routes 
     SET name = COALESCE($2, name),
         vehicle_id = COALESCE($3, vehicle_id),
         start_address = COALESCE($4, start_address), 
         end_address = COALESCE($5, end_address),
         distance = COALESCE($6, distance),
         estimated_time = COALESCE($7, estimated_time),
         start_lat = COALESCE($8, start_lat),
         start_lng = COALESCE($9, start_lng),
         end_lat = COALESCE($10, end_lat),
         end_lng = COALESCE($11, end_lng),
         updated_at = NOW()
     WHERE id = $1 
     RETURNING *`,
    [
      id,
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
    ],
  );

  return result.rows[0];
}

async function deleteRoute(id) {
  const result = await query("DELETE FROM routes WHERE id = $1 RETURNING id", [
    id,
  ]);

  return result.rows[0];
}

async function getRouteHistory(userId, limit = 20) {
  const result = await query(
    `SELECT r.*, v.name as vehicle_name 
     FROM routes r 
     LEFT JOIN vehicles v ON r.vehicle_id = v.id 
     WHERE r.user_id = $1 
     ORDER BY r.created_at DESC 
     LIMIT $2`,
    [userId, limit],
  );

  return result.rows;
}

async function addPoiToRoute(routeId, poiId, orderIndex) {
  const result = await query(
    `INSERT INTO route_pois (route_id, poi_id, order_index) 
     VALUES ($1, $2, $3) 
     RETURNING *`,
    [routeId, poiId, orderIndex],
  );

  return result.rows[0];
}

async function removePoiFromRoute(routeId, poiId) {
  const result = await query(
    "DELETE FROM route_pois WHERE route_id = $1 AND poi_id = $2 RETURNING id",
    [routeId, poiId],
  );

  return result.rows[0];
}

async function getRoutePois(routeId) {
  const result = await query(
    `SELECT p.*, rp.order_index 
     FROM route_pois rp 
     JOIN pois p ON rp.poi_id = p.id 
     WHERE rp.route_id = $1 
     ORDER BY rp.order_index`,
    [routeId],
  );

  return result.rows;
}

module.exports = {
  createRoute,
  getRoutesByUserId,
  findRouteById,
  updateRoute,
  deleteRoute,
  getRouteHistory,
  addPoiToRoute,
  removePoiFromRoute,
  getRoutePois,
};
