/// Platform channel names. Must match [com.movie.android.Constants].
class ChannelConstants {
  ChannelConstants._();

  /// EventChannel name used by native to push favorite movie IDs to browse.
  /// See MovieAndroid EventChannelRegistry and MethodChannelHandler.broadcastFavList.
  static const String eventChannelName = 'com.movie.android/events';

  /// Event method sent when Favorite tab broadcasts favorite movie IDs to Browse.
  /// See MovieAndroid MethodChannelHandler.broadcastFavList.
  static const String eventBroadcastFavList = 'broadcastFavList';

  /// Event method sent when user switches to Browse tab (MainActivity).
  /// See MovieAndroid Constants.EventChannel.EVENT_SHOULD_RELOAD_BROWSE.
  static const String eventShouldReloadBrowse = 'shouldReloadBrowse';

  /// MethodChannel name for Flutter ↔ native calls. Must match Constants.MethodChannel.NAME.
  static const String methodChannelName = 'com.movie.android/channel';

  /// Method name for notifying native when user toggles favorite from Browse.
  /// See MovieAndroid MethodChannelHandler.onToggleFavorite.
  static const String methodOnToggleFavorite = 'onToggleFavorite';
}
