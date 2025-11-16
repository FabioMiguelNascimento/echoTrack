import 'package:flutter/material.dart';
import 'package:g1_g2/components/custom_initial_layout.dart';
import 'package:g1_g2/components/custom_voltar_text_buttom.dart';
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
  // Seus controllers locais
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final countryController = TextEditingController();
  final stateController = TextEditingController();
  final cityController = TextEditingController();
  final cpfController = TextEditingController();

  bool _isEmailEditable = false;

  @override
  void initState() {
    super.initState();
    final vm = context.read<UserViewmodel>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      
      // 1. Manda o VM carregar os dados
      vm.loadCurrentUser().then((_) {
        // 2. DEPOIS que carregar, preenche o formulário
        // (Verifica se a tela ainda existe)
        if (mounted) {
          _fillForm(vm);
        }
      });
      
    });
  }

  // Preenche o formulário usando os Getters seguros do VM
  void _fillForm(UserViewmodel vm) {
    nameController.text = vm.currentUserName;
    emailController.text = vm.currentUserEmail;
    countryController.text = vm.currentUserCountry;
    stateController.text = vm.currentUserState;
    cityController.text = vm.currentUserCity;
    cpfController.text = vm.currentUserCpf;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    countryController.dispose();
    stateController.dispose();
    cityController.dispose();
    cpfController.dispose();
    super.dispose();
  }

  // (O _buildTextField pode ser o mesmo da resposta anterior)
  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isReadOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            readOnly: isReadOnly,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
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

  // Card de Informações
  Widget _buildInfoCard(UserViewmodel vm, UserViewmodel vmRead) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações Pessoais',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Atualize seus dados cadastrais',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            _buildTextField('Nome Completo', nameController),
            _buildTextField(
              'E-mail',
              emailController,
              isReadOnly: !_isEmailEditable,
            ),
            _buildTextField('CPF', cpfController),
            _buildTextField('País', countryController),
            _buildTextField('Estado', stateController),
            _buildTextField('Cidade', cityController),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      _fillForm(vm); // Reseta para os dados do VM
                    },
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: vm.isLoading
                        ? const SizedBox.shrink()
                        : const Icon(Icons.save, size: 20),
                    label: vm.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Salvar Alterações'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00A63E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: vm.isLoading
                        ? null
                        : () async {
                            final localContext = context;

                            // Chama o método 'updateProfile' do SEU VM
                            final success = await vmRead.updateProfile(
                              name: nameController.text.trim(),
                              email: emailController.text.trim(),
                              country: countryController.text.trim(),
                              state: stateController.text.trim(),
                              city: cityController.text.trim(),
                              cpf: cpfController.text.trim(),
                            );

                            if (!localContext.mounted) return;

                            if (success) {
                              ScaffoldMessenger.of(localContext).showSnackBar(
                                const SnackBar(
                                  content: Text('Perfil atualizado!'),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(localContext).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    vm.errorMessage ?? 'Erro ao salvar',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Card de Ações
  Widget _buildActionsCard(UserViewmodel vmRead) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Ações da Conta',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () {
                /* TODO: Alterar senha */
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Alterar Senha'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.logout, size: 20),
              label: const Text('Sair da Conta'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626), // Vermelho
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final localContext = context;
                // Chama o signOut do SEU VM
                await vmRead.signOut();

                if (localContext.mounted) {
                  Navigator.of(localContext).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 'watch' redesenha a tela quando 'notifyListeners' é chamado
    final vm = context.watch<UserViewmodel>();
    final vmRead = context.read<UserViewmodel>();

    return CustomInitialLayout(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          children: [
            Row(children: [CustomVoltarTextButtom(pageToBack: HomeUserPage())]),
            const SizedBox(height: 24),
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF00C950), Color(0xFF2B7FFF)],
                ),
                borderRadius: BorderRadius.circular(60),
              ),
              child: const Icon(
                Icons.person_2_rounded,
                color: Colors.white,
                size: 34,
              ),
            ),
            const SizedBox(height: 24),

            // --- CORREÇÃO APLICADA AQUI ---
            // 'initState' já chamou o load.
            // O 'build' agora só LÊ o estado.
            if (vm.isLoading && nameController.text.isEmpty)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            // Se não estiver carregando (ou já tiver dados), mostra os cards
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildInfoCard(vm, vmRead),
                      const SizedBox(height: 24),
                      _buildActionsCard(vmRead),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
