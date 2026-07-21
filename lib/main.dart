import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      fontFamily: 'Poppins',
      visualDensity: VisualDensity.compact,
      textTheme: const TextTheme(bodyMedium: TextStyle(color: Colors.white)),
    ),
    home: const VolumeEstimator(),
  ));
}

class VolumeEstimator extends StatefulWidget {
  const VolumeEstimator({super.key});
  @override
  State<VolumeEstimator> createState() => _VolumeEstimatorState();
}

class _VolumeEstimatorState extends State<VolumeEstimator> {
  final _formKey = GlobalKey<FormState>();
  final _lenCtrl = TextEditingController();
  final _widCtrl = TextEditingController();
  final _hgtCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  Map<String, double>? _results;
  final _currencyFormat = NumberFormat("#,##0.00", "en_US");
  bool _isButtonPressed = false;

  @override
  void dispose() {
    _lenCtrl.dispose();
    _widCtrl.dispose();
    _hgtCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color(0xFF0A1830),
          title: const Text("About Us", style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/cat.gif',
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "This Cost Estimator was developed by our TST interns as part of their internship project.\n\n"
                  "Creators:\nRJ Martinez & Anjun Parco\n\n"
                  "CvSU - Main Campus, 3rd Yr. BS-ECE Students",
                  style: TextStyle(color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CLOSE", style: TextStyle(color: Colors.blueAccent)),
            )
          ],
        ),
      ),
    );
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => _isButtonPressed = true);
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) setState(() => _isButtonPressed = false);
    });

    final l = double.parse(_lenCtrl.text);
    final w = double.parse(_widCtrl.text);
    final h = double.parse(_hgtCtrl.text);
    final qty = int.parse(_qtyCtrl.text);

    double productVolume = l * w * h;
    double moldVolume = (l + 2 * AppConfig.allowance) * (w + 2 * AppConfig.allowance) * (h + 2 * AppConfig.allowance);
    double siliconeVolumePerMold = moldVolume - productVolume;
    int moldsNeeded = (qty / AppConfig.shotsPerMold).ceil();

    double sMat = (siliconeVolumePerMold * moldsNeeded / AppConfig.siliconeMm3PerKg) * AppConfig.siliconeCostKg;
    double sLab = (moldsNeeded * AppConfig.siliconeTime) * AppConfig.siliconeLaborRate;
    double sTime = (moldsNeeded * AppConfig.siliconeTime).toDouble();

    double uMat = (productVolume * qty / AppConfig.urethaneMm3PerKg) * AppConfig.urethaneCostKg;
    double uLab = (qty * AppConfig.urethaneTime) * AppConfig.urethaneLaborRate;
    double uTime = (qty * AppConfig.urethaneTime).toDouble();

    double grandTotalTime = sTime + uTime;

    setState(() {
      _results = {
        "len": l, "wid": w, "hgt": h, "qty": qty.toDouble(), "molds": moldsNeeded.toDouble(),
        "sMat": sMat, "sLab": sLab, "sTot": sMat + sLab, "sTime": sTime,
        "uMat": uMat, "uLab": uLab, "uTot": uMat + uLab, "uTime": uTime,
        "grandTotal": sMat + sLab + uMat + uLab,
        "grandTotalTime": grandTotalTime,
      };
    });
  }

  Widget _buildGlassCard(Widget child) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(16),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, double min, double max) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextFormField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
        style: const TextStyle(fontSize: 13, color: Colors.white),
        decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white70, fontSize: 11),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            prefixIcon: Icon(icon, color: Colors.blueAccent, size: 14),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
            errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 9),
            contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10)),
        validator: (value) {
          final val = double.tryParse(value ?? '');
          if (val == null || val < min || val > max) return 'Range: ${min.toInt()}-${max.toInt()}';
          return null;
        },
      ),
    );
  }

  Widget _resultRow(String title, double value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          Text("\$${_currencyFormat.format(value)}", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ]),
      );

  Widget _resultTimeRow(String title, double totalMinutes) {
    int totalMins = totalMinutes.round();
    int days = totalMins ~/ (24 * 60);
    int remainingMinsAfterDays = totalMins % (24 * 60);
    int hours = remainingMinsAfterDays ~/ 60;
    int minutes = remainingMinsAfterDays % 60;

    List<String> parts = [];
    if (days > 0) parts.add("$days d");
    if (hours > 0 || days > 0) parts.add("$hours hr");
    parts.add("$minutes min");

    String formattedTime = parts.join(" ");

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(formattedTime, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF020408),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 40,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white, size: 20),
            onPressed: _showAbout,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: [Color(0xFF020408), Color(0xFF050D1A), Color(0xFF0A1830)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            Widget inputSection = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Volume Price Calculator", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),
                _buildGlassCard(Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(children: [
                    _buildTextField(_lenCtrl, 'Length (mm)', Icons.straighten, AppConfig.minDimension, AppConfig.maxDimension),
                    _buildTextField(_widCtrl, 'Width (mm)', Icons.width_full, AppConfig.minDimension, AppConfig.maxDimension),
                    _buildTextField(_hgtCtrl, 'Height (mm)', Icons.height, AppConfig.minDimension, AppConfig.maxDimension),
                    _buildTextField(_qtyCtrl, 'Quantity (pcs)', Icons.numbers, AppConfig.minQuantity.toDouble(), AppConfig.maxQuantity.toDouble()),
                    const SizedBox(height: 5),
                    AnimatedScale(
                      scale: _isButtonPressed ? 0.95 : 1.0,
                      duration: const Duration(milliseconds: 100),
                      child: SizedBox(
                          width: double.infinity,
                          height: 35,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                              onPressed: _calculate,
                              child: const Text("CALCULATE", style: TextStyle(color: Color(0xFF020408), fontWeight: FontWeight.bold, fontSize: 12)))),
                    ),
                  ]),
                )),
              ],
            );

            Widget resultsSection = AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _results == null
                  ? const SizedBox.shrink()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildGlassCard(Padding(
                            padding: const EdgeInsets.all(10),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              const Text("GRAND TOTAL", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13)),
                              Text("\$${_currencyFormat.format(_results!['grandTotal']!)}", style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.bold))
                            ]))),
                        const SizedBox(height: 5),
                        _buildGlassCard(Theme(
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent, visualDensity: VisualDensity.compact),
                          child: ExpansionTile(
                              textColor: Colors.white,
                              collapsedTextColor: Colors.white,
                              iconColor: Colors.white,
                              collapsedIconColor: Colors.white,
                              tilePadding: const EdgeInsets.symmetric(horizontal: 10),
                              title: const Text("VIEW DETAILS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              children: [
                                Padding(
                                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text("Dimensions : ${_results!['len']} x ${_results!['wid']} x ${_results!['hgt']} mm", style: const TextStyle(color: Colors.white, fontSize: 11)),
                                      Text("Quantity : ${_results!['qty']?.toInt()} | Molds : ${_results!['molds']?.toInt()}", style: const TextStyle(color: Colors.white, fontSize: 11)),
                                      const Divider(color: Colors.white24, height: 10),
                                      const Text("--- SILICONE ---", style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                                      _resultRow("Material", _results!['sMat']!),
                                      _resultRow("Labor", _results!['sLab']!),
                                      _resultTimeRow("Production Time", _results!['sTime']!),
                                      const SizedBox(height: 4),
                                      const Text("--- URETHANE ---", style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                                      _resultRow("Material", _results!['uMat']!),
                                      _resultRow("Labor", _results!['uLab']!),
                                      _resultTimeRow("Production Time", _results!['uTime']!),
                                      const Divider(color: Colors.white24, height: 10),
                                      _resultTimeRow("Total Client Time", _results!['grandTotalTime']!),
                                    ])),
                              ]),
                        )),
                      ],
                    ),
            );

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 20),
                child: Form(
                  key: _formKey,
                  child: isLandscape
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(child: inputSection),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _results == null
                                  ? resultsSection
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [resultsSection],
                                    ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            inputSection,
                            const SizedBox(height: 12),
                            resultsSection,
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}