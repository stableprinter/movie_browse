import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browse/features/movie_detail/domain/entities/cast_member.dart';

void main() {
  group('CastMember', () {
    test('creates instance with required fields', () {
      const castMember = CastMember(id: 1, name: 'John Doe');

      expect(castMember.id, 1);
      expect(castMember.name, 'John Doe');
      expect(castMember.profilePath, isNull);
      expect(castMember.character, isNull);
      expect(castMember.order, isNull);
    });

    test('creates instance with all fields', () {
      const castMember = CastMember(
        id: 1,
        name: 'John Doe',
        profilePath: '/profile.jpg',
        character: 'Hero',
        order: 0,
      );

      expect(castMember.id, 1);
      expect(castMember.name, 'John Doe');
      expect(castMember.profilePath, '/profile.jpg');
      expect(castMember.character, 'Hero');
      expect(castMember.order, 0);
    });

    test('equality works correctly', () {
      const castMember1 = CastMember(
        id: 1,
        name: 'John Doe',
        profilePath: '/profile.jpg',
        character: 'Hero',
        order: 0,
      );
      const castMember2 = CastMember(
        id: 1,
        name: 'John Doe',
        profilePath: '/profile.jpg',
        character: 'Hero',
        order: 0,
      );
      const castMember3 = CastMember(
        id: 2,
        name: 'Jane Doe',
      );

      expect(castMember1, equals(castMember2));
      expect(castMember1, isNot(equals(castMember3)));
    });

    test('hashCode works correctly', () {
      const castMember1 = CastMember(id: 1, name: 'John Doe');
      const castMember2 = CastMember(id: 1, name: 'John Doe');
      const castMember3 = CastMember(id: 2, name: 'Jane Doe');

      expect(castMember1.hashCode, equals(castMember2.hashCode));
      expect(castMember1.hashCode, isNot(equals(castMember3.hashCode)));
    });

    test('props includes all fields', () {
      const castMember = CastMember(
        id: 1,
        name: 'John Doe',
        profilePath: '/profile.jpg',
        character: 'Hero',
        order: 0,
      );

      expect(
        castMember.props,
        [1, 'John Doe', '/profile.jpg', 'Hero', 0],
      );
    });

    test('props handles null fields', () {
      const castMember = CastMember(id: 1, name: 'John Doe');

      expect(
        castMember.props,
        [1, 'John Doe', null, null, null],
      );
    });
  });
}
