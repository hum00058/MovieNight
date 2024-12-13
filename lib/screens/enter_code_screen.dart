import 'package:movie_app/utils/app_state.dart';
import 'package:movie_app/utils/http_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'movie_screen.dart';

class EnterCodeScreen extends StatefulWidget {
  const EnterCodeScreen({super.key});

  @override
  State<EnterCodeScreen> createState() => _EnterCodeScreenState();
}

class _EnterCodeScreenState extends State<EnterCodeScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Enter Code',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(40.0),
              child: TextField(
                controller: _codeController,
                maxLength: 4,
                decoration: const InputDecoration(
                  hintText: 'Enter 4-digit code',
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                _joinSession();
              },
              child: const Text('Begin Matching'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _joinSession() async {
    String? deviceId = Provider.of<AppState>(context, listen: false).deviceId;
    final codeString = _codeController.text;
    int? code;
    code = int.tryParse(codeString);

    if (code == null || code.toString().length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid 4-digit code'),
        ),
      );
      return;
    }

    final response = await HttpHelper.joinSession(deviceId, code);
    if (response['data']['session_id'] != null) {
      final sessionId = response['data']['session_id'];
      if (kDebugMode) {
        print(sessionId);
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MovieScreen(
            deviceId: deviceId!,
            sessionId: sessionId,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to join session. Please try again.'),
        ),
      );
    }
  }
}
