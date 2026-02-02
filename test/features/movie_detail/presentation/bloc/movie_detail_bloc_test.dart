import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:movie_browse/core/errors/failures.dart';
import 'package:movie_browse/core/service/method_channel_service.dart';
import 'package:movie_browse/features/movie_detail/domain/entities/cast_member.dart';
import 'package:movie_browse/features/movie_detail/domain/entities/movie_detail.dart';
import 'package:movie_browse/features/movie_detail/domain/usecases/get_movie_detail_usecase.dart';
import 'package:movie_browse/features/movie_detail/domain/usecases/toggle_favorite_usecase.dart';
import 'package:movie_browse/features/movie_detail/presentation/bloc/movie_detail_bloc.dart';
import 'package:movie_browse/features/movies/domain/entities/movie.dart';

class MockGetMovieDetailUseCase extends Mock implements GetMovieDetailUseCase {}

class MockToggleFavoriteUseCase extends Mock implements ToggleFavoriteUseCase {}

class MockMethodChannelService extends Mock implements MethodChannelService {}

void main() {
  late MockGetMovieDetailUseCase mockGetMovieDetailUseCase;
  late MockToggleFavoriteUseCase mockToggleFavoriteUseCase;
  late MockMethodChannelService mockMethodChannelService;
  const int tMovieId = 123;

  setUp(() {
    mockGetMovieDetailUseCase = MockGetMovieDetailUseCase();
    mockToggleFavoriteUseCase = MockToggleFavoriteUseCase();
    mockMethodChannelService = MockMethodChannelService();
  });

  const tMovie = Movie(
    id: tMovieId,
    title: 'Test Movie',
    posterPath: '/poster.jpg',
    overview: 'Test overview',
    releaseDate: '2023-01-01',
    voteAverage: 7.5,
    voteCount: 100,
  );

  const tCastMember = CastMember(
    id: 1,
    name: 'Test Actor',
    profilePath: '/profile.jpg',
    character: 'Test Character',
    order: 0,
  );

  const tMovieDetail = MovieDetail(
    movie: tMovie,
    cast: [tCastMember],
  );

  group('MovieDetailBloc', () {
    test('initial state is MovieDetailInitial', () {
      final bloc = MovieDetailBloc(
        mockGetMovieDetailUseCase,
        mockToggleFavoriteUseCase,
        mockMethodChannelService,
        tMovieId,
      );
      expect(bloc.state, equals(const MovieDetailInitial()));
      bloc.close();
    });

    group('MovieDetailLoadRequested', () {
      blocTest<MovieDetailBloc, MovieDetailState>(
        'emits [MovieDetailLoading, MovieDetailLoaded] when successful',
        build: () {
          when(() => mockGetMovieDetailUseCase(any()))
              .thenAnswer((_) async => const Right(tMovieDetail));
          return MovieDetailBloc(
            mockGetMovieDetailUseCase,
            mockToggleFavoriteUseCase,
            mockMethodChannelService,
            tMovieId,
          );
        },
        act: (bloc) => bloc.add(const MovieDetailLoadRequested()),
        expect: () => [
          const MovieDetailLoading(),
          const MovieDetailLoaded(
            detail: tMovieDetail,
            isFavorite: false,
          ),
        ],
        verify: (_) {
          verify(() => mockGetMovieDetailUseCase(tMovieId)).called(1);
        },
      );

      blocTest<MovieDetailBloc, MovieDetailState>(
        'emits [MovieDetailLoading, MovieDetailLoaded] with initialIsFavorite=true',
        build: () {
          when(() => mockGetMovieDetailUseCase(any()))
              .thenAnswer((_) async => const Right(tMovieDetail));
          return MovieDetailBloc(
            mockGetMovieDetailUseCase,
            mockToggleFavoriteUseCase,
            mockMethodChannelService,
            tMovieId,
            initialIsFavorite: true,
          );
        },
        act: (bloc) => bloc.add(const MovieDetailLoadRequested()),
        expect: () => [
          const MovieDetailLoading(),
          const MovieDetailLoaded(
            detail: tMovieDetail,
            isFavorite: true,
          ),
        ],
      );

      blocTest<MovieDetailBloc, MovieDetailState>(
        'emits [MovieDetailLoading, MovieDetailError] when ServerFailure occurs',
        build: () {
          when(() => mockGetMovieDetailUseCase(any()))
              .thenAnswer((_) async => const Left(ServerFailure('Server error')));
          return MovieDetailBloc(
            mockGetMovieDetailUseCase,
            mockToggleFavoriteUseCase,
            mockMethodChannelService,
            tMovieId,
          );
        },
        act: (bloc) => bloc.add(const MovieDetailLoadRequested()),
        expect: () => [
          const MovieDetailLoading(),
          const MovieDetailError('Server error'),
        ],
      );

      blocTest<MovieDetailBloc, MovieDetailState>(
        'emits [MovieDetailLoading, MovieDetailError] when NetworkFailure occurs',
        build: () {
          when(() => mockGetMovieDetailUseCase(any()))
              .thenAnswer((_) async => const Left(NetworkFailure('Network error')));
          return MovieDetailBloc(
            mockGetMovieDetailUseCase,
            mockToggleFavoriteUseCase,
            mockMethodChannelService,
            tMovieId,
          );
        },
        act: (bloc) => bloc.add(const MovieDetailLoadRequested()),
        expect: () => [
          const MovieDetailLoading(),
          const MovieDetailError('Network error'),
        ],
      );

      blocTest<MovieDetailBloc, MovieDetailState>(
        'emits default error message when failure message is null',
        build: () {
          when(() => mockGetMovieDetailUseCase(any()))
              .thenAnswer((_) async => const Left(ServerFailure()));
          return MovieDetailBloc(
            mockGetMovieDetailUseCase,
            mockToggleFavoriteUseCase,
            mockMethodChannelService,
            tMovieId,
          );
        },
        act: (bloc) => bloc.add(const MovieDetailLoadRequested()),
        expect: () => [
          const MovieDetailLoading(),
          const MovieDetailError('Failed to load movie details'),
        ],
      );
    });

    group('MovieDetailFavoriteToggled', () {
      blocTest<MovieDetailBloc, MovieDetailState>(
        'does nothing when current state is not MovieDetailLoaded',
        build: () => MovieDetailBloc(
          mockGetMovieDetailUseCase,
          mockToggleFavoriteUseCase,
          mockMethodChannelService,
          tMovieId,
        ),
        act: (bloc) => bloc.add(const MovieDetailFavoriteToggled()),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockToggleFavoriteUseCase(any(), any()));
          verifyNever(() => mockMethodChannelService.notifyToggleFavorite(any()));
        },
      );

      blocTest<MovieDetailBloc, MovieDetailState>(
        'does nothing when isFavoriteLoading is true',
        build: () => MovieDetailBloc(
          mockGetMovieDetailUseCase,
          mockToggleFavoriteUseCase,
          mockMethodChannelService,
          tMovieId,
        ),
        seed: () => const MovieDetailLoaded(
          detail: tMovieDetail,
          isFavorite: false,
          isFavoriteLoading: true,
        ),
        act: (bloc) => bloc.add(const MovieDetailFavoriteToggled()),
        expect: () => [],
        verify: (_) {
          verifyNever(() => mockToggleFavoriteUseCase(any(), any()));
        },
      );

      blocTest<MovieDetailBloc, MovieDetailState>(
        'toggles favorite from false to true successfully',
        build: () {
          when(() => mockToggleFavoriteUseCase(any(), any()))
              .thenAnswer((_) async => const Right(null));
          when(() => mockMethodChannelService.notifyToggleFavorite(any()))
              .thenAnswer((_) async => Future.value());
          return MovieDetailBloc(
            mockGetMovieDetailUseCase,
            mockToggleFavoriteUseCase,
            mockMethodChannelService,
            tMovieId,
          );
        },
        seed: () => const MovieDetailLoaded(
          detail: tMovieDetail,
          isFavorite: false,
        ),
        act: (bloc) => bloc.add(const MovieDetailFavoriteToggled()),
        expect: () => [
          const MovieDetailLoaded(
            detail: tMovieDetail,
            isFavorite: false,
            isFavoriteLoading: true,
          ),
          const MovieDetailLoaded(
            detail: tMovieDetail,
            isFavorite: true,
            isFavoriteLoading: false,
          ),
        ],
        verify: (_) {
          verify(() => mockToggleFavoriteUseCase(tMovieId, true)).called(1);
          verify(() => mockMethodChannelService.notifyToggleFavorite(tMovieId)).called(1);
        },
      );

      blocTest<MovieDetailBloc, MovieDetailState>(
        'toggles favorite from true to false successfully',
        build: () {
          when(() => mockToggleFavoriteUseCase(any(), any()))
              .thenAnswer((_) async => const Right(null));
          when(() => mockMethodChannelService.notifyToggleFavorite(any()))
              .thenAnswer((_) async => Future.value());
          return MovieDetailBloc(
            mockGetMovieDetailUseCase,
            mockToggleFavoriteUseCase,
            mockMethodChannelService,
            tMovieId,
          );
        },
        seed: () => const MovieDetailLoaded(
          detail: tMovieDetail,
          isFavorite: true,
        ),
        act: (bloc) => bloc.add(const MovieDetailFavoriteToggled()),
        expect: () => [
          const MovieDetailLoaded(
            detail: tMovieDetail,
            isFavorite: true,
            isFavoriteLoading: true,
          ),
          const MovieDetailLoaded(
            detail: tMovieDetail,
            isFavorite: false,
            isFavoriteLoading: false,
          ),
        ],
        verify: (_) {
          verify(() => mockToggleFavoriteUseCase(tMovieId, false)).called(1);
          verify(() => mockMethodChannelService.notifyToggleFavorite(tMovieId)).called(1);
        },
      );

      blocTest<MovieDetailBloc, MovieDetailState>(
        'reverts isFavoriteLoading when toggle fails',
        build: () {
          when(() => mockToggleFavoriteUseCase(any(), any()))
              .thenAnswer((_) async => const Left(ServerFailure('Failed to toggle')));
          return MovieDetailBloc(
            mockGetMovieDetailUseCase,
            mockToggleFavoriteUseCase,
            mockMethodChannelService,
            tMovieId,
          );
        },
        seed: () => const MovieDetailLoaded(
          detail: tMovieDetail,
          isFavorite: false,
        ),
        act: (bloc) => bloc.add(const MovieDetailFavoriteToggled()),
        expect: () => [
          const MovieDetailLoaded(
            detail: tMovieDetail,
            isFavorite: false,
            isFavoriteLoading: true,
          ),
          const MovieDetailLoaded(
            detail: tMovieDetail,
            isFavorite: false,
            isFavoriteLoading: false,
          ),
        ],
        verify: (_) {
          verify(() => mockToggleFavoriteUseCase(tMovieId, true)).called(1);
          verifyNever(() => mockMethodChannelService.notifyToggleFavorite(any()));
        },
      );
    });
  });
}
