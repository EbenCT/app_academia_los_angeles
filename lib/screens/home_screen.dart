import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../constants/app_constants.dart';
import '../providers/theme_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/animations/bounce_animation.dart';
import '../widgets/animations/fade_animation.dart';
import '../widgets/common/custom_button.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  int _selectedTab = 0;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.background,
      body: Stack(
        children: [
          // Fondo decorativo
          _buildBackgroundDecorations(),
          
          // Contenido principal
          SafeArea(
            child: Column(
              children: [
                // Barra superior con avatar y título
                _buildAppBar(context),
                
                // Contenido desplazable
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() => _selectedTab = index);
                    },
                    children: [
                      _buildMainContent(),
                      _buildChallengesContent(),
                      _buildProfileContent(),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Menú inferior animado
          _buildBottomNavigationBar(),
          
          // Botón flotante de asistente
          _buildFloatingAssistantButton(),
        ],
      ),
    );
  }

  Widget _buildBackgroundDecorations() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  // Burbujas decorativas
                  Positioned(
                    top: 50,
                    left: 30,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: const Color(0xFFFFD600).withOpacity(0.2),
                    ).animate().scale(delay: 200.ms),
                  ),
                  Positioned(
                    top: 100,
                    right: 30,
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: const Color(0xFFFF5252).withOpacity(0.2),
                    ).animate().scale(delay: 300.ms),
                  ),
                  Positioned(
                    bottom: 50,
                    left: 60,
                    child: CircleAvatar(
                      radius: 25,
                      backgroundColor: const Color(0xFF00E676).withOpacity(0.2),
                    ).animate().scale(delay: 400.ms),
                  ),
                  Positioned(
                    bottom: 100,
                    right: 60,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: const Color(0xFF651FFF).withOpacity(0.2),
                    ).animate().scale(delay: 500.ms),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          // Logo del colegio
          BounceAnimation(
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'LA',
                  style: GoogleFonts.comicNeue(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 10),
          
          // Título
          Expanded(
            child: FadeAnimation(
              delay: 100.ms,
              child: Text(
                AppConstants.appTitle,
                style: GoogleFonts.comicNeue(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
            ),
          ),
          
          // Avatar del estudiante
          BounceAnimation(
            delay: 200.ms,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFFFC107),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Ojos
                  Positioned(
                    top: 15,
                    left: 15,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 15,
                    right: 15,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  
                  // Boca
                  Positioned(
                    bottom: 15,
                    child: CustomPaint(
                      size: const Size(20, 10),
                      painter: _SmilePainter(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            
            // Tarjeta de nivel y progreso
            FadeAnimation(
              delay: 300.ms,
              child: _buildLevelCard(),
            ),
            
            const SizedBox(height: 20),
            
            // Monedas y puntos
            FadeAnimation(
              delay: 400.ms,
              child: _buildPointsCard(),
            ),
            
            const SizedBox(height: 20),
            
            // Título de materias
            FadeAnimation(
              delay: 500.ms,
              child: _buildSectionTitle('Mis Aventuras', Icons.explore),
            ),
            
            const SizedBox(height: 10),
            
            // Tarjetas de materias
            FadeAnimation(
              delay: 600.ms,
              child: _buildSubjectCard(
                'Matemáticas',
                '65% completado!',
                0.65,
                const Color(0xFF651FFF),
                '1+1',
                3,
              ),
            ),
            
            const SizedBox(height: 15),
            
            FadeAnimation(
              delay: 700.ms,
              child: _buildSubjectCard(
                'Ciencias',
                '48% completado!',
                0.48,
                const Color(0xFF00E676),
                '🧪',
                2,
              ),
            ),
            
            const SizedBox(height: 15),
            
            FadeAnimation(
              delay: 800.ms,
              child: _buildSubjectCard(
                'Historia',
                '75% completado!',
                0.75,
                const Color(0xFFFF5252),
                '📖',
                1,
              ),
            ),
            
            const SizedBox(height: 15),
            
            FadeAnimation(
              delay: 900.ms,
              child: _buildSubjectCard(
                'Lenguaje',
                '52% completado!',
                0.52,
                const Color(0xFFFF9800),
                'ABC',
                4,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Título de logros
            FadeAnimation(
              delay: 1000.ms,
              child: _buildSectionTitle('¡Mis Trofeos!', Icons.emoji_events),
            ),
            
            const SizedBox(height: 10),
            
            // Logros recientes
            FadeAnimation(
              delay: 1100.ms,
              child: _buildAchievementsRow(),
            ),
            
            const SizedBox(height: 20),
            
            // Título de misiones
            FadeAnimation(
              delay: 1200.ms,
              child: _buildSectionTitle('Misiones de Hoy', Icons.assignment),
            ),
            
            const SizedBox(height: 10),
            
            // Misiones del día
            FadeAnimation(
              delay: 1300.ms,
              child: _buildDailyMissionCard(
                '¡Resuelve 5 problemas!',
                'Matemáticas - Nivel 8',
                const Color(0xFF651FFF),
                '1+1',
                50,
              ),
            ),
            
            const SizedBox(height: 15),
            
            FadeAnimation(
              delay: 1400.ms,
              child: _buildDailyMissionCard(
                '¡Completa el experimento!',
                'Ciencias - Nivel 5',
                const Color(0xFF00E676),
                '🧪',
                75,
              ),
            ),
            
            const SizedBox(height: 80), // Espacio para el menú inferior
          ],
        ),
      ),
    );
  }

  Widget _buildChallengesContent() {
    return Center(
      child: Text(
        'Pantalla de Desafíos',
        style: GoogleFonts.comicNeue(fontSize: 24),
      ),
    );
  }

  Widget _buildProfileContent() {
    return Center(
      child: Text(
        'Pantalla de Perfil',
        style: GoogleFonts.comicNeue(fontSize: 24),
      ),
    );
  }

  Widget _buildLevelCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Nivel 7: Explorador Espacial!',
            style: GoogleFonts.comicNeue(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          
          const SizedBox(height: 15),
          
          // Barra de progreso con estrellas
          Stack(
            children: [
              Container(
                height: 15,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              Container(
                height: 15,
                width: MediaQuery.of(context).size.width * 0.6, // 60% de progreso
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(10),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00E676), Color(0xFF00C853)],
                  ),
                ),
              ),
              
              // Estrellas decorativas
              Positioned(
                left: MediaQuery.of(context).size.width * 0.3 - 15,
                top: -5,
                child: const Icon(Icons.star, color: Color(0xFFFFC107), size: 24),
              ),
              Positioned(
                left: MediaQuery.of(context).size.width * 0.6 - 15,
                top: -5,
                child: const Icon(Icons.star, color: Color(0xFFFFC107), size: 24),
              ),
            ],
          ),
          
          const SizedBox(height: 10),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '1500/2500 XP',
                style: GoogleFonts.comicNeue(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPointsCard() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Monedas
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD600),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: const Color(0xFFFF9800), width: 2),
            ),
            child: Center(
              child: Text(
                '\$',
                style: GoogleFonts.comicNeue(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF5D4037),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 10),
          
          Text(
            '750 monedas',
            style: GoogleFonts.comicNeue(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
          
          const Spacer(),
          
          // Puntos
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: AppColors.primary, width: 2),
            ),
            child: Center(
              child: Text(
                '⭐',
                style: GoogleFonts.comicNeue(
                  fontSize: 20,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 10),
          
          Text(
            '1200 puntos',
            style: GoogleFonts.comicNeue(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.comicNeue(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectCard(String title, String progressText, double progress, Color color, String emoji, int pendingTasks) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Icono decorativo
          Positioned(
            left: 10,
            top: 10,
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
          
          // Contenido
          Padding(
            padding: const EdgeInsets.only(left: 70),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.comicNeue(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 5),
                
                Text(
                  progressText,
                  style: GoogleFonts.comicNeue(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 10),
                
                // Barra de progreso
                Stack(
                  children: [
                    Container(
                      height: 10,
                      width: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    Container(
                      height: 10,
                      width: 100 * progress,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Notificación de tareas pendientes
          if (pendingTasks > 0)
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD600),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '$pendingTasks',
                    style: GoogleFonts.comicNeue(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF5D4037),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAchievementsRow() {
    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildAchievementBadge('¡Matemático!', const Color(0xFFFFD600), const Color(0xFFFF9800)),
              const SizedBox(width: 15),
              _buildAchievementBadge('¡Científico!', const Color(0xFFE0E0E0), const Color(0xFFBDBDBD)),
              const SizedBox(width: 15),
              _buildAchievementBadge('¡Lector!', const Color(0xFFBF360C), const Color(0xFF8D2000)),
              const SizedBox(width: 15),
              _buildAchievementBadge('¡Artista!', const Color(0xFF651FFF), const Color(0xFF7C4DFF)),
              const SizedBox(width: 15),
              _buildAchievementBadge('¡Deportista!', const Color(0xFF00E676), const Color(0xFF00C853)),
            ],
          ),
        ),
        
        const SizedBox(height: 15),
        
        CustomButton(
          text: '¡Ver todos!',
          onPressed: () {},
          isOutlined: true,
          backgroundColor: AppColors.primary,
          textColor: Colors.white,
          height: 40,
          width: 150,
        ),
      ],
    );
  }

  Widget _buildAchievementBadge(String title, Color color, Color baseColor) {
    return BounceAnimation(
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: Center(
              child: Container(
                width: 40,
                height: 20,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 5),
          
          Text(
            title,
            style: GoogleFonts.comicNeue(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.titleLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyMissionCard(String title, String subtitle, Color color, String emoji, int coins) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Indicador de color
          Container(
            width: 8,
            height: 60,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          
          const SizedBox(width: 15),
          
          // Icono
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.3),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          
          const SizedBox(width: 15),
          
          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.comicNeue(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                Text(
                  subtitle,
                  style: GoogleFonts.comicNeue(
                    fontSize: 14,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          
          // Recompensa
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFFFD600),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(
                '+$coins',
                style: GoogleFonts.comicNeue(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF5D4037),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Inicio
            _buildNavItem(0, Icons.home, 'Inicio'),
            
            // Desafíos
            Stack(
              alignment: Alignment.topRight,
              children: [
                _buildNavItem(1, Icons.emoji_events, 'Desafíos'),
                if (_selectedTab != 1)
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF5252),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Center(
                      child: Text(
                        '2',
                        style: GoogleFonts.comicNeue(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            
            // Perfil
            _buildNavItem(2, Icons.person, 'Perfil'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedTab == index;
    
    return GestureDetector(
      onTap: () {
        setState(() => _selectedTab = index);
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isSelected ? 50 : 40,
            height: isSelected ? 50 : 40,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withOpacity(0.2) : Colors.transparent,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              icon,
              size: isSelected ? 28 : 24,
              color: isSelected ? AppColors.primary : Colors.grey,
            ),
          ),
          
          const SizedBox(height: 5),
          
          Text(
            label,
            style: GoogleFonts.comicNeue(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.primary : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingAssistantButton() {
    return Positioned(
      right: 20,
      bottom: 90,
      child: BounceAnimation(
        infinite: true,
        child: FloatingActionButton(
          onPressed: () {
            // Acción del asistente
          },
          backgroundColor: AppColors.primary,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Ojos
              const Positioned(
                left: 15,
                top: 15,
                child: CircleAvatar(
                  radius: 4,
                  backgroundColor: Colors.white,
                ),
              ),
              const Positioned(
                right: 15,
                top: 15,
                child: CircleAvatar(
                  radius: 4,
                  backgroundColor: Colors.white,
                ),
              ),
              
              // Boca
              Positioned(
                bottom: 15,
                child: CustomPaint(
                  size: const Size(20, 10),
                  painter: _SmilePainter(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmilePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    
    final path = Path();
    path.moveTo(0, size.height);
    path.quadraticBezierTo(
      size.width / 2, size.height * 2, 
      size.width, size.height,
    );
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}