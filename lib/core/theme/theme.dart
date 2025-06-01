import 'package:flutter/material.dart';

// Define Colors based on enhanced UI Plan
const Color primaryDarkBlue = Color(0xFF1A365D); // Darker Blue for gradients
const Color primaryColor = Color(0xFF1976D2); // Medium Blue
const Color primaryLightColor = Color(0xFF2196F3); // Lighter Blue
const Color accentGreen = Color(0xFF4CAF50);
const Color accentGreenLight = Color(0xFF8BC34A);
const Color accentOrange = Color(0xFFFF9800);
const Color accentOrangeLight = Color(0xFFFFC107);
const Color accentRed = Color(0xFFF44336);
const Color accentRedDark = Color(0xFFE53935);
const Color lightBackgroundColor = Color(0xFFF5F5F5);
const Color darkTextColor = Color(0xFF212121);
const Color mediumTextColor = Color(0xFF424242);
const Color lightTextColor = Color(0xFFFFFFFF);
const Color cardBackgroundColor = Color(0xFFFFFFFF);

// Define Gradients
const LinearGradient primaryGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [primaryDarkBlue, primaryColor],
);

const LinearGradient secondaryGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [primaryColor, primaryLightColor],
);

const LinearGradient successGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [accentGreen, accentGreenLight],
);

const LinearGradient warningGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [accentOrange, accentOrangeLight],
);

const LinearGradient errorGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [accentRed, accentRedDark],
);

// Define Text Styles with improved hierarchy
final TextTheme appTextTheme = TextTheme(
  displayLarge: TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: darkTextColor,
  ),
  displayMedium: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: darkTextColor,
  ),
  headlineLarge: TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: darkTextColor,
  ),
  headlineMedium: TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: darkTextColor,
  ),
  headlineSmall: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: darkTextColor,
  ),
  titleLarge: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: darkTextColor,
  ),
  titleMedium: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: darkTextColor,
  ),
  titleSmall: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: darkTextColor,
  ),
  bodyLarge: TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: darkTextColor,
  ),
  bodyMedium: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: darkTextColor,
  ),
  bodySmall: TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: mediumTextColor,
  ),
  labelLarge: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: lightTextColor,
  ), // For buttons
  labelMedium: TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: lightTextColor,
  ),
  labelSmall: TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    color: mediumTextColor,
  ),
);

