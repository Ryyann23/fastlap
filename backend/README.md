# FastLap Backend

API REST para o aplicativo FastLap - Organização e otimização de rotas de delivery.

## 🛠️ Tecnologias

- **Node.js** - Runtime JavaScript
- **Express** - Framework web
- **PostgreSQL** - Banco de dados relacional
- **JWT** - Autenticação por tokens
- **bcrypt** - Hash de senhas

## 📁 Estrutura de Arquivos (Padrão MVC)

```
backend/
├── src/
│   ├── config/
│   │   └── database.js        # Configuração do banco de dados
│   ├── controllers/
│   │   ├── authController.js    # Autenticação
│   │   ├── userController.js     # Usuários
│   │   ├── vehicleController.js # Veículos
│   │   ├── routeController.js   # Rotas
│   │   ├── poiController.js    # Pontos de Interesse
│   │   └── statsController.js  # Estatísticas
│   ├── database/
│   │   └── migrate.js         # Script de migração
│   ├── middleware/
│   │   └── authMiddleware.js  # Middleware JWT
│   ├── models/
│   │   ├── userModel.js       # Usuários
│   │   ├── vehicleModel.js   # Veículos
│   │   ├── routeModel.js     # Rotas
│   │   ├── poiModel.js     # POIs
│   │   └── deliveryModel.js # Entregas
│   └── server.js           # Servidor principal
├── package.json
├── .env
└── .env.example
```

## 🚀 Como Executar

### 1. Pré-requisitos

- Node.js (v14+)
- PostgreSQL (v12+)

### 2. Configurar banco de dados

1. Crie o banco de dados:
```sql
CREATE DATABASE fastlap;
```

2. Configure as variáveis de ambiente:
```bash
cp .env.example .env
# Edite o arquivo .env com suas configurações
```

### 3. Instalar dependências

```bash
cd backend
npm install
```

### 4. Executar migração

```bash
npm run migrate
```

### 5. Iniciar servidor

```bash
npm start
```

O servidor estará disponível em `http://localhost:3000`

## 🔐 Endpoints da API

### Autenticação

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| POST | /api/auth/register | Cadastrar usuário |
| POST | /api/auth/login | Login |
| POST | /api/auth/logout | Logout |
| POST | /api/auth/forgot-password | Recuperar senha |
| POST | /api/auth/refresh | Atualizar token |
| GET | /api/auth/me | Usuário atual |

### Usuários

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | /api/users/:id | Buscar usuário |
| PUT | /api/users/:id | Atualizar perfil |
| DELETE | /api/users/:id | Deletar conta |
| PUT | /api/users/:id/password | Alterar senha |

### Veículos

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | /api/vehicles | Listar veículos |
| POST | /api/vehicles | Criar veículo |
| GET | /api/vehicles/:id | Buscar veículo |
| PUT | /api/vehicles/:id | Atualizar veículo |
| DELETE | /api/vehicles/:id | Deletar veículo |
| PUT | /api/vehicles/:id/select | Selecionar veículo |
| GET | /api/vehicles/selected | Veículo selecionado |

### Rotas

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | /api/routes | Listar rotas |
| POST | /api/routes | Criar rota |
| GET | /api/routes/:id | Buscar rota |
| PUT | /api/routes/:id | Atualizar rota |
| DELETE | /api/routes/:id | Deletar rota |
| GET | /api/routes/history | Histórico de rotas |
| POST | /api/routes/:id/pois | Adicionar POI |
| DELETE | /api/routes/:id/pois/:poiId | Remover POI |

### POIs

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | /api/pois | Listar POIs |
| POST | /api/pois | Criar POI |
| GET | /api/pois/:id | Buscar POI |
| PUT | /api/pois/:id | Atualizar POI |
| DELETE | /api/pois/:id | Deletar POI |
| GET | /api/pois/nearby | POIs próximos |

### Estatísticas

| Método | Endpoint | Descrição |
|--------|----------|-----------|
| GET | /api/stats/deliveries | Estatísticas de entregas |
| GET | /api/stats/routes | Estatísticas de rotas |
| GET | /api/stats/history | Histórico de entregas |
| POST | /api/stats/deliveries | Registrar entrega |
| PUT | /api/stats/deliveries/:id | Atualizar status |

## 📝 Exemplos de Uso

### Cadastrar usuário

```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "usuario@exemplo.com",
    "password": "senha123",
    "name": "João Silva",
    "username": "joaos"
  }'
```

### Login

```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "usuario@exemplo.com",
    "password": "senha123"
  }'
```

### Criar veículo

```bash
curl -X POST http://localhost:3000/api/vehicles \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SEU_ACCESS_TOKEN" \
  -d '{
    "name": "Moto de Trabalho",
    "type": "moto",
    "speed": 80,
    "capacity": 50,
    "weight": 150
  }'
```

### Criar rota

```bash
curl -X POST http://localhost:3000/api/routes \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer SEU_ACCESS_TOKEN" \
  -d '{
    "name": "Rota Centro",
    "vehicleId": "uuid-do-veiculo",
    "startAddress": "Rua A, 123",
    "endAddress": "Rua B, 456",
    "distance": 15.5,
    "estimatedTime": 30,
    "startLat": -23.5505,
    "startLng": -46.6333,
    "endLat": -23.5611,
    "endLng": -46.6562
  }'
```

## 🔒 Autenticação

A API usa JWT para autenticação. Após o login, você receberá:
- `accessToken` - Token de acesso (expira em 15 minutos)
- `refreshToken` - Token de refresh (expira em 7 dias)

Para acessar rotas protegidas, inclua o token no cabeçalho:

```
Authorization: Bearer SEU_ACCESS_TOKEN
```

## 📊 Banco de Dados

### Tabelas

- **users** - Usuários cadastrados
- **vehicles** - Veículos dos usuários
- **routes** - Rotas de entrega
- **pois** - Pontos de interesse
- **route_pois** - Relação entre rotas e POIs
- **delivery_history** - Histórico de entregas

### Índices

Para melhor performance, são criados índices em:
- `vehicles.user_id`
- `routes.user_id`
- `pois.user_id`
- `delivery_history.user_id`

## 🐳 Deploy com Docker

```dockerfile
FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 3000

CMD ["npm", "start"]
```

```bash
# Criar imagem
docker build -t fastlap-backend .

# Executar container
docker run -d -p 3000:3000 --env-file .env fastlap-backend
```

## 📄 Licença

ISC
