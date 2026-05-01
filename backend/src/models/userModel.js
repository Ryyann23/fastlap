const { query } = require("../config/database");
const bcrypt = require("bcrypt");

async function createUser({ email, password, name, username }) {
  const passwordHash = await bcrypt.hash(password, 10);

  const result = await query(
    `INSERT INTO users (email, password_hash, name, username) 
     VALUES ($1, $2, $3, $4) 
     RETURNING id, email, name, username, avatar_url, created_at`,
    [email, passwordHash, name, username],
  );

  return result.rows[0];
}

async function findUserByEmail(email) {
  const result = await query("SELECT * FROM users WHERE email = $1", [email]);

  return result.rows[0];
}

async function findUserById(id) {
  const result = await query(
    "SELECT id, email, name, username, avatar_url, created_at, updated_at FROM users WHERE id = $1",
    [id],
  );

  return result.rows[0];
}

async function updateUser(id, { name, username, avatar_url }) {
  const result = await query(
    `UPDATE users 
     SET name = COALESCE($2, name), 
         username = COALESCE($3, username), 
         avatar_url = COALESCE($4, avatar_url),
         updated_at = NOW()
     WHERE id = $1 
     RETURNING id, email, name, username, avatar_url, updated_at`,
    [id, name, username, avatar_url],
  );

  return result.rows[0];
}

async function updatePassword(id, newPassword) {
  const passwordHash = await bcrypt.hash(newPassword, 10);

  const result = await query(
    `UPDATE users SET password_hash = $2, updated_at = NOW() WHERE id = $1 RETURNING id`,
    [id, passwordHash],
  );

  return result.rows[0];
}

async function deleteUser(id) {
  const result = await query("DELETE FROM users WHERE id = $1 RETURNING id", [
    id,
  ]);

  return result.rows[0];
}

async function validatePassword(user, password) {
  return bcrypt.compare(password, user.password_hash);
}

module.exports = {
  createUser,
  findUserByEmail,
  findUserById,
  updateUser,
  updatePassword,
  deleteUser,
  validatePassword,
};
