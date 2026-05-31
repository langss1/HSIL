import 'package:flutter/material.dart';
import '../../core/themes/color_palette.dart';
import 'dashboard_screen.dart';
import 'gps_validation_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  List<Widget> get _pages => [
    const DashboardScreen(),
    const GPSValidationScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgCard : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.3) : AppColors.deepNavy.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _onTabTapped,
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedItemColor: AppColors.safetyOrange,
              unselectedItemColor: AppColors.textSecondary,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              type: BottomNavigationBarType.fixed,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              items: const [
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Icon(Icons.home_rounded, size: 26),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Icon(Icons.home_rounded, size: 28),
                  ),
                  label: 'Beranda',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Icon(Icons.photo_camera_rounded, size: 26),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Icon(Icons.photo_camera_rounded, size: 28),
                  ),
                  label: 'Absen',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Icon(Icons.history_rounded, size: 26),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Icon(Icons.history_rounded, size: 28),
                  ),
                  label: 'Riwayat',
                ),
                BottomNavigationBarItem(
                  icon: Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Icon(Icons.person_rounded, size: 26),
                  ),
                  activeIcon: Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Icon(Icons.person_rounded, size: 28),
                  ),
                  label: 'Profil',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderScreen({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.deepNavy : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(title, style: TextStyle(color: isDark ? Colors.white : AppColors.deepNavy)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.safetyOrange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: AppColors.safetyOrange),
            ),
            const SizedBox(height: 24),
            Text(
              'UI Soon',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.deepNavy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fitur ini sedang dalam pengembangan.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
