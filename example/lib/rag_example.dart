import 'package:flutter/material.dart';
import 'package:ai_chat_ui_kit/ai_chat_ui_kit.dart';

/// Example demonstrating RAG (Retrieval-Augmented Generation) chatbot.
///
/// Features:
/// - Document reference citations
/// - Source highlighting
/// - Context-aware responses
/// - Document metadata display
void main() {
  runApp(const RAGChatExample());
}

class RAGChatExample extends StatelessWidget {
  const RAGChatExample({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RAG Chat Example',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const RAGChatScreen(),
    );
  }
}

class RAGChatScreen extends StatefulWidget {
  const RAGChatScreen({super.key});

  @override
  State<RAGChatScreen> createState() => _RAGChatScreenState();
}

class _RAGChatScreenState extends State<RAGChatScreen> {
  final List<ChatMessage> _messages = [];
  final ChatUser _user = ChatUser(
    id: '1',
    name: 'User',
  );
  final ChatUser _assistant = ChatUser(
    id: '2',
    name: 'RAG Assistant',
    avatar: 'https://api.dicebear.com/7.x/bottts/png?seed=rag',
  );

  // Simulated document database
  final List<Document> _documents = [
    Document(
      id: '1',
      title: 'Flutter Documentation',
      content: 'Flutter is Google\'s UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase.',
      category: 'Technology',
    ),
    Document(
      id: '2',
      title: 'AI Chat UI Kit Guide',
      content: 'The AI Chat UI Kit provides comprehensive chat interface components optimized for AI chatbot applications with support for streaming, markdown, and voice input.',
      category: 'Documentation',
    ),
    Document(
      id: '3',
      title: 'RAG Systems Explained',
      content: 'Retrieval-Augmented Generation (RAG) combines the power of large language models with external knowledge retrieval to provide accurate, context-aware responses with source citations.',
      category: 'AI/ML',
    ),
    Document(
      id: '4',
      title: 'Best Practices for Chat UIs',
      content: 'Good chat UIs should provide clear visual hierarchy, support for rich media, real-time feedback, and accessible design patterns.',
      category: 'UX Design',
    ),
  ];

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
          content: 'Hello! I\'m a RAG-powered assistant with access to ${_documents.length} documents. I can answer questions with source citations. Try asking me about Flutter, chat UIs, or RAG systems!',
          sender: MessageSender.assistant,
          user: _assistant,
          timestamp: DateTime.now(),
          status: MessageStatus.sent,
        ),
      );
    });
  }

  void _handleSendMessage(String text) {
    if (text.trim().isEmpty) return;

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
    });

    // Simulate RAG response
    _generateRAGResponse(text);
  }

  void _generateRAGResponse(String query) {
    // Retrieve relevant documents
    final relevantDocs = _retrieveDocuments(query);

    String responseContent;
    Map<String, dynamic> metadata = {};

    if (relevantDocs.isEmpty) {
      responseContent = 'I couldn\'t find any relevant information in my knowledge base about "$query". Could you try rephrasing your question?';
    } else {
      // Generate response with citations
      final buffer = StringBuffer();

      if (relevantDocs.length == 1) {
        buffer.writeln('Based on the available information:\n');
        buffer.writeln(relevantDocs.first.content);
        buffer.writeln('\n---');
        buffer.writeln('\n**Source:**');
        buffer.writeln('📄 ${relevantDocs.first.title} (${relevantDocs.first.category})');
      } else {
        buffer.writeln('I found ${relevantDocs.length} relevant sources:\n');

        for (var i = 0; i < relevantDocs.length; i++) {
          final doc = relevantDocs[i];
          buffer.writeln('**[${i + 1}] ${doc.title}**');
          buffer.writeln(doc.content);
          buffer.writeln();
        }

        buffer.writeln('---');
        buffer.writeln('\n**Sources:**');
        for (var i = 0; i < relevantDocs.length; i++) {
          final doc = relevantDocs[i];
          buffer.writeln('[${i + 1}] ${doc.title} (${doc.category})');
        }
      }

      responseContent = buffer.toString();

      // Add metadata with sources
      metadata = {
        'sources': relevantDocs.map((doc) => {
          'id': doc.id,
          'title': doc.title,
          'category': doc.category,
        }).toList(),
        'retrieval_score': 0.85 + (relevantDocs.length * 0.05),
      };
    }

    // Add AI response
    setState(() {
      _messages.add(
        ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          content: responseContent,
          sender: MessageSender.assistant,
          user: _assistant,
          timestamp: DateTime.now(),
          status: MessageStatus.sent,
          metadata: metadata,
        ),
      );
    });
  }

  List<Document> _retrieveDocuments(String query) {
    final lowerQuery = query.toLowerCase();
    final results = <Document>[];

    // Simple keyword matching (in real RAG, this would be vector similarity)
    for (final doc in _documents) {
      final lowerContent = doc.content.toLowerCase();
      final lowerTitle = doc.title.toLowerCase();

      if (lowerContent.contains('flutter') && lowerQuery.contains('flutter')) {
        results.add(doc);
      } else if (lowerContent.contains('chat') && lowerQuery.contains('chat')) {
        results.add(doc);
      } else if (lowerContent.contains('rag') &&
          (lowerQuery.contains('rag') || lowerQuery.contains('retrieval'))) {
        results.add(doc);
      } else if (lowerTitle.toLowerCase().contains(lowerQuery) ||
          lowerQuery.split(' ').any((word) => lowerContent.contains(word))) {
        results.add(doc);
      }
    }

    return results.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ChatThemeProvider(
      theme: ChatTheme.light().copyWith(
        primaryColor: Colors.deepPurple,
        userBubbleColor: Colors.deepPurple.shade100,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('RAG Chat Example'),
          backgroundColor: Colors.deepPurple,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.library_books),
              tooltip: 'View documents',
              onPressed: () => _showDocumentsDialog(),
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.deepPurple.shade50,
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 20, color: Colors.deepPurple.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Answers include citations from ${_documents.length} knowledge sources',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.deepPurple.shade900,
                      ),
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
              onSendMessage: _handleSendMessage,
              hintText: 'Ask about Flutter, RAG, or chat UIs...',
              showAttachment: false,
              enableVoiceInput: false,
            ),
          ],
        ),
      ),
    );
  }

  void _showDocumentsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Knowledge Base'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: _documents.length,
            itemBuilder: (context, index) {
              final doc = _documents[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepPurple,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    doc.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        doc.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Chip(
                        label: Text(
                          doc.category,
                          style: const TextStyle(fontSize: 10),
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                  isThreeLine: true,
                ),
              );
            },
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
}

class Document {
  final String id;
  final String title;
  final String content;
  final String category;

  Document({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
  });
}
