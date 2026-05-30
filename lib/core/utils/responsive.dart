import 'package:flutter/material.dart';

/// Helper responsive dùng chung cho mọi màn hình.
class ResponsiveHelper {
  ResponsiveHelper._();

  static const double maxContentWidth = 640;
  static const double bottomNavPadding = 100;

  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  static double textScale(BuildContext context) =>
      MediaQuery.textScalerOf(context).scale(1);

  static bool isSmallPhone(BuildContext context) => screenWidth(context) < 360;

  static bool isNormalPhone(BuildContext context) {
    final w = screenWidth(context);
    return w >= 360 && w < 430;
  }

  static bool isLargePhone(BuildContext context) {
    final w = screenWidth(context);
    return w >= 430 && w < 600;
  }

  static bool isTablet(BuildContext context) => screenWidth(context) >= 600;

  static double horizontalPadding(BuildContext context) {
    if (isTablet(context)) return 32;
    if (isLargePhone(context)) return 24;
    if (isNormalPhone(context)) return 20;
    return 16;
  }

  static double verticalSpacing(BuildContext context, double base) {
    final scale = isSmallPhone(context) ? 0.85 : (isTablet(context) ? 1.1 : 1.0);
    final textFactor = textScale(context).clamp(1.0, 1.3);
    return base * scale * (textFactor > 1.15 ? 1.05 : 1.0);
  }

  static double responsiveFont(BuildContext context, double base) {
    final w = screenWidth(context);
    double factor = 1.0;
    if (w < 360) factor = 0.92;
    if (w >= 430 && w < 600) factor = 1.02;
    if (w >= 600) factor = 1.05;

    final scaled = base * factor * textScale(context);
    return scaled.clamp(base * 0.85, base * 1.25);
  }

  static double responsiveIconSize(BuildContext context, double base) {
    if (isSmallPhone(context)) return base * 0.9;
    if (isTablet(context)) return base * 1.1;
    return base;
  }

  static double cardRadius(BuildContext context) {
    if (isSmallPhone(context)) return 18;
    if (isLargePhone(context) || isTablet(context)) return 24;
    return 22;
  }

  static double headerHeight(BuildContext context, {bool compact = false}) {
    if (compact) return profileBannerHeight(context);
    return homeHeaderMinHeight(context);
  }

  /// Chiều cao banner gradient Profile (chỉ nền xanh).
  static double profileBannerHeight(BuildContext context) {
    if (isSmallPhone(context)) return 100;
    if (isTablet(context)) return 130;
    return 118;
  }

  /// Chiều cao tối thiểu header Home (nội dung quyết định, không fixed quá cao).
  static double homeHeaderMinHeight(BuildContext context) {
    if (isSmallPhone(context)) return 108;
    if (isNormalPhone(context)) return 118;
    if (isLargePhone(context)) return 128;
    return 138;
  }

  /// Overlap profile card lên banner.
  static double profileCardOverlap(BuildContext context) => 36;

  static double loginHeaderHeight(BuildContext context) {
    if (isSmallPhone(context)) return 140;
    if (isTablet(context)) return 200;
    return 170;
  }

  static double buttonHeight(BuildContext context) {
    if (isSmallPhone(context)) return 48;
    return 52;
  }

  static double checkInButtonSize(BuildContext context) {
    final w = screenWidth(context);
    final size = w * 0.42;
    return size.clamp(140.0, 200.0);
  }

  static double avatarSize(BuildContext context, {bool profile = false}) {
    if (profile) {
      if (isSmallPhone(context)) return 80;
      if (isLargePhone(context)) return 104;
      if (isTablet(context)) return 112;
      return 92;
    }
    if (isSmallPhone(context)) return 52;
    if (isTablet(context)) return 64;
    return 58;
  }

  static int statGridCrossAxisCount(BuildContext context) {
    if (isTablet(context) && screenWidth(context) >= 720) return 4;
    return 2;
  }

  static double statGridAspectRatio(BuildContext context) {
    if (isSmallPhone(context)) return 1.25;
    if (textScale(context) > 1.2) return 1.15;
    return 1.35;
  }

  static EdgeInsets pagePadding(BuildContext context, {bool withBottomNav = false}) {
    final h = horizontalPadding(context);
    final bottom = withBottomNav ? bottomNavPadding : verticalSpacing(context, 24);
    return EdgeInsets.fromLTRB(h, verticalSpacing(context, 16), h, bottom);
  }

  static Widget constrainContent(BuildContext context, Widget child) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isTablet(context) ? maxContentWidth : double.infinity,
        ),
        child: child,
      ),
    );
  }
}

/// Làm sạch text động từ backend, tránh null và ký tự lỗi encoding.
String safeDisplayText(
  String? value, {
  String fallback = '--',
  int maxLength = 200,
}) {
  if (value == null || value.trim().isEmpty || value.toLowerCase() == 'null') {
    return fallback;
  }
  var text = value.trim();
  if (text.contains('�')) {
    return fallback;
  }
  if (text.length > maxLength) {
    text = text.substring(0, maxLength);
  }
  return text;
}

String safePosition(String? position) {
  final p = position?.trim() ?? '';
  if (p.isEmpty || p.contains('�') || p.toLowerCase() == 'null') {
    return 'Nhân viên';
  }
  return p;
}

String safeBranchName(String? name) {
  return safeDisplayText(name, fallback: 'Chưa gán chi nhánh');
}

String safeAddress(String? address) {
  if (address == null || address.trim().isEmpty || address.contains('�')) {
    return '--';
  }
  return address.trim();
}
