import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/invitation_model.dart';
import '../models/rsvp_model.dart';
import '../models/remote_template_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/export_service.dart' as platform_export;
import 'dart:convert';

// Abstract Interface
abstract class IInvitationRepository {
  // Local Drafts (Hive-based)
  Future<void> saveLocalDraft(InvitationModel invitation);
  Future<InvitationModel?> getLocalDraft(String id);

  // Cloud Publications (Firestore with Mock Hive Fallbacks)
  Future<void> publishToCloud(InvitationModel invitation);
  Future<InvitationModel?> getCloudInvitation(String id);

  // Guest RSVPs (Firestore with Mock Hive Fallbacks)
  Future<void> submitRsvp(String invitationId, RsvpModel rsvp);
  Stream<List<RsvpModel>> listenToRsvps(String invitationId);

  // Remote Templates Fetch (Simulated API-driven Designs)
  Future<List<RemoteTemplateModel>> fetchRemoteTemplates();
}

// Unified dual-engine persistence repository
class DualStorageInvitationRepository implements IInvitationRepository {
  final Box _draftsBox;
  final Box _mockPublishedBox;
  final Box _mockRsvpsBox;
  
  bool _isFirebaseInitialized = false;
  FirebaseFirestore? _firestore;

  DualStorageInvitationRepository(
    this._draftsBox,
    this._mockPublishedBox,
    this._mockRsvpsBox,
  ) {
    try {
      // Safe check if Firebase has been initialized in main.dart
      if (Firebase.apps.isNotEmpty) {
        _firestore = FirebaseFirestore.instance;
        _isFirebaseInitialized = true;
        print("Firebase initialized successfully. Running in Cloud Sync mode.");
      } else {
        print("Firebase not initialized yet. Running in high-performance local mock database mode.");
      }
    } catch (e) {
      print("Firebase status check bypassed: $e. Running in high-performance local mock database mode.");
    }
  }

  // -------------------------------------------------------------
  // HIVE LOCAL DRAFT IMPLEMENTATIONS
  // -------------------------------------------------------------
  @override
  Future<void> saveLocalDraft(InvitationModel invitation) async {
    await _draftsBox.put(invitation.id, invitation.toJson());
  }

  @override
  Future<InvitationModel?> getLocalDraft(String id) async {
    final data = _draftsBox.get(id);
    if (data != null) {
      return InvitationModel.fromJson(Map<String, dynamic>.from(data));
    }
    return null;
  }

  // -------------------------------------------------------------
  // CLOUD PERSISTENCE IMPLEMENTATIONS (FIRESTORE OR MOCK HIVE)
  // -------------------------------------------------------------
  @override
  Future<void> publishToCloud(InvitationModel invitation) async {
    if (_isFirebaseInitialized && _firestore != null) {
      await _firestore!.collection('invitations').doc(invitation.id).set(invitation.toJson());
    } else {
      // Mock Cloud save inside local Hive Box
      await _mockPublishedBox.put(invitation.id, invitation.toJson());
    }
  }

  @override
  Future<InvitationModel?> getCloudInvitation(String id) async {
    if (_isFirebaseInitialized && _firestore != null) {
      final doc = await _firestore!.collection('invitations').doc(id).get();
      if (doc.exists && doc.data() != null) {
        return InvitationModel.fromJson(doc.data()!);
      }
    } else {
      // Mock Cloud fetch inside local Hive Box
      final data = _mockPublishedBox.get(id);
      if (data != null) {
        return InvitationModel.fromJson(Map<String, dynamic>.from(data));
      }
    }
    return null;
  }

  // -------------------------------------------------------------
  // REAL-TIME GUEST RSVPS (FIRESTORE OR MOCK HIVE STREAMING)
  // -------------------------------------------------------------
  @override
  Future<void> submitRsvp(String invitationId, RsvpModel rsvp) async {
    if (_isFirebaseInitialized && _firestore != null) {
      await _firestore!
          .collection('invitations')
          .doc(invitationId)
          .collection('rsvps')
          .doc(rsvp.id)
          .set(rsvp.toJson());
    } else {
      // Mock RSVP submit
      final List<dynamic> currentRsvps = _mockRsvpsBox.get(invitationId) ?? [];
      final List<Map<String, dynamic>> updated = List<Map<String, dynamic>>.from(
        currentRsvps.map((item) => Map<String, dynamic>.from(item))
      );
      updated.add(rsvp.toJson());
      await _mockRsvpsBox.put(invitationId, updated);

      // Broadcast update carrying both invitationId and the RSVP details!
      final Map<String, dynamic> payload = {
        'invitationId': invitationId,
        'rsvp': rsvp.toJson(),
      };
      platform_export.ExportService.broadcastUpdate(jsonEncode(payload));
    }
  }

