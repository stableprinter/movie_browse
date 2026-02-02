import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browse/features/person_detail/domain/entities/person.dart';

void main() {
  group('Person', () {
    test('supports value equality', () {
      const person1 = Person(id: 1, name: 'Test Person');
      const person2 = Person(id: 1, name: 'Test Person');

      expect(person1, equals(person2));
    });
  });
}

