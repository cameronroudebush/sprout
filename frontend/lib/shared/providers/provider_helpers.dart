import 'package:sprout/api/api.dart';

/// A centralized retry function to reduce over-retrying for data
Duration? riverpodRetry(int retryCount, Object error) {
  // Set a max amount of retries
  if (retryCount >= 5) return null;
  // Ignore 429 codes
  if (error is ApiException && error.code == 429) return null;
  // Exponential backoff
  return Duration(milliseconds: 200 * (1 << retryCount));
}
