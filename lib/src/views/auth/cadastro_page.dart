// lib/views/cadastro_page.dart (NOVO ARQUIVO)
import 'package:flutter/material.dart';
import 'package:g1_g2/components/custom_voltar_text_buttom.dart';
import 'package:provider/provider.dart';
import 'package:g1_g2/src/viewmodels/auth/cadastro_viewmodel.dart'; // Importe seu VM

class CadastroPage extends StatelessWidget {
  const CadastroPage({super.key});

  // Widget de helper para um campo de texto padrão
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    TextInputType type,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          hintText: label,
          filled: true,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(width: 2, color: Color(0xff00A63E)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(style: BorderStyle.none),
          ),
        ),
      ),
    );
  }

  // Widget de helper para os campos condicionais
  Widget _buildConditionalFields(CadastroViewModel vm) {
    switch (vm.tipoSelecionado) {
      case TipoUsuario.cliente:
        return _buildTextField(vm.cpfController, "CPF", TextInputType.number);
      case TipoUsuario.loja:
        return Column(
          children: [
            _buildTextField(vm.cnpjController, "CNPJ", TextInputType.number),
            _buildTextField(
              vm.enderecoLojaController,
              "Endereço da Loja",
              TextInputType.text,
            ),
          ],
        );
      default:
        return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CadastroViewModel>();
    final vmRead = context.read<CadastroViewModel>();

    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[Color(0xffF0FDF4), Color(0xffEFF6FF)],
            ),
          ),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Color(0x20000000)),
                  ),
                  shadowColor: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 30,
                      bottom: 30,
                      right: 20,
                      left: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(children: [CustomVoltarTextButtom()]),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Image.asset(
                                'assets/images/logo2.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),

                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Criar conta', style: TextStyle(fontSize: 20)),
                            Text(
                              'Comece a contribuir com o meio ambiente',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF717182),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 15),

                        // Seletor de Tipo de Usuário
                        Container(
                          decoration: BoxDecoration(
                            color: Color.fromARGB(24, 0, 0, 0),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 5,
                              right: 5,
                              top: 1,
                              bottom: 1,
                            ),
                            child: SegmentedButton<TipoUsuario>(
                              segments: const [
                                ButtonSegment(
                                  value: TipoUsuario.cliente,
                                  label: Text('Cliente'),
                                ),
                                ButtonSegment(
                                  value: TipoUsuario.loja,
                                  label: Text('Loja'),
                                ),
                                // Você pode remover o 'Admin' se o admin
                                // não puder se cadastrar publicamente
                                ButtonSegment(
                                  value: TipoUsuario.admin,
                                  label: Text('Admin'),
                                ),
                              ],
                              selected: {vm.tipoSelecionado},
                              onSelectionChanged:
                                  (Set<TipoUsuario> newSelection) {
                                    vmRead.setTipoUsuario(newSelection.first);
                                  },
                              showSelectedIcon: false,
                              style:
                                  SegmentedButton.styleFrom(
                                    // Cores base
                                    backgroundColor: Colors
                                        .transparent, // Fundo cinza (não selecionado)
                                    selectedBackgroundColor: Colors
                                        .white, // Fundo branco (selecionado)
                                    selectedForegroundColor: Color(
                                      0xFF00A63E,
                                    ), // Texto verde (selecionado)
                                  ).copyWith(
                                    // Customizações adicionais

                                    // 1. Remove a borda preta
                                    side: WidgetStateProperty.all(
                                      BorderSide.none,
                                    ),

                                    // 2. ARREDONDA TUDO (o contêiner e o botão selecionado)
                                    shape: WidgetStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                        ),

                        SizedBox(height: 15),

                        // --- Campos Comuns ---
                        _buildTextField(
                          vm.nomeController,
                          "Nome Completo",
                          TextInputType.name,
                        ),
                        _buildTextField(
                          vm.emailController,
                          "E-mail",
                          TextInputType.emailAddress,
                        ),
                        _buildTextField(
                          vm.passwordController,
                          "Senha",
                          TextInputType.visiblePassword,
                        ),
                        _buildTextField(
                          vm.cityController,
                          "Cidade",
                          TextInputType.text,
                        ),

                        // --- Campos Condicionais ---
                        _buildConditionalFields(vm),

                        SizedBox(height: 15),
                        // --- Botão de Cadastrar ---
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Color(0xff00A63E),
                          ),
                          onPressed: vm.isLoading
                              ? null
                              : () async {
                                  FocusScope.of(context).unfocus();
                                  bool sucesso = await vmRead.cadastrar();

                                  if (!context.mounted) return;

                                  if (sucesso) {
                                    // Sucesso! Mostra msg e volta p/ login
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "Cadastro realizado com sucesso!",
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                    Navigator.pop(
                                      context,
                                    ); // Volta p/ tela de login
                                  } else {
                                    // Erro! Mostra msg
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          vm.errorMessage ?? "Erro no cadastro",
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                          child: vm.isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  "Cadastrar",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
