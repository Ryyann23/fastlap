enum RoutePages {
  login('/login'),
  home('/home'),
  rotas('/rotas'),
  mapa('/mapa'),
  historico('/historico'),
  perfil('/perfil'),
  vehicles('/vehicles'),
  reports('/reports'),
  settings('/settings'),
  createRoute('/create-route');

  const RoutePages(this.path);

  final String path;
}