// Define App Theme with enhanced styling
final ThemeData appTheme = ThemeData(
  primaryColor: primaryColor,
  scaffoldBackgroundColor: lightBackgroundColor,
  colorScheme: ColorScheme.light(
    primary: primaryColor,
    secondary: accentGreen,
    error: accentRed,
    onPrimary: lightTextColor,
    onSecondary: lightTextColor,
    onError: lightTextColor,
    surface: cardBackgroundColor,
    onSurface: darkTextColor,
  ),
  textTheme: appTextTheme,
  appBarTheme: AppBarTheme(
    backgroundColor: primaryColor,
    foregroundColor: lightTextColor,
    elevation: 4.0,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: lightTextColor,
    ),
    centerTitle: false, // Will be adjusted for RTL in the app
  ),
  cardTheme: CardThemeData(
    color: cardBackgroundColor,
    elevation: 4.0, // Increased from 2.0
    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16.0), // Increased from 12.0
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: Colors.grey.shade400),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(color: Colors.grey.shade400),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: primaryColor, width: 2.0),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: accentRed, width: 1.0),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: accentRed, width: 2.0),
    ),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(
      vertical: 16.0,
      horizontal: 12.0,
    ),
    // Enhanced error styling
    errorStyle: TextStyle(
      color: accentRed,
      fontSize: 12.0,
      fontWeight: FontWeight.w500,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: lightTextColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      textStyle: appTextTheme.labelLarge,
      elevation: 4.0, // Increased from default
      shadowColor: primaryColor.withValues(alpha: .5),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: primaryColor,
      side: const BorderSide(color: primaryColor, width: 1.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      textStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: primaryColor,
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: primaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      textStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
    ),
  ),
  sliderTheme: SliderThemeData(
    activeTrackColor: primaryColor,
    inactiveTrackColor: primaryColor.withValues(alpha: .3),
    thumbColor: primaryColor,
    overlayColor: primaryColor.withValues(alpha: .2),
    valueIndicatorColor: primaryColor,
    valueIndicatorTextStyle: const TextStyle(color: lightTextColor),
    trackHeight: 4.0,
    thumbShape: const RoundSliderThumbShape(
      enabledThumbRadius: 12.0, // Larger for better touch target
    ),
    overlayShape: const RoundSliderOverlayShape(
      overlayRadius: 24.0, // Larger for better touch feedback
    ),
    trackShape: const RoundedRectSliderTrackShape(),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith<Color?>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return primaryColor;
      }
      return Colors.grey.shade400; // Custom color for unselected
    }),
    trackColor: WidgetStateProperty.resolveWith<Color?>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return primaryColor.withValues(alpha: .5);
      }
      return Colors.grey.shade300; // Custom color for unselected
    }),
    trackOutlineColor: WidgetStateProperty.resolveWith<Color?>((
      Set<WidgetState> states,
    ) {
      if (states.contains(WidgetState.selected)) {
        return Colors.transparent;
      }
      return Colors
          .grey
          .shade400; // Color for the outline when the switch is off
    }),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: Colors.white,
    selectedItemColor: primaryColor,
    unselectedItemColor: Colors.grey.shade600,
    selectedLabelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
    unselectedLabelStyle: TextStyle(fontSize: 12),
    type: BottomNavigationBarType.fixed,
    elevation: 8.0,
  ),
  // Enhanced NavigationBar theme for Material 3
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: Colors.white,
    indicatorColor: primaryColor.withValues(alpha: .2),
    labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
      if (states.contains(WidgetState.selected)) {
        return TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: primaryColor,
        );
      }
      return TextStyle(fontSize: 12, color: Colors.grey.shade600);
    }),
    iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
      if (states.contains(WidgetState.selected)) {
        return const IconThemeData(color: primaryColor);
      }
      return IconThemeData(color: Colors.grey.shade600);
    }),
    elevation: 8.0,
    height: 80.0, // Taller navigation bar
  ),
  listTileTheme: ListTileThemeData(
    iconColor: primaryColor,
    textColor: darkTextColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
    tileColor: Colors.transparent,
    selectedTileColor: primaryColor.withValues(alpha: .1),
  ),
  dividerTheme: const DividerThemeData(
    color: Color(0xFFE0E0E0),
    thickness: 1.0,
    indent: 16.0,
    endIndent: 16.0,
  ),
  progressIndicatorTheme: const ProgressIndicatorThemeData(
    color: primaryColor,
    circularTrackColor: Color(0xFFE0E0E0),
    linearTrackColor: Color(0xFFE0E0E0),
  ),
  tooltipTheme: TooltipThemeData(
    decoration: BoxDecoration(
      color: Colors.grey.shade800,
      borderRadius: BorderRadius.circular(8.0),
    ),
    textStyle: const TextStyle(color: Colors.white),
  ),
  snackBarTheme: SnackBarThemeData(
    backgroundColor: Colors.grey.shade900,
    contentTextStyle: const TextStyle(color: Colors.white),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    behavior: SnackBarBehavior.floating,
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: Colors.white,
    elevation: 16.0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    elevation: 6.0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
  ),
  useMaterial3: true,
);

