import 'package:flutter/material.dart';
import 'package:sprout/setup/widgets/pages/wrapper.dart';

class CompleteSetupPage extends StatefulWidget {
  final VoidCallback onSetupSuccess;
  final bool isDesktop;

  const CompleteSetupPage(this.onSetupSuccess, this.isDesktop, {super.key});

  @override
  State<CompleteSetupPage> createState() => _CompleteSetupPageState();
}

class _CompleteSetupPageState extends State<CompleteSetupPage> with TickerProviderStateMixin {
  late AnimationController _entryController;
  late AnimationController _pulseController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Curves.elasticOut,
      ),
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOutSine,
      ),
    );
    _entryController.forward().then((_) {
      if (mounted) {
        _pulseController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SetupPageWrapper(
      widget.isDesktop,
      "Go to Sprout",
      widget.onSetupSuccess,
      Column(
        spacing: 24,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ScaleTransition(
            scale: _scaleAnimation,
            child: ScaleTransition(
              scale: _pulseAnimation,
              child: FadeTransition(
                opacity: _entryController,
                child: const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 128,
                ),
              ),
            ),
          ),
          Text(
            'Setup Complete!',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: widget.isDesktop ? 48 : 36),
            textAlign: TextAlign.center,
          ),
          Text(
            'Your account has been successfully created. You\'re all set to explore the app!',
            style: TextStyle(fontSize: widget.isDesktop ? 20 : 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
