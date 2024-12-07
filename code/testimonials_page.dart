import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TestimonialsPage extends StatefulWidget {
  const TestimonialsPage({super.key});

  @override
  State<TestimonialsPage> createState() => _TestimonialsPageState();
}

class _TestimonialsPageState extends State<TestimonialsPage> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            setState(() => isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse('https://maxliving.com/success-stories/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Success Stories',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}