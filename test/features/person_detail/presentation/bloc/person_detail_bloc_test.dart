import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_browse/core/errors/failures.dart';
import 'package:movie_browse/features/person_detail/domain/entities/person.dart';
import 'package:movie_browse/features/person_detail/domain/usecases/get_person_detail_usecase.dart';
import 'package:movie_browse/features/person_detail/presentation/bloc/person_detail_bloc.dart';

class MockGetPersonDetailUseCase extends Mock
    implements GetPersonDetailUseCase {}

void main() {
  late MockGetPersonDetailUseCase mockGetPersonDetailUseCase;
  const int tPersonId = 123;

  setUp(() {
    mockGetPersonDetailUseCase = MockGetPersonDetailUseCase();
  });

  const tPerson = Person(
    id: tPersonId,
    name: 'Test Person',
    profilePath: '/profile.jpg',
    biography: 'Test biography',
    birthday: '1980-01-01',
    placeOfBirth: 'Test City',
  );

  group('PersonDetailBloc', () {
    test('initial state is PersonDetailInitial', () {
      final bloc = PersonDetailBloc(
        mockGetPersonDetailUseCase,
        tPersonId,
      );
      expect(bloc.state, equals(const PersonDetailInitial()));
      bloc.close();
    });

    group('PersonDetailLoadRequested', () {
      blocTest<PersonDetailBloc, PersonDetailState>(
        'emits [PersonDetailLoading, PersonDetailLoaded] when successful',
        build: () {
          when(() => mockGetPersonDetailUseCase(any()))
              .thenAnswer((_) async => const Right(tPerson));
          return PersonDetailBloc(
            mockGetPersonDetailUseCase,
            tPersonId,
          );
        },
        act: (bloc) => bloc.add(const PersonDetailLoadRequested()),
        expect: () => [
          const PersonDetailLoading(),
          const PersonDetailLoaded(tPerson),
        ],
        verify: (_) {
          verify(() => mockGetPersonDetailUseCase(tPersonId)).called(1);
        },
      );

      blocTest<PersonDetailBloc, PersonDetailState>(
        'emits [PersonDetailLoading, PersonDetailError] when ServerFailure occurs',
        build: () {
          when(() => mockGetPersonDetailUseCase(any()))
              .thenAnswer((_) async => const Left(ServerFailure('Server error')));
          return PersonDetailBloc(
            mockGetPersonDetailUseCase,
            tPersonId,
          );
        },
        act: (bloc) => bloc.add(const PersonDetailLoadRequested()),
        expect: () => [
          const PersonDetailLoading(),
          const PersonDetailError('Server error'),
        ],
      );

      blocTest<PersonDetailBloc, PersonDetailState>(
        'emits [PersonDetailLoading, PersonDetailError] when NetworkFailure occurs',
        build: () {
          when(() => mockGetPersonDetailUseCase(any()))
              .thenAnswer((_) async => const Left(NetworkFailure('Network error')));
          return PersonDetailBloc(
            mockGetPersonDetailUseCase,
            tPersonId,
          );
        },
        act: (bloc) => bloc.add(const PersonDetailLoadRequested()),
        expect: () => [
          const PersonDetailLoading(),
          const PersonDetailError('Network error'),
        ],
      );

      blocTest<PersonDetailBloc, PersonDetailState>(
        'emits default error message when failure message is null',
        build: () {
          when(() => mockGetPersonDetailUseCase(any()))
              .thenAnswer((_) async => const Left(ServerFailure()));
          return PersonDetailBloc(
            mockGetPersonDetailUseCase,
            tPersonId,
          );
        },
        act: (bloc) => bloc.add(const PersonDetailLoadRequested()),
        expect: () => [
          const PersonDetailLoading(),
          const PersonDetailError('Failed to load person details'),
        ],
      );

      blocTest<PersonDetailBloc, PersonDetailState>(
        'loads person with minimal information',
        build: () {
          const minimalPerson = Person(
            id: tPersonId,
            name: 'Minimal Person',
          );
          when(() => mockGetPersonDetailUseCase(any()))
              .thenAnswer((_) async => const Right(minimalPerson));
          return PersonDetailBloc(
            mockGetPersonDetailUseCase,
            tPersonId,
          );
        },
        act: (bloc) => bloc.add(const PersonDetailLoadRequested()),
        expect: () => [
          const PersonDetailLoading(),
          const PersonDetailLoaded(
            Person(
              id: tPersonId,
              name: 'Minimal Person',
            ),
          ),
        ],
      );

      blocTest<PersonDetailBloc, PersonDetailState>(
        'loads person with complete information',
        build: () {
          when(() => mockGetPersonDetailUseCase(any()))
              .thenAnswer((_) async => const Right(tPerson));
          return PersonDetailBloc(
            mockGetPersonDetailUseCase,
            tPersonId,
          );
        },
        act: (bloc) => bloc.add(const PersonDetailLoadRequested()),
        expect: () => [
          const PersonDetailLoading(),
          const PersonDetailLoaded(tPerson),
        ],
      );

      blocTest<PersonDetailBloc, PersonDetailState>(
        'maintains personId through multiple load requests',
        build: () {
          when(() => mockGetPersonDetailUseCase(any()))
              .thenAnswer((_) async => const Right(tPerson));
          return PersonDetailBloc(
            mockGetPersonDetailUseCase,
            tPersonId,
          );
        },
        act: (bloc) {
          bloc.add(const PersonDetailLoadRequested());
          return Future.delayed(
            const Duration(milliseconds: 100),
            () => bloc.add(const PersonDetailLoadRequested()),
          );
        },
        expect: () => [
          const PersonDetailLoading(),
          const PersonDetailLoaded(tPerson),
          const PersonDetailLoading(),
          const PersonDetailLoaded(tPerson),
        ],
        verify: (_) {
          verify(() => mockGetPersonDetailUseCase(tPersonId)).called(2);
        },
      );

      blocTest<PersonDetailBloc, PersonDetailState>(
        'handles rapid consecutive load requests',
        build: () {
          when(() => mockGetPersonDetailUseCase(any()))
              .thenAnswer((_) async => const Right(tPerson));
          return PersonDetailBloc(
            mockGetPersonDetailUseCase,
            tPersonId,
          );
        },
        act: (bloc) {
          bloc.add(const PersonDetailLoadRequested());
          bloc.add(const PersonDetailLoadRequested());
          bloc.add(const PersonDetailLoadRequested());
        },
        expect: () => [
          const PersonDetailLoading(),
          const PersonDetailLoaded(tPerson),
          const PersonDetailLoading(),
          const PersonDetailLoaded(tPerson),
          const PersonDetailLoading(),
          const PersonDetailLoaded(tPerson),
        ],
        verify: (_) {
          verify(() => mockGetPersonDetailUseCase(tPersonId)).called(3);
        },
      );

      blocTest<PersonDetailBloc, PersonDetailState>(
        'recovers from error state on successful retry',
        build: () {
          var callCount = 0;
          when(() => mockGetPersonDetailUseCase(any())).thenAnswer((_) async {
            callCount++;
            if (callCount == 1) {
              return const Left(NetworkFailure('Network error'));
            }
            return const Right(tPerson);
          });
          return PersonDetailBloc(
            mockGetPersonDetailUseCase,
            tPersonId,
          );
        },
        act: (bloc) async {
          bloc.add(const PersonDetailLoadRequested());
          await Future.delayed(const Duration(milliseconds: 100));
          bloc.add(const PersonDetailLoadRequested());
        },
        expect: () => [
          const PersonDetailLoading(),
          const PersonDetailError('Network error'),
          const PersonDetailLoading(),
          const PersonDetailLoaded(tPerson),
        ],
        verify: (_) {
          verify(() => mockGetPersonDetailUseCase(tPersonId)).called(2);
        },
      );
    });

    group('PersonDetailBloc with different person IDs', () {
      blocTest<PersonDetailBloc, PersonDetailState>(
        'loads correct person based on personId constructor parameter',
        build: () {
          const anotherPersonId = 456;
          const anotherPerson = Person(
            id: anotherPersonId,
            name: 'Another Person',
          );
          when(() => mockGetPersonDetailUseCase(anotherPersonId))
              .thenAnswer((_) async => const Right(anotherPerson));
          return PersonDetailBloc(
            mockGetPersonDetailUseCase,
            anotherPersonId,
          );
        },
        act: (bloc) => bloc.add(const PersonDetailLoadRequested()),
        expect: () => [
          const PersonDetailLoading(),
          const PersonDetailLoaded(
            Person(
              id: 456,
              name: 'Another Person',
            ),
          ),
        ],
        verify: (_) {
          verify(() => mockGetPersonDetailUseCase(456)).called(1);
          verifyNever(() => mockGetPersonDetailUseCase(tPersonId));
        },
      );
    });
  });
}
