import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browse/features/person_detail/data/models/person_model.dart';

void main() {
  group('PersonModel', () {
    test('fromJson parses correctly', () {
      const json = {
        'id': 1,
        'name': 'Person',
        'profile_path': '/profile.png',
        'biography': 'Bio',
        'birthday': '2000-01-01',
        'place_of_birth': 'Earth',
      };

      final model = PersonModel.fromJson(json);

      expect(model.id, 1);
      expect(model.name, 'Person');
      expect(model.profilePath, '/profile.png');
      expect(model.biography, 'Bio');
      expect(model.birthday, '2000-01-01');
      expect(model.placeOfBirth, 'Earth');
    });
  });
}

