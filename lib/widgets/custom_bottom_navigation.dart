import 'package:flutter/material.dart';
import 'package:fit_agent/themes/app_theme.dart';
import 'package:fit_agent/screens/home_screen.dart';
import 'package:fit_agent/screens/favorites_screen.dart';
import 'package:fit_agent/screens/profile_screen.dart';
import 'package:fit_agent/screens/preferences_screen.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  
  const CustomBottomNavigation({super.key, this.currentIndex = 0});

  @override
  Widget build(BuildContext context) {
    void onItemTap(int idx) {
      if (idx == currentIndex) return; // No navegar si ya estamos en esa pantalla
      
      switch (idx) {
        case 0: // Inicio
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
          break;
        case 1: // Favoritos
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const FavoritesScreen()),
          );
          break;
        case 2: // Perfil
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
          break;
        case 3: // Preferencias
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PreferencesScreen()),
          );
          break;
      }
    }

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppTheme.verdeOscuro,
      selectedItemColor: AppTheme.blanco,
      unselectedItemColor: AppTheme.grisClaro.withOpacity(0.7),
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
      currentIndex: currentIndex,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Inicio",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: "Favoritos",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "Perfil",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: "Preferencias",
        ),
      ],
      onTap: onItemTap,
    );
  }
}
