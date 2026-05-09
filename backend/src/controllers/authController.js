const userModel = require("../models/userModel");
const {
  generateAccessToken,
  generateRefreshToken,
  verifyRefreshToken,
} = require("../middleware/authMiddleware");

async function register(req, res) {
  try {
    const { email, password, name, username } = req.body;

    if (!email || !password || !name) {
      return res
        .status(400)
        .json({ error: "Email, senha e nome são obrigatórios" });
    }

    const existingUser = await userModel.findUserByEmail(email);
    if (existingUser) {
      return res.status(400).json({ error: "Email já cadastrado" });
    }

    const user = await userModel.createUser({
      email,
      password,
      name,
      username,
    });

    const accessToken = generateAccessToken(user.id);
    const refreshToken = generateRefreshToken(user.id);

    res.status(201).json({
      message: "Usuário cadastrado com sucesso",
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        username: user.username,
      },
      accessToken,
      refreshToken,
    });
  } catch (error) {
    console.error("Erro no register:", error.message);
    res.status(500).json({ error: "Erro ao cadastrar usuário" });
  }
}

async function login(req, res) {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: "Email e senha são obrigatórios" });
    }

    const user = await userModel.findUserByEmail(email);
    if (!user) {
      return res.status(401).json({ error: "Email ou senha incorretos" });
    }

    const validPassword = await userModel.validatePassword(user, password);
    if (!validPassword) {
      return res.status(401).json({ error: "Email ou senha incorretos" });
    }

    const accessToken = generateAccessToken(user.id);
    const refreshToken = generateRefreshToken(user.id);

    res.json({
      message: "Login realizado com sucesso",
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        username: user.username,
        avatarUrl: user.avatar_url,
      },
      accessToken,
      refreshToken,
    });
  } catch (error) {
    console.error("Erro no login:", error.message);
    res.status(500).json({ error: "Erro ao fazer login" });
  }
}

async function logout(req, res) {
  res.json({ message: "Logout realizado com sucesso" });
}

async function forgotPassword(req, res) {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ error: "Email é obrigatório" });
    }

    const user = await userModel.findUserByEmail(email);
    if (!user) {
      return res.json({
        message: "Se o email existir, um link de recuperação será enviado",
      });
    }

    res.json({
      message: "Se o email existir, um link de recuperação será enviado",
    });
  } catch (error) {
    console.error("Erro no forgotPassword:", error.message);
    res.status(500).json({ error: "Erro ao processar solicitação" });
  }
}

async function refreshToken(req, res) {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(400).json({ error: "Refresh token é obrigatório" });
    }

    const user = await verifyRefreshToken(refreshToken);

    const newAccessToken = generateAccessToken(user.userId);
    const newRefreshToken = generateRefreshToken(user.userId);

    res.json({
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    });
  } catch (error) {
    console.error("Erro no refreshToken:", error.message);
    res.status(403).json({ error: "Refresh token inválido ou expirado" });
  }
}

async function getMe(req, res) {
  try {
    const user = await userModel.findUserById(req.user.userId);

    if (!user) {
      return res.status(404).json({ error: "Usuário não encontrado" });
    }

    res.json({
      id: user.id,
      email: user.email,
      name: user.name,
      username: user.username,
      avatarUrl: user.avatar_url,
      createdAt: user.created_at,
    });
  } catch (error) {
    console.error("Erro no getMe:", error.message);
    res.status(500).json({ error: "Erro ao buscar usuário" });
  }
}

module.exports = {
  register,
  login,
  logout,
  forgotPassword,
  refreshToken,
  getMe,
};
