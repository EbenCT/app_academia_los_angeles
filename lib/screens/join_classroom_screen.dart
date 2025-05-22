// lib/screens/join_classroom/join_classroom_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../config/routes.dart';
import '../providers/student_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/animations/fade_animation.dart';
import '../widgets/common/custom_button.dart';
import '../widgets/common/custom_text_field.dart';
import '../widgets/common/loading_indicator.dart';
import '../widgets/common/space_background.dart';

class JoinClassroomScreen extends StatefulWidget {
  const JoinClassroomScreen({Key? key}) : super(key: key);
  @override
  State<JoinClassroomScreen> createState() => _JoinClassroomScreenState();
}

class _JoinClassroomScreenState extends State<JoinClassroomScreen> with SingleTickerProviderStateMixin {
  final _codeController = TextEditingController();
  MobileScannerController? _scannerController;
  bool _isScanning = false;
  late AnimationController _animationController;
  String _lastScannedCode = "Ninguno";
  bool _isProcessingCode = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
    _isScanning = false; // Asegurarnos que empiece como false
    _lastScannedCode = "Ninguno";
  }

  @override
  void dispose() {
    _codeController.dispose();
    _scannerController?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _joinClassroomByCode(String code) async {
    print('------ INICIANDO PROCESO DE UNIÓN ------');
    print('Código recibido: "$code"');
    // Verificar si el código es un número
    final classroomId = int.tryParse(code);
    print('ID del aula interpretado: $classroomId');
    if (classroomId == null) {
      print('Error: el código no es un número válido');
      setState(() {
        _isProcessingCode = false; // Usar la nueva variable _isProcessingCode
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: El código debe ser un número',
            style: TextStyle(fontFamily: 'Comic Sans MS'),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    
    final studentProvider = Provider.of<StudentProvider>(context, listen: false);
    print('Llamando a studentProvider.joinClassroomByCode("$code")');
    final success = await studentProvider.joinClassroomByCode(code);
    print('Resultado de unión: $success');
    print('Error: ${studentProvider.error}');
    
    if (success && mounted) {
      print('¡Éxito! El estudiante se unió al aula');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '¡Te has unido al aula correctamente!',
            style: TextStyle(fontFamily: 'Comic Sans MS'),
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      // Navegar al home después de unirse
      print('Redirigiendo al HomeScreen en 2 segundos...');
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          print('Navegando a HomeScreen');
          AppRoutes.navigateToMainAndClearStack(context);
        }
      });
    } else if (mounted) {
      print('Falló la unión al aula');
      setState(() {
        _isProcessingCode = false; // Usar la nueva variable aquí también
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            studentProvider.error ?? 'Error al unirse al aula',
            style: TextStyle(fontFamily: 'Comic Sans MS'),
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
    
    // Asegurarse de que _isProcessingCode se resetee si algo falla
    if (mounted && !success) {
      setState(() {
        _isProcessingCode = false;
      });
    }
    print('------ FIN DEL PROCESO DE UNIÓN ------');
  }

  void _toggleQRScanner() {
    setState(() {
      _isScanning = !_isScanning; // Esto cambia el estado de la pestaña, NO el estado de procesamiento
      // Reiniciar el estado de escaneo cada vez que se activa el scanner
      if (_scannerController != null) {
        _scannerController?.dispose();
        _scannerController = null;
      } else {
        _scannerController = MobileScannerController(
          facing: CameraFacing.back,
          torchEnabled: false,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final user = Provider.of<AuthProvider>(context).currentUser;
    final studentProvider = Provider.of<StudentProvider>(context);
    final isLoading = studentProvider.isLoading;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: Stack(
        children: [
          // Usamos el nuevo widget SpaceBackground
          SpaceBackground.forJoinClassroom(
            child: SafeArea(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: size.height - MediaQuery.of(context).padding.top,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Barra superior con título
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () {
                                  // Aquí podríamos navegar al login si es necesario
                                  // Por ahora no haremos nada
                                },
                                icon: Icon(Icons.rocket_launch, color: Colors.white),
                              ),
                              Text(
                                'Unirse a un Aula',
                                style: TextStyle(
                                  fontFamily: 'Comic Sans MS',
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black45,
                                      blurRadius: 5,
                                      offset: const Offset(1, 1),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 48),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Mensaje de bienvenida
                        FadeAnimation(
                          delay: const Duration(milliseconds: 200),
                          child: Text(
                            '¡Hola, ${user?.username ?? "Explorador"}!',
                            style: TextStyle(
                              fontFamily: 'Comic Sans MS',
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  blurRadius: 5,
                                  offset: const Offset(1, 1),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 10),
                        FadeAnimation(
                          delay: const Duration(milliseconds: 300),
                          child: Text(
                            'Para comenzar tu aventura espacial, únete a un aula',
                            style: TextStyle(
                              fontFamily: 'Comic Sans MS',
                              fontSize: 16,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  blurRadius: 5,
                                  offset: const Offset(1, 1),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 30),
                        // Tarjeta de unión a aula
                        Flexible(
                          fit: FlexFit.loose,
                          child: FadeAnimation(
                            delay: const Duration(milliseconds: 400),
                            slideOffset: const Offset(0, 30),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? AppColors.darkSurface.withOpacity(0.95)
                                    : Colors.white.withOpacity(0.95),
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Tabs para seleccionar método
                                  FadeAnimation(
                                    delay: const Duration(milliseconds: 500),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: _buildTab(
                                            title: 'Código',
                                            icon: Icons.text_fields,
                                            isSelected: !_isScanning,
                                            onTap: _isScanning ? _toggleQRScanner : null,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: _buildTab(
                                            title: 'Escanear QR',
                                            icon: Icons.qr_code_scanner,
                                            isSelected: _isScanning,
                                            onTap: !_isScanning ? _toggleQRScanner : null,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  // Contenido basado en la pestaña seleccionada
                                  if (!_isScanning)
                                    _buildCodeInput()
                                  else
                                    _buildQRScanner(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Indicador de carga
          if (isLoading)
            Container(
              color: Colors.black45,
              child: const LoadingIndicator(
                message: 'Conectando con la estación espacial...',
                useAstronaut: true,
                size: 180,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.primary.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? AppColors.primary : Colors.grey,
              size: 30,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.primary : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeInput() {
    return FadeAnimation(
      delay: const Duration(milliseconds: 600),
      child: Column(
        children: [
          Text(
            'Ingresa el código de tu aula',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _codeController,
            hintText: 'Código del aula',
            prefixIcon: Icons.class_rounded,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: 'Unirse al Aula',
            onPressed: () {
              final code = _codeController.text.trim();
              if (code.isNotEmpty) {
                // Validar que sea un número
                if (int.tryParse(code) != null) {
                  _joinClassroomByCode(code);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Por favor, ingresa un ID de aula válido (número)',
                        style: TextStyle(fontFamily: 'Comic Sans MS'),
                      ),
                      backgroundColor: AppColors.warning,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Por favor, ingresa el ID del aula',
                      style: TextStyle(fontFamily: 'Comic Sans MS'),
                    ),
                    backgroundColor: AppColors.warning,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            icon: Icons.rocket_launch,
            backgroundColor: AppColors.primary,
            height: 55,
          ),
          const SizedBox(height: 16),
          Text(
            'Pregunta a tu profesor por el código del aula',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white60
                  : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQRScanner() {
    return FadeAnimation(
      delay: const Duration(milliseconds: 600),
      child: Column(
        children: [
          Text(
            'Escanea el código QR de tu aula',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            height: 250,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: _scannerController != null
                      ? MobileScanner(
                          controller: _scannerController!,
                          onDetect: (capture) {
                            final List<Barcode> barcodes = capture.barcodes;
                            print('Barcodes detectados: ${barcodes.length}');
                            for (final barcode in barcodes) {
                              print('Código detectado:');
                              print(' - rawValue: "${barcode.rawValue}"');
                              print(' - displayValue: "${barcode.displayValue}"');
                              print(' - format: ${barcode.format.name}');
                              print(' - type: ${barcode.type.name}');
                              final String? code = barcode.rawValue;
                              print("código escaneado $code");

                              // Usar la nueva variable para el control de procesamiento
                              if (code != null && code.isNotEmpty && !_isProcessingCode) {
                                print("dentro del if $code");
                                setState(() {
                                  _lastScannedCode = code;
                                  _isProcessingCode = true; // Marcar que estamos procesando
                                });
                                // Mostrar un diálogo con el código detectado
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (context) => AlertDialog(
                                    title: Text('Código QR Detectado', style: TextStyle(fontFamily: 'Comic Sans MS')),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('Se ha detectado el siguiente código:', style: TextStyle(fontFamily: 'Comic Sans MS')),
                                        SizedBox(height: 10),
                                        Container(
                                          padding: EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(10),
                                            border: Border.all(color: AppColors.primary)
                                          ),
                                          child: Text(
                                            code,
                                            style: TextStyle(
                                              fontFamily: 'Comic Sans MS',
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text('¿Deseas unirte a esta aula?', style: TextStyle(fontFamily: 'Comic Sans MS')),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          setState(() {
                                            _isProcessingCode = false; // Reiniciar al cancelar
                                          });
                                        },
                                        child: Text('Cancelar', style: TextStyle(fontFamily: 'Comic Sans MS')),
                                      ),
                                      ElevatedButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _joinClassroomByCode(code);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                        ),
                                        child: Text('Unirme', style: TextStyle(fontFamily: 'Comic Sans MS')),
                                      ),
                                    ],
                                  ),
                                );
                                break; // Salir del bucle
                              }
                            }
                          },
                        )
                      : Center(
                          child: Text(
                            'Iniciando cámara...',
                            style: TextStyle(
                              fontFamily: 'Comic Sans MS',
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                ),
                // Panel de depuración
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Estado: ${_isScanning ? "Procesando" : "Esperando"}',
                          style: TextStyle(
                            fontFamily: 'Comic Sans MS',
                            fontSize: 10,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Último código: $_lastScannedCode',
                          style: TextStyle(
                            fontFamily: 'Comic Sans MS',
                            fontSize: 10,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Apunta la cámara hacia el código QR que te mostró tu profesor',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white60
                  : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}