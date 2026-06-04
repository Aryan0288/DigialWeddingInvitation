import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/invitation_model.dart';
import '../../data/models/remote_template_model.dart';
import '../../data/repositories/invitation_repository.dart';

class InvitationDetailState {
  final InvitationModel? invitation;
  final List<RemoteTemplateModel> availableTemplates;
  final bool isLoading;
  final Duration timeLeft;

  InvitationDetailState({
    this.invitation,
    this.availableTemplates = const [],
    this.isLoading = true,
    this.timeLeft = const Duration(),
  });

  InvitationDetailState copyWith({
    InvitationModel? invitation,
    List<RemoteTemplateModel>? availableTemplates,
    bool? isLoading,
    Duration? timeLeft,
  }) {
    return InvitationDetailState(
      invitation: invitation ?? this.invitation,
      availableTemplates: availableTemplates ?? this.availableTemplates,
      isLoading: isLoading ?? this.isLoading,
      timeLeft: timeLeft ?? this.timeLeft,
    );
  }
}

class InvitationViewModel extends StateNotifier<InvitationDetailState> {
  final IInvitationRepository _repository;
  final String _invitationId;
  Timer? _timer;

  InvitationViewModel(this._repository, this._invitationId)
      : super(InvitationDetailState()) {
    loadInvitation();
  }

  Future<void> loadInvitation() async {
    state = state.copyWith(isLoading: true);
    try {
      final data = await _repository.getCloudInvitation(_invitationId);
      final templates = await _repository.fetchRemoteTemplates();
      
      state = state.copyWith(
        invitation: data,
        availableTemplates: templates,
        isLoading: false,
      );

      if (data != null) {
        _startTimer();
      }
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _updateCountdown();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    if (state.invitation == null) return;
    final now = DateTime.now();
    final difference = state.invitation!.weddingDate.difference(now);
    state = state.copyWith(
      timeLeft: difference.isNegative ? Duration.zero : difference,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final invitationViewModelProvider =
    StateNotifierProvider.family.autoDispose<InvitationViewModel, InvitationDetailState, String>((ref, id) {
  final repository = ref.watch(invitationRepositoryProvider);
  return InvitationViewModel(repository, id);
});
