import 'package:flutter/material.dart';
import '../../app/theme.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            height: 40,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '불러오는 중...',
            style: TextStyle(
              color: AppColors.textHint,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorView({super.key, required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('다시 시도'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EmptyStateView extends StatelessWidget {
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyStateView({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: AppColors.textHint),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 15,
                height: 1.5,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              SizedBox(
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: onAction,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(actionLabel!),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

void showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(
      children: [
        const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    ),
    backgroundColor: AppColors.accent,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    duration: const Duration(seconds: 3),
  ));
}

void showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Row(
      children: [
        const Icon(Icons.check_circle_outline_rounded,
            color: Colors.white, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(fontSize: 14),
          ),
        ),
      ],
    ),
    backgroundColor: AppColors.success,
    behavior: SnackBarBehavior.floating,
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    duration: const Duration(seconds: 2),
  ));
}
