// lib/widgets/profile/advanced_avatar_customization_widget.dart
import 'package:flutter/material.dart';
import '../../models/avatar_model.dart';
import '../../theme/app_colors.dart';
import '../animations/fade_animation.dart';
import '../common/custom_button.dart';
import 'triangle_painter.dart';

class AdvancedAvatarCustomizationWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onAvatarUpdated;
  final AvatarModel? initialAvatar;

  const AdvancedAvatarCustomizationWidget({
    Key? key,
    required this.onAvatarUpdated,
    this.initialAvatar,
  }) : super(key: key);

  @override
  State<AdvancedAvatarCustomizationWidget> createState() => _AdvancedAvatarCustomizationWidgetState();
}

class _AdvancedAvatarCustomizationWidgetState extends State<AdvancedAvatarCustomizationWidget> with SingleTickerProviderStateMixin {
  // Controlador para las pestañas
  late TabController _tabController;
  
  // Avatar properties
  late String _gender;
  late int _skinToneIndex;
  late int _eyesIndex;
  late int _noseIndex;
  late int _mouthIndex;
  late int _hairStyleIndex;
  late int _hairColorIndex;
  late int _topIndex;
  late int _bottomIndex;
  late int _shoesIndex;
  late bool _hasGlasses;
  late bool _hasHat;
  late bool _hasBackpack;
  
  // Available options
  final List<Color> _skinTones = [
    const Color(0xFFFADCBC), // Light
    const Color(0xFFF1C27D), // Medium
    const Color(0xFFE0AC69), // Tan
    const Color(0xFFC68642), // Brown
    const Color(0xFF8D5524), // Dark
  ];
  
  final List<Color> _hairColors = [
    Colors.black,
    Colors.brown,
    Colors.amber,
    Colors.red,
    const Color(0xFF8D4848), // castaño rojizo
    Colors.blueGrey,
    Colors.purple,
    Colors.pink,
  ];
  
  final Map<String, List<String>> _hairStyles = {
    'boy': ['Corto', 'Medio', 'Largo', 'Rizado', 'Punk'],
    'girl': ['Corto', 'Coleta', 'Largo', 'Trenzas', 'Rizado'],
  };
  
  final Map<String, List<String>> _tops = {
    'boy': ['Camiseta', 'Sudadera', 'Camisa', 'Uniforme', 'Espacial'],
    'girl': ['Camiseta', 'Vestido', 'Blusa', 'Uniforme', 'Espacial'],
  };
  
  final Map<String, List<String>> _bottoms = {
    'boy': ['Jeans', 'Shorts', 'Deportivos', 'Uniformes', 'Espaciales'],
    'girl': ['Jeans', 'Falda', 'Leggings', 'Uniformes', 'Espaciales'],
  };
  
  final List<String> _shoes = ['Deportivas', 'Formales', 'Botas', 'Espaciales'];
  
  final List<String> _expressions = ['Alegre', 'Sorprendido', 'Serio', 'Emocionado'];
  
  final List<String> _eyeTypes = ['Redondos', 'Almendrados', 'Grandes', 'Pequeños'];
  
  final List<String> _noseTypes = ['Pequeña', 'Respingada', 'Ancha', 'Puntiaguda'];
  
