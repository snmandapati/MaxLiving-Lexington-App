import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArticlesPage extends StatefulWidget {
  const ArticlesPage({super.key});

  @override
  State<ArticlesPage> createState() => _ArticlesPageState();
}

class _ArticlesPageState extends State<ArticlesPage> {
  late final WebViewController controller;
  bool isLoading = true;
  bool canGoBack = false;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) async {
            final canNavigateBack = await controller.canGoBack();
            setState(() {
              isLoading = false;
              canGoBack = canNavigateBack;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://maxliving.com/category/healthy-articles') ||
                request.url.startsWith('https://maxliving.com/healthy-articles')) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      )
      ..loadRequest(Uri.parse('https://maxliving.com/category/healthy-articles/'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: canGoBack
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () async {
                  if (await controller.canGoBack()) {
                    controller.goBack();
                  }
                },
              )
            : null,
        title: const Text(
          'Articles',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              controller.reload();
            },
          ),
        ],
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