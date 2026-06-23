import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

enum BinType {
  general,
  recycling,
  compost,
  ewaste,
  ashtray,
}

enum FillLevel {
  empty,
  moderate,
  full,
}

class Bin {
  final String id;
  final double latitude;
  final double longitude;
  final BinType type;
  final String description;
  final FillLevel fillLevel;
  final int upvotes;
  final bool isUserAdded;
  final DateTime dateAdded;

  Bin({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.description,
    required this.fillLevel,
    this.upvotes = 0,
    this.isUserAdded = false,
    DateTime? dateAdded,
  }) : dateAdded = dateAdded ?? DateTime.now();

  LatLng get location => LatLng(latitude, longitude);

  Bin copyWith({
    String? id,
    double? latitude,
    double? longitude,
    BinType? type,
    String? description,
    FillLevel? fillLevel,
    int? upvotes,
    bool? isUserAdded,
    DateTime? dateAdded,
  }) {
    return Bin(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      type: type ?? this.type,
      description: description ?? this.description,
      fillLevel: fillLevel ?? this.fillLevel,
      upvotes: upvotes ?? this.upvotes,
      isUserAdded: isUserAdded ?? this.isUserAdded,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'type': type.name,
      'description': description,
      'fillLevel': fillLevel.name,
      'upvotes': upvotes,
      'isUserAdded': isUserAdded,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }

  factory Bin.fromJson(Map<String, dynamic> json) {
    return Bin(
      id: json['id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      type: BinType.values.byName(json['type'] as String),
      description: json['description'] as String,
      fillLevel: FillLevel.values.byName(json['fillLevel'] as String),
      upvotes: json['upvotes'] as int? ?? 0,
      isUserAdded: json['isUserAdded'] as bool? ?? false,
      dateAdded: json['dateAdded'] != null 
          ? DateTime.parse(json['dateAdded'] as String) 
          : null,
    );
  }
}

// Extensions for visual styling and clean data extraction

extension BinTypeExtension on BinType {
  String get displayName {
    switch (this) {
      case BinType.general:
        return 'General Waste';
      case BinType.recycling:
        return 'Recycling';
      case BinType.compost:
        return 'Organic / Compost';
      case BinType.ewaste:
        return 'E-Waste / Battery';
      case BinType.ashtray:
        return 'Ash Tray / Public';
    }
  }

  IconData get icon {
    switch (this) {
      case BinType.general:
        return Icons.delete_outline;
      case BinType.recycling:
        return Icons.recycling;
      case BinType.compost:
        return Icons.eco_outlined;
      case BinType.ewaste:
        return Icons.bolt;
      case BinType.ashtray:
        return Icons.smoking_rooms;
    }
  }

  Color get color {
    switch (this) {
      case BinType.general:
        return const Color(0xFF6B7280); // Slate Gray
      case BinType.recycling:
        return const Color(0xFF10B981); // Emerald Green
      case BinType.compost:
        return const Color(0xFFF59E0B); // Amber / Brownish Gold
      case BinType.ewaste:
        return const Color(0xFFEF4444); // Crimson Red
      case BinType.ashtray:
        return const Color(0xFF8B5CF6); // Violet / Indigo
    }
  }

  Color get lightColor => color.withOpacity(0.15);
}

extension FillLevelExtension on FillLevel {
  String get displayName {
    switch (this) {
      case FillLevel.empty:
        return 'Empty';
      case FillLevel.moderate:
        return 'Moderate';
      case FillLevel.full:
        return 'Full';
    }
  }

  Color get color {
    switch (this) {
      case FillLevel.empty:
        return const Color(0xFF10B981); // Green
      case FillLevel.moderate:
        return const Color(0xFFF59E0B); // Amber
      case FillLevel.full:
        return const Color(0xFFEF4444); // Red
    }
  }
}
