import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/bin_model.dart';
import '../../viewmodels/map_viewmodel.dart';
import 'glass_panel.dart';

class BinDetailsSheet extends StatelessWidget {
  const BinDetailsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MapViewModel>();
    final bin = vm.selectedBin;
    final isDarkMode = vm.isDarkMode;

    final isVisible = bin != null;

    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final secondaryTextColor = isDarkMode ? Colors.white70 : const Color(0xFF475569);
    final shadowColor = isDarkMode ? Colors.black45 : Colors.black12;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      bottom: isVisible ? 106.0 : -350.0, // Push above CategorySelector (90px) + margin
      left: 16,
      right: 16,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 250),
        opacity: isVisible ? 1.0 : 0.0,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: GlassPanel(
              borderRadius: 24,
              padding: const EdgeInsets.all(20.0),
              child: bin == null
                  ? const SizedBox(height: 200)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header row: Icon, Name and Close button
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: bin.type.color.withOpacity(0.15),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: bin.type.color.withOpacity(0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: Icon(
                                bin.type.icon,
                                color: bin.type.color,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    bin.type.displayName,
                                    style: TextStyle(
                                      color: textColor,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    bin.isUserAdded ? 'Added by Community' : 'Official Seed Bin',
                                    style: TextStyle(
                                      color: bin.isUserAdded
                                          ? const Color(0xFF10B981)
                                          : secondaryTextColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Close Button
                            IconButton(
                              icon: Icon(Icons.close, color: secondaryTextColor, size: 22),
                              onPressed: () => vm.selectBin(null),
                              splashRadius: 20,
                            ),
                          ],
                        ),
                        const Divider(height: 24, thickness: 0.8),
                        
                        // Location Info
                        Text(
                          'LOCATION & LANDMARK',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          bin.description,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Interactive Fill Level Row
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
                            final isLevelSelected = bin.fillLevel == level;
                            final levelColor = level.color;
                            
                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: InkWell(
                                  onTap: () => vm.updateBinFillLevel(bin.id, level),
                                  borderRadius: BorderRadius.circular(10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isLevelSelected
                                          ? levelColor.withOpacity(0.15)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isLevelSelected
                                            ? levelColor
                                            : (isDarkMode ? Colors.white10 : Colors.black12),
                                        width: isLevelSelected ? 1.5 : 1.0,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        level.displayName,
                                        style: TextStyle(
                                          color: isLevelSelected ? levelColor : secondaryTextColor,
                                          fontWeight: isLevelSelected ? FontWeight.bold : FontWeight.w500,
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

                        // Bottom Actions Row: Upvote/Verify Button & Date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Reported: ${bin.dateAdded.day}/${bin.dateAdded.month}/${bin.dateAdded.year}',
                              style: TextStyle(
                                color: secondaryTextColor.withOpacity(0.8),
                                fontSize: 11,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () => vm.upvoteBin(bin.id),
                              icon: const Icon(Icons.verified_outlined, size: 16),
                              label: Text('Verify Bin (${bin.upvotes})'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDarkMode
                                    ? const Color(0xFF0F172A)
                                    : const Color(0xFF1E293B),
                                foregroundColor: const Color(0xFF10B981),
                                shadowColor: shadowColor,
                                elevation: 1,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: const Color(0xFF10B981).withOpacity(0.3),
                                    width: 1.0,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
