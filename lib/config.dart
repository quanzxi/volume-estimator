class AppConfig {
  // --- Input Validation Constraints ---
  static const double minDimension = 1.0;
  static const double maxDimension = 500.0;
  static const int minQuantity = 1;
  static const int maxQuantity = 1000;

  // --- Production Constants ---
  static const double allowance = 40.0;
  static const double siliconeCostKg = 21.84;
  static const double urethaneCostKg = 30.00;

  // Labor Rates (Hourly rate divided by 60 = Per-minute rate)
  // Silicone: $6.00/hr = $0.10/min
  // Urethane: $2.00/hr = $0.033/min
  static const double siliconeLaborRate = 6.00 / 60; 
  static const double urethaneLaborRate = 2.00 / 60; 

  // --- Process Times (Active labor time in minutes) ---
  static const int siliconeTime = 60; 
  static const int urethaneTime = 20; 
  static const int shotsPerMold = 20;

  // --- Material Properties ---
  static const double siliconeMm3PerKg = 900000.0;
  static const double urethaneMm3PerKg = 1000000.0;
}