import 'package:flutter/services.dart';

import '../constants/channel_constants.dart';

/// Calls native methods via MethodChannel. Used when running inside
/// the MovieAndroid host (e.g. to notify Favorite tab on toggle).
class MethodChannelService {
  MethodChannelService()
    : _channel = MethodChannel(ChannelConstants.methodChannelName);

  final MethodChannel _channel;

  /// Notifies native that the user toggled favorite for [movieId] from Browse.
  /// Native forwards this to the Favorite engine via EventChannel.
  /// No-op if not running in MovieAndroid or call fails.
  Future<void> notifyToggleFavorite(int movieId) async {
    await _channel.invokeMethod<void>(
      ChannelConstants.methodOnToggleFavorite,
      movieId,
    );
  }
}
