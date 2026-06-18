part of 'forgot_password_bloc.dart';

abstract class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object?> get props => [];
}

class ForgotPasswordInitial extends ForgotPasswordState {}

class ForgotPasswordLoading extends ForgotPasswordState {}

class ForgotPasswordEmailSent extends ForgotPasswordState {
  final String email;
  const ForgotPasswordEmailSent(this.email);

  @override
  List<Object?> get props => [email];
}

class ForgotPasswordOTPVerified extends ForgotPasswordState {
  final String resetToken;
  const ForgotPasswordOTPVerified(this.resetToken);

  @override
  List<Object?> get props => [resetToken];
}

class ForgotPasswordSuccess extends ForgotPasswordState {}

class ForgotPasswordError extends ForgotPasswordState {
  final String message;
  const ForgotPasswordError(this.message);

  @override
  List<Object?> get props => [message];
}