// Define Dark Theme based on the same design principles
final ThemeData darkAppTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: primaryColor,
  scaffoldBackgroundColor: const Color(0xFF121212),
  colorScheme: ColorScheme.dark(
    primary: primaryLightColor,
    secondary: accentGreenLight,
    error: accentRed,
    onPrimary: lightTextColor,
    onSecondary: lightTextColor,
    onError: lightTextColor,
    surface: const Color(0xFF1E1E1E),
    onSurface: lightTextColor,
  ),
  textTheme: TextTheme(
    displayLarge: appTextTheme.displayLarge?.copyWith(color: lightTextColor),
    displayMedium: appTextTheme.displayMedium?.copyWith(color: lightTextColor),
    headlineLarge: appTextTheme.headlineLarge?.copyWith(color: lightTextColor),
    headlineMedium: appTextTheme.headlineMedium?.copyWith(
      color: lightTextColor,
    ),
    headlineSmall: appTextTheme.headlineSmall?.copyWith(color: lightTextColor),
    titleLarge: appTextTheme.titleLarge?.copyWith(color: lightTextColor),
    titleMedium: appTextTheme.titleMedium?.copyWith(color: lightTextColor),
    titleSmall: appTextTheme.titleSmall?.copyWith(color: lightTextColor),
    bodyLarge: appTextTheme.bodyLarge?.copyWith(color: lightTextColor),
    bodyMedium: appTextTheme.bodyMedium?.copyWith(color: lightTextColor),
    bodySmall: appTextTheme.bodySmall?.copyWith(color: Colors.grey.shade300),
    labelLarge: appTextTheme.labelLarge,
    labelMedium: appTextTheme.labelMedium,
    labelSmall: appTextTheme.labelSmall?.copyWith(color: Colors.grey.shade300),
  ),
  // Other theme properties would be defined similarly to light theme but with dark mode colors
  useMaterial3: true,
);

// Custom widget for gradient containers
class GradientContainer extends StatelessWidget {
  final Widget child;
  final LinearGradient gradient;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadius? borderRadius;
  final double? height;
  final double? width;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  const GradientContainer({
    super.key,
    required this.child,
    required this.gradient,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.borderRadius,
    this.height,
    this.width,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: borderRadius,
        border: border,
        boxShadow: boxShadow,
      ),
      child: child,
    );
  }
}

// Custom widget for gradient buttons
class GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final LinearGradient gradient;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;
  final double elevation;
  final double? height;
  final double? width;

  const GradientButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.gradient = primaryGradient,
    this.padding = const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
    this.borderRadius,
    this.elevation = 4.0,
    this.height,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final borderRadius = this.borderRadius ?? BorderRadius.circular(12.0);

    return Material(
      elevation: elevation,
      borderRadius: borderRadius,
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: borderRadius,
        child: Ink(
          height: height,
          width: width,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: borderRadius,
          ),
          child: Container(
            padding: padding,
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}

// Custom widget for status indicators
class StatusIndicator extends StatelessWidget {
  final String status;
  final IconData icon;
  final Color color;
  final bool isGradient;
  final LinearGradient? gradient;

  const StatusIndicator({
    super.key,
    required this.status,
    required this.icon,
    required this.color,
    this.isGradient = false,
    this.gradient,
  });

  // Factory constructors for common statuses
  factory StatusIndicator.connected({Key? key}) {
    return StatusIndicator(
      key: key,
      status: 'Connected',
      icon: Icons.check_circle,
      color: accentGreen,
      isGradient: true,
      gradient: successGradient,
    );
  }

  factory StatusIndicator.disconnected({Key? key}) {
    return StatusIndicator(
      key: key,
      status: 'Disconnected',
      icon: Icons.cancel,
      color: accentRed,
      isGradient: true,
      gradient: errorGradient,
    );
  }

  factory StatusIndicator.warning({Key? key, required String status}) {
    return StatusIndicator(
      key: key,
      status: status,
      icon: Icons.warning,
      color: accentOrange,
      isGradient: true,
      gradient: warningGradient,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isGradient && gradient != null)
          ShaderMask(
            shaderCallback: (bounds) => gradient!.createShader(bounds),
            child: Icon(icon, color: Colors.white),
          )
        else
          Icon(icon, color: color),
        const SizedBox(width: 8),
        Text(
          status,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
