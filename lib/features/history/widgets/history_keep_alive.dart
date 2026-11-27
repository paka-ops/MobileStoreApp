import 'package:flutter/material.dart';

/// ============================================================================
/// HISTORY KEEP ALIVE — conserve l'état d'un onglet d'historique.
///
/// Les quatre pages du `PageView` gardent ainsi leurs données chargées et leur
/// position de défilement lors des glissements (comportement identique à
/// l'implémentation d'origine).
/// ============================================================================
class HistoryKeepAlive extends StatefulWidget {
  final Widget child;

  const HistoryKeepAlive({super.key, required this.child});

  @override
  State<HistoryKeepAlive> createState() => _HistoryKeepAliveState();
}

class _HistoryKeepAliveState extends State<HistoryKeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
