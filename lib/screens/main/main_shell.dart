import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../attendance/check_in_out_screen.dart';
import '../attendance/my_working_hours_screen.dart';
import '../home/employee_home_screen.dart';
import '../profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => MainShellState();
}

class MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  void goToTab(int index) {
    if (index >= 0 && index < 4) {
      setState(() => _currentIndex = index);
    }
  }

  late final List<Widget> _pages = [
    EmployeeHomeScreen(onNavigateToCheckIn: () => goToTab(1)),
    const CheckInOutScreen(),
    const MyWorkingHoursScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: goToTab,
        backgroundColor: AppColors.card,
        indicatorColor: AppColors.primary.withValues(alpha: 0.15),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.fingerprint),
            selectedIcon: Icon(Icons.fingerprint),
            label: 'Chấm công',
          ),
          NavigationDestination(
            icon: Icon(Icons.schedule_outlined),
            selectedIcon: Icon(Icons.schedule),
            label: 'Giờ làm',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}
