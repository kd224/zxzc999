import 'package:flutter/material.dart';

class EmailVerificationScreen extends StatelessWidget {
  final String email;

  const EmailVerificationScreen({required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Email verification')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           Icon(Icons.email_outlined, size: 35, color: Theme.of(context).primaryColor,),
            const SizedBox(height: 15),
            // TODO: Company name
            const Text(
              'Thanks you for signing up for Company name account',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 25),
            const Text('We have sent an email to:', style: TextStyle(fontSize: 16),),
            Text(email, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 25),
            const Text(
              'Please verify your email address in order to access your Company name account.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
