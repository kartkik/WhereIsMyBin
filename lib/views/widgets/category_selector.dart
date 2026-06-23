import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/bin_model.dart';
import '../../viewmodels/map_viewmodel.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MapViewModel>();
    final isDarkMode = vm.isDarkMode;

    // List of categories to display
    final List<_CategoryItem> items = [
      _CategoryItem(
        type: null,
        label: 'All Bins',
        icon: Icons.map_outlined,
        color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
      ),
      _CategoryItem(
        type: BinType.recycling,
        label: BinType.recycling.displayName,
        icon: BinType.recycling.icon,
        color: BinType.recycling.color,
      ),
      _CategoryItem(
        type: BinType.general,
        label: BinType.general.displayName,
        icon: BinType.general.icon,
        color: BinType.general.color,
      ),
      _CategoryItem(
        type: BinType.compost,
        label: 'Compost',
        icon: BinType.compost.icon,
        color: BinType.compost.color,
      ),
      _CategoryItem(
        type: BinType.ewaste,
        label: 'E-Waste',
        icon: BinType.ewaste.icon,
        color: BinType.ewaste.color,
      ),
      _CategoryItem(
        type: BinType.ashtray,
        label: 'Ash Tray',
        icon: BinType.ashtray.icon,
        color: BinType.ashtray.color,
      ),
    ];

    return Container(
      height: 90,
      width: double.infinity,
      alignment: Alignment.center,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final count = vm.getBinCount(item.type);
          final isSelected = vm.selectedCategory == item.type;

          return _CategoryButton(
            item: item,
            count: count,
            isSelected: isSelected,
            isDarkMode: isDarkMode,
            onTap: () => vm.selectCategory(item.type),
          );
        },
      ),
    );
  }
}

class _CategoryItem {
  final BinType? type;
  final String label;
  final IconData icon;
  final Color color;

  const _CategoryItem({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
  });
}

class _CategoryButton extends StatefulWidget {
  final _CategoryItem item;
  final int count;
  final bool isSelected;
  final bool isDarkMode;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.item,
    required this.count,
    required this.isSelected,
    required this.isDarkMode,
    required this.onTap,
  });

  @override
  State<_CategoryButton> createState() => _CategoryButtonState();
}

class _CategoryButtonState extends State<_CategoryButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final activeBgColor = widget.isDarkMode
        ? widget.item.color.withOpacity(0.25)
        : widget.item.color.withOpacity(0.12);

    final defaultBgColor = widget.isDarkMode
        ? const Color(0xFF1E293B).withOpacity(0.8)
        : Colors.white.withOpacity(0.85);

    final activeBorderColor = widget.item.color;
    final defaultBorderColor = widget.isDarkMode
        ? Colors.white.withOpacity(0.06)
        : Colors.black.withOpacity(0.06);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 100,
            margin: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
            decoration: BoxDecoration(
              color: widget.isSelected ? activeBgColor : defaultBgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.isSelected ? activeBorderColor : defaultBorderColor,
                width: widget.isSelected ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: widget.isSelected
                      ? widget.item.color.withOpacity(0.15)
                      : Colors.black.withOpacity(0.04),
                  blurRadius: widget.isSelected ? 12 : 6,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Icon and Text Column
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        widget.item.icon,
                        color: widget.isSelected ? widget.item.color : (widget.isDarkMode ? Colors.white70 : const Color(0xFF475569)),
                        size: 24,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.item.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: widget.isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: widget.isSelected 
                              ? (widget.isDarkMode ? Colors.white : widget.item.color) 
                              : (widget.isDarkMode ? Colors.white70 : const Color(0xFF334155)),
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge overlay at top-right
                if (widget.count > 0)
                  Positioned(
                    top: -12,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: widget.isDarkMode ? const Color(0xFF0F172A) : const Color(0xFF334155),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: widget.isDarkMode ? Colors.white12 : Colors.white24,
                          width: 1.0,
                        ),
                      ),
                      child: Text(
                        '+${widget.count}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
