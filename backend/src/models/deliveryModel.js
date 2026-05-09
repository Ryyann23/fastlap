const { query } = require("../config/database");

async function createDelivery({
  userId,
  routeId,
  status = "in_progress",
  distance,
  duration,
}) {
  const result = await query(
    `INSERT INTO delivery_history (user_id, route_id, status, distance, duration) 
     VALUES ($1, $2, $3, $4, $5) 
     RETURNING *`,
    [userId, routeId, status, distance, duration],
  );

  return result.rows[0];
}

async function getDeliveryHistory(userId, limit = 50) {
  const result = await query(
    `SELECT dh.*, r.name as route_name, r.start_address, r.end_address, v.name as vehicle_name
     FROM delivery_history dh
     LEFT JOIN routes r ON dh.route_id = r.id
     LEFT JOIN vehicles v ON r.vehicle_id = v.id
     WHERE dh.user_id = $1
     ORDER BY dh.completed_at DESC
     LIMIT $2`,
    [userId, limit],
  );

  return result.rows;
}

async function updateDeliveryStatus(id, status) {
  const completedAt =
    status === "completed" || status === "cancelled" ? "NOW()" : "NULL";

  const result = await query(
    `UPDATE delivery_history 
     SET status = $2, 
         completed_at = ${completedAt}
     WHERE id = $1 
     RETURNING *`,
    [id, status],
  );

  return result.rows[0];
}

async function getUserStats(userId) {
  // Total de entregas
  const totalResult = await query(
    `SELECT 
      COUNT(*) as total_deliveries,
      SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed_deliveries,
      SUM(CASE WHEN status = 'cancelled' THEN 1 ELSE 0 END) as cancelled_deliveries,
      SUM(distance) as total_distance,
      AVG(duration) as avg_duration
     FROM delivery_history 
     WHERE user_id = $1`,
    [userId],
  );

  const byDayResult = await query(
    `SELECT 
      TO_CHAR(completed_at, 'Day') as day,
      COUNT(*) as count
     FROM delivery_history 
     WHERE user_id = $1 AND status = 'completed' AND completed_at IS NOT NULL
     GROUP BY TO_CHAR(completed_at, 'Day')
     ORDER BY count DESC`,
    [userId],
  );

  const byHourResult = await query(
    `SELECT 
      EXTRACT(HOUR FROM completed_at) as hour,
      COUNT(*) as count
     FROM delivery_history 
     WHERE user_id = $1 AND status = 'completed' AND completed_at IS NOT NULL
     GROUP BY EXTRACT(HOUR FROM completed_at)
     ORDER BY count DESC`,
    [userId],
  );

  return {
    summary: totalResult.rows[0],
    byDay: byDayResult.rows,
    byHour: byHourResult.rows,
  };
}

async function getRouteStats(userId) {
  const result = await query(
    `SELECT 
      COUNT(*) as total_routes,
      AVG(distance) as avg_distance,
      AVG(estimated_time) as avg_estimated_time,
      SUM(distance) as total_distance
     FROM routes 
     WHERE user_id = $1`,
    [userId],
  );

  return result.rows[0];
}

module.exports = {
  createDelivery,
  getDeliveryHistory,
  updateDeliveryStatus,
  getUserStats,
  getRouteStats,
};