  @override
  Stream<List<RsvpModel>> listenToRsvps(String invitationId) {
    if (_isFirebaseInitialized && _firestore != null) {
      return _firestore!
          .collection('invitations')
          .doc(invitationId)
          .collection('rsvps')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs
                .map((doc) => RsvpModel.fromJson(doc.data()))
                .toList();
          });
    } else {
      // High-performance real-time watcher emulating cloud snapshots using Hive!
      final StreamController<List<RsvpModel>> controller = StreamController<List<RsvpModel>>();
      
      void emitCurrent() {
        final List<dynamic> current = _mockRsvpsBox.get(invitationId) ?? [];
        final List<RsvpModel> rsvps = current
            .map((item) => RsvpModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
        // Sort by newest first
        rsvps.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        if (!controller.isClosed) {
          controller.add(rsvps);
        }
      }

      // Emit initial database contents
      emitCurrent();

      // Watch all changes to the mock RSVPs box generally (reliable on Web and Mobile)
      final subscription = _mockRsvpsBox.watch().listen((event) {
        if (event.key == invitationId) {
          emitCurrent();
        }
      });

      // Listen to cross-tab BroadcastChannel updates instantly!
      final broadcastSubscription = platform_export.ExportService.listenForUpdates().listen((msg) {
        try {
          final Map<String, dynamic> payload = jsonDecode(msg);
          final String id = payload['invitationId'] ?? '';
          if (id == invitationId) {
            final Map<String, dynamic> rsvpJson = payload['rsvp'] ?? {};
            final rsvp = RsvpModel.fromJson(rsvpJson);

            // Update Tab A's local in-memory Box cache so it has the new guest!
            final List<dynamic> current = _mockRsvpsBox.get(invitationId) ?? [];
            final List<Map<String, dynamic>> updated = List<Map<String, dynamic>>.from(
              current.map((item) => Map<String, dynamic>.from(item))
            );
            
            if (!updated.any((item) => item['id'] == rsvp.id)) {
              updated.add(rsvp.toJson());
              _mockRsvpsBox.put(invitationId, updated);
            }
            emitCurrent();
          }
        } catch (e) {
          print("Error processing cross-tab sync: $e");
        }
      });

      controller.onCancel = () {
        subscription.cancel();
        broadcastSubscription.cancel();
        controller.close();
      };

      return controller.stream;
    }
  }

  // -------------------------------------------------------------
  // DYNAMIC REMOTE TEMPLATE OPTIONS FETCH
  // -------------------------------------------------------------
  @override
  Future<List<RemoteTemplateModel>> fetchRemoteTemplates() async {
    // Simulates an API/Server JSON request, adding a full catalog of 15 premium templates
    final List<Map<String, dynamic>> rawList = [
      {
        'id': 1,
        'title': 'Classic Mandala (Gold & Red)',
        'description': 'Rich dark royal red with golden concentric patterns and luxury Sanskrit headers.',
        'primaryColorHex': '#5B0000',
        'secondaryColorHex': '#D4AF37',
        'bgGradientHex': ['#5B0000', '#3B0000'],
        'bgPatternUrl': 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=2000',
        'dividerIconUrl': 'https://cdn-icons-png.flaticon.com/512/3106/3106807.png',
        'borderFrameUrl': 'https://cdn-icons-png.flaticon.com/512/10700/10700940.png',
        'fontTitle': 'Cinzel',
        'fontBody': 'Montserrat',
      },
      {
        'id': 2,
        'title': 'Royal Peacock (Maroon & Teal)',
        'description': 'Elegant deep maroon backdrop complemented by teal peacock elements and gold frames.',
        'primaryColorHex': '#380208',
        'secondaryColorHex': '#D4AF37',
        'bgGradientHex': ['#380208', '#180004'],
        'bgPatternUrl': 'https://images.unsplash.com/photo-1604871000636-074fa5117945?q=80&w=2000',
        'dividerIconUrl': 'https://cdn-icons-png.flaticon.com/512/3233/3233514.png',
        'borderFrameUrl': 'https://cdn-icons-png.flaticon.com/512/9950/9950587.png',
        'fontTitle': 'Playfair Display',
        'fontBody': 'Montserrat',
      },
      {
        'id': 3,
        'title': 'Rose Gold (Minimalist Floral)',
        'description': 'Beautiful blush rose gold shimmers bordered with detailed thin floral leafy branches.',
        'primaryColorHex': '#B76E79',
        'secondaryColorHex': '#4A3437',
        'bgGradientHex': ['#FFF0F2', '#EAD1D5'],
        'bgPatternUrl': 'https://images.unsplash.com/photo-1528459801416-a9e53bbf4e17?q=80&w=2000',
        'dividerIconUrl': 'https://cdn-icons-png.flaticon.com/512/620/620757.png',
        'borderFrameUrl': 'https://cdn-icons-png.flaticon.com/512/5904/5904123.png',
        'fontTitle': 'Alex Brush',
        'fontBody': 'Montserrat',
      },
      {
        'id': 4,
        'title': 'Maharaja Jaipur Palace (Emerald & Gold)',
        'description': 'Royal Jaipur emerald green coupled with imperial gold mandalas and palace borders.',
        'primaryColorHex': '#004B49',
        'secondaryColorHex': '#F1C40F',
        'bgGradientHex': ['#003332', '#004B49', '#001A19'],
        'bgPatternUrl': 'https://images.unsplash.com/photo-1621510456681-23a23cfb5f57?q=80&w=2000',
        'dividerIconUrl': 'https://cdn-icons-png.flaticon.com/512/2913/2913604.png',
        'borderFrameUrl': 'https://cdn-icons-png.flaticon.com/512/10700/10700940.png',
        'fontTitle': 'Cinzel',
        'fontBody': 'Montserrat',
      },
      {
        'id': 5,
        'title': 'Rajputana Crimson & Gold',
        'description': 'Royal Crimson with gold arched borders, reflecting traditional Rajput heritage.',
        'primaryColorHex': '#7A0010',
        'secondaryColorHex': '#E0B034',
        'bgGradientHex': ['#7A0010', '#4A000A'],
        'bgPatternUrl': 'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?q=80&w=2000',
        'dividerIconUrl': 'https://cdn-icons-png.flaticon.com/512/3106/3106807.png',
        'borderFrameUrl': 'https://cdn-icons-png.flaticon.com/512/9950/9950587.png',
        'fontTitle': 'Playfair Display',
        'fontBody': 'Montserrat',
      },
      {
        'id': 6,
        'title': 'Mughal Heritage (Indigo & Gold)',
        'description': 'Royal Indigo backdrop paired with imperial gold archways and floral centerpieces.',
        'primaryColorHex': '#2E1A47',
        'secondaryColorHex': '#E6C229',
        'bgGradientHex': ['#2E1A47', '#1A0D2E'],
        'bgPatternUrl': 'https://images.unsplash.com/photo-1604871000636-074fa5117945?q=80&w=2000',
        'dividerIconUrl': 'https://cdn-icons-png.flaticon.com/512/3233/3233514.png',
        'borderFrameUrl': 'https://cdn-icons-png.flaticon.com/512/10700/10700940.png',
        'fontTitle': 'Cinzel',
        'fontBody': 'Montserrat',
      },
      {
        'id': 7,
        'title': 'Ivory Gold (Luxury)',
        'description': 'Elegant ivory backdrop contrasted with rich charcoal typography and a clean gold frame.',
        'primaryColorHex': '#F8F5F0',
        'secondaryColorHex': '#1F1F1F',
        'bgGradientHex': ['#F8F5F0', '#F2EFE9'],
        'bgPatternUrl': 'https://images.unsplash.com/photo-1528459801416-a9e53bbf4e17?q=80&w=2000',
        'dividerIconUrl': 'https://cdn-icons-png.flaticon.com/512/620/620757.png',
        'borderFrameUrl': 'https://cdn-icons-png.flaticon.com/512/5904/5904123.png',
        'fontTitle': 'Playfair Display',
        'fontBody': 'Outfit',
      },
      {
        'id': 8,
        'title': 'Champagne Luxury',
        'description': 'Luxurious warm champagne tones paired with classic serif typography and gold dividers.',
        'primaryColorHex': '#F7E7CE',
        'secondaryColorHex': '#2B2B2B',
        'bgGradientHex': ['#F7E7CE', '#ECD4B4'],
        'bgPatternUrl': 'https://images.unsplash.com/photo-1528459801416-a9e53bbf4e17?q=80&w=2000',
        'dividerIconUrl': 'https://cdn-icons-png.flaticon.com/512/2913/2913604.png',
        'borderFrameUrl': 'https://cdn-icons-png.flaticon.com/512/5904/5904123.png',
        'fontTitle': 'Playfair Display',
        'fontBody': 'Montserrat',
      },
      {
        'id': 9,
        'title': 'Midnight Navy & Gold',
        'description': 'Stunning dark navy sky gradient decorated with glowing star mandalas and golden borders.',
        'primaryColorHex': '#0D1B2A',
        'secondaryColorHex': '#D4AF37',
        'bgGradientHex': ['#0D1B2A', '#08111D'],
        'bgPatternUrl': 'https://images.unsplash.com/photo-1621510456681-23a23cfb5f57?q=80&w=2000',
        'dividerIconUrl': 'https://cdn-icons-png.flaticon.com/512/2913/2913604.png',
        'borderFrameUrl': 'https://cdn-icons-png.flaticon.com/512/10700/10700940.png',
        'fontTitle': 'Cinzel',
        'fontBody': 'Montserrat',
      },
      {
        'id': 10,
        'title': 'Rose Garden (Floral)',
        'description': 'Romance-inspired blush pink background adorned with intricate watercolor floral illustrations.',
        'primaryColorHex': '#FFF5F5',
        'secondaryColorHex': '#6B4F4F',
        'bgGradientHex': ['#FFF5F5', '#FFEBEB'],
        'bgPatternUrl': 'https://images.unsplash.com/photo-1528459801416-a9e53bbf4e17?q=80&w=2000',
        'dividerIconUrl': 'https://cdn-icons-png.flaticon.com/512/620/620757.png',
        'borderFrameUrl': 'https://cdn-icons-png.flaticon.com/512/5904/5904123.png',
        'fontTitle': 'Alex Brush',
        'fontBody': 'Montserrat',
      },
      {
        'id': 11,
        'title': 'Lavender Bloom',
        'description': 'Delicate pastel lavender theme framed by hand-painted lavender branches and silver lines.',
        'primaryColorHex': '#ECEBF7',
        'secondaryColorHex': '#3D2C5E',
        'bgGradientHex': ['#ECEBF7', '#D9D7ED'],
        'bgPatternUrl': 'https://images.unsplash.com/photo-1528459801416-a9e53bbf4e17?q=80&w=2000',
        'dividerIconUrl': 'https://cdn-icons-png.flaticon.com/512/620/620757.png',
        'borderFrameUrl': 'https://cdn-icons-png.flaticon.com/512/5904/5904123.png',
        'fontTitle': 'Playfair Display',
        'fontBody': 'Montserrat',
      },
      {
        'id': 12,
        'title': 'White Magnolia',
        'description': 'Fine-art cream backdrop featuring minimalist white magnolia blooms and thin border accents.',
        'primaryColorHex': '#FAFAF8',
        'secondaryColorHex': '#3A3A3A',
        'bgGradientHex': ['#FAFAF8', '#F3F3EF'],
        'bgPatternUrl': 'https://images.unsplash.com/photo-1528459801416-a9e53bbf4e17?q=80&w=2000',
        'dividerIconUrl': 'https://cdn-icons-png.flaticon.com/512/620/620757.png',
        'borderFrameUrl': 'https://cdn-icons-png.flaticon.com/512/5904/5904123.png',
        'fontTitle': 'Alex Brush',
        'fontBody': 'Montserrat',
      },
      {
        'id': 13,
        'title': 'Minimal Gold',
        'description': 'Ultra-clean modern off-white invitation utilizing simple line art frames and refined typography.',
        'primaryColorHex': '#FAF9F6',
        'secondaryColorHex': '#C5A059',
        'bgGradientHex': ['#FAF9F6', '#F2F1E8'],
        'bgPatternUrl': 'https://images.unsplash.com/photo-1528459801416-a9e53bbf4e17?q=80&w=2000',
        'dividerIconUrl': 'https://cdn-icons-png.flaticon.com/512/2913/2913604.png',
        'borderFrameUrl': 'https://cdn-icons-png.flaticon.com/512/5904/5904123.png',
        'fontTitle': 'Cinzel',
        'fontBody': 'Montserrat',
      },
      {
        'id': 14,
        'title': 'Elegant Serif (Modern)',
        'description': 'High-contrast editorial serif layout with no frames, letting elegant typography speak for itself.',
        'primaryColorHex': '#EFEFEE',
        'secondaryColorHex': '#2C3E50',
        'bgGradientHex': ['#EFEFEE', '#DFDFDE'],
        'bgPatternUrl': 'https://images.unsplash.com/photo-1528459801416-a9e53bbf4e17?q=80&w=2000',
        'dividerIconUrl': 'https://cdn-icons-png.flaticon.com/512/2913/2913604.png',
        'borderFrameUrl': 'https://cdn-icons-png.flaticon.com/512/5904/5904123.png',
        'fontTitle': 'Playfair Display',
        'fontBody': 'Montserrat',
      },
      {
        'id': 15,
        'title': 'Luxury Black & Gold',
        'description': 'Stunning dark theme featuring a matte black backdrop with geometric golden borders.',
        'primaryColorHex': '#121212',
        'secondaryColorHex': '#D4AF37',
        'bgGradientHex': ['#121212', '#1C1C1C'],
        'bgPatternUrl': 'https://images.unsplash.com/photo-1621510456681-23a23cfb5f57?q=80&w=2000',
        'dividerIconUrl': 'https://cdn-icons-png.flaticon.com/512/2913/2913604.png',
        'borderFrameUrl': 'https://cdn-icons-png.flaticon.com/512/10700/10700940.png',
        'fontTitle': 'Cinzel',
        'fontBody': 'Montserrat',
      }
    ];
    return rawList.map((json) => RemoteTemplateModel.fromJson(json)).toList();
  }
}

