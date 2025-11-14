import 'package:flutter/material.dart';
import '../config/premium_theme.dart';

/// Premium Animated Button with Gradient
class PremiumButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Gradient? gradient;
  final IconData? icon;
  final bool isLoading;
  final bool isFullWidth;
  final EdgeInsets? padding;

  const PremiumButton({
    super.key,
    required this.text,
    this.onPressed,
    this.gradient,
    this.icon,
    this.isLoading = false,
    this.isFullWidth = true,
    this.padding,
  });

  @override
  State<PremiumButton> createState() => _PremiumButtonState();
}

class _PremiumButtonState extends State<PremiumButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: PremiumTheme.animationFast,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isPressed = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTapCancel: () {
        setState(() => _isPressed = false);
        _controller.reverse();
      },
      onTap: widget.isLoading ? null : widget.onPressed,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: AnimatedContainer(
          duration: PremiumTheme.animationFast,
          width: widget.isFullWidth ? double.infinity : null,
          padding: widget.padding ??
              const EdgeInsets.symmetric(
                horizontal: PremiumTheme.spaceLg,
                vertical: PremiumTheme.spaceMd,
              ),
          decoration: BoxDecoration(
            gradient: widget.gradient ?? PremiumTheme.primaryGradient,
            borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
            boxShadow: _isPressed
                ? []
                : [
                    PremiumTheme.shadowPrimary,
                    PremiumTheme.shadowMd,
                  ],
          ),
          child: widget.isLoading
              ? const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, color: Colors.white, size: 20),
                      const SizedBox(width: PremiumTheme.spaceSm),
                    ],
                    Text(
                      widget.text,
                      style: PremiumTheme.labelLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

/// Glass Card with Blur Effect
class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: padding ??
            const EdgeInsets.all(PremiumTheme.spaceLg),
        decoration: BoxDecoration(
          gradient: PremiumTheme.glassGradient,
          borderRadius: BorderRadius.circular(PremiumTheme.radiusLg),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: PremiumTheme.glassShadow,
        ),
        child: child,
      ),
    );
  }
}

/// Premium Card with Gradient Border
class PremiumCard extends StatelessWidget {
  final Widget child;
  final Gradient? gradient;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool showShadow;

  const PremiumCard({
    super.key,
    required this.child,
    this.gradient,
    this.padding,
    this.onTap,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient ?? PremiumTheme.primaryGradient,
          borderRadius: BorderRadius.circular(PremiumTheme.radiusLg),
          boxShadow: showShadow
              ? [PremiumTheme.shadowLg]
              : null,
        ),
        child: Container(
          margin: const EdgeInsets.all(2),
          padding: padding ??
              const EdgeInsets.all(PremiumTheme.spaceLg),
          decoration: BoxDecoration(
            color: PremiumTheme.surface,
            borderRadius: BorderRadius.circular(PremiumTheme.radiusLg - 2),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Animated Gradient Container
class AnimatedGradientContainer extends StatefulWidget {
  final Widget child;
  final List<Color> colors;
  final Duration duration;

  const AnimatedGradientContainer({
    super.key,
    required this.child,
    required this.colors,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<AnimatedGradientContainer> createState() =>
      _AnimatedGradientContainerState();
}

class _AnimatedGradientContainerState extends State<AnimatedGradientContainer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.colors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [
                _animation.value * 0.5,
                0.5 + _animation.value * 0.5,
              ],
            ),
          ),
          child: widget.child,
        );
      },
    );
  }
}

/// Premium Text Field
class PremiumTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final IconData? icon;
  final TextEditingController? controller;
  final int maxLines;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;

  const PremiumTextField({
    super.key,
    required this.label,
    this.hint,
    this.icon,
    this.controller,
    this.maxLines = 1,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
  });

  @override
  State<PremiumTextField> createState() => _PremiumTextFieldState();
}

