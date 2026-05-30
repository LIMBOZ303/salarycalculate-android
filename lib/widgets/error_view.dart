import 'error_state.dart';

/// Giữ tương thích import cũ.
class ErrorView extends ErrorState {
  const ErrorView({
    super.key,
    required super.message,
    super.onRetry,
  });
}
