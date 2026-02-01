import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/datasources/person_remote_datasource_impl.dart';
import 'data/repositories/person_repository_impl.dart';
import 'domain/usecases/get_person_detail_usecase.dart';
import 'presentation/bloc/person_detail_bloc.dart';
import 'presentation/pages/person_detail_page.dart';

typedef PersonDetailBlocFactory = PersonDetailBloc Function(int personId);

PersonDetailBloc createPersonDetailBloc(int personId) {
  final remoteDatasource = PersonRemoteDatasourceImpl();
  final repository =
      PersonRepositoryImpl(remoteDatasource: remoteDatasource);
  final getPersonDetailUseCase = GetPersonDetailUseCase(repository);
  return PersonDetailBloc(getPersonDetailUseCase, personId);
}

Widget createPersonDetailPage(int personId) {
  return RepositoryProvider<PersonDetailBlocFactory>.value(
    value: createPersonDetailBloc,
    child: PersonDetailPage(personId: personId),
  );
}
