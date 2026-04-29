// Este arquivo demonstra como usar o sistema de veículos no projeto FastLap

// ============================================================================
// 1. SELECIONANDO E GERENCIANDO VEÍCULOS
// ============================================================================
// 
// A página de veículos pode ser acessada através do botão "Veiculo" na home page.
// 
// Para acessar o serviço de veículos em qualquer lugar do app:
//
// import 'package:fastlap/shared/data/vehicle_service.dart';
//
// final vehicleService = VehicleService();
// 
// // Selecionar um veículo
// vehicleService.selectVehicle(vehicle);
//
// // Obter o veículo selecionado
// final selectedVehicle = vehicleService.selectedVehicle;
//
// // Criar um novo veículo
// final newVehicle = Vehicle(
//   id: const Uuid().v4(),
//   name: 'Moto Rápida',
//   type: VehicleType.moto,
//   speedPerKm: 100.0,
//   carryCapacity: 50.0,
//   weight: 150.0,
// );
// vehicleService.addVehicle(newVehicle);

// ============================================================================
// 2. CALCULANDO TEMPO DE ROTA COM VEÍCULO
// ============================================================================
//
// Para calcular quanto tempo uma rota levará com o veículo selecionado:
//
// import 'package:fastlap/shared/data/route_calculator_service.dart';
//
// final calculatorService = RouteCalculatorService();
// final travelTimeMinutes = calculatorService.calculateRouteTravelTimeMinutes(route);
// final formattedTime = calculatorService.formatTravelTime(travelTimeMinutes!);
//
// Exemplo: Se a rota tem 30km e o veículo vai a 100 km/h:
// - Tempo = (30 / 100) * 60 = 18 minutos

// ============================================================================
// 3. USANDO O WIDGET DE INFORMAÇÃO DE ROTA COM VEÍCULO
// ============================================================================
//
// Para mostrar o tempo estimado de uma rota com o veículo selecionado:
//
// import 'package:fastlap/shared/widgets/route_vehicle_info.dart';
//
// RouteVehicleInfo(
//   route: myRoute,
//   scale: scale,
// )
//
// Este widget mostra:
// - Nome do veículo selecionado
// - Distância da rota
// - Tempo estimado
// - Velocidade do veículo

// ============================================================================
// 4. PROPRIEDADES DO VEÍCULO
// ============================================================================
//
// Cada veículo tem as seguintes propriedades:
//
// - id: Identificador único (UUID)
// - name: Nome do veículo (ex: "Moto Padrão")
// - type: Tipo (moto, carro, caminhão)
// - speedPerKm: Velocidade em km/h
// - carryCapacity: Capacidade de carga em kg
// - weight: Peso do veículo em kg
// - isSelected: Booleano indicando se está selecionado
//
// Métodos úteis:
// - calculateTravelTimeMinutes(distanceKm): Calcula tempo de viagem
// - calculateRequiredLoads(weightNeeded): Calcula quantas cargas são necessárias

// ============================================================================
// 5. TIPOS DE VEÍCULOS DISPONÍVEIS
// ============================================================================
//
// enum VehicleType { moto, carro, caminhao }
//
// Cada tipo tem características diferentes que afetam:
// - Velocidade máxima
// - Capacidade de carga
// - Peso do veículo
// - Emojis representativos (🏍️ 🚗 🚚)

// ============================================================================
// 6. ADICIONANDO VEÍCULOS PADRÃO
// ============================================================================
//
// Ao iniciar o app, há 2 veículos padrão:
// - Moto Padrão: 80 km/h, 50 kg de capacidade
// - Carro Padrão: 100 km/h, 500 kg de capacidade
//
// O usuário pode adicionar, editar ou remover veículos conforme necessário.

// ============================================================================
// 7. INTEGRAÇÃO COM ROTAS
// ============================================================================
//
// Quando o usuário cria uma nova rota, pode:
// 1. Selecionar um veículo na página de veículos
// 2. Ver o tempo estimado de viagem na rota
// 3. Usar isso para planejar melhor suas entregas
//
// O sistema é como selecionar um personagem em um jogo RPG:
// Cada veículo tem suas características que afetam como você joga/trabalha.
