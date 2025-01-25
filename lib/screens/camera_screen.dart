import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isStreaming = false;
  bool _isLoading = false;
  String? _rpiAddress;
  int _selectedCameraId = 0;
  final TextEditingController _ipController = TextEditingController();
  late WebViewController _webViewController;
  final _formKey = GlobalKey<FormState>(); // Added form key for validation

  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
              _isStreaming = false;
            });
            _showErrorDialog(error.description);
          },
        ),
      );
  }

  Future<bool> _testConnection(String address) async {
    try {
      final response = await http.get(Uri.parse('http://$address:5000/status'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.teal, // Example color scheme - Customize this!
        fontFamily: 'Roboto',       // Example font - Customize this!
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
            textStyle: const TextStyle(fontSize: 18),
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8), // Rounded corners
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8), // Rounded corners for text fields
          ),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('RPi Camera Stream'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form( // Wrapped in Form widget for validation
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField( // Using TextFormField for validation
                  controller: _ipController,
                  decoration: const InputDecoration(
                    labelText: 'Raspberry Pi IP Address',
                    hintText: 'Enter IP address (e.g., 192.168.1.100)',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter an IP address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<int>(
                        value: _selectedCameraId,
                        decoration: const InputDecoration(labelText: 'Select Camera'),
                        onChanged: _isStreaming ? null : (int? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedCameraId = newValue;
                            });
                          }
                        },
                        items: const [
                          DropdownMenuItem(value: 0, child: Text('Camera 0')),
                          DropdownMenuItem(value: 1, child: Text('Camera 1')),
                        ],
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) { // Validate form
                            final success = await _testConnection(_ipController.text);
                            if (!success) {
                              _showErrorDialog('Could not connect to Raspberry Pi');
                              return;
                            }
                            setState(() {
                              _rpiAddress = _ipController.text;
                              _isStreaming = !_isStreaming;
                              if (_isStreaming) {
                                _webViewController.loadRequest(
                                  Uri.parse(
                                      'http://${_rpiAddress}:5000/video_feed/$_selectedCameraId'),
                                );
                              } else {
                                _webViewController.loadRequest(Uri.parse('about:blank'));
                              }
                            });
                          }
                        },
                        child: Text(_isStreaming ? 'Stop Stream' : 'View Stream'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _isStreaming && _rpiAddress != null
                      ? Stack(
                          children: [
                            WebViewWidget(controller: _webViewController),
                            if (_isLoading)
                              const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 5,
                                ),
                              ),
                          ],
                        )
                      : const Center(
                          child: Text(
                            'Press "View Stream" to start streaming',
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }
}