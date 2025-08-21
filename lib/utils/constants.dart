class AppConstants {
  static const String appName = 'Glintly Shop';
  static const String appVersion = '1.0.0';
  
  // Spacing
  static const double paddingXS = 4.0;
  static const double paddingSM = 8.0;
  static const double paddingMD = 16.0;
  static const double paddingLG = 24.0;
  static const double paddingXL = 32.0;
  
  // Border radius
  static const double radiusSM = 4.0;
  static const double radiusMD = 8.0;
  static const double radiusLG = 12.0;
  static const double radiusXL = 16.0;
  
  // Icon sizes
  static const double iconSM = 16.0;
  static const double iconMD = 24.0;
  static const double iconLG = 32.0;
  static const double iconXL = 48.0;
  
  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 150);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  
  // Breakpoints for responsive design
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;
  
  // Product categories
  static const List<String> productCategories = [
    'Electronics',
    'Clothing',
    'Books',
    'Home & Garden',
    'Sports',
    'Beauty',
    'Toys',
    'Food',
  ];
  
  // Order status colors
  static const Map<String, String> orderStatusColors = {
    'pending': '#F59E0B',
    'confirmed': '#3B82F6',
    'shipped': '#8B5CF6',
    'delivered': '#10B981',
    'cancelled': '#EF4444',
  };
  
  // Image placeholders
  static const String productPlaceholder = 'https://via.placeholder.com/300x300?text=Product';
  static const String avatarPlaceholder = 'https://via.placeholder.com/100x100?text=Avatar';
  
  // Error messages
  static const String networkErrorMessage = 'Network error. Please check your connection and try again.';
  static const String genericErrorMessage = 'Something went wrong. Please try again later.';
  static const String authErrorMessage = 'Authentication failed. Please check your credentials.';
}