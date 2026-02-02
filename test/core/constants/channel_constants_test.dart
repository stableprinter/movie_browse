import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browse/core/constants/channel_constants.dart';

void main() {
  group('ChannelConstants', () {
    test('event and method names are non-empty', () {
      expect(ChannelConstants.eventChannelName, isNotEmpty);
      expect(ChannelConstants.eventBroadcastFavList, isNotEmpty);
      expect(ChannelConstants.eventShouldReloadBrowse, isNotEmpty);
      expect(ChannelConstants.methodChannelName, isNotEmpty);
      expect(ChannelConstants.methodOnToggleFavorite, isNotEmpty);
    });
  });
}

