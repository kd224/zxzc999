import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';
import 'package:validators/validators.dart';
import 'package:zxzc9992/services/auth/auth.dart';

class ForgotPasswordFormScreen extends StatelessWidget {
  final String email;

  const ForgotPasswordFormScreen({
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();

    final _controller = TextEditingController();
    _controller.text = email;

    Future<void> _saveForm() async {
      if (!_formKey.currentState!.validate()) return;

      final res = await Auth().auth.api.resetPasswordForEmail(
            _controller.text,
            options: AuthOptions(redirectTo: 'zxzc9992://reset-callback/'),
          );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recover password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Enter the e-mail address you provided during registration. We will send a link to change the password to your mailbox.',
              ),
              TextFormField(
                controller: _controller,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                    labelText: 'Email Address',
                    suffixIcon: Icon(Icons.email_rounded)),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email';
                  }

                  if (!isEmail(value)) {
                    return 'Please enter a valid email';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 25),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).shadowColor,
                      spreadRadius: 1,
                      blurRadius: 1,
                      offset: const Offset(0, 1),
                    ),
                  ],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextButton(
                  child: const Text(
                    'Reset password',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16),
                  ),
                  onPressed: _saveForm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
