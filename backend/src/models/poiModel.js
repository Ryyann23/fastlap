const { query } = require("../config/database");

async function createPoi({
  userId,
  name,
  category,
  address,
  latitude,
  longitude,
  notes,
}) {
  const result = await query(
    `INSERT INTO pois (user_id, name, category, address, latitude, longitude, notes) 
     VALUES ($1, $2, $3, $4, $5, $6, $7) 
     RETURNING *`,
    [userId, name, category, address, latitude, longitude, notes],
  );

  return result.rows[0];
}

async function getPoisByUserId(userId) {
  const result = await query(
    "SELECT * FROM pois WHERE user_id = $1 ORDER BY created_at DESC",
    [userId],
  );

  return result.rows;
}


async function getPoisByCategory(userId, category) {
  const result = await query(
    "SELECT * FROM pois WHERE user_id = $1 AND category = $2 ORDER BY name",
    [userId, category],
  );

  return result.rows;
}

async function findPoiById(id) {
  const result = await query("SELECT * FROM pois WHERE id = $1", [id]);

  return result.rows[0];
}

async function updatePoi(
  id,
  { name, category, address, latitude, longitude, notes },
) {
  const result = await query(
    `UPDATE pois 
     SET name = COALESCE($2, name),
         category = COALESCE($3, category),
         address = COALESCE($4, address),
         latitude = COALESCE($5, latitude),
         longitude = COALESCE($6, longitude),
         notes = COALESCE($7, notes),
         updated_at = NOW()
     WHERE id = $1 
     RETURNING *`,
    [id, name, category, address, latitude, longitude, notes],
  );

  return result.rows[0];
}

async function deletePoi(id) {
  const result = await query("DELETE FROM pois WHERE id = $1 RETURNING id", [
    id,
  ]);

  return result.rows[0];
}

async function getNearbyPois(userId, latitude, longitude, radiusKm = 5) {
  const result = await query(
    `SELECT *, 
            (6371 * acos(cos(radians($3)) * cos(radians(latitude)) * cos(radians(longitude) - radians($2)) + sin(radians($3)) * sin(radians(latitude)))) AS distance 
     FROM pois 
     WHERE user_id = $1 
     AND (6371 * acos(cos(radians($3)) * cos(radians(latitude)) * cos(radians(longitude) - radians($2)) + sin(radians($3)) * sin(radians(latitude)))) <= $4
     ORDER BY distance`,
    [userId, longitude, latitude, radiusKm],
  );

  return result.rows;
}

module.exports = {
  createPoi,
  getPoisByUserId,
  getPoisByCategory,
  findPoiById,
  updatePoi,
  deletePoi,
  getNearbyPois,
};
