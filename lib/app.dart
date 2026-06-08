import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';
import 'core/network/dio_client.dart';
import 'core/permissions/location_permission_service.dart';
import 'core/storage/secure_storage_service.dart';
import 'providers/attendance_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/employee_provider.dart';
import 'providers/payroll_provider.dart';
import 'screens/splash/splash_screen.dart';
import 'services/attendance_service.dart';
import 'services/auth_service.dart';
import 'services/device_service.dart';
import 'services/employee_service.dart';
import 'services/location_service.dart';
import 'services/payroll_service.dart';

class EmployeeAttendanceApp extends StatelessWidget {
  const EmployeeAttendanceApp({super.key});

  @override
  Widget build(BuildContext context) {
    final storage = SecureStorageService();
    final dioClient = DioClient(storage);
    final authService = AuthService(dioClient);
    final employeeService = EmployeeService(dioClient);
    final locationService = LocationService(LocationPermissionService());
    final deviceService = DeviceService();
    final attendanceService = AttendanceService(
      dioClient,
      locationService,
      deviceService,
    );
    final payrollService = PayrollService(dioClient);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            authService: authService,
            storage: storage,
            dioClient: dioClient,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => EmployeeProvider(employeeService),
        ),
        ChangeNotifierProvider(
          create: (_) => AttendanceProvider(attendanceService),
        ),
        ChangeNotifierProvider(
          create: (_) => PayrollProvider(payrollService),
        ),
      ],
      child: MaterialApp(
        title: 'Salary Calculate',
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.3);
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(scale),
            ),
            child: child ?? const SizedBox.shrink(),
          );
        },
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            surface: AppColors.background,
          ),
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.card,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: AppColors.card,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
