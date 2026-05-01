const userModel = require("../models/userModel");

async function getUser(req, res) {
  try {
    const { id } = req.params;

    if (id !== req.user.userId) {
      return res.status(403).json({ error: "Acesso negado" });
    }

    const user = await userModel.findUserById(id);

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
    console.error("Erro ao buscar usuário:", error.message);
    res.status(500).json({ error: "Erro ao buscar usuário" });
  }
}

async function updateUser(req, res) {
  try {
    const { id } = req.params;

    if (id !== req.user.userId) {
      return res.status(403).json({ error: "Acesso negado" });
    }

    const { name, username, avatar_url } = req.body;

    const user = await userModel.updateUser(id, { name, username, avatar_url });

    if (!user) {
      return res.status(404).json({ error: "Usuário não encontrado" });
    }

    res.json({
      message: "Perfil atualizado com sucesso",
      user: {
        id: user.id,
        email: user.email,
        name: user.name,
        username: user.username,
        avatarUrl: user.avatar_url,
      },
    });
  } catch (error) {
    console.error("Erro ao atualizar usuário:", error.message);
    res.status(500).json({ error: "Erro ao atualizar perfil" });
  }
}

async function deleteUser(req, res) {
  try {
    const { id } = req.params;

    if (id !== req.user.userId) {
      return res.status(403).json({ error: "Acesso negado" });
    }

    const result = await userModel.deleteUser(id);

    if (!result) {
      return res.status(404).json({ error: "Usuário não encontrado" });
    }

    res.json({ message: "Conta deletada com sucesso" });
  } catch (error) {
    console.error("Erro ao deletar usuário:", error.message);
    res.status(500).json({ error: "Erro ao deletar conta" });
  }
}

async function changePassword(req, res) {
  try {
    const { id } = req.params;

    if (id !== req.user.userId) {
      return res.status(403).json({ error: "Acesso negado" });
    }

    const { currentPassword, newPassword } = req.body;

    if (!currentPassword || !newPassword) {
      return res
        .status(400)
        .json({ error: "Senha atual e nova senha são obrigatórias" });
    }

    const user = await userModel.findUserById(id);

    if (!user) {
      return res.status(404).json({ error: "Usuário não encontrado" });
    }

    const validPassword = await userModel.validatePassword(
      user,
      currentPassword,
    );

    if (!validPassword) {
      return res.status(401).json({ error: "Senha atual incorreta" });
    }

    await userModel.updatePassword(id, newPassword);

    res.json({ message: "Senha atualizada com sucesso" });
  } catch (error) {
    console.error("Erro ao alterar senha:", error.message);
    res.status(500).json({ error: "Erro ao alterar senha" });
  }
}

module.exports = {
  getUser,
  updateUser,
  deleteUser,
  changePassword,
};
