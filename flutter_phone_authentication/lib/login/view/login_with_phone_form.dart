import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phone_authentication/login/cubit/login_cubit.dart';
import 'package:formz/formz.dart';

String otp;

class LoginWithPhoneForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state.status.isSubmissionFailure) {
          Scaffold.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              const SnackBar(content: Text('Authentication Failure')),
            );
        }
      },
      child: Align(
        alignment: const Alignment(0, -1 / 3),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PhoneInput(),
              const SizedBox(height: 8.0),
              _OtpInput(),
              const SizedBox(height: 8.0),
              _SubmitButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhoneInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.phone != current.phone,
      builder: (context, state) {
        return TextField(
          key: const Key('loginForm_emailInput_textField'),
          onChanged: (phone) => context.read<LoginCubit>().phoneChanged(phone),
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            suffix: IconButton(
                icon: Icon(Icons.arrow_forward),
                onPressed: state.status.isValidated
                    ? () => context.read<LoginCubit>().loginWithPhone()
                    : null),
            labelText: 'Phone',
            helperText: '',
            errorText: state.phone.invalid ? 'invalid phone' : null,
          ),
        );
      },
    );
  }
}

class _OtpInput extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.otp != current.otp,
      builder: (context, state) {
        otp = state.otp.value;

        return TextField(
          key: const Key('loginForm_otpInput_textField'),
          onChanged: (otp) {
            context.read<LoginCubit>().otpChanged(otp);
          },
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            labelText: 'Otp',
            helperText: '',
            errorText: state.otp.invalid ? 'invalid Otp' : null,
          ),
        );
      },
    );
  }
}

class _SubmitButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (previous, current) => previous.status != current.status,
      builder: (context, state) {
        return state.status.isSubmissionInProgress
            ? const CircularProgressIndicator()
            : ElevatedButton(
                key: const Key('submitForm_continue_raisedButton'),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  primary: const Color(0xFFFFD600),
                ),
                child: const Text('SUBMIT'),
                onPressed: state.status.isValidated
                    ? () {
                        print(otp);
                        context.read<LoginCubit>().submitOtp(otp);
                      }
                    : null,
              );
      },
    );
  }
}
