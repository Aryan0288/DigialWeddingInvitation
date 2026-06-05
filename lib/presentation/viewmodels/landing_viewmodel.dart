import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/remote_template_model.dart';
import '../../data/repositories/invitation_repository.dart';

class LandingState {
  final List<RemoteTemplateModel> templates;
  final bool loadingTemplates;
  final String selectedCollection;

  LandingState({
    required this.templates,
    required this.loadingTemplates,
    required this.selectedCollection,
  });

  LandingState copyWith({
    List<RemoteTemplateModel>? templates,
    bool? loadingTemplates,
    String? selectedCollection,
  }) {
    return LandingState(
      templates: templates ?? this.templates,
      loadingTemplates: loadingTemplates ?? this.loadingTemplates,
      selectedCollection: selectedCollection ?? this.selectedCollection,
    );
  }
}

class LandingViewModel extends StateNotifier<LandingState> {
  final IInvitationRepository _repository;

  LandingViewModel(this._repository)
      : super(LandingState(
          templates: [],
          loadingTemplates: true,
          selectedCollection: 'All',
        )) {
    loadTemplates();
  }

  Future<void> loadTemplates() async {
    try {
      final list = await _repository.fetchRemoteTemplates();
      state = state.copyWith(
        templates: list,
        loadingTemplates: false,
      );
    } catch (_) {
      state = state.copyWith(loadingTemplates: false);
    }
  }

  void selectCollection(String collection) {
    state = state.copyWith(selectedCollection: collection);
  }
}

final landingViewModelProvider =
    StateNotifierProvider.autoDispose<LandingViewModel, LandingState>((ref) {
  final repository = ref.watch(invitationRepositoryProvider);
  return LandingViewModel(repository);
});
