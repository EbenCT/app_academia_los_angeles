// lib/screens/debug/fluttermoji_explorer_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttermoji/fluttermoji.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FluttermojiExplorerScreen extends StatefulWidget {
  const FluttermojiExplorerScreen({Key? key}) : super(key: key);

  @override
  State<FluttermojiExplorerScreen> createState() => _FluttermojiExplorerScreenState();
}

class _FluttermojiExplorerScreenState extends State<FluttermojiExplorerScreen> {
  Map<String, int>? _currentOptions;
  bool _isLoading = true;
  String _output = '';
  String _errorLog = '';
  
  // Todas las categorías que vamos a explorar
  final List<String> _categories = [
    'topType',
    'accessoriesType', 
    'clotheType',
    'facialHairType',
    'eyeType',
    'eyebrowType',
    'mouthType',
    'skinColor',
    'hairColor',
    'facialHairColor',
    'clotheColor',
    'graphicType',
  ];

  @override
  void initState() {
    super.initState();
    _investigateFluttermojiMethods();
    _loadCurrentOptions();
  }

  // Primero investigamos qué métodos están disponibles
  void _investigateFluttermojiMethods() {
    StringBuffer buffer = StringBuffer();
    buffer.writeln('=== FLUTTERMOJI METHODS INVESTIGATION ===\n');
    
    try {
      final controller = FluttermojiController();
      
      buffer.writeln('FluttermojiController disponible: ✓');
      buffer.writeln('Métodos que vamos a probar:');
      buffer.writeln('- getFluttermojiOptions()');
      buffer.writeln('- setFluttermoji() variants...');
      buffer.writeln('');
      
    } catch (e) {
      buffer.writeln('Error creando controller: $e');
    }
    
    setState(() {
      _errorLog = buffer.toString();
    });
  }

  Future<void> _loadCurrentOptions() async {
    setState(() {
      _isLoading = true;
    });

    StringBuffer logBuffer = StringBuffer(_errorLog);

    try {
      final controller = FluttermojiController();
      logBuffer.writeln('Intentando getFluttermojiOptions()...');
      
      final options = await controller.getFluttermojiOptions();
      logBuffer.writeln('✓ getFluttermojiOptions() exitoso');
      logBuffer.writeln('Tipo de respuesta: ${options.runtimeType}');
      logBuffer.writeln('Contenido: $options');
      logBuffer.writeln('');
      
      // Convertir el resultado
      Map<String, int> convertedOptions = {};
      if (options is Map) {
        options.forEach((key, value) {
          final keyStr = key?.toString() ?? 'unknown';
          final valueInt = value is int ? value : 0;
          convertedOptions[keyStr] = valueInt;
          logBuffer.writeln('$keyStr: $valueInt');
        });
      }
      
      setState(() {
        _currentOptions = convertedOptions;
        _isLoading = false;
        _errorLog = logBuffer.toString();
      });
      
      _generateReport();
    } catch (e) {
      logBuffer.writeln('❌ Error en getFluttermojiOptions(): $e');
      setState(() {
        _isLoading = false;
        _errorLog = logBuffer.toString();
        _output = 'Error loading options: $e';
      });
    }
  }

  void _generateReport() {
    if (_currentOptions == null) return;
    
    StringBuffer buffer = StringBuffer();
    buffer.writeln('=== FLUTTERMOJI VALUES REPORT ===\n');
    buffer.writeln('Valores actuales configurados:\n');
    
    for (String category in _categories) {
      final value = _currentOptions![category];
      buffer.writeln('$category: $value');
    }
    
    buffer.writeln('\n=== CÓDIGO PARA USAR EN TU APP ===\n');
    buffer.writeln('// Copia este código en tu FluttermojiShopService');
    buffer.writeln('static List<FluttermojiItemModel> getAllItems() {');
    buffer.writeln('  return [');
    
    // Generar código de ejemplo basado en los valores encontrados
    _generateExampleItems(buffer);
    
    buffer.writeln('  ];');
    buffer.writeln('}');
    
    setState(() {
      _output = buffer.toString();
    });
  }

