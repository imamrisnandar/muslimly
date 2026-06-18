part of 'forgot_password_bloc.dart';

abstract class ForgotPasswordEvent extends Equatable {
  const ForgotPasswordEvent();

  @override
  List<Object?> get props => [];
}

class ForgotPasswordEmailSubmitted extends ForgotPasswordEvent {
  final String email;
  const ForgotPasswordEmailSubmitted(this.email);

  @override
  List<Object?> get props => [email];
}

class ForgotPasswordOTPSubmitted extends ForgotPasswordEvent {
  final String email;
  final String otp;
  const ForgotPasswordOTPSubmitted({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

class ForgotPasswordResetSubmitted extends ForgotPasswordEvent {
  final String resetToken;
  final String newPassword;
  const ForgotPasswordResetSubmitted({required this.resetToken, required this.newPassword});

  @override
  List<Object?> get props => [resetToken, newPassword];
}
