import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/person.dart';
import '../../domain/usecases/get_person_detail_usecase.dart';

part 'person_detail_event.dart';
part 'person_detail_state.dart';

class PersonDetailBloc extends Bloc<PersonDetailEvent, PersonDetailState> {
  PersonDetailBloc(this._getPersonDetailUseCase, this._personId)
      : super(const PersonDetailInitial()) {
    on<PersonDetailLoadRequested>(_onLoadRequested);
  }

  final GetPersonDetailUseCase _getPersonDetailUseCase;
  final int _personId;

  Future<void> _onLoadRequested(
    PersonDetailLoadRequested event,
    Emitter<PersonDetailState> emit,
  ) async {
    emit(const PersonDetailLoading());
    final result = await _getPersonDetailUseCase(_personId);
    result.fold(
      (failure) => emit(PersonDetailError(
          failure.message ?? 'Failed to load person details')),
      (person) => emit(PersonDetailLoaded(person)),
    );
  }
}
