import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/bin_model.dart';

abstract class StorageService {
  Future<List<Bin>> loadBins();
  Future<void> saveBin(Bin bin);
  Future<void> updateBin(Bin bin);
}

class SharedPreferencesStorageService implements StorageService {
  static const String _storageKey = 'whereismybin_bins';

  // Seed bins in Paris matching coordinates around Latin Quarter, Île Saint-Louis, and Le Marais
  final List<Bin> _seedBins = [
    Bin(
      id: 'seed-1',
      latitude: 48.8582,
      longitude: 2.3585,
      type: BinType.recycling,
      description: 'Rue Vieille-du-Temple, next to the local bakery',
      fillLevel: FillLevel.empty,
      upvotes: 8,
      isUserAdded: false,
    ),
    Bin(
      id: 'seed-2',
      latitude: 48.8617,
      longitude: 2.3562,
      type: BinType.general,
      description: 'Jardin Anne Frank, near the entrance gates',
      fillLevel: FillLevel.moderate,
      upvotes: 4,
      isUserAdded: false,
    ),
    Bin(
      id: 'seed-3',
      latitude: 48.8518,
      longitude: 2.3564,
      type: BinType.compost,
      description: 'Quai d\'Anjou, Île Saint-Louis near the bridge',
      fillLevel: FillLevel.empty,
      upvotes: 12,
      isUserAdded: false,
    ),
    Bin(
      id: 'seed-4',
      latitude: 48.8606,
      longitude: 2.3522,
      type: BinType.ewaste,
      description: 'Rue Rambuteau, outside the local community centre',
      fillLevel: FillLevel.full,
      upvotes: 2,
      isUserAdded: false,
    ),
    Bin(
      id: 'seed-5',
      latitude: 48.8569,
      longitude: 2.3541,
      type: BinType.ashtray,
      description: 'Rue des Barres, in the pedestrian courtyard',
      fillLevel: FillLevel.moderate,
      upvotes: 15,
      isUserAdded: false,
    ),
    Bin(
      id: 'seed-6',
      latitude: 48.8578,
      longitude: 2.3482,
      type: BinType.recycling,
      description: 'Rue de Rivoli, near Châtelet metro exit 4',
      fillLevel: FillLevel.moderate,
      upvotes: 9,
      isUserAdded: false,
    ),
    Bin(
      id: 'seed-7',
      latitude: 48.8535,
      longitude: 2.3499,
      type: BinType.general,
      description: 'Île de la Cité, near the Notre-Dame square entrance',
      fillLevel: FillLevel.full,
      upvotes: 24,
      isUserAdded: false,
    ),
    Bin(
      id: 'seed-8',
      latitude: 48.8502,
      longitude: 2.3451,
      type: BinType.compost,
      description: 'Boulevard Saint-Germain, near the park benches',
      fillLevel: FillLevel.empty,
      upvotes: 5,
      isUserAdded: false,
    ),
    Bin(
      id: 'seed-9',
      latitude: 48.8631,
      longitude: 2.3611,
      type: BinType.ewaste,
      description: 'Rue de Bretagne, inside the supermarket entryway',
      fillLevel: FillLevel.moderate,
      upvotes: 7,
      isUserAdded: false,
    ),
    Bin(
      id: 'seed-10',
      latitude: 48.8552,
      longitude: 2.3653,
      type: BinType.ashtray,
      description: 'Place des Vosges, south-east corner gate',
      fillLevel: FillLevel.empty,
      upvotes: 18,
      isUserAdded: false,
    ),
  ];

  @override
  Future<List<Bin>> loadBins() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final binsJson = prefs.getString(_storageKey);

      if (binsJson == null) {
        // First run: save seed bins to database and return them
        await _saveBinsToPrefs(prefs, _seedBins);
        return _seedBins;
      }

      final List<dynamic> decoded = json.decode(binsJson) as List<dynamic>;
      return decoded
          .map((item) => Bin.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Fallback in case of errors
      return _seedBins;
    }
  }

  @override
  Future<void> saveBin(Bin bin) async {
    final prefs = await SharedPreferences.getInstance();
    final currentBins = await loadBins();
    currentBins.add(bin);
    await _saveBinsToPrefs(prefs, currentBins);
  }

  @override
  Future<void> updateBin(Bin bin) async {
    final prefs = await SharedPreferences.getInstance();
    final currentBins = await loadBins();
    final index = currentBins.indexWhere((b) => b.id == bin.id);
    if (index != -1) {
      currentBins[index] = bin;
      await _saveBinsToPrefs(prefs, currentBins);
    }
  }

  Future<void> _saveBinsToPrefs(SharedPreferences prefs, List<Bin> bins) async {
    final jsonString = json.encode(bins.map((b) => b.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }
}
