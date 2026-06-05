import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/rsvp_model.dart';
import '../../data/repositories/invitation_repository.dart';

class GuestRsvpState {
  final bool isAttending;
  final int guestCount;
  final String mealPreference;
  final bool isSaving;
  final bool isSubmitted;

  GuestRsvpState({
    this.isAttending = true,
    this.guestCount = 1,
    this.mealPreference = 'Standard',
    this.isSaving = false,
    this.isSubmitted = false,
  });

  GuestRsvpState copyWith({
    bool? isAttending,
    int? guestCount,
    String? mealPreference,
    bool? isSaving,
    bool? isSubmitted,
  }) {
    return GuestRsvpState(
      isAttending: isAttending ?? this.isAttending,
      guestCount: guestCount ?? this.guestCount,
      mealPreference: mealPreference ?? this.mealPreference,
      isSaving: isSaving ?? this.isSaving,
      isSubmitted: isSubmitted ?? this.isSubmitted,
    );
  }
}

class GuestRsvpViewModel extends StateNotifier<GuestRsvpState> {
  final IInvitationRepository _repository;
  final String _invitationId;

  GuestRsvpViewModel(this._repository, this._invitationId) : super(GuestRsvpState());

  void setAttending(bool isAttending) {
    state = state.copyWith(isAttending: isAttending);
  }

  void setGuestCount(int count) {
    state = state.copyWith(guestCount: count);
  }

  void setMealPreference(String pref) {
    state = state.copyWith(mealPreference: pref);
  }

  Future<void> submitRsvp(String name) async {
    if (name.isEmpty) return;
    state = state.copyWith(isSaving: true);
    try {
      final rsvp = RsvpModel(
        id: const Uuid().v4(),
        guestName: name,
        guestsCount: state.isAttending ? state.guestCount : 0,
        mealPreference: state.isAttending ? state.mealPreference : 'Standard',
        isAttending: state.isAttending,
        timestamp: DateTime.now(),
      );

      await _repository.submitRsvp(_invitationId, rsvp);
      state = state.copyWith(isSaving: false, isSubmitted: true);
    } catch (_) {
      state = state.copyWith(isSaving: false);
    }
  }
}

final guestRsvpViewModelProvider =
    StateNotifierProvider.family.autoDispose<GuestRsvpViewModel, GuestRsvpState, String>((ref, invitationId) {
  final repository = ref.watch(invitationRepositoryProvider);
  return GuestRsvpViewModel(repository, invitationId);
});
