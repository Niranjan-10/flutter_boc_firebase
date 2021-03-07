import 'package:formz/formz.dart';

enum OtpValidationError { invalid }

class Otp extends FormzInput<String, OtpValidationError> {
  const Otp.pure() : super.pure('');
  const Otp.dirty([String value = '']) : super.dirty(value);

  static final RegExp _otpRegExp = RegExp(
    r"^[0-9]+$",
  );

  @override
  OtpValidationError validator(String value) {
    return _otpRegExp.hasMatch(value) ? null : OtpValidationError.invalid;
  }
}
