import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/invitation_model.dart';
import '../../data/models/remote_template_model.dart';
import '../../data/repositories/invitation_repository.dart';
import '../../services/export_service.dart' as platform_export;

// State Holder Class
class BuilderState {
  final int currentStep;
  final InvitationModel invitation;
  final List<RemoteTemplateModel> availableTemplates;
  final bool isSaving;
  final String? generatedUrl;

  BuilderState({
    required this.currentStep,
    required this.invitation,
    required this.availableTemplates,
    this.isSaving = false,
    this.generatedUrl,
  });

  BuilderState copyWith({
    int? currentStep,
    InvitationModel? invitation,
    List<RemoteTemplateModel>? availableTemplates,
    bool? isSaving,
    String? generatedUrl,
  }) {
    return BuilderState(
      currentStep: currentStep ?? this.currentStep,
      invitation: invitation ?? this.invitation,
      availableTemplates: availableTemplates ?? this.availableTemplates,
      isSaving: isSaving ?? this.isSaving,
      generatedUrl: generatedUrl ?? this.generatedUrl,
    );
  }
}

// StateNotifier for Invitation Builder
class BuilderViewModel extends StateNotifier<BuilderState> {
  final IInvitationRepository _repository;
  final _uuid = const Uuid();

  BuilderViewModel(this._repository)
      : super(BuilderState(
          currentStep: 0,
          invitation: InvitationModel.empty(),
          availableTemplates: [],
        ));

  // Initialize or Load existing invitation
  Future<void> loadInvitation(String? id) async {
    state = state.copyWith(isSaving: true);
    
    // Fetch remote designs dynamically from the "API"
    final List<RemoteTemplateModel> templates = await _repository.fetchRemoteTemplates();

    if (id == null || id.isEmpty) {
      // Create new blank session with unique ID
      state = BuilderState(
        currentStep: 0,
        invitation: InvitationModel.empty().copyWith(id: _uuid.v4()),
        availableTemplates: templates,
      );
      return;
    }

    // Try loading local draft from Hive Box first
    InvitationModel? localDraft = await _repository.getLocalDraft(id);
    if (localDraft != null) {
      state = BuilderState(
        currentStep: 0,
        invitation: localDraft,
        availableTemplates: templates,
      );
      return;
    }

    // Fallback: Query Cloud invitation
    InvitationModel? cloudInvitation = await _repository.getCloudInvitation(id);
    if (cloudInvitation != null) {
      state = BuilderState(
        currentStep: 0,
        invitation: cloudInvitation,
        availableTemplates: templates,
      );
    } else {
      // Fallback: Create blank
      state = BuilderState(
        currentStep: 0,
        invitation: InvitationModel.empty().copyWith(id: id),
        availableTemplates: templates,
      );
    }
  }

