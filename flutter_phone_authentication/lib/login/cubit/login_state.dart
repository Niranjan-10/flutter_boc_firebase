part of 'login_cubit.dart';

class LoginState extends Equatable {
  const LoginState({
    this.email = const Email.pure(),
    this.password = const Password.pure(),
    this.status = FormzStatus.pure,
    this.phone = const Phone.pure(),
    this.otp = const Otp.pure()
  });

  final Email email;
  final Password password;
  final FormzStatus status;
  final Phone phone;
  final Otp otp;

  @override
  List<Object> get props => [email, password, status,phone,otp];

  LoginState copyWith({
    Email email,
    Password password,
    FormzStatus status,
    Phone phone,
    Otp otp
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      status: status ?? this.status,
      phone: phone?? this.phone,
      otp: otp?? this.otp
    );
  }
}
