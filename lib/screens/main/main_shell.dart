import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/responsive.dart';
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

  double _navHeight(BuildContext context) {
    if (ResponsiveHelper.isSmallPhone(context)) return 62;
    return 68;
  }

  double _labelSize(BuildContext context) {
    if (ResponsiveHelper.isSmallPhone(context)) return 11;
    return 12;
  }

  @override
  Widget build(BuildContext context) {
    final navH = _navHeight(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, -4),
              ),
            ],
            border: Border(
              top: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
            ),
          ),
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              height: navH,
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                return TextStyle(
                  fontSize: _labelSize(context),
                  fontWeight: states.contains(WidgetState.selected)
                      ? FontWeight.w600
                      : FontWeight.w500,
                );
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                final selected = states.contains(WidgetState.selected);
                return IconThemeData(
                  size: ResponsiveHelper.responsiveIconSize(context, selected ? 24 : 22),
                  color: selected ? AppColors.primary : AppColors.textSecondary,
                );
              }),
            ),
            child: NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: goToTab,
              backgroundColor: Colors.transparent,
              elevation: 0,
              indicatorColor: AppColors.lightBlue,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Trang chủ',
                ),
                NavigationDestination(
                  icon: Icon(Icons.fingerprint_outlined),
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
          ),
        ),
      ),
    );
  }
}
