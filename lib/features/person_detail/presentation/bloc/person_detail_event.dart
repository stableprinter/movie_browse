part of 'person_detail_bloc.dart';

sealed class PersonDetailEvent extends Equatable {
  const PersonDetailEvent();

  @override
  List<Object?> get props => [];
}

final class PersonDetailLoadRequested extends PersonDetailEvent {
  const PersonDetailLoadRequested();
}
