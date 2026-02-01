part of 'movie_detail_bloc.dart';

sealed class MovieDetailState extends Equatable {
  const MovieDetailState();

  @override
  List<Object?> get props => [];
}

final class MovieDetailInitial extends MovieDetailState {
  const MovieDetailInitial();
}

final class MovieDetailLoading extends MovieDetailState {
  const MovieDetailLoading();
}

final class MovieDetailLoaded extends MovieDetailState {
  const MovieDetailLoaded({
    required this.detail,
    this.isFavorite = false,
    this.isFavoriteLoading = false,
  });

  final MovieDetail detail;
  final bool isFavorite;
  final bool isFavoriteLoading;

  MovieDetailLoaded copyWith({
    MovieDetail? detail,
    bool? isFavorite,
    bool? isFavoriteLoading,
  }) =>
      MovieDetailLoaded(
        detail: detail ?? this.detail,
        isFavorite: isFavorite ?? this.isFavorite,
        isFavoriteLoading: isFavoriteLoading ?? this.isFavoriteLoading,
      );

  @override
  List<Object?> get props => [detail, isFavorite, isFavoriteLoading];
}

final class MovieDetailError extends MovieDetailState {
  const MovieDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
