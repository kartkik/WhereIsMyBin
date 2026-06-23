import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/map_viewmodel.dart';
import 'glass_panel.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    final vm = context.read<MapViewModel>();
    _controller = TextEditingController(text: vm.searchQuery);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MapViewModel>();
    final isDarkMode = vm.isDarkMode;

    // Synchronize controller if search query was cleared programmatically
    if (_controller.text != vm.searchQuery) {
      _controller.text = vm.searchQuery;
    }

    final textColor = isDarkMode ? Colors.white : const Color(0xFF1E293B);
    final hintColor = isDarkMode ? Colors.white54 : Colors.black45;
    final iconColor = isDarkMode ? Colors.white70 : const Color(0xFF64748B);

    final showReset = vm.searchQuery.isNotEmpty || 
                      vm.selectedCategory != null ||
                      vm.showOnlyAddedByMe ||
                      vm.showOnlyEmpty ||
                      vm.showOnlyVerified;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 550),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Row(
            children: [
              // Left action: Back/Reset button if filters are active
              if (showReset)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FloatingActionButton.small(
                    heroTag: 'clear_all_fab',
                    onPressed: () {
                      _controller.clear();
                      vm.setSearchQuery('');
                      vm.selectCategory(null);
                      if (vm.showOnlyAddedByMe) vm.toggleQuickFilter('added_by_me');
                      if (vm.showOnlyEmpty) vm.toggleQuickFilter('only_empty');
                      if (vm.showOnlyVerified) vm.toggleQuickFilter('verified');
                      vm.selectBin(null);
                    },
                    backgroundColor: isDarkMode 
                        ? const Color(0xFF334155).withOpacity(0.9) 
                        : Colors.white.withOpacity(0.9),
                    foregroundColor: textColor,
                    elevation: 2,
                    child: const Icon(Icons.arrow_back, size: 20),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: FloatingActionButton.small(
                    heroTag: 'app_logo_fab',
                    onPressed: null,
                    disabledElevation: 2,
                    backgroundColor: isDarkMode 
                        ? const Color(0xFF334155).withOpacity(0.9) 
                        : Colors.white.withOpacity(0.9),
                    foregroundColor: isDarkMode ? const Color(0xFF10B981) : const Color(0xFF059669),
                    child: const Icon(Icons.delete_sweep, size: 22),
                  ),
                ),

              // Main search field panel
              Expanded(
                child: GlassPanel(
                  borderRadius: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: iconColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          onChanged: (val) => vm.setSearchQuery(val),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search waste bins or streets...',
                            hintStyle: TextStyle(color: hintColor, fontSize: 14),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          ),
                        ),
                      ),
                      if (vm.searchQuery.isNotEmpty)
                        IconButton(
                          icon: Icon(Icons.close, color: iconColor, size: 18),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            _controller.clear();
                            vm.setSearchQuery('');
                          },
                        ),
                    ],
                  ),
                ),
              ),

              // Near Me Floating Pill (as in the top-center screenshot)
              const SizedBox(width: 8),
              GestureDetector(
                onTap: vm.goToMyLocation,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isDarkMode 
                        ? const Color(0xFF334155).withOpacity(0.9) 
                        : const Color(0xFF0F172A).withOpacity(0.75),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                    border: Border.all(
                      color: isDarkMode 
                          ? Colors.white.withOpacity(0.08) 
                          : Colors.white.withOpacity(0.2),
                    )
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.my_location, 
                        color: isDarkMode ? const Color(0xFF10B981) : Colors.white, 
                        size: 16
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Near me',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
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
    );
  }
}
