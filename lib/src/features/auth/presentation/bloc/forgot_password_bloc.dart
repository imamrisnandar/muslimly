import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/auth_repository.dart';

part 'forgot_password_event.dart';
part 'forgot_password_state.dart';

class ForgotPasswordBloc extends Bloc<ForgotPasswordEvent, ForgotPasswordState> {
  final AuthRepository _authRepository;

  ForgotPasswordBloc(this._authRepository) : super(ForgotPasswordInitial()) {
    on<ForgotPasswordEmailSubmitted>(_onEmailSubmitted);
    on<ForgotPasswordOTPSubmitted>(_onOTPSubmitted);
    on<ForgotPasswordResetSubmitted>(_onResetSubmitted);
  }

  Future<void> _onEmailSubmitted(
    ForgotPasswordEmailSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(ForgotPasswordLoading());
    final result = await _authRepository.forgotPassword(event.email);
    result.fold(
      (failure) => emit(ForgotPasswordError(failure.message)),
      (_) => emit(ForgotPasswordEmailSent(event.email)),
    );
  }

  Future<void> _onOTPSubmitted(
    ForgotPasswordOTPSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(ForgotPasswordLoading());
    final result = await _authRepository.verifyOTP(event.email, event.otp);
    result.fold(
      (failure) => emit(ForgotPasswordError(failure.message)),
      (resetToken) => emit(ForgotPasswordOTPVerified(resetToken)),
    );
  }

  Future<void> _onResetSubmitted(
    ForgotPasswordResetSubmitted event,
    Emitter<ForgotPasswordState> emit,
  ) async {
    emit(ForgotPasswordLoading());
    final result = await _authRepository.resetPassword(event.resetToken, event.newPassword);
    result.fold(
      (failure) => emit(ForgotPasswordError(failure.message)),
      (_) => emit(ForgotPasswordSuccess()),
    );
  }
}