// -------------------------------------------------------------
// RIVERPOD INITIALIZERS AND PROVIDERS
// -------------------------------------------------------------

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized yet in main.dart');
});

final draftsBoxProvider = Provider<Box>((ref) {
  throw UnimplementedError('Drafts box not initialized yet in main.dart');
});

final mockPublishedBoxProvider = Provider<Box>((ref) {
  throw UnimplementedError('Mock published box not initialized yet in main.dart');
});

final mockRsvpsBoxProvider = Provider<Box>((ref) {
  throw UnimplementedError('Mock RSVPs box not initialized yet in main.dart');
});

final invitationRepositoryProvider = Provider<IInvitationRepository>((ref) {
  final drafts = ref.watch(draftsBoxProvider);
  final mockPub = ref.watch(mockPublishedBoxProvider);
  final mockRsvps = ref.watch(mockRsvpsBoxProvider);
  return DualStorageInvitationRepository(drafts, mockPub, mockRsvps);
});

final rsvpsStreamProvider = StreamProvider.family<List<RsvpModel>, String>((ref, invitationId) {
  final repository = ref.watch(invitationRepositoryProvider);
  return repository.listenToRsvps(invitationId);
});

class DraftsNotifier extends Notifier<List<InvitationModel>> {
  @override
  List<InvitationModel> build() {
    final box = ref.watch(draftsBoxProvider);
    
    final subscription = box.watch().listen((_) {
      state = _getDrafts(box);
    });
    
    ref.onDispose(() {
      subscription.cancel();
    });
    
    return _getDrafts(box);
  }

