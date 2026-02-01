part of 'person_detail_bloc.dart';

sealed class PersonDetailState extends Equatable {
  const PersonDetailState();

  @override
  List<Object?> get props => [];
}

final class PersonDetailInitial extends PersonDetailState {
  const PersonDetailInitial();
}

final class PersonDetailLoading extends PersonDetailState {
  const PersonDetailLoading();
}

final class PersonDetailLoaded extends PersonDetailState {
  const PersonDetailLoaded(this.person);

  final Person person;

  @override
  List<Object?> get props => [person];
}

final class PersonDetailError extends PersonDetailState {
  const PersonDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
