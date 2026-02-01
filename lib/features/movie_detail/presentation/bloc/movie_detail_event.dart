part of 'movie_detail_bloc.dart';

sealed class MovieDetailEvent extends Equatable {
  const MovieDetailEvent();

  @override
  List<Object?> get props => [];
}

final class MovieDetailLoadRequested extends MovieDetailEvent {
  const MovieDetailLoadRequested();
}

final class MovieDetailFavoriteToggled extends MovieDetailEvent {
  const MovieDetailFavoriteToggled();
}
