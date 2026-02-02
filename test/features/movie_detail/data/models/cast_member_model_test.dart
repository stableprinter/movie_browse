import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browse/features/movie_detail/data/models/cast_member_model.dart';

void main() {
  group('CastMemberModel', () {
    test('fromJson parses correctly', () {
      const json = {
        'id': 1,
        'name': 'Actor',
        'profile_path': '/profile.png',
        'character': 'Hero',
        'order': 2,
      };

      final model = CastMemberModel.fromJson(json);

      expect(model.id, 1);
      expect(model.name, 'Actor');
      expect(model.profilePath, '/profile.png');
      expect(model.character, 'Hero');
      expect(model.order, 2);
    });
  });
}

