import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/views/landing/landing_view.dart';
import '../../presentation/views/builder/builder_view.dart';
import '../../presentation/views/invitation_view/invitation_view.dart';
import '../../presentation/views/splash/splash_view.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SplashView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LandingView(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: '/builder',
        pageBuilder: (context, state) {
          final String? id = state.uri.queryParameters['id'];
          final String? stepStr = state.uri.queryParameters['step'];
          final int? step = stepStr != null ? int.tryParse(stepStr) : null;
          final String? templateStr = state.uri.queryParameters['template'];
          final int? templateId = templateStr != null ? int.tryParse(templateStr) : null;
          
          return CustomTransitionPage(
            key: state.pageKey,
            child: InvitationBuilderView(editingId: id, startStep: step, preselectedTemplateId: templateId),
            transitionDuration: const Duration(milliseconds: 400),
            reverseTransitionDuration: const Duration(milliseconds: 300),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.96, end: 1.0).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutBack,
                    ),
                  ),
                  child: child,
                ),
              );
            },
          );
        },
      ),
      GoRoute(
        path: '/invitation/:id',
        pageBuilder: (context, state) {
          final String id = state.pathParameters['id'] ?? '';
          return CustomTransitionPage(
            key: state.pageKey,
            child: InvitationDetailView(invitationId: id),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          );
        },
      ),
    ],
  );
});
