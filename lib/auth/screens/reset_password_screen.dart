import 'package:flutter/material.dart';
import 'package:supabase/supabase.dart';
import 'package:zxzc9992/auth/screens/auth_screen.dart';
import 'package:zxzc9992/services/auth/auth.dart';

class ResetPasswordScreen extends StatelessWidget {
  final String jwt;

  const ResetPasswordScreen({required this.jwt});

  @override
  Widget build(BuildContext context) {
    final _passwordController = TextEditingController();
    final _confirmPasswdController = TextEditingController();

    final _formKey = GlobalKey<FormState>();

    Future<void> _saveForm() async {
      if (!_formKey.currentState!.validate()) return;

      final res = await Auth().auth.api.updateUser(
            jwt,
            UserAttributes(password: _passwordController.text),
          );

      if (res.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('An error occured'),
          backgroundColor: Colors.red,
        ));
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Password successfully changed'),
      ));

      Navigator.of(context).pushReplacementNamed(AuthScreen.routeName);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset password'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _passwordController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }

                if (value != _confirmPasswdController.text) {
                  return 'Passwords must match';
                }

                if (value.length < 8) {
                  return 'Password must contain at least 8 characters';
                }

                return null;
              },
            ),
            TextFormField(
              controller: _confirmPasswdController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }

                if (value.length < 8) {
                  return 'Password must contain at least 8 characters';
                }

                return null;
              },
            ),
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
                child:
                    // _isLoading
                    //     ? const SizedBox(
                    //         child: CircularProgressIndicator(
                    //           color: Colors.white,
                    //           strokeWidth: 3,
                    //         ),
                    //         height: 20,
                    //         width: 20,
                    //       )
                    //     :
                    const Text(
                  'Submit changes',
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
    );
  }
}
