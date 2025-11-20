import 'package:flutter/material.dart';
import 'package:g1_g2/components/custom_initial_layout.dart';
import 'package:g1_g2/components/custom_voltar_text_buttom.dart';
import 'package:g1_g2/src/repositories/auth_repository.dart'; // Mantido para signOut
import 'package:g1_g2/src/viewmodels/user/user_viewmodel.dart';
import 'package:g1_g2/src/views/auth/login_page.dart';
import 'package:g1_g2/src/views/user/home_user_page.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Seus controllers locais (mantidos como você os tem)
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _countryController;
  late TextEditingController _stateController;
  late TextEditingController _cityController;
  late TextEditingController _cpfController;

  bool _isEmailEditable = false;
  bool _isLoadingError = false; // Sinaliza se o initState falhou

  @override
  void initState() {
    super.initState();
    final vm = context.read<UserViewmodel>();

    // Inicializa os controllers para o primeiro build (vazios)
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _countryController = TextEditingController();
    _stateController = TextEditingController();
    _cityController = TextEditingController();
    _cpfController = TextEditingController();

    // Agenda o carregamento de dados para DEPOIS do primeiro build.
    // Esta lógica de carregamento é a que você pediu para manter.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      vm.loadCurrentUser().then((success) {
        if (success && mounted) {
          // Se carregar com sucesso, preenche o formulário
          _fillForm(vm);
          setState(() {}); // Força a reconstrução com os dados
        } else if (!success && mounted) {
          // Se falhar, marca erro e mostra SnackBar
          setState(() {
            _isLoadingError = true; // Define o erro de carregamento inicial
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                vm.errorMessage ?? 'Erro ao carregar dados do usuário.',
              ),
            ),
          );
          // Opcional: navegar para trás se o carregamento falhou criticamente
          // Navigator.pop(context);
        }
      });
    });
  }

  // Helper para preencher usando os Getters do VM (lógica mantida)
  void _fillForm(UserViewmodel vm) {
    _nameController.text = vm.currentUserName;
    _emailController.text = vm.currentUserEmail;
    _countryController.text = vm.currentUserCountry;
    _stateController.text = vm.currentUserState;
    _cityController.text = vm.currentUserCity;
    _cpfController.text = vm.currentUserCpf;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _cpfController.dispose();
    super.dispose();
  }

  // --- NOVO: _buildTextField com o estilo do EditCollectPointFormPage ---
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    TextInputType type, {
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Inclui o label acima do TextField, como no seu exemplo
          Text(
            '${label.split(' ')[0]}:', // Pega a primeira palavra do label para título (e-mail, nome, etc)
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: type,
            readOnly: readOnly,
            decoration: InputDecoration(
              hintText: label, // O hintText será o label completo
              filled: true,
              // Cores e bordas copiadas do seu EditCollectPointFormPage
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(width: 2, color: Color(0xff00A63E)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  style: BorderStyle.none,
                ), // Sem borda visível normalmente
              ),
              // Adiciona o ícone de "editar" para o campo de e-mail
              suffixIcon: label == 'E-mail'
                  ? IconButton(
                      icon: Icon(
                        _isEmailEditable ? Icons.clear : Icons.edit,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _isEmailEditable = !_isEmailEditable;
                        });
                      },
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  // --- NOVO: Build com o layout completo do EditCollectPointFormPage ---
  @override
  Widget build(BuildContext context) {
    final vm = context
        .watch<UserViewmodel>(); // 'watch' para reagir a mudanças no VM
    final vmRead = context.read<UserViewmodel>(); // 'read' para chamar métodos

    // Se houve erro no carregamento inicial (ex: usuário não logado)
    if (_isLoadingError) {
      return const Scaffold(
        body: Center(child: Text('Falha ao carregar perfil.')),
      );
    }

    // Se o ViewModel está carregando E os campos ainda não foram preenchidos
    if (vm.isLoading && _nameController.text.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // O Layout completo dentro de um Card, como no EditCollectPointFormPage
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(width: 24), // Espaço para alinhar o botão "Voltar"
                CustomVoltarTextButtom(pageToBack: HomeUserPage()),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Color(0x20000000)),
                  ),
                  shadowColor: Colors.transparent,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              'Editar Perfil', // Título centralizado
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),

                          // --- Seus Campos de Formulário com o novo estilo ---
                          _buildTextField(
                            _nameController,
                            'Nome Completo',
                            TextInputType.text,
                          ),
                          _buildTextField(
                            _emailController,
                            'E-mail',
                            TextInputType.emailAddress,
                            readOnly: !_isEmailEditable,
                          ),
                          _buildTextField(
                            _cpfController,
                            'CPF',
                            TextInputType.number,
                            readOnly: true,
                          ),
                          _buildTextField(
                            _countryController,
                            'País',
                            TextInputType.text,
                          ),
                          _buildTextField(
                            _stateController,
                            'Estado',
                            TextInputType.text,
                          ),
                          _buildTextField(
                            _cityController,
                            'Cidade',
                            TextInputType.text,
                          ),
                          SizedBox(height: 20),

                          // --- Botões com o estilo do EditCollectPointFormPage ---

                          // Botão "Sair da Conta" (estilo OutlinedButton, como "Cancelar")
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () async {
                                final localContext = context;
                                await vmRead
                                    .signOut(); // Chamada para o seu método signOut do VM
                                if (localContext.mounted) {
                                  Navigator.of(localContext).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                      builder: (_) => const LoginPage(),
                                    ),
                                    (route) => false,
                                  );
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                // Cores e estilo copiados do seu EditCollectPointFormPage
                                foregroundColor: Colors.red,
                                backgroundColor: Colors.white,
                                minimumSize: const Size(0, 50),
                                side: BorderSide(
                                  color: Colors
                                      .red
                                      .shade300, // Borda vermelha clara
                                  width: 1,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Sair da Conta',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.0),

                          // Botão "Salvar Alterações" (estilo ElevatedButton)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                // Cores e estilo copiados do seu EditCollectPointFormPage
                                backgroundColor: const Color(0xff00A63E),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: const Color(
                                  0xff00A63E,
                                ).withOpacity(0.7),
                                disabledForegroundColor: Colors.white,
                                minimumSize: const Size(0, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed:
                                  vm
                                      .isLoading // Desabilita se estiver carregando
                                  ? null
                                  : () async {
                                      final localContext = context;

                                      // Validação simples (seus campos não podem ser vazios)
                                      if (_nameController.text.trim().isEmpty ||
                                          _emailController.text
                                              .trim()
                                              .isEmpty ||
                                          _cpfController.text.trim().isEmpty) {
                                        ScaffoldMessenger.of(
                                          localContext,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Preencha todos os campos obrigatórios.',
                                            ),
                                            backgroundColor: Colors.orange,
                                          ),
                                        );
                                        return;
                                      }

                                      // Chamada para o seu método updateProfile do VM
                                      final success = await vmRead
                                          .updateProfile(
                                            name: _nameController.text.trim(),
                                            email: _emailController.text.trim(),
                                            country: _countryController.text
                                                .trim(),
                                            state: _stateController.text.trim(),
                                            city: _cityController.text.trim(),
                                            cpf: _cpfController.text.trim(),
                                          );

                                      if (!localContext.mounted) return;

                                      if (success) {
                                        ScaffoldMessenger.of(
                                          localContext,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Perfil atualizado com sucesso!',
                                            ),
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          localContext,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              vm.errorMessage ??
                                                  'Erro ao salvar alterações.',
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                              child: vm.isLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : const Text(
                                      'Salvar Alterações',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(height: 90),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
