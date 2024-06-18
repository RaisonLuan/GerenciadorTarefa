import 'dart:math';

class Funcionario {
  final String id;
  final String nome;
  final String cargo;
  final bool emFerias;

  Funcionario({
    required this.id,
    required this.nome,
    required this.cargo,
    this.emFerias = false,
  });
}

class Setor {
  final String nome;

  Setor({required this.nome});
}

class GeradorValidade {
  final List<Funcionario> _funcionarios;
  final Random _random;

  GeradorValidade({required List<Funcionario> funcionarios})
      : _funcionarios = funcionarios,
        _random = Random();

  Map<String, List<String>> gerarSorteio() {
    // Map contendo setores por cargo
    Map<String, List<String>> setoresPorCargo = {
      'Atendente': List<String>.generate(10, (index) => 'Setor ${index + 1}'),
      'Balconista': [
        'A',
        'E',
        'P',
        'Genérico 1',
        'Genérico 2',
        'Estoque',
        'Balcão'
      ],
      'Farmacêutico': ['Antibiótico', 'Lista A/B', 'Lista C', 'Geladeira'],
    };

    // Resultado do sorteio
    Map<String, List<String>> sorteio = {};

    // Map para controle dos setores disponíveis
    Map<String, List<String>> setoresDisponiveis = {};
    setoresPorCargo.forEach((cargo, setores) {
      setoresDisponiveis[cargo] = List.from(
          setores); // Criar cópia dos setores para controle de disponibilidade
    });

    // Embaralhar os funcionários para garantir aleatoriedade
    _funcionarios.shuffle();

    // Inicializar sorteio para todos os funcionários válidos
    for (Funcionario funcionario in _funcionarios) {
      if (!funcionario.emFerias &&
          setoresPorCargo.containsKey(funcionario.cargo)) {
        sorteio[funcionario.nome] = [];
      }
    }

    // Atribuir setores de forma equilibrada
    for (String cargo in setoresPorCargo.keys) {
      List<Funcionario> funcionariosCargo = _funcionarios.where((f) =>
      f.cargo == cargo && !f.emFerias).toList();
      List<String> setoresDisponiveisParaCargo = setoresDisponiveis[cargo]!;
      int numFuncionarios = funcionariosCargo.length;
      int numSetores = setoresDisponiveisParaCargo.length;

      if (numFuncionarios == 0) continue;

      // Dividir funcionários entre os setores disponíveis
      int numRepeticoes = (numFuncionarios / numSetores).ceil();
      for (int i = 0; i < numRepeticoes; i++) {
        for (int j = 0; j < numSetores; j++) {
          int index = i * numSetores + j;
          if (index < numFuncionarios) {
            Funcionario funcionario = funcionariosCargo[index];
            sorteio[funcionario.nome]!.add(setoresDisponiveisParaCargo[j]);
          }
        }
      }
    }

    return sorteio;
  }


  void main() {
    List<Funcionario> funcionarios = [
      Funcionario(id: '1', nome: 'Alice', cargo: 'Atendente'),
      Funcionario(id: '2', nome: 'Bob', cargo: 'Atendente'),
      Funcionario(id: '3', nome: 'Charlie', cargo: 'Balconista'),
      Funcionario(
          id: '4', nome: 'David', cargo: 'Farmacêutico', emFerias: true),
      // Em férias
      Funcionario(id: '5', nome: 'Eve', cargo: 'Farmacêutico'),
    ];

    GeradorValidade gerador = GeradorValidade(funcionarios: funcionarios);
    Map<String, List<String>> sorteio = gerador.gerarSorteio();

    sorteio.forEach((nome, setores) {
      print('$nome: $setores');
    });
  }
}