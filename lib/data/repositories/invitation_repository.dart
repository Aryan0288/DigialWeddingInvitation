import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/invitation_model.dart';
import '../models/rsvp_model.dart';
import '../models/remote_template_model.dart';
import 'template_data.dart';
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
  List<RemoteTemplateModel>? _cachedTemplates;

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
    if (_cachedTemplates != null) {
      return _cachedTemplates!;
    }
    _cachedTemplates = rawTemplatesData.map((json) => RemoteTemplateModel.fromJson(json)).toList();
    return _cachedTemplates!;
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
