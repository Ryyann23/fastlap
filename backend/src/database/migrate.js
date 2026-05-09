const { pool, query } = require("../config/database");

async function migrate() {
  console.log("Iniciando migração do banco de dados\n");

  try {
    await query(`
      CREATE TABLE IF NOT EXISTS users (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        email VARCHAR(255) UNIQUE NOT NULL,
        password_hash VARCHAR(255) NOT NULL,
        name VARCHAR(100) NOT NULL,
        username VARCHAR(50),
        avatar_url VARCHAR(500),
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      );
    `);
    console.log("Tabela users criada");

    await query(`
      CREATE TABLE IF NOT EXISTS vehicles (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        name VARCHAR(100) NOT NULL,
        type VARCHAR(20) NOT NULL CHECK (type IN ('moto', 'carro', 'caminhao')),
        speed FLOAT NOT NULL,
        capacity FLOAT NOT NULL,
        weight FLOAT NOT NULL,
        is_selected BOOLEAN DEFAULT false,
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      );
    `);
    console.log("Tabela vehicles criada");

    await query(`
      CREATE TABLE IF NOT EXISTS routes (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        vehicle_id UUID REFERENCES vehicles(id) ON DELETE SET NULL,
        name VARCHAR(200) NOT NULL,
        start_address VARCHAR(500) NOT NULL,
        end_address VARCHAR(500) NOT NULL,
        distance FLOAT NOT NULL,
        estimated_time INTEGER NOT NULL,
        start_lat FLOAT,
        start_lng FLOAT,
        end_lat FLOAT,
        end_lng FLOAT,
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      );
    `);
    console.log("Tabela routes criada");

    await query(`
      CREATE TABLE IF NOT EXISTS pois (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        name VARCHAR(200) NOT NULL,
        category VARCHAR(50) NOT NULL,
        address VARCHAR(500),
        latitude FLOAT,
        longitude FLOAT,
        notes TEXT,
        created_at TIMESTAMP DEFAULT NOW(),
        updated_at TIMESTAMP DEFAULT NOW()
      );
    `);
    console.log("Tabela pois criada");

    await query(`
      CREATE TABLE IF NOT EXISTS route_pois (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        route_id UUID REFERENCES routes(id) ON DELETE CASCADE,
        poi_id UUID REFERENCES pois(id) ON DELETE CASCADE,
        order_index INTEGER DEFAULT 0,
        UNIQUE(route_id, poi_id)
      );
    `);
    console.log("Tabela route_pois criada");

    await query(`
      CREATE TABLE IF NOT EXISTS delivery_history (
        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
        user_id UUID REFERENCES users(id) ON DELETE CASCADE,
        route_id UUID REFERENCES routes(id) ON DELETE SET NULL,
        status VARCHAR(20) DEFAULT 'in_progress' CHECK (status IN ('in_progress', 'completed', 'cancelled')),
        distance FLOAT,
        duration INTEGER,
        completed_at TIMESTAMP,
        created_at TIMESTAMP DEFAULT NOW()
      );
    `);
    console.log("Tabela delivery_history criada");

    await query(
      `CREATE INDEX IF NOT EXISTS idx_vehicles_user_id ON vehicles(user_id);`,
    );
    await query(
      `CREATE INDEX IF NOT EXISTS idx_routes_user_id ON routes(user_id);`,
    );
    await query(
      `CREATE INDEX IF NOT EXISTS idx_pois_user_id ON pois(user_id);`,
    );
    await query(
      `CREATE INDEX IF NOT EXISTS idx_delivery_history_user_id ON delivery_history(user_id);`,
    );
    console.log("✓ Índices criados");

    console.log("\nMigração concluída com sucesso!\n");
    process.exit(0);
  } catch (error) {
    console.error("\nErro na migração:", error.message);
    process.exit(1);
  }
}

migrate();
