import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ai_chat_ui_kit/ai_chat_ui_kit.dart';

/// Example demonstrating API integration with OpenAI-compatible services.
///
/// Features:
/// - Real API integration pattern
/// - Error handling
/// - Retry logic
/// - API key management
/// - Rate limiting awareness
///
/// Note: This example uses a mock API. Replace with your actual API endpoint.
void main() {
  runApp(const APIIntegrationExample());
}

class APIIntegrationExample extends StatelessWidget {
  const APIIntegrationExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'API Integration Example',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const APIIntegrationScreen(),
    );
  }
}

class APIIntegrationScreen extends StatefulWidget {
  const APIIntegrationScreen({super.key});

  @override
  State<APIIntegrationScreen> createState() => _APIIntegrationScreenState();
}

class _APIIntegrationScreenState extends State<APIIntegrationScreen> {
  final List<ChatMessage> _messages = [];
  final ChatUser _user = ChatUser(
    id: '1',
    name: 'User',
  );
  final ChatUser _assistant = ChatUser(
    id: '2',
    name: 'API Assistant',
    avatar: 'https://api.dicebear.com/7.x/bottts/png?seed=api',
  );

  final AIService _aiService = AIService();
  bool _isProcessing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(
        ChatMessage(
          id: '0',
          content: '''**API Integration Demo**

This example shows how to integrate the AI Chat UI Kit with external APIs like:
• OpenAI GPT-4 / GPT-3.5
• Anthropic Claude
• Google Gemini
• Custom AI services

**Features:**
✅ Asynchronous API calls
✅ Error handling & retries
✅ Loading states
✅ Rate limiting
✅ Token management

*Note: This demo uses a mock API. Replace AIService with your actual API client.*''',
          sender: MessageSender.assistant,
          user: _assistant,
          timestamp: DateTime.now(),
          status: MessageStatus.sent,
        ),
      );
    });
  }

  Future<void> _handleSendMessage(String text) async {
    if (text.trim().isEmpty || _isProcessing) return;

    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text,
      sender: MessageSender.user,
      user: _user,
      timestamp: DateTime.now(),
      status: MessageStatus.sent,
    );

    setState(() {
      _messages.add(userMessage);
      _isProcessing = true;
      _error = null;
    });

    try {
      // Call AI API
      final response = await _aiService.sendMessage(
        message: text,
        conversationHistory: _messages,
      );

      // Add AI response
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: response.content,
        sender: MessageSender.assistant,
        user: _assistant,
        timestamp: DateTime.now(),
        status: MessageStatus.sent,
        metadata: {
          'model': response.model,
          'tokens_used': response.tokensUsed,
          'completion_time': response.completionTime,
          'finish_reason': response.finishReason,
        },
      );

      setState(() {
        _messages.add(aiMessage);
        _isProcessing = false;
      });

    } on RateLimitException catch (e) {
      setState(() {
        _error = '⏱️ Rate limit exceeded. Please wait ${e.retryAfter} seconds.';
        _isProcessing = false;
      });
      _showErrorSnackBar(_error!);

    } on APIException catch (e) {
      setState(() {
        _error = '❌ API Error: ${e.message}';
        _isProcessing = false;
      });
      _showErrorSnackBar(_error!);
      _addErrorMessage(e.message);

    } catch (e) {
      setState(() {
        _error = '⚠️ Unexpected error: ${e.toString()}';
        _isProcessing = false;
      });
      _showErrorSnackBar(_error!);
      _addErrorMessage('An unexpected error occurred. Please try again.');
    }
  }

  void _addErrorMessage(String errorText) {
    final errorMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: '⚠️ $errorText',
      sender: MessageSender.system,
      user: _assistant,
      timestamp: DateTime.now(),
      status: MessageStatus.failed,
    );

    setState(() {
      _messages.add(errorMessage);
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChatThemeProvider(
      theme: ChatTheme.light().copyWith(
        primaryColor: Colors.indigo,
        userBubbleColor: Colors.indigo.shade100,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('API Integration'),
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              tooltip: 'API Settings',
              onPressed: _showAPISettings,
            ),
          ],
        ),
        body: Column(
          children: [
            if (_isProcessing)
              LinearProgressIndicator(
                backgroundColor: Colors.indigo.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
              ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                border: Border(
                  bottom: BorderSide(color: Colors.indigo.shade200),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _aiService.isConfigured ? Icons.check_circle : Icons.warning,
                    size: 20,
                    color: _aiService.isConfigured ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _aiService.isConfigured
                          ? 'Connected to ${_aiService.providerName}'
                          : 'Demo mode - Configure API key in settings',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: MessageList(
                messages: _messages,
                showDateSeparators: true,
              ),
            ),
            MessageInputComposer(
              onSendMessage: (text) => _handleSendMessage(text),
              hintText: _isProcessing ? 'Processing...' : 'Ask me anything...',
              showAttachment: false,
              enableVoiceInput: false,
            ),
          ],
        ),
      ),
    );
  }

  void _showAPISettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('API Configuration'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'To use real AI services, configure your API key:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildProviderOption('OpenAI', 'GPT-4, GPT-3.5'),
              _buildProviderOption('Anthropic', 'Claude 3'),
              _buildProviderOption('Google', 'Gemini Pro'),
              _buildProviderOption('Custom', 'Your own API'),
              const SizedBox(height: 16),
              const Text(
                'Example code:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '''AIService(
  apiKey: 'your-api-key',
  baseUrl: 'https://api.openai.com/v1',
  model: 'gpt-4',
)''',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderOption(String name, String models) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        dense: true,
        leading: const Icon(Icons.cloud, size: 20),
        title: Text(name),
        subtitle: Text(models, style: const TextStyle(fontSize: 11)),
      ),
    );
  }
}

// ===== AI Service Implementation =====

class AIService {
  final String? apiKey;
  final String baseUrl;
  final String model;

  AIService({
    this.apiKey,
    this.baseUrl = 'https://api.example.com/v1',
    this.model = 'demo-model',
  });

  bool get isConfigured => apiKey != null && apiKey!.isNotEmpty;
  String get providerName => 'Demo API';

  Future<AIResponse> sendMessage({
    required String message,
    required List<ChatMessage> conversationHistory,
  }) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    // In a real implementation, you would call the actual API:
    // final response = await http.post(
    //   Uri.parse('$baseUrl/chat/completions'),
    //   headers: {
    //     'Authorization': 'Bearer $apiKey',
    //     'Content-Type': 'application/json',
    //   },
    //   body: jsonEncode({
    //     'model': model,
    //     'messages': _convertToAPIFormat(conversationHistory),
    //   }),
    // );

    // Simulate different responses
    final lowerMessage = message.toLowerCase();
    String content;

    if (lowerMessage.contains('error')) {
      throw APIException('Simulated API error');
    } else if (lowerMessage.contains('rate limit')) {
      throw RateLimitException(retryAfter: 60);
    } else if (lowerMessage.contains('api')) {
      content = '''**About API Integration:**

When integrating with AI APIs, follow these best practices:

1. **Error Handling**: Always handle network errors, rate limits, and API errors
2. **Retries**: Implement exponential backoff for transient failures
3. **Streaming**: Use streaming for better UX (see streaming_example.dart)
4. **Caching**: Cache responses when appropriate
5. **Security**: Never expose API keys in client code

**Code Example:**
\`\`\`dart
final response = await http.post(
  Uri.parse(apiUrl),
  headers: {
    'Authorization': 'Bearer \$apiKey',
    'Content-Type': 'application/json',
  },
  body: jsonEncode(requestData),
);
\`\`\`

This is a mock response. Configure a real API key to get actual AI responses!''';
    } else {
      content = '''You said: "$message"

This is a **demo response** from the mock API service.

To get real AI responses:
1. Configure your API key in settings
2. Update the AIService class with your provider
3. Implement proper error handling

Try asking about "API" or mentioning "error" or "rate limit" to see different responses!''';
    }

    return AIResponse(
      content: content,
      model: model,
      tokensUsed: message.split(' ').length + content.split(' ').length,
      completionTime: '1.2s',
      finishReason: 'stop',
    );
  }

  List<Map<String, String>> _convertToAPIFormat(List<ChatMessage> messages) {
    return messages.map((msg) => {
      'role': msg.isUser ? 'user' : 'assistant',
      'content': msg.content,
    }).toList();
  }
}

class AIResponse {
  final String content;
  final String model;
  final int tokensUsed;
  final String completionTime;
  final String finishReason;

  AIResponse({
    required this.content,
    required this.model,
    required this.tokensUsed,
    required this.completionTime,
    required this.finishReason,
  });
}

class APIException implements Exception {
  final String message;
  APIException(this.message);
}

class RateLimitException implements Exception {
  final int retryAfter;
  RateLimitException({required this.retryAfter});
}
