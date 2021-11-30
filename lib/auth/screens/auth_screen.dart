import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:string_validator/string_validator.dart';
import 'package:zxzc9992/auth/screens/email_verification_screen.dart';
import 'package:zxzc9992/auth/screens/forgot_password_form_screen.dart';
import 'package:zxzc9992/auth/screens/reset_password_screen.dart';
import 'package:zxzc9992/services/auth/auth.dart';
import 'package:zxzc9992/services/parse_uri_parameters.dart';
import 'package:zxzc9992/utils/enums/auth_mode.dart';
import 'package:uni_links/uni_links.dart';
import 'dart:async';

class AuthScreen extends StatefulWidget {
  static const routeName = '/auth';

  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  StreamSubscription? _sub;
  final _auth = Auth();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswdController = TextEditingController();

  AuthMode _authMode = AuthMode.login;

  bool _isLoading = false;
  bool _isInit = false;
  bool _initialUriIsHandled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _handleIncomingLinks();
      _handleInitialLinks();
      final args = ModalRoute.of(context)!.settings.arguments as AuthMode?;
      if (args != null) {
        _authMode = args;
      }
    }
    _isInit = false;
  }

  void _handleIncomingLinks() {
    _sub = uriLinkStream.listen((Uri? uri) {
      if (!mounted) return;

      final parameters = parseUriParameters(uri!);

      print('Uri: $uri, parameters: $parameters');

      _handleUriParameters(parameters);
    }, onError: (err) {
      print('_handleIncomingLinks err: $err');
      if (!mounted) return;
    });
  }

  Future<void> _handleInitialLinks() async {
    if (!_initialUriIsHandled) {
      _initialUriIsHandled = true;

      try {
        final uri = await getInitialUri();
        final parameters = parseUriParameters(uri!);

        _handleUriParameters(parameters);

        if (!mounted) return;
      } on PlatformException {
        // Platform messages may fail but we ignore the exception
        print('falied to get initial uri');
      } on FormatException catch (err) {
        print('_handleInitialLinks err: $err');
        if (!mounted) return;
      }
    }
  }

  void _handleUriParameters(Map<String, String> parameters) {
    // User email confirmation
    if (parameters['type'] == 'signup') {
      Navigator.of(context).pushReplacementNamed('/home');
      return;
    }

    // Recovery password
    if (parameters['type'] == 'recovery') {
      final accessToken = parameters['access_token'];

      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => ResetPasswordScreen(jwt: accessToken!),
      ));
      return;
    }
  }

  void _switchAuthMode() {
    setState(() {
      _authMode == AuthMode.login
          ? _authMode = AuthMode.signup
          : _authMode = AuthMode.login;
    });
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    if (_authMode == AuthMode.login) {
      final res = await _auth.signIn(
        _emailController.text,
        _passwordController.text,
      );

      _handleResponse(res, true);
    } else {
      print('signup');
      final res = await _auth.signUp(
        _emailController.text,
        _passwordController.text,
      );

      _handleResponse(res, false);
    }

    setState(() => _isLoading = false);
  }

  void _handleResponse(bool isSuccess, bool isLogin) {
    if (isSuccess) {
      if (isLogin) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      } else {
        // TODO: pushNamedAndRemoveUntil (uni_links stream in auth)
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                EmailVerificationScreen(email: _emailController.text),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('An error occured'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  void dispose() {
    super.dispose();
    _sub?.cancel();
  }

  String get _authModeString =>
      _authMode == AuthMode.login ? 'Log In' : 'Sign Up';

  //TODO Do not allow all characters in email and password
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('$_authModeString to Memause' )),
      appBar: AppBar(title: Text(_authModeString)),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(children: [
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  suffixIcon: Icon(Icons.email_rounded),
                ),
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
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  suffixIcon: Icon(Icons.password_rounded),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }

                  if (_authMode == AuthMode.signup &&
                      value != _confirmPasswdController.text) {
                    return 'Passwords must match';
                  }

                  if (value.length < 8) {
                    return 'Password must contain at least 8 characters';
                  }

                  return null;
                },
              ),
              if (_authMode == AuthMode.signup)
                TextFormField(
                  controller: _confirmPasswdController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                    suffixIcon: Icon(Icons.password_rounded),
                  ),
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
              if (_authMode == AuthMode.signup)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 25),
                  child: AgreementText(),
                ),
              if (_authMode == AuthMode.login)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    child: const Text('Forgot password?'),
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => ForgotPasswordFormScreen(
                          email: _emailController.text,
                        ),
                      ));
                    },
                  ),
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
                  child: _isLoading
                      ? const SizedBox(
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                          height: 20,
                          width: 20,
                        )
                      : Text(
                          _authModeString,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16),
                        ),
                  onPressed: _saveForm,
                ),
              ),
              TextButton(
                child: ChangeAuthModeText(_authMode == AuthMode.login && true),
                onPressed: _switchAuthMode,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

class AgreementText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: const TextSpan(
        // TODO: Company name
        //text: 'By signing in to Memause, you agree to the ',
        text: 'By signing in to, you agree to the ',
        style: TextStyle(fontSize: 14, color: Colors.black),
        children: <TextSpan>[
          TextSpan(
            text: 'Terms of service ',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
          TextSpan(text: 'and '),
          TextSpan(
            text: 'Privacy policy',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}

class ChangeAuthModeText extends StatelessWidget {
  final bool isLogin;

  const ChangeAuthModeText(this.isLogin);

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        text: isLogin ? "Don't have an accout? " : 'Already have an account? ',
        style: const TextStyle(fontSize: 14, color: Colors.black),
        children: <TextSpan>[
          TextSpan(
            text: isLogin ? 'Sign Up' : 'Log In',
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.blue),
          )
        ],
      ),
    );
  }
}
