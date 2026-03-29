import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// Events
abstract class DesignEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SelectBagTypeEvent extends DesignEvent {
  final String bagType;
  SelectBagTypeEvent(this.bagType);
  @override
  List<Object?> get props => [bagType];
}

class UploadImageEvent extends DesignEvent {
  final String imagePath;
  UploadImageEvent(this.imagePath);
  @override
  List<Object?> get props => [imagePath];
}

class GenerateAIDesignEvent extends DesignEvent {
  final String prompt;
  GenerateAIDesignEvent(this.prompt);
  @override
  List<Object?> get props => [prompt];
}

class SaveDesignEvent extends DesignEvent {
  final String designId;
  SaveDesignEvent(this.designId);
  @override
  List<Object?> get props => [designId];
}

// States
abstract class DesignState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DesignInitial extends DesignState {}

class DesignLoading extends DesignState {}

class BagTypeSelected extends DesignState {
  final String bagType;
  BagTypeSelected(this.bagType);
  @override
  List<Object?> get props => [bagType];
}

class ImageUploaded extends DesignState {
  final String imagePath;
  ImageUploaded(this.imagePath);
  @override
  List<Object?> get props => [imagePath];
}

class AIDesignGenerating extends DesignState {}

class AIDesignGenerated extends DesignState {
  final String designUrl;
  AIDesignGenerated(this.designUrl);
  @override
  List<Object?> get props => [designUrl];
}

class DesignSaved extends DesignState {
  final String designId;
  DesignSaved(this.designId);
  @override
  List<Object?> get props => [designId];
}

class DesignError extends DesignState {
  final String message;
  DesignError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class DesignBloc extends Bloc<DesignEvent, DesignState> {
  DesignBloc() : super(DesignInitial()) {
    on<SelectBagTypeEvent>(_onSelectBagType);
    on<UploadImageEvent>(_onUploadImage);
    on<GenerateAIDesignEvent>(_onGenerateAIDesign);
    on<SaveDesignEvent>(_onSaveDesign);
  }

  Future<void> _onSelectBagType(
    SelectBagTypeEvent event,
    Emitter<DesignState> emit,
  ) async {
    emit(DesignLoading());
    await Future.delayed(const Duration(milliseconds: 500));
    emit(BagTypeSelected(event.bagType));
  }

  Future<void> _onUploadImage(
    UploadImageEvent event,
    Emitter<DesignState> emit,
  ) async {
    emit(DesignLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(ImageUploaded(event.imagePath));
  }

  Future<void> _onGenerateAIDesign(
    GenerateAIDesignEvent event,
    Emitter<DesignState> emit,
  ) async {
    emit(AIDesignGenerating());
    await Future.delayed(const Duration(seconds: 3));
    emit(AIDesignGenerated('https://example.com/design.png'));
  }

  Future<void> _onSaveDesign(
    SaveDesignEvent event,
    Emitter<DesignState> emit,
  ) async {
    emit(DesignLoading());
    await Future.delayed(const Duration(seconds: 1));
    emit(DesignSaved(event.designId));
  }
}
