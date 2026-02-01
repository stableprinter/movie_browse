import 'package:flutter/services.dart';

import '../constants/channel_constants.dart';

/// Event types from native EventChannel (com.movie.android/events).
sealed class EventChannelEvent {
  const EventChannelEvent();
}

/// Favorite movie IDs sent when Favorite tab calls broadcastFavList.
final class FavoriteIdsEvent extends EventChannelEvent {
  FavoriteIdsEvent(this.ids);
  final List<int> ids;
}

/// Sent when user switches to Browse tab; browse page should reload.
final class ShouldReloadBrowseEvent extends EventChannelEvent {
  const ShouldReloadBrowseEvent();
}

/// Exposes the native EventChannel stream.
/// Native sends a map: { "method": String, "param": dynamic }.
/// See MovieAndroid EventChannelRegistry.send(engineId, method, param).
/// Consumers (e.g. MoviesBloc) subscribe and cancel in their own lifecycle.
class EventChannelService {
  EventChannelService() : _channel = EventChannel(ChannelConstants.eventChannelName);

  final EventChannel _channel;

  /// Stream of events from native: favorite IDs and shouldReloadBrowse.
  Stream<EventChannelEvent> get eventStream {
    return _channel.receiveBroadcastStream().map(_parseEvent);
  }

  /// Legacy: stream of favorite movie ID lists only.
  Stream<List<int>> get favoriteMovieIdsStream {
    return eventStream.where((e) => e is FavoriteIdsEvent).map((e) => (e as FavoriteIdsEvent).ids);
  }

  static EventChannelEvent _parseEvent(dynamic value) {
    final map = value as Map?;
    if (map == null) return FavoriteIdsEvent([]);

    final method = map['method'] as String?;
    final param = map['param'];

    switch (method) {
      case ChannelConstants.eventShouldReloadBrowse:
        return const ShouldReloadBrowseEvent();
      case ChannelConstants.eventBroadcastFavList:
        if (param is List) {
          final ids = param
              .map((e) => e is int ? e : (e is num ? e.toInt() : null))
              .whereType<int>()
              .toList();
          return FavoriteIdsEvent(ids);
        }
        return FavoriteIdsEvent([]);
      default:
        return FavoriteIdsEvent([]);
    }
  }
}
