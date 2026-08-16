import 'package:api_debugger/api_debugger.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ApiDebugger.init(enabled: true);
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'API Debugger example',
      theme: ThemeData(colorSchemeSeed: const Color(0xFF4F46E5)),
      builder: (context, child) => ApiDebuggerOverlay(
        child: child ?? const SizedBox.shrink(),
      ),
      home: const ExampleHome(),
    );
  }
}

class ExampleHome extends StatefulWidget {
  const ExampleHome({super.key});

  @override
  State<ExampleHome> createState() => _ExampleHomeState();
}

class _ExampleHomeState extends State<ExampleHome> {
  late final Dio _dio;
  String _message = 'Enable the debugger, then send a request.';

  @override
  void initState() {
    super.initState();
    _dio = Dio()..interceptors.add(ApiDebuggerInterceptor());
  }

  Future<void> _sendRequest() async {
    setState(() => _message = 'Loading...');
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://jsonplaceholder.typicode.com/todos/1',
      );
      setState(() => _message = 'Response: ${response.statusCode}');
    } on DioException catch (error) {
      setState(() => _message = 'Request failed: ${error.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Debugger'),
        actions: const [ApiDebuggerSwitch()],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_message, textAlign: TextAlign.center),
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: _sendRequest,
                icon: const Icon(Icons.send_rounded),
                label: const Text('Send sample request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
