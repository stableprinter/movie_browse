import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:movie_browse/core/config/app_config.dart';
import 'package:movie_browse/features/person_detail/domain/entities/person.dart';
import 'package:movie_browse/features/person_detail/presentation/bloc/person_detail_bloc.dart';
import 'package:movie_browse/features/person_detail/presentation/pages/person_detail_page.dart';
import 'package:mocktail/mocktail.dart';

class MockPersonDetailBloc extends Mock implements PersonDetailBloc {}

void main() {
  late MockPersonDetailBloc mockPersonDetailBloc;

  setUpAll(() {
    registerFallbackValue(const PersonDetailLoadRequested());
  });

  setUp(() {
    mockPersonDetailBloc = MockPersonDetailBloc();

    // Setup default AppConfig
    AppConfig.set(
      appName: 'Test Movie App',
      imageBaseUrl: 'https://image.tmdb.org/t/p/w500',
    );

    // Setup default bloc stream
    when(() => mockPersonDetailBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockPersonDetailBloc.state).thenReturn(const PersonDetailInitial());
    when(() => mockPersonDetailBloc.close()).thenAnswer((_) async {});
    when(() => mockPersonDetailBloc.add(any())).thenReturn(null);
  });

  Widget createTestWidget({int personId = 123}) {
    return BlocProvider<PersonDetailBloc>.value(
      value: mockPersonDetailBloc,
      child: MaterialApp(
        home: PersonDetailView(personId: personId),
      ),
    );
  }

  group('PersonDetailPage Widget', () {
    testWidgets('displays empty widget when in initial state',
        (tester) async {
      when(() => mockPersonDetailBloc.state).thenReturn(const PersonDetailInitial());

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(SizedBox), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('displays loading indicator when in loading state',
        (tester) async {
      when(() => mockPersonDetailBloc.state).thenReturn(const PersonDetailLoading());

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error message and retry button when in error state',
        (tester) async {
      const errorMessage = 'Failed to load person details';
      when(() => mockPersonDetailBloc.state)
          .thenReturn(const PersonDetailError(errorMessage));

      await tester.pumpWidget(createTestWidget());

      expect(find.text(errorMessage), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('retry button dispatches PersonDetailLoadRequested event',
        (tester) async {
      when(() => mockPersonDetailBloc.state)
          .thenReturn(const PersonDetailError('Error'));

      await tester.pumpWidget(createTestWidget());

      await tester.tap(find.text('Retry'));
      await tester.pump();

      verify(() => mockPersonDetailBloc.add(const PersonDetailLoadRequested()))
          .called(greaterThanOrEqualTo(1));
    });

    testWidgets('displays person detail when loaded with all information',
        (tester) async {
      const person = Person(
        id: 123,
        name: 'Test Actor',
        profilePath: '/profile.jpg',
        biography: 'Test biography of the actor',
        birthday: '1990-01-01',
        placeOfBirth: 'Test City',
      );

      when(() => mockPersonDetailBloc.state).thenReturn(
        const PersonDetailLoaded(person),
      );

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Test Actor'), findsOneWidget);
      expect(find.text('Born: 1990-01-01 in Test City'), findsOneWidget);
      expect(find.text('Biography'), findsOneWidget);
      expect(find.text('Test biography of the actor'), findsOneWidget);
    });

    testWidgets('displays person without profile photo when profilePath is null',
        (tester) async {
      const person = Person(
        id: 123,
        name: 'Test Actor',
        profilePath: null,
      );

      when(() => mockPersonDetailBloc.state).thenReturn(
        const PersonDetailLoaded(person),
      );

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Test Actor'), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('does not display biography when biography is null',
        (tester) async {
      const person = Person(
        id: 123,
        name: 'Test Actor',
        biography: null,
      );

      when(() => mockPersonDetailBloc.state).thenReturn(
        const PersonDetailLoaded(person),
      );

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Test Actor'), findsOneWidget);
      expect(find.text('Biography'), findsNothing);
    });

    testWidgets('does not display biography when biography is empty',
        (tester) async {
      const person = Person(
        id: 123,
        name: 'Test Actor',
        biography: '',
      );

      when(() => mockPersonDetailBloc.state).thenReturn(
        const PersonDetailLoaded(person),
      );

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Test Actor'), findsOneWidget);
      expect(find.text('Biography'), findsNothing);
    });

    testWidgets('does not display birth info when birthday is null',
        (tester) async {
      const person = Person(
        id: 123,
        name: 'Test Actor',
        birthday: null,
        placeOfBirth: 'Test City',
      );

      when(() => mockPersonDetailBloc.state).thenReturn(
        const PersonDetailLoaded(person),
      );

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Test Actor'), findsOneWidget);
      expect(find.textContaining('Born:'), findsNothing);
    });

    testWidgets('does not display birth info when birthday is empty',
        (tester) async {
      const person = Person(
        id: 123,
        name: 'Test Actor',
        birthday: '',
        placeOfBirth: 'Test City',
      );

      when(() => mockPersonDetailBloc.state).thenReturn(
        const PersonDetailLoaded(person),
      );

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Test Actor'), findsOneWidget);
      expect(find.textContaining('Born:'), findsNothing);
    });

    testWidgets('displays birthday without place when placeOfBirth is null',
        (tester) async {
      const person = Person(
        id: 123,
        name: 'Test Actor',
        birthday: '1990-01-01',
        placeOfBirth: null,
      );

      when(() => mockPersonDetailBloc.state).thenReturn(
        const PersonDetailLoaded(person),
      );

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Test Actor'), findsOneWidget);
      expect(find.text('Born: 1990-01-01'), findsOneWidget);
      expect(find.textContaining('in'), findsNothing);
    });

    testWidgets('displays birthday without place when placeOfBirth is empty',
        (tester) async {
      const person = Person(
        id: 123,
        name: 'Test Actor',
        birthday: '1990-01-01',
        placeOfBirth: '',
      );

      when(() => mockPersonDetailBloc.state).thenReturn(
        const PersonDetailLoaded(person),
      );

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Test Actor'), findsOneWidget);
      expect(find.text('Born: 1990-01-01'), findsOneWidget);
      expect(find.textContaining('in'), findsNothing);
    });

    testWidgets('displays app bar with title', (tester) async {
      const person = Person(
        id: 123,
        name: 'Test Actor',
      );

      when(() => mockPersonDetailBloc.state).thenReturn(
        const PersonDetailLoaded(person),
      );

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Person'), findsOneWidget);
    });

    testWidgets('displays person with minimal information',
        (tester) async {
      const person = Person(
        id: 123,
        name: 'Minimal Actor',
      );

      when(() => mockPersonDetailBloc.state).thenReturn(
        const PersonDetailLoaded(person),
      );

      await tester.pumpWidget(createTestWidget());

      expect(find.text('Minimal Actor'), findsOneWidget);
      expect(find.text('Biography'), findsNothing);
      expect(find.textContaining('Born:'), findsNothing);
      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('page is scrollable', (tester) async {
      final person = Person(
        id: 123,
        name: 'Test Actor',
        biography: 'A very long biography ' * 100,
        birthday: '1990-01-01',
        placeOfBirth: 'Test City',
      );

      when(() => mockPersonDetailBloc.state).thenReturn(
        PersonDetailLoaded(person),
      );

      await tester.pumpWidget(createTestWidget());

      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });
}
