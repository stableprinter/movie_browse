import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browse/core/config/app_config.dart';
import 'package:movie_browse/features/movie_detail/domain/entities/cast_member.dart';
import 'package:movie_browse/features/movie_detail/presentation/widgets/cast_list_item.dart';

void main() {
  setUp(() {
    AppConfig.set(imageBaseUrl: 'https://image.test.com');
  });

  group('CastListItem', () {
    testWidgets('displays cast member name', (tester) async {
      const castMember = CastMember(
        id: 1,
        name: 'John Doe',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CastListItem(
              castMember: castMember,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('displays character name when available', (tester) async {
      const castMember = CastMember(
        id: 1,
        name: 'John Doe',
        character: 'Hero',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CastListItem(
              castMember: castMember,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Hero'), findsOneWidget);
    });

    testWidgets('does not display character name when null', (tester) async {
      const castMember = CastMember(
        id: 1,
        name: 'John Doe',
        character: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CastListItem(
              castMember: castMember,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
      // No character text should be displayed
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      expect(textWidgets.length, 1);
    });

    testWidgets('does not display character name when empty', (tester) async {
      const castMember = CastMember(
        id: 1,
        name: 'John Doe',
        character: '',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CastListItem(
              castMember: castMember,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
      // No character text should be displayed
      final textWidgets = tester.widgetList<Text>(find.byType(Text));
      expect(textWidgets.length, 1);
    });

    testWidgets('displays placeholder when profile path is null', (tester) async {
      const castMember = CastMember(
        id: 1,
        name: 'John Doe',
        profilePath: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CastListItem(
              castMember: castMember,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      const castMember = CastMember(
        id: 1,
        name: 'John Doe',
      );

      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CastListItem(
              castMember: castMember,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      expect(tapped, isTrue);
    });

    testWidgets('displays both name and character when both available', (tester) async {
      const castMember = CastMember(
        id: 1,
        name: 'Jane Smith',
        character: 'Villain',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CastListItem(
              castMember: castMember,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Jane Smith'), findsOneWidget);
      expect(find.text('Villain'), findsOneWidget);
    });
  });
}
