import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../constants/app_durations.dart';
import '../../constants/app_spacing.dart';
import '../../constants/app_spacing.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_decorations.dart';
import '../../theme/app_text_styles.dart';

/// ============================================================================
/// APP DIALOG — dialog premium : barrière floutée, apparition fade + scale.
///
///   AppDialog.show(
///     context,
///     icon: Icons.delete_forever_rounded,
///     iconColor: c.danger,
///     iconSoftColor: c.dangerSoft,
///     title: 'Supprimer le produit',
///     message: 'Cette action est irréversible.',
///     actions: [ ... ],   // des AppButton — la logique reste dans l'écran
///   )
/// ============================================================================
class AppDialog {
  AppDialog._();

  static Future<T?> show<T>(
    BuildContext context, {
    IconData? icon,
    Color? iconColor,
    Color? iconSoftColor,
    Widget? customTitle,
    String? title,
    String? message,
    Widget? content,
    List<Widget> actions = const [],
    bool barrierDismissible = true,
  }) {
    final c = DashColors(context);

    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierLabel: 'Dialog',
      barrierColor: c.barrier,
      pageBuilder: (dialogContext, animation, secondaryAnimation) {
        final List<Widget> columnChildren = <Widget>[];

        if (icon != null) {
          columnChildren
            ..add(
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: iconSoftColor ?? c.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? c.primary,
                  size: 30,
                ),
              ),
            )
            ..add(const SizedBox(height: 18));
        }

        if (customTitle != null) {
          columnChildren.add(customTitle);
        } else if (title != null) {
          columnChildren.add(
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTextStyles.h3.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
                color: c.textPrimary,
              ),
            ),
          );
        }

        if (message != null) {
          columnChildren
            ..add(const SizedBox(height: 10))
            ..add(
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: c.textSecondary,
                  fontSize: 13.5,
                  height: 1.5,
                ),
              ),
            );
        }

        if (content != null) {
          columnChildren
            ..add(const SizedBox(height: 18))
            ..add(content);
        }

        if (actions.isNotEmpty) {
          columnChildren
            ..add(const SizedBox(height: 24))
            ..add(
              Row(
                children: [
                  for (int i = 0; i < actions.length; i++) ...[
                    if (i > 0) const SizedBox(width: 10),
                    Expanded(child: actions[i]),
                  ],
                ],
              ),
            );
        }

        return BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Center(
            child: _FadeScaleIn(
              animation: animation,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 24),
                constraints: const BoxConstraints(maxWidth: 400),
                child: Dialog(
                  backgroundColor: c.card,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xl),
                    side: BorderSide(color: c.border),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: columnChildren,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
      transitionDuration: AppDurations.medium,
    );
  }
}

/// ============================================================================
/// APP SHEET — bottom sheet premium avec poignée et coins arrondis.
/// ============================================================================
class AppSheet {
  AppSheet._();

  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    String? title,
    double maxHeightFactor = 0.85,
    bool isDismissible = true,
  }) {
    final c = DashColors(context);

    return showModalBottomSheet<T>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: isDismissible,
      barrierColor: c.barrier,
      builder: (sheetContext) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight:
                  MediaQuery.sizeOf(sheetContext).height * maxHeightFactor,
            ),
            child: Container(
              decoration: AppDecorations.sheet(c),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: AppSizes.sheetHandleWidth,
                    height: AppSizes.sheetHandleHeight,
                    decoration: BoxDecoration(
                      color: c.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  if (title != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15.5,
                            letterSpacing: -0.2,
                            color: c.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  Flexible(child: builder(sheetContext)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// ============================================================================
/// _FadeScaleIn — animation interne fade + scale (0.92 → 1.0).
/// ============================================================================
class _FadeScaleIn extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const _FadeScaleIn({required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: animation, curve: Curves.easeOut);
    return FadeTransition(
      opacity: curved,
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.92, end: 1.0).animate(curved),
        child: child,
      ),
    );
  }
}
