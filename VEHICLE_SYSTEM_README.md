# 🚗 Sistema de Veículos - FastLap

## Visão Geral

O sistema de veículos foi implementado para permitir que os usuários registrem seus veículos (motos, carros, caminhões) e utilizem essas informações para calcular o tempo estimado de uma rota.

## 📋 O que foi criado

### 1. **Modelo de Veículo** (`vehicle_model.dart`)
- Tipos de veículo: Moto 🏍️, Carro 🚗, Caminhão 🚚
- Propriedades: nome, velocidade (km/h), capacidade de carga (kg), peso (kg)
- Métodos úteis:
  - `calculateTravelTimeMinutes(distanceKm)` - calcula tempo de viagem
  - `calculateRequiredLoads(weightNeeded)` - calcula quantas cargas são necessárias

### 2. **Serviço de Veículos** (`vehicle_service.dart`)
Gerencia:
- ✅ Criar novo veículo
- ✏️ Editar veículo
- 🗑️ Deletar veículo
- ⭐ Selecionar/desselecionar veículo
- 📝 Listar todos os veículos

### 3. **Página de Veículos** (`vehicles_page.dart`)
Interface completa com:
- Lista de veículos cadastrados
- Botão para criar novo veículo
- Editar veículos existentes
- Deletar veículos
- Selecionar um veículo (como escolher um personagem em um jogo)

### 4. **Serviço de Cálculo de Rotas** (`route_calculator_service.dart`)
Calcula informações de rota com base no veículo selecionado:
- Tempo estimado de viagem
- Capacidade de carga necessária
- Formatação de tempo (ex: 1h 30m)

### 5. **Widget de Informação de Rota** (`route_vehicle_info.dart`)
Widget reutilizável que mostra:
- Veículo selecionado
- Distância da rota
- Tempo estimado
- Velocidade do veículo

## 🎮 Como Usar

### Acessar Página de Veículos
1. Na home page, clique no botão "Veiculo" (ou qualquer outro quick action)
2. Você será levado à página de gerenciamento de veículos

### Criar um Novo Veículo
1. Clique em "NOVO VEÍCULO"
2. Preencha os dados:
   - **Nome**: Ex: "Moto de Trabalho"
   - **Tipo**: Selecione entre Moto, Carro ou Caminhão
   - **Velocidade**: Em km/h (ex: 80)
   - **Capacidade de Carga**: Em kg (ex: 50)
   - **Peso**: Em kg (ex: 150)
3. Clique em "Criar"

### Selecionar um Veículo
1. Na lista de veículos, clique em "SELECIONAR"
2. O veículo será destacado com uma borda colorida
3. Ao voltar para a home, o veículo permanece selecionado

### Editar um Veículo
1. Clique no ícone ✏️ no veículo
2. Modifique os dados desejados
3. Clique em "Salvar"

### Deletar um Veículo
1. Clique no ícone 🗑️ no veículo
2. Confirme a exclusão

## 📊 Exemplo de Cálculo

Se você tem:
- **Rota**: 30 km
- **Veículo**: Moto a 100 km/h

O tempo estimado será:
```
Tempo = (30 km / 100 km/h) × 60 min = 18 minutos
```

## 🔧 Integração com Rotas

Para usar informações do veículo selecionado na página de rotas:

```dart
import 'package:fastlap/shared/widgets/route_vehicle_info.dart';

// Na sua página de rota, adicione:
RouteVehicleInfo(
  route: myRoute,
  scale: scale,
)
```

## 📱 Veículos Padrão

O app começa com 2 veículos padrão:
- **Moto Padrão**: 80 km/h, 50 kg capacidade
- **Carro Padrão**: 100 km/h, 500 kg capacidade

## 🎯 Design Pattern

O sistema segue o padrão "Seleção de Personagem":
- Como em um RPG, você seleciona um veículo
- Cada veículo tem características únicas
- O veículo selecionado afeta como você "joga" (realiza entregas)

## 📦 Dependências Adicionadas

- `uuid: ^4.0.0` - Para gerar IDs únicos dos veículos

## 🎨 Características de Design

- ✅ Tema escuro e claro suportados
- ✅ Responsivo (escala automática)
- ✅ Ícones emoji representativos
- ✅ Gradiente de cor consistente com o app
- ✅ Animações suaves
