import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/views/landing/landing_view.dart';
import '../../presentation/views/builder/builder_view.dart';
import '../../presentation/views/invitation_view/invitation_view.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LandingView(),
      ),
      GoRoute(
        path: '/builder',
        builder: (context, state) {
          final String? id = state.uri.queryParameters['id'];
          final String? stepStr = state.uri.queryParameters['step'];
          final int? step = stepStr != null ? int.tryParse(stepStr) : null;
          return InvitationBuilderView(editingId: id, startStep: step);
        },
      ),
      GoRoute(
        path: '/invitation/:id',
        builder: (context, state) {
          final String id = state.pathParameters['id'] ?? '';
          return InvitationDetailView(invitationId: id);
        },
      ),
    ],
  );
});