class _PremiumTextFieldState extends State<PremiumTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: PremiumTheme.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: PremiumTheme.spaceSm),
        Focus(
          onFocusChange: (hasFocus) {
            setState(() => _isFocused = hasFocus);
          },
          child: AnimatedContainer(
            duration: PremiumTheme.animationFast,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(PremiumTheme.radiusMd),
              border: Border.all(
                color: _isFocused
                    ? PremiumTheme.primary
                    : PremiumTheme.border,
                width: _isFocused ? 2 : 1,
              ),
              color: PremiumTheme.surfaceVariant,
              boxShadow: _isFocused
                  ? [PremiumTheme.shadowPrimary.copyWith(blurRadius: 10)]
                  : [],
            ),
            child: TextFormField(
              controller: widget.controller,
              maxLines: widget.maxLines,
              keyboardType: widget.keyboardType,
              obscureText: widget.obscureText,
              validator: widget.validator,
              style: PremiumTheme.bodyLarge,
              decoration: InputDecoration(
                hintText: widget.hint,
                hintStyle: PremiumTheme.bodyMedium.copyWith(
                  color: PremiumTheme.textTertiary,
                ),
                prefixIcon: widget.icon != null
                    ? Icon(widget.icon, color: PremiumTheme.primary)
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: PremiumTheme.spaceMd,
                  vertical: PremiumTheme.spaceMd,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Premium Chip
class PremiumChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final IconData? icon;
  final Gradient? gradient;

  const PremiumChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.icon,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: PremiumTheme.animationFast,
        padding: const EdgeInsets.symmetric(
          horizontal: PremiumTheme.spaceMd,
          vertical: PremiumTheme.spaceSm,
        ),
        decoration: BoxDecoration(
          gradient: isSelected
              ? (gradient ?? PremiumTheme.primaryGradient)
              : null,
          color: isSelected ? null : PremiumTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(PremiumTheme.radiusFull),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : PremiumTheme.border,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [PremiumTheme.shadowPrimary.copyWith(blurRadius: 8)]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected
                    ? Colors.white
                    : PremiumTheme.textSecondary,
              ),
              const SizedBox(width: PremiumTheme.spaceXs),
            ],
            Text(
              label,
              style: PremiumTheme.labelMedium.copyWith(
                color: isSelected
                    ? Colors.white
                    : PremiumTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shimmer Loading Effect
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              colors: [
                PremiumTheme.surfaceVariant,
                PremiumTheme.border,
                PremiumTheme.surfaceVariant,
              ],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        );
      },
    );
  }
}

/// Premium Badge
class PremiumBadge extends StatelessWidget {
  final String text;
  final Gradient? gradient;
  final Color? backgroundColor;

  const PremiumBadge({
    super.key,
    required this.text,
    this.gradient,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: PremiumTheme.spaceSm,
        vertical: PremiumTheme.spaceXs,
      ),
      decoration: BoxDecoration(
        gradient: gradient,
        color: backgroundColor,
        borderRadius: BorderRadius.circular(PremiumTheme.radiusFull),
        boxShadow: gradient != null
            ? [PremiumTheme.shadowSm]
            : [],
      ),
      child: Text(
        text,
        style: PremiumTheme.labelSmall.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Stats Card with Animation
class StatsCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Gradient gradient;

  const StatsCard({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(PremiumTheme.spaceMd),
      decoration: BoxDecoration(
        color: PremiumTheme.surface,
        borderRadius: BorderRadius.circular(PremiumTheme.radiusLg),
        boxShadow: [PremiumTheme.shadowMd],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(PremiumTheme.spaceSm),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(PremiumTheme.radiusSm),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(height: PremiumTheme.spaceSm),
          Text(
            value,
            style: PremiumTheme.headlineMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: PremiumTheme.spaceXs),
          Text(
            label,
            style: PremiumTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Floating Action Button with Gradient
class PremiumFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon;
  final Gradient? gradient;

  const PremiumFAB({
    super.key,
    required this.onPressed,
    required this.icon,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient ?? PremiumTheme.primaryGradient,
        borderRadius: BorderRadius.circular(PremiumTheme.radiusFull),
        boxShadow: [
          PremiumTheme.shadowPrimary,
          PremiumTheme.shadowLg,
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(PremiumTheme.radiusFull),
          child: Container(
            padding: const EdgeInsets.all(PremiumTheme.spaceMd),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}

/// Premium Progress Bar
class PremiumProgressBar extends StatelessWidget {
  final double progress;
  final Gradient? gradient;
  final double height;

  const PremiumProgressBar({
    super.key,
    required this.progress,
    this.gradient,
    this.height = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: PremiumTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(PremiumTheme.radiusFull),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient ?? PremiumTheme.primaryGradient,
            borderRadius: BorderRadius.circular(PremiumTheme.radiusFull),
            boxShadow: [
              BoxShadow(
                color: PremiumTheme.primary.withValues(alpha: 0.3),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