  List<InvitationModel> _getDrafts(Box box) {
    return box.values
        .map((data) => InvitationModel.fromJson(Map<String, dynamic>.from(data)))
        .toList();
  }
}

final draftsProvider = NotifierProvider<DraftsNotifier, List<InvitationModel>>(() {
  return DraftsNotifier();
});

class MockPublishedKeysNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    final box = ref.watch(mockPublishedBoxProvider);
    
    final subscription = box.watch().listen((_) {
      state = _getKeys(box);
    });
    
    ref.onDispose(() {
      subscription.cancel();
    });
    
    return _getKeys(box);
  }

  Set<String> _getKeys(Box box) {
    return box.keys.map((k) => k.toString()).toSet();
  }
}

final mockPublishedKeysProvider = NotifierProvider<MockPublishedKeysNotifier, Set<String>>(() {
  return MockPublishedKeysNotifier();
});

class ActiveInvitationIdsNotifier extends Notifier<Set<String>> {
  static const _key = 'active_invitations';

  @override
  Set<String> build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final list = prefs.getStringList(_key) ?? [];
    return list.toSet();
  }

  Future<void> markAsActive(String id) async {
    final prefs = ref.read(sharedPreferencesProvider);
    final current = state;
    if (!current.contains(id)) {
      final updated = {...current, id};
      state = updated;
      await prefs.setStringList(_key, updated.toList());
    }
  }
}

final activeInvitationIdsProvider = NotifierProvider<ActiveInvitationIdsNotifier, Set<String>>(() {
  return ActiveInvitationIdsNotifier();
});
