# Low-Level Design (LLD.md): Digital Wedding Invitation Builder (V3)

This document describes class structures, database adapters, and reactive stream listeners supporting Hive local storage, Firebase Firestore cloud, and the Dynamic Remote Template Engine.

---

## 📊 Class Structures & Models

### 1. Model: `RemoteTemplateModel` (Dynamic Remote Presets)
Contains layout styling vectors and remote background patterns queried from the database.

```dart
class RemoteTemplateModel {
  final int id;
  final String title;
  final String description;
  
  // Custom Color Accents
  final String primaryColorHex;    // e.g. "#5B0000"
  final String secondaryColorHex;  // e.g. "#D4AF37"
  final List<String> bgGradientHex; // e.g. ["#5B0000", "#3B0000"]
  
  // Remote Vector & Image Assets
  final String bgPatternUrl;        // Background mandala texture URL
  final String dividerIconUrl;      // Center division vector asset URL
  final String borderFrameUrl;      // Elegant borders overlay URL
  
  // Typography Style Pairings
  final String fontTitle;          // e.g. "Cinzel"
  final String fontBody;           // e.g. "Montserrat"

  RemoteTemplateModel({
    required this.id,
    required this.title,
    required this.description,
    required this.primaryColorHex,
    required this.secondaryColorHex,
    required this.bgGradientHex,
    required this.bgPatternUrl,
    required this.dividerIconUrl,
    required this.borderFrameUrl,
    required this.fontTitle,
    required this.fontBody,
  });

  factory RemoteTemplateModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

### 2. Model: `RsvpModel`
Encapsulates guest response data.

```dart
class RsvpModel {
  final String id;
  final String guestName;
  final int guestsCount;
  final String mealPreference; // Standard, Vegetarian, Vegan
  final bool isAttending;
  final DateTime timestamp;

  RsvpModel({
    required this.id,
    required this.guestName,
    required this.guestsCount,
    required this.mealPreference,
    required this.isAttending,
    required this.timestamp,
  });

  Map<String, dynamic> toJson();
  factory RsvpModel.fromJson(Map<String, dynamic> json);
}
```

---

## 🎨 Dynamic Template Rendering System

Rather than compiling static layouts, the builder integrates a dynamic layout renderer that parses color hex codes, loads Google Fonts dynamically, and caches network assets:

```dart
class DynamicTemplateWidget extends StatelessWidget {
  final InvitationModel invitation;
  final RemoteTemplateModel templateSpec;
  final bool isPreview;

  const DynamicTemplateWidget({
    super.key,
    required this.invitation,
    required this.templateSpec,
    this.isPreview = true,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Parse Hex Colors
    final Color primaryColor = HexColor.fromHex(templateSpec.primaryColorHex);
    final Color secondaryColor = HexColor.fromHex(templateSpec.secondaryColorHex);
    
    // 2. Fetch Google Fonts dynamically at runtime
    final TextStyle titleStyle = GoogleFonts.getFont(
      templateSpec.fontTitle,
      textStyle: TextStyle(color: secondaryColor, fontSize: 32),
    );

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: templateSpec.bgGradientHex.map((hex) => HexColor.fromHex(hex)).toList(),
        ),
      ),
      child: Stack(
        children: [
          // 3. Load Network Mandala / Feather Overlay
          CachedNetworkImage(
            imageUrl: templateSpec.bgPatternUrl,
            opacity: const AlwaysStoppedAnimation(0.12),
          ),
          
          // 4. Border Overlay
          CachedNetworkImage(imageUrl: templateSpec.borderFrameUrl),
          
          // 5. Dynamic Text Bindings
          Center(
            child: Column(
              children: [
                Text(invitation.brideName, style: titleStyle),
                CachedNetworkImage(imageUrl: templateSpec.dividerIconUrl, width: 40),
                Text(invitation.groomName, style: titleStyle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

---

## ⚙️ Service & Repository Architecture

We utilize abstract repositories to keep our viewmodels free from database platform bindings.

```text
                        ┌────────────────────────┐
                        │  IInvitationRepository  │  (Abstract Class)
                        └───────────┬────────────┘
                                    │
                  ┌─────────────────┴─────────────────┐
                  ▼                                   ▼
      ┌──────────────────────┐            ┌──────────────────────┐
      │HiveInvitationRepo    │            │FirestoreInvitation   │
      │(Local Offline Drafts)│            │(Cloud & Live Sync)   │
      └──────────────────────┘            └──────────────────────┘
```

### 1. Database Interfaces
```dart
abstract class IInvitationRepository {
  // Local Hive Operations
  Future<void> saveLocalDraft(InvitationModel invitation);
  Future<InvitationModel?> getLocalDraft(String id);

  // Cloud Firestore Operations
  Future<void> publishToCloud(InvitationModel invitation);
  Future<InvitationModel?> getCloudInvitation(String id);

  // Guest RSVP Streams
  Future<void> submitRsvp(String invitationId, RsvpModel rsvp);
  Stream<List<RsvpModel>> listenToRsvps(String invitationId);
  
  // Remote Template Options
  Future<List<RemoteTemplateModel>> fetchRemoteTemplates();
}
```

---

## ⚙️ ViewModels Design (Riverpod + Streams)

### 1. `BuilderViewModel` (5-Step Wizard & RSVP Stream Integration)
Tracks form details, local draft syncing, cloud publishing, and dashboard states.

```dart
class BuilderViewModel extends StateNotifier<BuilderState> {
  final IInvitationRepository _repository;

  BuilderViewModel(this._repository) : super(BuilderState.initial());

  // Steps: 0=Template, 1=Couple, 2=Logistics, 3=Publish, 4=RSVP Dashboard
  void nextStep();
  void previousStep();
  void setStep(int step);

  // Auto-saves draft to Hive locally as values change
  Future<void> autoSaveLocalDraft();

  // Publishes final configuration to Firestore cloud
  Future<void> publishInvitation(String hostUrl);
}
```

### 2. Riverpod RSVP Stream Provider
A reactive stream provider that listens to Firestore updates and refreshes the Host RSVP Dashboard dynamically.

```dart
final rsvpsStreamProvider = StreamProvider.family<List<RsvpModel>, String>((ref, invitationId) {
  final repository = ref.watch(invitationRepositoryProvider);
  return repository.listenToRsvps(invitationId);
});

final remoteTemplatesProvider = FutureProvider<List<RemoteTemplateModel>>((ref) async {
  final repository = ref.watch(invitationRepositoryProvider);
  return repository.fetchRemoteTemplates();
});
```

---

## 🌳 Widget Component Tree (RSVP Dashboard Step Included)

Below is the layout stack for the builder workspace:

```text
Scaffold (InvitationBuilderView)
 └── Row (Desktop Split View)
      ├── Expanded (Left: Active Wizard Form Card)
      │    └── Card
      │         └── Column
      │              ├── StepProgressIndicator (5-step progress bar)
      │              ├── Expanded
      │              │    └── IndexedStack (index: currentStep)
      │              │         ├── Step 1: Select Template Cards (Listens to remoteTemplatesProvider)
      │              │         ├── Step 2: Couple Details Forms
      │              │         ├── Step 3: Event Logistics Pickers
      │              │         ├── Step 4: Publish & Share (Save to Firestore)
      │              │         └── Step 5: HostRsvpDashboardWidget (Real-time charts & grids)
      │              └── StepNavigationButtons (Next / Back)
      │
      └── Expanded (Right: Visual Live Preview)
           └── AspectRatio (9:16 Custom Painter Card Preview)
```
