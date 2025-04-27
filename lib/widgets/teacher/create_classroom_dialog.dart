// lib/widgets/teacher/create_classroom_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/classroom_provider.dart';
import '../../theme/app_colors.dart';
import '../animations/fade_animation.dart';
import '../common/custom_button.dart';
import '../common/custom_text_field.dart';

class CreateClassroomDialog extends StatefulWidget {
  const CreateClassroomDialog({
    super.key,
  });

  @override
  State<CreateClassroomDialog> createState() => _CreateClassroomDialogState();
}

class _CreateClassroomDialogState extends State<CreateClassroomDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  int? _selectedCourseId;
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final classroomProvider = Provider.of<ClassroomProvider>(context);
    final courses = classroomProvider.courses;
    
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '¡Crea una nueva aula!',
                  style: TextStyle(
                    fontFamily: 'Comic Sans MS',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(height: 16),
                FadeAnimation(
                  delay: const Duration(milliseconds: 200),
                  child: CustomTextField(
                    controller: _nameController,
                    hintText: 'Nombre del aula',
                    prefixIcon: Icons.class_rounded,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Por favor ingresa un nombre para el aula';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                FadeAnimation(
                  delay: const Duration(milliseconds: 300),
                  child: CustomTextField(
                    controller: _descriptionController,
                    hintText: 'Descripción (opcional)',
                    prefixIcon: Icons.description_rounded,
                  ),
                ),
                const SizedBox(height: 16),
                FadeAnimation(
                  delay: const Duration(milliseconds: 400),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        isExpanded: true,
                        hint: Text(
                          'Selecciona un curso',
                          style: TextStyle(
                            fontFamily: 'Comic Sans MS',
                            color: AppColors.textHint,
                          ),
                        ),
                        value: _selectedCourseId,
                        items: courses.map((course) {
                          return DropdownMenuItem<int>(
                            value: course.id,
                            child: Text(
                              course.title,
                              style: TextStyle(fontFamily: 'Comic Sans MS'),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCourseId = value;
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: 'Cancelar',
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        isOutlined: true,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomButton(
                        text: 'Crear',
                        onPressed: () => _createClassroom(context),
                        backgroundColor: AppColors.secondary,
                        isLoading: classroomProvider.isLoading,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Future<void> _createClassroom(BuildContext context) async {
    if (_formKey.currentState!.validate() && _selectedCourseId != null) {
      final classroomProvider = Provider.of<ClassroomProvider>(context, listen: false);
      
      final success = await classroomProvider.createClassroom(
        _nameController.text.trim(),
        _descriptionController.text.trim().isNotEmpty 
            ? _descriptionController.text.trim() 
            : null,
        _selectedCourseId!,
      );
      
      if (success && mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '¡Aula creada exitosamente!',
              style: TextStyle(fontFamily: 'Comic Sans MS'),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              classroomProvider.error ?? 'Error al crear el aula',
              style: TextStyle(fontFamily: 'Comic Sans MS'),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } else if (_selectedCourseId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor selecciona un curso',
            style: TextStyle(fontFamily: 'Comic Sans MS'),
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}