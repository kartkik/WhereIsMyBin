import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/bin_model.dart';
import '../../viewmodels/map_viewmodel.dart';
import 'glass_panel.dart';

class AddBinOverlay extends StatefulWidget {
  const AddBinOverlay({super.key});

  @override
  State<AddBinOverlay> createState() => _AddBinOverlayState();
}

class _AddBinOverlayState extends State<AddBinOverlay> {
  final _formKey = GlobalKey<FormState>();
  final _descController = TextEditingController();
  
  BinType _selectedType = BinType.recycling;
  FillLevel _selectedFill = FillLevel.empty;

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MapViewModel>();
    if (!vm.isAddBinMode) return const SizedBox.shrink();

    final isDarkMode = vm.isDarkMode;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDarkMode ? Colors.white70 : const Color(0xFF475569);
    final inputBgColor = isDarkMode ? const Color(0xFF0F172A).withOpacity(0.4) : Colors.black.withOpacity(0.03);

    return Stack(
      children: [
        // 1. TOP INSTRUCTION PILL (Slides down)
        Positioned(
          top: 80, // Position below search bar
          left: 16,
          right: 16,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: GlassPanel(
                borderRadius: 20,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                customBgColor: isDarkMode
                    ? const Color(0xFF0F172A).withOpacity(0.85)
                    : const Color(0xFF1E293B).withOpacity(0.9),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF10B981), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Drag the map to center the target over the bin\'s location.',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // 2. CENTER TARGET CROSSHAIR (fixed at center of stack)
        Center(
          child: IgnorePointer(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Glowing pin icon or crosshair
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _selectedType.color.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _selectedType.color,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _selectedType.color.withOpacity(0.3),
                        blurRadius: 16,
                        spreadRadius: 4,
                      )
                    ],
                  ),
                  child: Icon(
                    _selectedType.icon,
                    color: _selectedType.color,
                    size: 32,
                  ),
                ),
                // Center point indicator
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 3,
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // 3. BOTTOM FORM PANEL
        Positioned(
          bottom: 16,
          left: 16,
          right: 16,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: GlassPanel(
                borderRadius: 24,
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Report New Bin',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          TextButton(
                            onPressed: vm.cancelAddBinMode,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.redAccent,
                            ),
                            child: const Text('Cancel', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Selection of Waste Category
                      Text(
                        'SELECT BIN CATEGORY',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Grid or horizontal scroll of categories
                      SizedBox(
                        height: 50,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: BinType.values.map((type) {
                            final isSel = _selectedType == type;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: ChoiceChip(
                                label: Text(type.displayName),
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                  color: isSel 
                                      ? (isDarkMode ? Colors.white : type.color)
                                      : secondaryTextColor,
                                ),
                                iconTheme: IconThemeData(
                                  color: isSel ? type.color : secondaryTextColor,
                                  size: 16,
                                ),
                                avatar: Icon(type.icon),
                                selected: isSel,
                                onSelected: (selected) {
                                  if (selected) {
                                    setState(() {
                                      _selectedType = type;
                                    });
                                  }
                                },
                                selectedColor: type.color.withOpacity(0.18),
                                checkmarkColor: type.color,
                                showCheckmark: false,
                                backgroundColor: isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.04),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: BorderSide(
                                    color: isSel ? type.color : Colors.transparent,
                                    width: 1.2,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Location notes
                      Text(
                        'LOCATION DESCRIPTION & LANDMARKS',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descController,
                        style: TextStyle(color: textColor, fontSize: 14),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please describe the location.';
                          }
                          if (value.trim().length < 5) {
                            return 'Please add a bit more detail (min 5 chars).';
                          }
                          return null;
                        },
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'e.g. Near the park bench, next to the bus shelter',
                          hintStyle: TextStyle(color: secondaryTextColor.withOpacity(0.6), fontSize: 13),
                          fillColor: inputBgColor,
                          filled: true,
                          errorStyle: const TextStyle(fontSize: 11, color: Colors.redAccent),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: isDarkMode ? Colors.white10 : Colors.black12,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: _selectedType.color, width: 1.5),
                          ),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Initial Fill level
                      Text(
                        'CURRENT FILL LEVEL',
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: FillLevel.values.map((level) {
                          final isSel = _selectedFill == level;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4.0),
                              child: InkWell(
                                onTap: () => setState(() => _selectedFill = level),
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isSel
                                        ? level.color.withOpacity(0.15)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSel
                                          ? level.color
                                          : (isDarkMode ? Colors.white10 : Colors.black12),
                                      width: isSel ? 1.5 : 1.0,
                                    ),
                                  ),
                                  child: Center(
                                    child: Text(
                                      level.displayName,
                                      style: TextStyle(
                                        color: isSel ? level.color : secondaryTextColor,
                                        fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Confirm Action Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              // Perform confirms and save
                              await vm.confirmAddBin(
                                description: _descController.text.trim(),
                                type: _selectedType,
                                fillLevel: _selectedFill,
                              );
                              
                              // Clear details
                              _descController.clear();
                              
                              // Show premium success feedback
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                    content: Center(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981),
                                          borderRadius: BorderRadius.circular(20),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2),
                                              blurRadius: 15,
                                              offset: const Offset(0, 5),
                                            )
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                                            SizedBox(width: 10),
                                            Text(
                                              'Bin reported successfully!',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _selectedType.color,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.add_location_alt_outlined, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Save Bin Location',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
