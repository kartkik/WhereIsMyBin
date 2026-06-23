import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:uuid/uuid.dart';
import '../models/bin_model.dart';
import '../services/storage_service.dart';
import '../services/location_service.dart';

class MapViewModel extends ChangeNotifier {
  final StorageService _storageService;
  final LocationService _locationService;
  final _uuid = const Uuid();

  // Internal states
  List<Bin> _allBins = [];
  bool _isLoading = false;
  
  LatLng _mapCenter = const LatLng(48.8566, 2.3522); // Default to Paris center
  double _mapZoom = 14.0;
  final MapController _mapController = MapController();

  Bin? _selectedBin;
  BinType? _selectedCategory; // Null represents "All Bins"
  
  String _searchQuery = '';
  
  // Quick filters
  bool _showOnlyAddedByMe = false;
  bool _showOnlyEmpty = false;
  bool _showOnlyVerified = false;

  // Add Bin Mode states
  bool _isAddBinMode = false;
  LatLng _addBinLocation = const LatLng(48.8566, 2.3522);

  // Styling settings
  bool _isDarkMode = false;

  MapViewModel({
    required StorageService storageService,
    required LocationService locationService,
  })  : _storageService = storageService,
        _locationService = locationService;

  // Getters
  bool get isLoading => _isLoading;
  LatLng get mapCenter => _mapCenter;
  double get mapZoom => _mapZoom;
  MapController get mapController => _mapController;
  
  Bin? get selectedBin => _selectedBin;
  BinType? get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  bool get showOnlyAddedByMe => _showOnlyAddedByMe;
  bool get showOnlyEmpty => _showOnlyEmpty;
  bool get showOnlyVerified => _showOnlyVerified;

  bool get isAddBinMode => _isAddBinMode;
  LatLng get addBinLocation => _addBinLocation;
  bool get isDarkMode => _isDarkMode;

  // Calculates filtered bins dynamically
  List<Bin> get filteredBins {
    return _allBins.where((bin) {
      // 1. Category Filter
      if (_selectedCategory != null && bin.type != _selectedCategory) {
        return false;
      }
      // 2. Search Query (matches description or category name)
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesDesc = bin.description.toLowerCase().contains(query);
        final matchesType = bin.type.displayName.toLowerCase().contains(query);
        if (!matchesDesc && !matchesType) {
          return false;
        }
      }
      // 3. Quick Filters
      if (_showOnlyAddedByMe && !bin.isUserAdded) {
        return false;
      }
      if (_showOnlyEmpty && bin.fillLevel != FillLevel.empty) {
        return false;
      }
      if (_showOnlyVerified && bin.upvotes < 8) {
        return false;
      }
      return true;
    }).toList();
  }

  // Get counts for badge overlays
  int getBinCount(BinType? type) {
    if (type == null) return _allBins.length;
    return _allBins.where((b) => b.type == type).length;
  }

  // Lifecycle Initialization
  Future<void> init() async {
    _isLoading = true;
    notifyListeners();

    // Load persisted and seed bins
    _allBins = await _storageService.loadBins();
    
    // Request device geolocation. If granted, update map view center.
    final userPos = await _locationService.getCurrentLocation();
    if (userPos != null) {
      _mapCenter = userPos;
      try {
        _mapController.move(_mapCenter, _mapZoom);
      } catch (_) {
        // Safe catch if map is not fully loaded/rendered yet
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  // Map Position Updates (fired from user manual dragging)
  void updateMapCenter(LatLng center, double zoom) {
    _mapCenter = center;
    _mapZoom = zoom;
    // Don't call notifyListeners to prevent infinite redrawing loops, 
    // but keep local coordinates updated.
  }

  // Select Category
  void selectCategory(BinType? category) {
    if (_selectedCategory == category) {
      _selectedCategory = null; // Toggle off if clicked again
    } else {
      _selectedCategory = category;
    }
    notifyListeners();
  }

  // Toggle Quick Filters
  void toggleQuickFilter(String filterKey) {
    switch (filterKey) {
      case 'added_by_me':
        _showOnlyAddedByMe = !_showOnlyAddedByMe;
        break;
      case 'only_empty':
        _showOnlyEmpty = !_showOnlyEmpty;
        break;
      case 'verified':
        _showOnlyVerified = !_showOnlyVerified;
        break;
    }
    notifyListeners();
  }

  // Search filter
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Select a marker to open details sheet
  void selectBin(Bin? bin) {
    _selectedBin = bin;
    if (bin != null) {
      _mapCenter = bin.location;
      try {
        _mapController.move(bin.location, 16.0);
      } catch (_) {}
    }
    notifyListeners();
  }

  // Upvote/Verify a bin
  Future<void> upvoteBin(String binId) async {
    final index = _allBins.indexWhere((b) => b.id == binId);
    if (index != -1) {
      final bin = _allBins[index];
      final updatedBin = bin.copyWith(upvotes: bin.upvotes + 1);
      _allBins[index] = updatedBin;
      
      if (_selectedBin?.id == binId) {
        _selectedBin = updatedBin;
      }
      
      notifyListeners();
      await _storageService.updateBin(updatedBin);
    }
  }

  // Update fill level status
  Future<void> updateBinFillLevel(String binId, FillLevel fillLevel) async {
    final index = _allBins.indexWhere((b) => b.id == binId);
    if (index != -1) {
      final bin = _allBins[index];
      final updatedBin = bin.copyWith(fillLevel: fillLevel);
      _allBins[index] = updatedBin;
      
      if (_selectedBin?.id == binId) {
        _selectedBin = updatedBin;
      }
      
      notifyListeners();
      await _storageService.updateBin(updatedBin);
    }
  }

  // Toggle Dark/Light Theme Map Styles
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  // Go to my physical location
  Future<void> goToMyLocation() async {
    _isLoading = true;
    notifyListeners();

    final userPos = await _locationService.getCurrentLocation();
    if (userPos != null) {
      _mapCenter = userPos;
      try {
        _mapController.move(_mapCenter, 15.5);
      } catch (_) {}
    }

    _isLoading = false;
    notifyListeners();
  }

  // Add Bin Flow control
  void startAddBinMode() {
    _selectedBin = null; // Close active details panel
    _isAddBinMode = true;
    _addBinLocation = _mapCenter; // Focus target in center of current viewport
    notifyListeners();
  }

  void updateAddBinLocation(LatLng position) {
    _addBinLocation = position;
    notifyListeners();
  }

  void cancelAddBinMode() {
    _isAddBinMode = false;
    notifyListeners();
  }

  Future<void> confirmAddBin({
    required String description,
    required BinType type,
    required FillLevel fillLevel,
  }) async {
    final newBin = Bin(
      id: _uuid.v4(),
      latitude: _addBinLocation.latitude,
      longitude: _addBinLocation.longitude,
      type: type,
      description: description,
      fillLevel: fillLevel,
      upvotes: 1, // Add initial verification vote by poster
      isUserAdded: true,
    );

    _allBins.add(newBin);
    _isAddBinMode = false;
    
    // Auto-select the newly created bin to show details
    _selectedBin = newBin;
    _mapCenter = newBin.location;
    
    notifyListeners();

    try {
      _mapController.move(newBin.location, 16.5);
    } catch (_) {}

    await _storageService.saveBin(newBin);
  }
}
