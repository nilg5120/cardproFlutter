import 'package:cardpro/features/containers/domain/usecases/add_container.dart';
import 'package:cardpro/features/containers/domain/usecases/delete_container.dart';
import 'package:cardpro/features/containers/domain/usecases/edit_container.dart';
import 'package:cardpro/features/containers/domain/usecases/get_containers.dart';
import 'package:cardpro/features/containers/presentation/bloc/container_event.dart';
import 'package:cardpro/features/decks/domain/entities/container.dart' as container_entity;
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ContainerState extends Equatable {
  const ContainerState();
  @override
  List<Object?> get props => [];
}

class ContainerInitial extends ContainerState {}

class ContainerLoading extends ContainerState {}

class ContainerLoaded extends ContainerState {
  final List<container_entity.Container> containers;
  const ContainerLoaded(this.containers);

  @override
  List<Object> get props => [containers];
}

class ContainerError extends ContainerState {
  final String message;
  const ContainerError(this.message);

  @override
  List<Object> get props => [message];
}

class ContainerBloc extends Bloc<ContainerEvent, ContainerState> {
  final GetContainers getContainers;
  final AddContainer addContainer;
  final DeleteContainer deleteContainer;
  final EditContainer editContainer;

  ContainerBloc({
    required this.getContainers,
    required this.addContainer,
    required this.deleteContainer,
    required this.editContainer,
  }) : super(ContainerInitial()) {
    on<GetContainersEvent>(_onGet);
    on<AddContainerEvent>(_onAdd);
    on<DeleteContainerEvent>(_onDelete);
    on<EditContainerEvent>(_onEdit);
  }

  Future<void> _onGet(GetContainersEvent event, Emitter<ContainerState> emit) async {
    emit(ContainerLoading());
    try {
      final list = await getContainers();
      emit(ContainerLoaded(list));
    } catch (e) {
      emit(ContainerError(e.toString()));
    }
  }

  Future<void> _onAdd(AddContainerEvent event, Emitter<ContainerState> emit) async {
    emit(ContainerLoading());
    final ok = await addContainer(AddContainerParams(
      name: event.name,
      description: event.description,
      containerType: event.containerType,
    ));
    if (ok == null) {
      emit(const ContainerError('Failed to add'));
    } else {
      add(GetContainersEvent());
    }
  }

  Future<void> _onDelete(DeleteContainerEvent event, Emitter<ContainerState> emit) async {
    emit(ContainerLoading());
    final success = await deleteContainer(DeleteContainerParams(id: event.id));
    if (!success) {
      emit(const ContainerError('Failed to delete'));
    } else {
      add(GetContainersEvent());
    }
  }

  Future<void> _onEdit(EditContainerEvent event, Emitter<ContainerState> emit) async {
    emit(ContainerLoading());
    final ok = await editContainer(EditContainerParams(
      id: event.id,
      name: event.name,
      description: event.description,
      containerType: event.containerType,
    ));
    if (ok == null) {
      emit(const ContainerError('Failed to edit'));
    } else {
      add(GetContainersEvent());
    }
  }
}

