import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../common/loading_indicator.dart';

/// Base para pantallas con estructura común
class ScreenBase extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final bool isLoading;
  final String? loadingMessage;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final Color? backgroundColor;
  final Color? appBarColor;
  final PreferredSizeWidget? bottomAppBar;
  final bool useAstronautLoading;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  
  const ScreenBase({
    Key? key,
    required this.title,
    required this.body,
    this.actions,
    this.isLoading = false,
    this.loadingMessage,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.backgroundColor,
    this.appBarColor,
    this.bottomAppBar,
    this.useAstronautLoading = true,
    this.showBackButton = false,
    this.onBackPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ?? Theme.of(context).scaffoldBackgroundColor;
    final barColor = appBarColor ?? 
                     (isDarkMode ? AppColors.darkPrimary : AppColors.primary);
    
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(
            fontFamily: 'Comic Sans MS',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: barColor,
        centerTitle: true,
        elevation: 0,
        actions: actions,
        leading: showBackButton ? 
          IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
          ) : null,
        bottom: bottomAppBar,
      ),
      body: Stack(
        children: [
          body,
          if (isLoading)
            _buildLoadingOverlay(),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
  
  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black54,
      child: LoadingIndicator(
        message: loadingMessage,
        useAstronaut: useAstronautLoading,
        size: 150,
      ),
    );
  }
  
  /// Constructor para pantallas de profesores con estilo específico
  factory ScreenBase.forTeacher({
    required String title,
    required Widget body,
    List<Widget>? actions,
    bool isLoading = false,
    String? loadingMessage,
    Widget? bottomNavigationBar,
    Widget? floatingActionButton,
    PreferredSizeWidget? bottomAppBar,
    bool showBackButton = false,
    VoidCallback? onBackPressed,
  }) => ScreenBase(
    title: title,
    body: body,
    actions: actions,
    isLoading: isLoading,
    loadingMessage: loadingMessage,
    bottomNavigationBar: bottomNavigationBar,
    floatingActionButton: floatingActionButton,
    appBarColor: AppColors.secondary,
    bottomAppBar: bottomAppBar,
    showBackButton: showBackButton,
    onBackPressed: onBackPressed,
  );
  
  /// Constructor para pantallas de estudiantes con estilo específico
  factory ScreenBase.forStudent({
    required String title,
    required Widget body,
    List<Widget>? actions,
    bool isLoading = false,
    String? loadingMessage,
    Widget? bottomNavigationBar,
    Widget? floatingActionButton,
    PreferredSizeWidget? bottomAppBar,
    bool showBackButton = false,
    VoidCallback? onBackPressed,
  }) => ScreenBase(
    title: title,
    body: body,
    actions: actions,
    isLoading: isLoading,
    loadingMessage: loadingMessage,
    bottomNavigationBar: bottomNavigationBar,
    floatingActionButton: floatingActionButton,
    appBarColor: AppColors.primary,
    bottomAppBar: bottomAppBar,
    showBackButton: showBackButton,
    onBackPressed: onBackPressed,
  );
}