  @override
  void initState() {
    super.initState();
    
    // Inicializar el controlador de pestañas
    _tabController = TabController(length: 6, vsync: this);
    
    // Inicializar campos desde avatar inicial si está disponible
 if (widget.initialAvatar != null) {
      _initializeFromAvatar(widget.initialAvatar!);
    } else {
      // Valores por defecto
      _gender = 'boy';
      _skinToneIndex = 0;
      _eyesIndex = 0;
      _noseIndex = 0;
      _mouthIndex = 0;
      _hairStyleIndex = 0;
      _hairColorIndex = 0;
      _topIndex = 0;
      _bottomIndex = 0;
      _shoesIndex = 0;
      _hasGlasses = false;
      _hasHat = false;
      _hasBackpack = false;
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  void _initializeFromAvatar(AvatarModel avatar) {
    _gender = avatar.gender;
    _skinToneIndex = avatar.skinToneIndex;
    _eyesIndex = avatar.eyesIndex;
    _noseIndex = avatar.noseIndex;
    _mouthIndex = avatar.mouthIndex;
    _hairStyleIndex = avatar.hair.styleIndex;
    _hairColorIndex = avatar.hair.colorIndex;
    _topIndex = avatar.outfit.topIndex;
    _bottomIndex = avatar.outfit.bottomIndex;
    _shoesIndex = avatar.outfit.shoesIndex;
    _hasGlasses = avatar.accessories.hasGlasses;
    _hasHat = avatar.accessories.hasHat;
    _hasBackpack = avatar.accessories.hasBackpack;
  }
  
  void _updateAvatar() {
    final avatarData = {
      'gender': _gender,
      'skinToneIndex': _skinToneIndex,
      'eyesIndex': _eyesIndex,
      'noseIndex': _noseIndex,
      'mouthIndex': _mouthIndex,
      'hair': {
        'styleIndex': _hairStyleIndex,
        'colorIndex': _hairColorIndex,
      },
      'outfit': {
        'topIndex': _topIndex,
        'bottomIndex': _bottomIndex,
        'shoesIndex': _shoesIndex,
      },
      'accessories': {
        'hasGlasses': _hasGlasses,
        'hasHat': _hasHat,
        'hasBackpack': _hasBackpack,
      }
    };
    
    widget.onAvatarUpdated(avatarData);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkPrimary
                : AppColors.primary.withOpacity(0.9),
            Theme.of(context).brightness == Brightness.dark
                ? AppColors.darkSurface
                : Colors.white,
          ],
        ),
      ),
      child: Column(
        children: [
          // Título y botón de cerrar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '¡Personaliza tu avatar espacial!',
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          // Vista previa del avatar
          Expanded(
            flex: 3,
            child: FadeAnimation(
              delay: const Duration(milliseconds: 200),
              child: _buildAvatarPreview(),
            ),
          ),
          
          // Pestañas para personalización
          TabBar(
            controller: _tabController,
            indicatorColor: AppColors.secondary,
            labelColor: AppColors.secondary,
            unselectedLabelColor: Colors.grey,
            isScrollable: true,
            tabs: const [
              Tab(text: 'Básico', icon: Icon(Icons.person)),
              Tab(text: 'Cara', icon: Icon(Icons.face)),
              Tab(text: 'Cabello', icon: Icon(Icons.content_cut)),
              Tab(text: 'Ropa', icon: Icon(Icons.style)),
              Tab(text: 'Zapatos', icon: Icon(Icons.directions_walk_outlined)),
              Tab(text: 'Accesorios', icon: Icon(Icons.shopping_bag)),
            ],
          ),
          
          // Opciones de personalización
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkSurface
                    : Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Pestaña de opciones básicas
                  _buildBasicOptions(),
                  
                  // Pestaña de características faciales
                  _buildFacialOptions(),
                  
                  // Pestaña de cabello
                  _buildHairOptions(),
                  
                  // Pestaña de ropa
                  _buildClothingOptions(),
                  
                  // Pestaña de zapatos
                  _buildShoesOptions(),
                  
                  // Pestaña de accesorios
                  _buildAccessoryOptions(),
                ],
              ),
            ),
          ),
          
          // Botón guardar
          Padding(
            padding: const EdgeInsets.all(20),
            child: CustomButton(
              text: 'Guardar mi Avatar Espacial',
              onPressed: () {
                _updateAvatar();
                Navigator.pop(context);
              },
              backgroundColor: AppColors.secondary,
              icon: Icons.save_alt,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAvatarPreview() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 15),
      width: 240,
      height: 320,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurface.withOpacity(0.7)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Aquí se construiría un avatar completamente personalizado
          // Este es un ejemplo simplificado
          _buildFullBodyAvatar(),
          
          // Botón de aleatorio
          Positioned(
            bottom: 10,
            right: 10,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: AppColors.secondary,
              child: const Icon(Icons.shuffle, color: Colors.white),
              onPressed: _randomizeAvatar,
            ),
          ),
          
          // Indicador de género
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _gender == 'boy' ? Colors.blue : Colors.pink,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                _gender == 'boy' ? 'Niño' : 'Niña',
                style: const TextStyle(
                  fontFamily: 'Comic Sans MS',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFullBodyAvatar() {
    // Colores basados en índices seleccionados
    final skinColor = _skinTones[_skinToneIndex];
    final hairColor = _hairColors[_hairColorIndex];
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Cabeza con rasgos faciales
        Stack(
          alignment: Alignment.center,
          children: [
            // Forma básica de la cabeza
            Container(
              width: 80,
              height: 95,
              decoration: BoxDecoration(
                color: skinColor,
                borderRadius: BorderRadius.circular(40),
              ),
            ),
            
            // Cabello
            Positioned(
              top: -5,
              child: _buildHair(hairColor),
            ),
            
            // Ojos
            Positioned(
              top: 35,
              child: _buildEyes(),
            ),
            
            // Nariz
            Positioned(
              top: 50,
              child: _buildNose(),
            ),
            
            // Boca
            Positioned(
              top: 65,
              child: _buildMouth(),
            ),
            
            // Accesorios faciales
            if (_hasGlasses)
              Positioned(
                top: 40,
                child: _buildGlasses(),
              ),
              
            if (_hasHat)
              Positioned(
                top: -25,
                child: _buildHat(),
              ),
          ],
        ),
        
        // Cuello
        Container(
          width: 20,
          height: 10,
          color: skinColor,
        ),
        
        // Torso con ropa
        Stack(
          alignment: Alignment.center,
          children: [
            _buildTop(),
            
            // Mochila si está habilitada
            if (_hasBackpack) 
              Positioned(
                right: -25,
                child: _buildBackpack(),
              ),
          ],
        ),
        
        // Piernas con pantalones/faldas
        _buildBottom(),
        
        // Zapatos
        _buildShoes(),
      ],
    );
  }
  
  Widget _buildHair(Color hairColor) {
    // Diferentes estilos de pelo según género y estilo seleccionado
    if (_gender == 'boy') {
      switch (_hairStyleIndex) {
        case 0: // Corto
          return Container(
            width: 85,
            height: 30,
            decoration: BoxDecoration(
              color: hairColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
          );
        case 1: // Medio
          return Container(
            width: 90,
            height: 35,
            decoration: BoxDecoration(
              color: hairColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
          );
        case 2: // Largo
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: 90,
                height: 35,
                decoration: BoxDecoration(
                  color: hairColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                left: 10,
                child: Container(
                  width: 15,
                  height: 30,
                  decoration: BoxDecoration(
                    color: hairColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                right: 10,
                child: Container(
                  width: 15,
                  height: 30,
                  decoration: BoxDecoration(
                    color: hairColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          );
        case 3: // Rizado
          return Container(
            width: 95,
            height: 40,
            decoration: BoxDecoration(
              color: hairColor,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(
                7,
                (index) => Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _skinTones[_skinToneIndex],
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          );
        case 4: // Punk
          return Stack(
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: 85,
                height: 25,
                decoration: BoxDecoration(
                  color: hairColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
              ),
              ...List.generate(
                5,
                (index) => Positioned(
                  top: -15,
                  left: 15.0 + (index * 13),
                  child: Container(
                    width: 8,
                    height: 25,
                    decoration: BoxDecoration(
                      color: hairColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        topRight: Radius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        default:
          return Container();
      }
    } else { // girl
      switch (_hairStyleIndex) {
        case 0: // Corto
          return Container(
            width: 85,
            height: 35,
            decoration: BoxDecoration(
              color: hairColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40),
                topRight: Radius.circular(40),
              ),
            ),
          );
        case 1: // Coleta
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: 85,
                height: 35,
                decoration: BoxDecoration(
                  color: hairColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
              ),
              Positioned(
                top: -15,
                child: Container(
                  width: 25,
                  height: 40,
                  decoration: BoxDecoration(
                    color: hairColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          );
        case 2: // Largo
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: 90,
                height: 35,
                decoration: BoxDecoration(
                  color: hairColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                left: 5,
                child: Container(
                  width: 25,
                  height: 60,
                  decoration: BoxDecoration(
                    color: hairColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -50,
                right: 5,
                child: Container(
                  width: 25,
                  height: 60,
                  decoration: BoxDecoration(
                    color: hairColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(15),
                      bottomRight: Radius.circular(15),
                    ),
                  ),
                ),
              ),
            ],
          );
        case 3: // Trenzas
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                width: 85,
                height: 35,
                decoration: BoxDecoration(
                  color: hairColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                left: 15,
                child: Container(
                  width: 12,
                  height: 50,
                  decoration: BoxDecoration(
                    color: hairColor,
                  ),
                  child: Column(
                    children: List.generate(
                      5,
                      (index) => Container(
                        height: 8,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.black.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -40,
                right: 15,
                child: Container(
                  width: 12,
                  height: 50,
                  decoration: BoxDecoration(
                    color: hairColor,
                  ),
                  child: Column(
                    children: List.generate(
                      5,
                      (index) => Container(
                        height: 8,
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.black.withOpacity(0.2),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        case 4: // Rizado
          return Container(
            width: 95,
            height: 45,
            decoration: BoxDecoration(
              color: hairColor,
              borderRadius: BorderRadius.circular(30),
            ),
            child: GridView.count(
              crossAxisCount: 6,
              physics: const NeverScrollableScrollPhysics(),
              children: List.generate(
                24,
                (index) => Container(
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: hairColor.withOpacity(0.7),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: hairColor.withOpacity(0.9),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),
          );
        default:
          return Container();
      }
    }
  }
  
  Widget _buildEyes() {
    final Color eyeColor = Colors.white;
    
    switch (_eyesIndex) {
      case 0: // Redondos
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: eyeColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Center(
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: eyeColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Center(
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        );
      case 1: // Almendrados
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 16,
              height: 12,
              decoration: BoxDecoration(
                color: eyeColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Center(
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Container(
              width: 16,
              height: 12,
              decoration: BoxDecoration(
                color: eyeColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Center(
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        );
      case 2: // Grandes
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: eyeColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: eyeColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Center(
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        );
      case 3: // Pequeños
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: eyeColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Center(
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 20),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: eyeColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Center(
                child: Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        );
      default:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: eyeColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Center(
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 15),
            Container(
              width: 15,
              height: 15,
              decoration: BoxDecoration(
                color: eyeColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 1),
              ),
              child: Center(
                child: Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        );
    }
  }
  
  Widget _buildNose() {
    final Color noseColor = _skinTones[_skinToneIndex].withOpacity(0.8);
    
    switch (_noseIndex) {
      case 0: // Pequeña
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: noseColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Colors.black.withOpacity(0.3),
              width: 1,
            ),
          ),
        );
      case 1: // Respingada
        return CustomPaint(
          size: const Size(10, 10),
          painter: TrianglePainter(
            color: noseColor,
            strokeColor: Colors.black.withOpacity(0.3),
          ),
        );
      case 2: // Ancha
        return Container(
          width: 14,
          height: 8,
          decoration: BoxDecoration(
            color: noseColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Colors.black.withOpacity(0.3),
              width: 1,
            ),
          ),
        );
      case 3: // Puntiaguda
        return Container(
          width: 6,
          height: 12,
          decoration: BoxDecoration(
            color: noseColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(3),
              bottomRight: Radius.circular(3),
              topLeft: Radius.circular(1),
              topRight: Radius.circular(1),
            ),
            border: Border.all(
              color: Colors.black.withOpacity(0.3),
              width: 1,
            ),
          ),
        );
      default:
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: noseColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: Colors.black.withOpacity(0.3),
              width: 1,
            ),
          ),
        );
    }
  }
  
  Widget _buildMouth() {
    final Color mouthColor = Colors.red.shade300;
    
    switch (_mouthIndex) {
      case 0: // Alegre
        return Container(
          width: 30,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
              topLeft: Radius.circular(3),
              topRight: Radius.circular(3),
            ),
            border: Border.all(
              color: mouthColor,
              width: 2,
            ),
          ),
        );
      case 1: // Sorprendido
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            shape: BoxShape.circle,
            border: Border.all(
              color: mouthColor,
              width: 2,
            ),
          ),
        );
      case 2: // Serio
        return Container(
          width: 25,
          height: 3,
          decoration: BoxDecoration(
            color: mouthColor,
            borderRadius: BorderRadius.circular(1),
          ),
        );
      case 3: // Emocionado
        return Column(
          children: [
            Container(
              width: 25,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
                border: Border.all(
                  color: mouthColor,
                  width: 1,
                ),
              ),
            ),
            Container(
              width: 25,
              height: 2,
              color: mouthColor,
            ),
          ],
        );
      default:
        return Container(
          width: 25,
          height: 3,
          decoration: BoxDecoration(
            color: mouthColor,
            borderRadius: BorderRadius.circular(1),
          ),
        );
    }
  }
  
  Widget _buildGlasses() {
    return Container(
      width: 60,
      height: 20,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.black,
                width: 2,
              ),
            ),
          ),
          Container(
            width: 10,
            height: 2,
            color: Colors.black,
          ),
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.black,
                width: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHat() {
    // Colores disponibles para sombreros
    final List<Color> hatColors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
    ];
    
    // Seleccionar un color basado en algún índice (puedes añadir esta opción)
    final Color hatColor = hatColors[_hairColorIndex % hatColors.length];
    
    return Container(
      width: 100,
      height: 30,
      decoration: BoxDecoration(
        color: hatColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(50),
          topRight: Radius.circular(50),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 100,
            height: 10,
            decoration: BoxDecoration(
              color: hatColor.withOpacity(0.7),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTop() {
    // Colores para camisetas
    final List<Color> topColors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.purple,
      Colors.orange,
    ];
    
    // Color de la camiseta
    final Color topColor = topColors[_topIndex % topColors.length];
    
    return Column(
      children: [
        // Forma básica de la camiseta
        Container(
          width: 70,
          height: 60,
          decoration: BoxDecoration(
            color: topColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          child: Stack(
            children: [
              // Detalles según el tipo de camiseta
              if (_topIndex == 1) // Sudadera/Vestido
                Center(
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _gender == 'boy' ? 'A' : 'B',
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
              
              if (_topIndex == 2) // Camisa/Blusa
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              
              if (_topIndex == 3) // Uniforme
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.black,
                            width: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              
              if (_topIndex == 4) // Espacial
                Stack(
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.rocket,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildBottom() {
    // Colores para pantalones
    final List<Color> bottomColors = [
      Colors.blue.shade900,
      Colors.indigo.shade800,
      Colors.brown.shade800,
      Colors.green.shade800,
      Colors.purple.shade800,
    ];
    
    // Color del pantalón/falda
    final Color bottomColor = bottomColors[_bottomIndex % bottomColors.length];
    
    // Para niñas, los índices 1 y 2 son falda y vestido respectivamente
    if (_gender == 'girl' && (_bottomIndex == 1 || _bottomIndex == 2)) {
      return Container(
        width: 70,
        height: 40,
        decoration: BoxDecoration(
          color: bottomColor,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
        ),
      );
    } else {
      // Pantalones para niños y algunos estilos de niñas
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 30,
            height: 50,
            color: bottomColor,
          ),
          const SizedBox(width: 4),
          Container(
            width: 30,
            height: 50,
            color: bottomColor,
          ),
        ],
      );
    }
  }
  
  Widget _buildShoes() {
    // Colores para zapatos
    final List<Color> shoesColors = [
      Colors.black,
      Colors.brown.shade900,
      Colors.blue.shade900,
      Colors.grey.shade800,
    ];
    
    // Color de zapatos
    final Color shoesColor = shoesColors[_shoesIndex % shoesColors.length];
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 25,
          height: 15,
          decoration: BoxDecoration(
            color: shoesColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(5),
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(5),
            ),
          ),
        ),
        const SizedBox(width: 15),
        Container(
          width: 25,
          height: 15,
          decoration: BoxDecoration(
            color: shoesColor,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(5),
              bottomLeft: Radius.circular(5),
              bottomRight: Radius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildBackpack() {
    // Colores para mochilas
    final List<Color> backpackColors = [
      Colors.orange,
      Colors.green,
      Colors.purple,
      Colors.red,
      Colors.blue,
    ];
    
    // Color de mochila basado en algún índice (puedes añadir esta opción)
    final Color backpackColor = backpackColors[_topIndex % backpackColors.length];
    
    return Container(
      width: 30,
      height: 45,
      decoration: BoxDecoration(
        color: backpackColor,
        borderRadius: BorderRadius.circular(5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 2,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: 15,
            height: 6,
            decoration: BoxDecoration(
              color: backpackColor.withOpacity(0.7),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: Colors.black.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          Container(
            width: 15,
            height: 6,
            decoration: BoxDecoration(
              color: backpackColor.withOpacity(0.7),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: Colors.black.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBasicOptions() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selección de género
          Text(
            'Tipo de Avatar',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildGenderOption('boy', 'Niño', Icons.face),
              const SizedBox(width: 20),
              _buildGenderOption('girl', 'Niña', Icons.face_3),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Selección de tono de piel
          Text(
            'Tono de Piel',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          _buildColorSelector(_skinTones, _skinToneIndex, (index) {
            setState(() {
              _skinToneIndex = index;
            });
          }),
        ],
      ),
    );
  }
  
  Widget _buildFacialOptions() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selección de ojos
          Text(
            'Ojos',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          _buildOptionSelector(
            _eyeTypes,
            _eyesIndex,
            (index) {
              setState(() {
                _eyesIndex = index;
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          // Selección de nariz
          Text(
            'Nariz',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          _buildOptionSelector(
            _noseTypes,
            _noseIndex,
            (index) {
              setState(() {
                _noseIndex = index;
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          // Selección de boca/expresión
          Text(
            'Expresión',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          _buildOptionSelector(
            _expressions,
            _mouthIndex,
            (index) {
              setState(() {
                _mouthIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildHairOptions() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selección de estilo de pelo
          Text(
            'Estilo de Pelo',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          _buildOptionSelector(
            _hairStyles[_gender]!,
            _hairStyleIndex,
            (index) {
              setState(() {
                _hairStyleIndex = index;
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          // Selección de color de pelo
          Text(
            'Color de Pelo',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          _buildColorSelector(_hairColors, _hairColorIndex, (index) {
            setState(() {
              _hairColorIndex = index;
            });
          }),
        ],
      ),
    );
  }
  
  Widget _buildClothingOptions() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selección de camiseta/parte superior
          Text(
            _gender == 'boy' ? 'Camiseta' : 'Parte Superior',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          _buildOptionSelector(
            _tops[_gender]!,
            _topIndex,
            (index) {
              setState(() {
                _topIndex = index;
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          // Selección de pantalón/parte inferior
          Text(
            _gender == 'boy' ? 'Pantalón' : 'Parte Inferior',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          _buildOptionSelector(
            _bottoms[_gender]!,
            _bottomIndex,
            (index) {
              setState(() {
                _bottomIndex = index;
              });
            },
          ),
        ],
      ),
    );
  }
  
  Widget _buildShoesOptions() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selección de zapatos
          Text(
            'Zapatos',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 10),
          _buildOptionSelector(
            _shoes,
            _shoesIndex,
            (index) {
              setState(() {
                _shoesIndex = index;
              });
            },
          ),
          
          const SizedBox(height: 20),
          
          // Previsualización de zapatos
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.darkPrimary.withOpacity(0.2)
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Text(
                  'Vista previa de zapatos',
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 15),
                _buildShoes(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAccessoryOptions() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selección de gafas
          SwitchListTile(
            title: Text(
              'Gafas',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            value: _hasGlasses,
            activeColor: AppColors.secondary,
            onChanged: (value) {
              setState(() {
                _hasGlasses = value;
              });
            },
            secondary: Icon(
              Icons.visibility,
              color: _hasGlasses ? AppColors.secondary : Colors.grey,
              size: 30,
            ),
          ),
          
          const Divider(),
          
          // Selección de sombrero
          SwitchListTile(
            title: Text(
              'Sombrero',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            value: _hasHat,
            activeColor: AppColors.secondary,
            onChanged: (value) {
              setState(() {
                _hasHat = value;
              });
            },
            secondary: Icon(
              Icons.face,
              color: _hasHat ? AppColors.secondary : Colors.grey,
              size: 30,
            ),
          ),
          
          const Divider(),
          
          // Selección de mochila
          SwitchListTile(
            title: Text(
              'Mochila',
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            value: _hasBackpack,
            activeColor: AppColors.secondary,
            onChanged: (value) {
              setState(() {
                _hasBackpack = value;
              });
            },
            secondary: Icon(
              Icons.backpack,
              color: _hasBackpack ? AppColors.secondary : Colors.grey,
              size: 30,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Previsualización de accesorios
          if (_hasGlasses || _hasHat || _hasBackpack)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkPrimary.withOpacity(0.2)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  Text(
                    'Vista previa de accesorios',
                    style: TextStyle(
                      fontFamily: 'Comic Sans MS',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (_hasGlasses)
                        _buildGlasses(),
                      if (_hasHat)
                        Container(
                          width: 50,
                          height: 30,
                          child: _buildHat(),
                        ),
                      if (_hasBackpack)
                        _buildBackpack(),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildGenderOption(String gender, String label, IconData icon) {
    final isSelected = _gender == gender;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _gender = gender;
          // Resetear índices específicos de género para evitar errores
          _hairStyleIndex = 0;
          _topIndex = 0;
          _bottomIndex = 0;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? (gender == 'boy' ? Colors.blue : Colors.pink)
              : Colors.grey.withOpacity(0.3),
          borderRadius: BorderRadius.circular(30),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: (gender == 'boy' ? Colors.blue : Colors.pink).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey,
              size: 28,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildColorSelector(List<Color> colors, int selectedIndex, Function(int) onSelected) {
    return SizedBox(
      height: 70,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: Container(
              margin: const EdgeInsets.only(right: 15),
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: colors[index],
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.secondary : Colors.transparent,
                  width: 3,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 30,
                      ),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildOptionSelector(List<String> options, int selectedIndex, Function(int) onSelected) {
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.secondary : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  options[index],
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
  
  // Función para aleatorizar el avatar
  void _randomizeAvatar() {
    setState(() {
      // Mantener el género pero aleatorizar todo lo demás
      _skinToneIndex = _random(0, _skinTones.length - 1);
      _eyesIndex = _random(0, _eyeTypes.length - 1);
      _noseIndex = _random(0, _noseTypes.length - 1);
      _mouthIndex = _random(0, _expressions.length - 1);
      _hairStyleIndex = _random(0, _hairStyles[_gender]!.length - 1);
      _hairColorIndex = _random(0, _hairColors.length - 1);
      _topIndex = _random(0, _tops[_gender]!.length - 1);
      _bottomIndex = _random(0, _bottoms[_gender]!.length - 1);
      _shoesIndex = _random(0, _shoes.length - 1);
      
      // Aleatorizar accesorios (30% de probabilidad)
      _hasGlasses = _random(0, 100) < 30;
      _hasHat = _random(0, 100) < 30;
      _hasBackpack = _random(0, 100) < 30;
    });
  }
  
  // Función para generar número aleatorio en un rango
  int _random(int min, int max) {
    return min + (max - min + 1) * DateTime.now().microsecond % (max - min + 1);
  }
}