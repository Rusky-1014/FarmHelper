import 'package:flutter/material.dart';

enum ButtonState { idle, loading, done }

class MorphingAnalyzeButton extends StatefulWidget {
  final ButtonState state;
  final Color accentColor;
  final VoidCallback? onTap;
  final String label;

  const MorphingAnalyzeButton({
    super.key,
    required this.state,
    required this.accentColor,
    required this.label,
    this.onTap,
  });

  @override
  State<MorphingAnalyzeButton> createState() => _MorphingAnalyzeButtonState();
}

class _MorphingAnalyzeButtonState extends State<MorphingAnalyzeButton>
    with TickerProviderStateMixin {
  late AnimationController _morphController;
  late AnimationController _pulseController;
  late Animation<double> _widthAnim;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _morphController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _widthAnim = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _morphController, curve: Curves.easeInOut),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(MorphingAnalyzeButton old) {
    super.didUpdateWidget(old);
    if (widget.state == ButtonState.loading && old.state == ButtonState.idle) {
      _morphController.forward();
    } else if (widget.state == ButtonState.idle &&
        old.state != ButtonState.idle) {
      _morphController.reverse();
    }
  }

  @override
  void dispose() {
    _morphController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.state == ButtonState.idle ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: Listenable.merge([_morphController, _pulseController]),
        builder: (context, _) {
          final isLoading = widget.state == ButtonState.loading;
          final isDone = widget.state == ButtonState.done;

          return ScaleTransition(
            scale: _pulseAnim,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(isLoading ? 30 : 18),
                gradient: isLoading
                    ? null
                    : isDone
                        ? const LinearGradient(
                            colors: [Color(0xFF2DBD6E), Color(0xFF1A8A4A)],
                          )
                        : LinearGradient(
                            colors: [
                              widget.accentColor,
                              widget.accentColor.withOpacity(0.75),
                            ],
                          ),
                color: isLoading ? widget.accentColor.withOpacity(0.15) : null,
                boxShadow: isLoading || isDone
                    ? []
                    : [
                        BoxShadow(
                          color: widget.accentColor.withOpacity(0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                border: isLoading
                    ? Border.all(
                        color: widget.accentColor.withOpacity(0.4), width: 1.5)
                    : null,
              ),
              child: Center(
                child: isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(widget.accentColor),
                        ),
                      )
                    : isDone
                        ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.check_circle_rounded,
                                  color: Colors.white, size: 22),
                              SizedBox(width: 10),
                              Text(
                                'COMPLETE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.biotech_rounded,
                                  color: Colors.white, size: 22),
                              const SizedBox(width: 10),
                              Text(
                                widget.label,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ],
                          ),
              ),
            ),
          );
        },
      ),
    );
  }
}