  void _generateExampleItems(StringBuffer buffer) {
    // Generar elementos de ejemplo para topType (cabello)
    buffer.writeln('    // === CABELLO/TOPS ===');
    for (int i = 0; i <= 20; i++) {
      buffer.writeln('    FluttermojiItemModel(');
      buffer.writeln('      id: \'hair_$i\',');
      buffer.writeln('      displayName: \'Cabello Estilo $i\',');
      buffer.writeln('      category: FluttermojiCategory.topType,');
      buffer.writeln('      fluttermojiValue: $i,');
      buffer.writeln('      price: ${i == 0 ? 0 : (i * 10 + 20)},');
      buffer.writeln('      isDefault: ${i == 0},');
      buffer.writeln('      description: \'Estilo de cabello $i\',');
      buffer.writeln('    ),');
    }

    // Generar elementos de ejemplo para accessoriesType
    buffer.writeln('\n    // === ACCESORIOS ===');
    for (int i = 0; i <= 15; i++) {
      buffer.writeln('    FluttermojiItemModel(');
      buffer.writeln('      id: \'accessory_$i\',');
      buffer.writeln('      displayName: \'Accesorio $i\',');
      buffer.writeln('      category: FluttermojiCategory.accessoriesType,');
      buffer.writeln('      fluttermojiValue: $i,');
      buffer.writeln('      price: ${i == 0 ? 0 : (i * 15 + 30)},');
      buffer.writeln('      isDefault: ${i == 0},');
      buffer.writeln('      description: \'Accesorio tipo $i\',');
      buffer.writeln('    ),');
    }

    // Generar elementos de ejemplo para clotheType
    buffer.writeln('\n    // === ROPA ===');
    for (int i = 0; i <= 25; i++) {
      buffer.writeln('    FluttermojiItemModel(');
      buffer.writeln('      id: \'clothes_$i\',');
      buffer.writeln('      displayName: \'Ropa $i\',');
      buffer.writeln('      category: FluttermojiCategory.clotheType,');
      buffer.writeln('      fluttermojiValue: $i,');
      buffer.writeln('      price: ${i == 0 ? 0 : (i * 12 + 25)},');
      buffer.writeln('      isDefault: ${i == 0},');
      buffer.writeln('      description: \'Vestimenta tipo $i\',');
      buffer.writeln('    ),');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fluttermoji Explorer'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadCurrentOptions,
          ),
          IconButton(
            icon: Icon(Icons.copy),
            onPressed: _copyToClipboard,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Preview del avatar actual
                Container(
                  height: 200,
                  color: Colors.grey[100],
                  child: Center(
                    child: FluttermojiCircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.white,
                    ),
                  ),
                ),
                
                // Log de errores y debug (expandible)
                ExpansionTile(
                  title: Text('Debug Log'),
                  children: [
                    Container(
                      height: 150,
                      padding: EdgeInsets.all(8),
                      child: SingleChildScrollView(
                        child: SelectableText(
                          _errorLog,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 10,
                            color: Colors.blue[800],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Controles para cambiar valores
                Container(
                  height: 120,
                  padding: EdgeInsets.all(16),
                  child: _buildControls(),
                ),
                
                // Output del reporte
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SelectableText(
                          _output,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            color: Colors.green[300],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildControls() {
    if (_currentOptions == null) return Container();
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((category) {
          final currentValue = _currentOptions![category] ?? 0;
          return Container(
            margin: EdgeInsets.only(right: 16),
            child: Column(
              children: [
                Text(
                  category,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => _changeValue(category, currentValue - 1),
                      icon: Icon(Icons.remove),
                      iconSize: 16,
                    ),
                    Container(
                      width: 40,
                      child: Text(
                        '$currentValue',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _changeValue(category, currentValue + 1),
                      icon: Icon(Icons.add),
                      iconSize: 16,
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _changeValue(String category, int newValue) async {
    if (newValue < 0) return;
    
    StringBuffer logBuffer = StringBuffer(_errorLog);
    logBuffer.writeln('\n=== TESTING VALUE CHANGE ===');
    logBuffer.writeln('Categoría: $category');
    logBuffer.writeln('Nuevo valor: $newValue');
    
    try {
      // Intentar diferentes formas de cambiar el valor
      logBuffer.writeln('Intentando cambiar usando SharedPreferences directamente...');
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(category, newValue);
      
      logBuffer.writeln('✓ Valor guardado en SharedPreferences');
      
      // Actualizar el mapa local
      setState(() {
        _currentOptions![category] = newValue;
        _errorLog = logBuffer.toString();
      });
      
      // Forzar actualización del avatar
      // El avatar debería actualizar automáticamente al leer de SharedPreferences
      
      _generateReport();
      
    } catch (e) {
      logBuffer.writeln('❌ Error cambiando valor: $e');
      setState(() {
        _errorLog = logBuffer.toString();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error setting $category to $newValue: $e')),
      );
    }
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: _output));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Reporte copiado al portapapeles')),
    );
  }
}

// Widget helper para acceso rápido desde cualquier pantalla (solo para debug)
class FluttermojiDebugButton extends StatelessWidget {
  const FluttermojiDebugButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      mini: true,
      backgroundColor: Colors.red,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FluttermojiExplorerScreen(),
          ),
        );
      },
      child: Icon(Icons.bug_report, color: Colors.white),
    );
  }
}

// Función utilitaria para generar todos los rangos de valores
class FluttermojiValueMapper {
  static Map<String, List<int>> getKnownRanges() {
    return {
      'topType': List.generate(26, (i) => i), // 0-25 (aproximado)
      'accessoriesType': List.generate(16, (i) => i), // 0-15 (aproximado)
      'clotheType': List.generate(26, (i) => i), // 0-25 (aproximado)
      'facialHairType': List.generate(18, (i) => i), // 0-17 (aproximado)
      'eyeType': List.generate(27, (i) => i), // 0-26 (aproximado)
      'eyebrowType': List.generate(16, (i) => i), // 0-15 (aproximado)
      'mouthType': List.generate(28, (i) => i), // 0-27 (aproximado)
      'skinColor': List.generate(8, (i) => i), // 0-7 (colores de piel)
      'hairColor': List.generate(18, (i) => i), // 0-17 (colores de cabello)
      'facialHairColor': List.generate(18, (i) => i), // 0-17 (colores de barba)
      'clotheColor': List.generate(10, (i) => i), // 0-9 (colores de ropa)
      'graphicType': List.generate(13, (i) => i), // 0-12 (gráficos en ropa)
    };
  }

  // Función para testear todos los valores posibles de una categoría
  static Future<List<int>> findValidValuesForCategory(String category) async {
    List<int> validValues = [];
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Testear valores del 0 al 50 para encontrar cuáles funcionan
      for (int i = 0; i <= 50; i++) {
        try {
          // Intentar guardar el valor
          await prefs.setInt(category, i);
          validValues.add(i);
          
          print('Valid value for $category: $i');
          
          // Pequeña pausa para evitar sobrecargar
          await Future.delayed(Duration(milliseconds: 50));
        } catch (e) {
          // Si falla, el valor no es válido
          print('Invalid value for $category: $i - Error: $e');
        }
      }
    } catch (e) {
      print('Error testing category $category: $e');
    }
    
    return validValues;
  }
}