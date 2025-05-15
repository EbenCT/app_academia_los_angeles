import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../animations/fade_animation.dart';
import '../common/custom_button.dart';

class AvatarCustomizationWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onAvatarUpdated;
  final Map<String, dynamic>? initialAvatar;

  const AvatarCustomizationWidget({
    Key? key,
    required this.onAvatarUpdated,
    this.initialAvatar,
  }) : super(key: key);

  @override
  State<AvatarCustomizationWidget> createState() => _AvatarCustomizationWidgetState();
}

class _AvatarCustomizationWidgetState extends State<AvatarCustomizationWidget> {
  // Avatar properties
  String _gender = 'boy'; // default to boy
  int _skinToneIndex = 0;
  int _hairStyleIndex = 0;
  int _hairColorIndex = 0;
  int _outfitIndex = 0;
  int _accessoryIndex = 0;
  
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
    Colors.amberAccent,
    Colors.red,
    Colors.orange,
    Colors.blue,
    Colors.purple,
    Colors.pink,
  ];
  
  final Map<String, List<String>> _hairStyles = {
    'boy': ['Short', 'Medium', 'Long', 'Curly', 'Spiky'],
    'girl': ['Short', 'Ponytail', 'Long', 'Braids', 'Curly'],
  };
  
  final Map<String, List<String>> _outfits = {
    'boy': ['Casual', 'School', 'Space', 'Sporty', 'Formal'],
    'girl': ['Casual', 'School', 'Space', 'Sporty', 'Formal'],
  };
  
  final Map<String, List<String>> _accessories = {
    'boy': ['None', 'Glasses', 'Hat', 'Backpack', 'Space Helmet'],
    'girl': ['None', 'Glasses', 'Hairband', 'Backpack', 'Space Helmet'],
  };
  
  @override
  void initState() {
    super.initState();
    
    // Initialize from saved avatar if available
    if (widget.initialAvatar != null) {
      _gender = widget.initialAvatar!['gender'] ?? 'boy';
      _skinToneIndex = widget.initialAvatar!['skinToneIndex'] ?? 0;
      _hairStyleIndex = widget.initialAvatar!['hairStyleIndex'] ?? 0;
      _hairColorIndex = widget.initialAvatar!['hairColorIndex'] ?? 0;
      _outfitIndex = widget.initialAvatar!['outfitIndex'] ?? 0;
      _accessoryIndex = widget.initialAvatar!['accessoryIndex'] ?? 0;
    }
  }
  
  void _updateAvatar() {
    final avatarData = {
      'gender': _gender,
      'skinToneIndex': _skinToneIndex,
      'hairStyleIndex': _hairStyleIndex,
      'hairColorIndex': _hairColorIndex,
      'outfitIndex': _outfitIndex,
      'accessoryIndex': _accessoryIndex,
    };
    
    widget.onAvatarUpdated(avatarData);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkSurface
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personaliza tu avatar',
            style: TextStyle(
              fontFamily: 'Comic Sans MS',
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Avatar preview
          FadeAnimation(
            delay: const Duration(milliseconds: 200),
            child: Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // This is a placeholder - in a real app, you'd build a custom avatar
                  // based on the selected properties
                  CircleAvatar(
                    radius: 70,
                    backgroundColor: _skinTones[_skinToneIndex],
                    child: Icon(
                      _gender == 'boy' ? Icons.face : Icons.face_3,
                      size: 100,
                      color: AppColors.primary,
                    ),
                  ),
                  // You would add more layers here for hair, outfits, accessories
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Gender selection
          _buildSectionTitle('Soy un:'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildGenderOption('boy', 'Niño', Icons.face),
              const SizedBox(width: 24),
              _buildGenderOption('girl', 'Niña', Icons.face_3),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Skin tone selector
          _buildSectionTitle('Tono de piel:'),
          _buildColorSelector(_skinTones, _skinToneIndex, (index) {
            setState(() {
              _skinToneIndex = index;
            });
          }),
          
          const SizedBox(height: 16),
          
          // Hair style selector
          _buildSectionTitle('Estilo de cabello:'),
          _buildOptionSelector(
            _hairStyles[_gender]!,
            _hairStyleIndex,
            (index) {
              setState(() {
                _hairStyleIndex = index;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // Hair color selector
          _buildSectionTitle('Color de cabello:'),
          _buildColorSelector(_hairColors, _hairColorIndex, (index) {
            setState(() {
              _hairColorIndex = index;
            });
          }),
          
          const SizedBox(height: 16),
          
          // Outfit selector
          _buildSectionTitle('Vestimenta:'),
          _buildOptionSelector(
            _outfits[_gender]!,
            _outfitIndex,
            (index) {
              setState(() {
                _outfitIndex = index;
              });
            },
          ),
          
          const SizedBox(height: 16),
          
          // Accessory selector
          _buildSectionTitle('Accesorios:'),
          _buildOptionSelector(
            _accessories[_gender]!,
            _accessoryIndex,
            (index) {
              setState(() {
                _accessoryIndex = index;
              });
            },
          ),
          
          const SizedBox(height: 24),
          
          // Save button
          CustomButton(
            text: 'Guardar Avatar',
            onPressed: () {
              _updateAvatar();
              Navigator.pop(context);
            },
            backgroundColor: AppColors.primary,
            icon: Icons.save,
          ),
        ],
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'Comic Sans MS',
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white70
              : Colors.black87,
        ),
      ),
    );
  }
  
  Widget _buildGenderOption(String gender, String label, IconData icon) {
    final isSelected = _gender == gender;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _gender = gender;
          // Reset indices to prevent out-of-bounds errors when switching gender
          _hairStyleIndex = 0;
          _outfitIndex = 0;
          _accessoryIndex = 0;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Comic Sans MS',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildColorSelector(List<Color> colors, int selectedIndex, Function(int) onSelected) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: colors.length,
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors[index],
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  width: 3,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : null,
              ),
              child: isSelected
                  ? const Center(
                      child: Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 24,
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
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          return GestureDetector(
            onTap: () => onSelected(index),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Center(
                child: Text(
                  options[index],
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 14,
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
}