  // Wizard Navigation (0 to 4 steps)
  void nextStep() {
    if (state.currentStep < 4) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void setStep(int step) {
    if (step >= 0 && step <= 4) {
      state = state.copyWith(currentStep: step);
    }
  }

  // Internal Helper: Async auto-save draft to local Hive box on user keypress
  Future<void> _autoSaveDraft() async {
    if (state.invitation.id.isNotEmpty) {
      await _repository.saveLocalDraft(state.invitation);
    }
  }

  // Form Field Updates
  void updateBrideName(String name) {
    state = state.copyWith(
      invitation: state.invitation.copyWith(brideName: name),
    );
    _autoSaveDraft();
  }

  void updateBrideImageUrl(String url) {
    state = state.copyWith(
      invitation: state.invitation.copyWith(brideImageUrl: url),
    );
    _autoSaveDraft();
  }

  void updateGroomName(String name) {
    state = state.copyWith(
      invitation: state.invitation.copyWith(groomName: name),
    );
    _autoSaveDraft();
  }

  void updateGroomImageUrl(String url) {
    state = state.copyWith(
      invitation: state.invitation.copyWith(groomImageUrl: url),
    );
    _autoSaveDraft();
  }

  void updateWeddingDate(DateTime date) {
    state = state.copyWith(
      invitation: state.invitation.copyWith(weddingDate: date),
    );
    _autoSaveDraft();
  }

  void updateWeddingTime(String time) {
    state = state.copyWith(
      invitation: state.invitation.copyWith(weddingTime: time),
    );
    _autoSaveDraft();
  }

  void updateVenueName(String name) {
    state = state.copyWith(
      invitation: state.invitation.copyWith(venueName: name),
    );
    _autoSaveDraft();
  }

  void updateVenueAddress(String address) {
    state = state.copyWith(
      invitation: state.invitation.copyWith(venueAddress: address),
    );
    _autoSaveDraft();
  }

  void updatePersonalMessage(String message) {
    state = state.copyWith(
      invitation: state.invitation.copyWith(personalMessage: message),
    );
    _autoSaveDraft();
  }

  void selectTemplate(int templateId) {
    state = state.copyWith(
      invitation: state.invitation.copyWith(selectedTemplateId: templateId),
    );
    _autoSaveDraft();
  }

  // Actions
  Future<void> saveAndGenerateLink(String hostUrl) async {
    state = state.copyWith(isSaving: true);
    
    // 1. Save to local Hive drafts Box
    await _repository.saveLocalDraft(state.invitation);

    // 2. Publish live configuration to Firebase Firestore Cloud
    await _repository.publishToCloud(state.invitation);
    
    // 3. Generate public shareable URL deep link
    final String url = '$hostUrl#/invitation/${state.invitation.id}';
    
    state = state.copyWith(
      isSaving: false,
      generatedUrl: url,
    );
  }

  Future<bool> downloadPNG(ScreenshotController screenshotController) async {
    try {
      final Uint8List? bytes = await screenshotController.capture(
        delay: const Duration(milliseconds: 100),
      );

      if (bytes != null) {
        final String filename = 'Wedding_Invitation_${state.invitation.brideName.replaceAll(" ", "")}_${state.invitation.groomName.replaceAll(" ", "")}.png';
        await platform_export.ExportService.savePng(bytes, filename);
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}

// Riverpod Provider
final builderViewModelProvider =
    StateNotifierProvider.autoDispose<BuilderViewModel, BuilderState>((ref) {
  final repository = ref.watch(invitationRepositoryProvider);
  return BuilderViewModel(repository);
});

// ── Debounced invitation mirror for the live preview ────────────────────────
//
// The live preview renders a heavy 360x640 template tree. Rebuilding it on
// every keystroke is wasteful, so this notifier mirrors the builder's
// invitation but coalesces rapid text edits into a single emission ~300ms
// after typing stops. Structural changes (template selection, photo
// upload/removal) are emitted immediately so they still feel instant.
//
// The builder view model remains the immediate source of truth, so saving,
// exporting and validation always use the latest values — no data loss.
class _DebouncedInvitationNotifier extends StateNotifier<InvitationModel> {
  _DebouncedInvitationNotifier(super.initial);

  static const Duration _debounce = Duration(milliseconds: 300);
  Timer? _timer;

  void schedule(InvitationModel next) {
    final current = state;
    final structuralChange =
        next.selectedTemplateId != current.selectedTemplateId ||
            next.brideImageUrl != current.brideImageUrl ||
            next.groomImageUrl != current.groomImageUrl;

    if (structuralChange) {
      _timer?.cancel();
      state = next;
      return;
    }

    _timer?.cancel();
    _timer = Timer(_debounce, () => state = next);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final debouncedInvitationProvider = StateNotifierProvider.autoDispose<
    _DebouncedInvitationNotifier, InvitationModel>((ref) {
  final notifier = _DebouncedInvitationNotifier(
    ref.read(builderViewModelProvider).invitation,
  );
  ref.listen<InvitationModel>(
    builderViewModelProvider.select((s) => s.invitation),
    (_, next) => notifier.schedule(next),
  );
  return notifier;
});
