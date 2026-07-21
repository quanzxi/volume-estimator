// ==========================================
// config.dart
// ==========================================
class AppConfig {
  static bool isDarkMode = true;
  static double minDimensionMm = 1.0;
  static double minDimensionIn = 0.04;
  
  // Independent limits for metric and imperial
  static double maxDimensionMm = 500.0;
  static double maxDimensionIn = 19.685; 
  
  static int minQuantity = 1;
  static int maxQuantity = 10000;
  
  // Mold & Production constants
  static double allowance = 40.0; // Matching 40mm allowance from reference sheet
  static double shotsPerMold = 20.0; // Matching 20 shots per mold from reference sheet
  
  // Silicone parameters
  static double siliconeMm3PerKg = 909090.0;
  static double siliconeCostKg = 21.84; // Matching $21.84 per kilo reference
  static double siliconeTime = 60.0; // 60 minutes standard
  static double siliconeLaborRate = 20.0; // Hourly rate (divided by 60 for per-minute)
  
  // Urethane parameters
  static double urethaneMm3PerKg = 869565.0;
  static double urethaneCostKg = 30.0; // Matching $30 per kilo reference
  static double urethaneTime = 20.0; // 20 minutes standard
  static double urethaneLaborRate = 15.0; // Hourly rate (divided by 60 for per-minute)
}