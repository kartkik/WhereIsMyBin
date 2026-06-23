import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../models/bin_model.dart';
import '../viewmodels/map_viewmodel.dart';
import 'widgets/glass_panel.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/category_selector.dart';
import 'widgets/bin_details_sheet.dart';
import 'widgets/add_bin_overlay.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    // Load bins and coordinate geolocations on launch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapViewModel>().init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MapViewModel>();
    final isDarkMode = vm.isDarkMode;

    // CartoDB tiles are highly clean and minimalist, allowing custom markers to stand out
    final tileUrl = isDarkMode
        ? 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png'
        : 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png';

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          // 1. BASE MAP LAYER
          FlutterMap(
            mapController: vm.mapController,
            options: MapOptions(
              initialCenter: vm.mapCenter,
              initialZoom: vm.mapZoom,
              minZoom: 3.0,
              maxZoom: 19.0,
              onTap: (tapPosition, point) {
                // Clicking on map deselects active bin
                if (!vm.isAddBinMode) {
                  vm.selectBin(null);
                }
              },
              onPositionChanged: (camera, hasGesture) {
                // If in placement mode, the center crosshair tracks center coordinates
                if (vm.isAddBinMode) {
                  vm.updateAddBinLocation(camera.center);
                }
                vm.updateMapCenter(camera.center, camera.zoom);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: tileUrl,
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.whereismybin.app',
              ),
              // Render Markers
              MarkerLayer(
                markers: vm.filteredBins.map((bin) {
                  final isSelected = vm.selectedBin?.id == bin.id;
                  return Marker(
                    point: bin.location,
                    width: isSelected ? 50 : 42,
                    height: isSelected ? 54 : 46,
                    alignment: Alignment.topCenter,
                    child: GestureDetector(
                      onTap: () {
                        if (!vm.isAddBinMode) {
                          vm.selectBin(bin);
                        }
                      },
                      child: _MapPinMarker(bin: bin, isSelected: isSelected),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // 2. SEARCH BAR OVERLAY (Hidden in Add Mode)
          if (!vm.isAddBinMode)
            const Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SearchBarWidget(),
            ),

          // 3. QUICK FILTERS ROW (Hidden in Add Mode)
          if (!vm.isAddBinMode)
            Positioned(
              bottom: vm.selectedBin != null ? 370.0 : 106.0,
              left: 16,
              child: Row(
                children: [
                  _buildQuickFilterChip(
                    label: 'Added by Me',
                    isActive: vm.showOnlyAddedByMe,
                    icon: Icons.person_pin_circle_outlined,
                    onTap: () => vm.toggleQuickFilter('added_by_me'),
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(width: 8),
                  _buildQuickFilterChip(
                    label: 'Only Empty',
                    isActive: vm.showOnlyEmpty,
                    icon: Icons.check_circle_outline,
                    onTap: () => vm.toggleQuickFilter('only_empty'),
                    isDarkMode: isDarkMode,
                  ),
                  const SizedBox(width: 8),
                  _buildQuickFilterChip(
                    label: 'Verified Bins',
                    isActive: vm.showOnlyVerified,
                    icon: Icons.verified_user_outlined,
                    onTap: () => vm.toggleQuickFilter('verified'),
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),

          // 4. FLOATING ACTION BUTTONS COLUMN
          Positioned(
            bottom: vm.isAddBinMode
                ? 16.0
                : (vm.selectedBin != null ? 370.0 : 106.0),
            right: 16,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Theme Toggle FAB
                FloatingActionButton.small(
                  heroTag: 'theme_toggle_fab',
                  onPressed: vm.toggleTheme,
                  backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                  foregroundColor: isDarkMode ? Colors.amber : const Color(0xFF475569),
                  elevation: 3,
                  child: Icon(isDarkMode ? Icons.wb_sunny_outlined : Icons.dark_mode_outlined),
                ),
                const SizedBox(height: 8),
                // My Location FAB
                FloatingActionButton.small(
                  heroTag: 'my_location_fab',
                  onPressed: vm.goToMyLocation,
                  backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                  foregroundColor: isDarkMode ? const Color(0xFF10B981) : const Color(0xFF059669),
                  elevation: 3,
                  child: const Icon(Icons.gps_fixed),
                ),
                // Add Bin Mode toggle FAB (Only show when not in placement mode)
                if (!vm.isAddBinMode) ...[
                  const SizedBox(height: 12),
                  FloatingActionButton(
                    heroTag: 'add_bin_trigger_fab',
                    onPressed: vm.startAddBinMode,
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    elevation: 5,
                    child: const Icon(Icons.add_location_alt, size: 26),
                  ),
                ],
              ],
            ),
          ),

          // 5. DETAIL VIEW SHEET LAYER
          if (!vm.isAddBinMode) const BinDetailsSheet(),

          // 6. CATEGORIES FILTER BAR LAYER (Hidden in Add Mode)
          if (!vm.isAddBinMode)
            const Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: CategorySelector(),
            ),

          // 7. ADD BIN MODE OVERLAYS LAYER (Draggable form + target)
          if (vm.isAddBinMode) const AddBinOverlay(),

          // 8. LOADER OVERLAY
          if (vm.isLoading)
            Container(
              color: Colors.black.withOpacity(0.35),
              child: const Center(
                child: GlassPanel(
                  borderRadius: 16,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'Locating waste bins...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildQuickFilterChip({
    required String label,
    required bool isActive,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    final activeColor = const Color(0xFF10B981);
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withOpacity(0.18)
              : (isDarkMode ? const Color(0xFF1E293B).withOpacity(0.8) : Colors.white.withOpacity(0.85)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? activeColor : (isDarkMode ? Colors.white10 : Colors.black.withOpacity(0.06)),
            width: isActive ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isActive ? activeColor.withOpacity(0.1) : Colors.black.withOpacity(0.03),
              blurRadius: 6,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? activeColor : (isDarkMode ? Colors.white70 : const Color(0xFF64748B)),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
                color: isActive ? (isDarkMode ? Colors.white : activeColor) : textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapPinMarker extends StatelessWidget {
  final Bin bin;
  final bool isSelected;

  const _MapPinMarker({
    required this.bin,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final color = bin.type.color;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Pin body containing the icon
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isSelected ? 42.0 : 34.0,
          height: isSelected ? 42.0 : 34.0,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.55),
                blurRadius: isSelected ? 12.0 : 6.0,
                spreadRadius: isSelected ? 4.0 : 1.0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(
            bin.type.icon,
            color: Colors.white,
            size: isSelected ? 20.0 : 16.0,
          ),
        ),
        // Downward pointer arrow
        ClipPath(
          clipper: _PinArrowClipper(),
          child: Container(
            width: 8,
            height: 6,
            color: Colors.white,
            margin: const EdgeInsets.only(top: 0.1),
          ),
        ),
      ],
    );
  }
}

class _PinArrowClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width / 2, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
