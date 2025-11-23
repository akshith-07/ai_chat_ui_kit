# Contributing to AI Chat UI Kit

Thank you for your interest in contributing to the AI Chat UI Kit! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [How to Contribute](#how-to-contribute)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Pull Request Process](#pull-request-process)
- [Reporting Issues](#reporting-issues)

## Code of Conduct

This project follows the [Contributor Covenant Code of Conduct](https://www.contributor-covenant.org/). By participating, you are expected to uphold this code. Please report unacceptable behavior to the project maintainers.

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR-USERNAME/ai_chat_ui_kit.git
   cd ai_chat_ui_kit
   ```
3. **Add the upstream remote**:
   ```bash
   git remote add upstream https://github.com/ORIGINAL-OWNER/ai_chat_ui_kit.git
   ```
4. **Create a new branch** for your feature or bug fix:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Setup

### Prerequisites

- Flutter SDK (latest stable version)
- Dart SDK (comes with Flutter)
- Git
- Your favorite IDE (VS Code, Android Studio, IntelliJ IDEA)

### Installation

1. Install dependencies:
   ```bash
   flutter pub get
   ```

2. Run code generation (if needed):
   ```bash
   flutter pub run build_runner build
   ```

3. Verify everything works:
   ```bash
   flutter analyze
   flutter test
   ```

## Project Structure

```
ai_chat_ui_kit/
├── lib/
│   ├── controllers/      # State management and controllers
│   ├── models/           # Data models
│   ├── themes/           # Theming system
│   ├── utils/            # Utility functions
│   └── widgets/          # UI components
├── example/              # Example applications
│   └── lib/
│       ├── main.dart
│       ├── streaming_example.dart
│       ├── rag_example.dart
│       ├── multimodal_example.dart
│       ├── voice_chat_example.dart
│       └── api_integration_example.dart
├── test/                 # Unit and widget tests
│   ├── models/
│   ├── controllers/
│   ├── utils/
│   ├── widgets/
│   └── integration/
└── pubspec.yaml
```

## How to Contribute

### Types of Contributions

We welcome various types of contributions:

- **Bug Fixes**: Fix issues reported in GitHub Issues
- **New Features**: Add new widgets, features, or capabilities
- **Documentation**: Improve README, API docs, or examples
- **Tests**: Add or improve test coverage
- **Performance**: Optimize existing code
- **Examples**: Add new example applications

### Before You Start

1. **Check existing issues** to see if someone is already working on it
2. **Create an issue** if one doesn't exist for your contribution
3. **Discuss significant changes** with maintainers before implementation
4. **Keep changes focused**: One feature/fix per pull request

## Coding Standards

### Dart Style Guide

Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart):

- Use `dartfmt` to format code:
  ```bash
  dart format .
  ```

- Run analyzer:
  ```bash
  flutter analyze
  ```

### Code Quality Rules

1. **Documentation**:
   - All public APIs must have dartdoc comments
   - Include usage examples in documentation
   - Document parameters, return values, and exceptions

   ```dart
   /// A widget that displays a chat message bubble.
   ///
   /// The [message] parameter is required and contains the message data.
   /// Use [showAvatar] to control avatar visibility.
   ///
   /// Example:
   /// ```dart
   /// MessageBubble(
   ///   message: chatMessage,
   ///   showAvatar: true,
   /// )
   /// ```
   class MessageBubble extends StatelessWidget {
     // ...
   }
   ```

2. **Naming Conventions**:
   - Classes: `PascalCase`
   - Variables/Functions: `camelCase`
   - Constants: `lowerCamelCase` or `SCREAMING_SNAKE_CASE`
   - Private members: prefix with `_`

3. **File Organization**:
   - One class per file (except for small helper classes)
   - File names: `snake_case.dart`
   - Group imports: Dart SDK, external packages, local imports

   ```dart
   import 'dart:async';

   import 'package:flutter/material.dart';
   import 'package:intl/intl.dart';

   import '../models/chat_message.dart';
   import '../themes/chat_theme.dart';
   ```

4. **Widget Best Practices**:
   - Use `const` constructors when possible
   - Prefer composition over inheritance
   - Extract widgets for better organization
   - Use proper lifecycle methods (dispose, etc.)

5. **Error Handling**:
   - Always handle errors gracefully
   - Use try-catch for async operations
   - Provide meaningful error messages

## Testing Guidelines

### Test Requirements

- **Unit Tests**: All utilities and models must have unit tests
- **Widget Tests**: All widgets must have widget tests
- **Integration Tests**: Major features should have integration tests
- **Minimum Coverage**: Aim for 80%+ code coverage

### Writing Tests

1. **Test File Naming**: `<file_name>_test.dart`
2. **Test Organization**: Use `group` to organize related tests
3. **Test Description**: Clear, descriptive test names

Example:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ai_chat_ui_kit/ai_chat_ui_kit.dart';

void main() {
  group('ChatMessage', () {
    test('creates instance with required parameters', () {
      final message = ChatMessage(
        id: '1',
        content: 'Hello',
        sender: MessageSender.user,
        user: ChatUser(id: '1', name: 'User'),
        timestamp: DateTime.now(),
      );

      expect(message.content, 'Hello');
      expect(message.isUser, isTrue);
    });

    test('copyWith updates only specified fields', () {
      final original = ChatMessage(/*...*/);
      final updated = original.copyWith(content: 'New content');

      expect(updated.content, 'New content');
      expect(updated.id, original.id);
    });
  });
}
```

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/models/chat_message_test.dart

# Run with coverage
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Pull Request Process

### Before Submitting

1. **Update from upstream**:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Run tests**:
   ```bash
   flutter analyze
   flutter test
   flutter pub publish --dry-run
   ```

3. **Update documentation** if needed

4. **Add changelog entry** in CHANGELOG.md

### PR Guidelines

1. **Title**: Clear, concise description of changes
   - Good: "Add search functionality to MessageList widget"
   - Bad: "Update code"

2. **Description**: Include:
   - What changes were made
   - Why the changes were necessary
   - How to test the changes
   - Screenshots (for UI changes)
   - Related issue numbers

3. **Commits**:
   - Use meaningful commit messages
   - Follow conventional commits format:
     - `feat: add voice input button`
     - `fix: resolve message bubble alignment issue`
     - `docs: update README with new examples`
     - `test: add unit tests for ExportService`
     - `refactor: simplify StreamingChatController logic`

4. **Code Review**:
   - Address all review comments
   - Be open to feedback
   - Make requested changes promptly

### PR Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Tests pass locally
- [ ] New tests added
- [ ] Manual testing performed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review performed
- [ ] Documentation updated
- [ ] No new warnings
- [ ] Tests added/updated
- [ ] CHANGELOG.md updated
```

## Reporting Issues

### Bug Reports

Include:
- **Clear title** describing the bug
- **Steps to reproduce**
- **Expected behavior**
- **Actual behavior**
- **Flutter/Dart version**
- **Device/OS information**
- **Screenshots** (if applicable)
- **Code samples** demonstrating the issue

### Feature Requests

Include:
- **Clear description** of the feature
- **Use case**: Why is this needed?
- **Proposed implementation** (if you have ideas)
- **Alternative solutions** considered
- **Examples** from other libraries (if applicable)

### Questions

- Check existing issues and documentation first
- Use GitHub Discussions for general questions
- Stack Overflow for implementation questions
- GitHub Issues only for bugs and feature requests

## Development Tips

### Useful Commands

```bash
# Format all code
dart format .

# Analyze code
flutter analyze

# Run tests with coverage
flutter test --coverage

# Check package score
flutter pub publish --dry-run

# Generate documentation
dartdoc

# Run example app
cd example && flutter run
```

### IDE Setup

#### VS Code

Recommended extensions:
- Flutter
- Dart
- Error Lens
- GitLens

#### Android Studio / IntelliJ IDEA

- Install Flutter and Dart plugins
- Enable Dart Analysis
- Configure formatter to run on save

## Getting Help

- **Documentation**: Check README.md and API documentation
- **Examples**: Review example apps in `example/lib/`
- **Issues**: Search existing GitHub issues
- **Discussions**: Use GitHub Discussions for questions

## Recognition

Contributors will be recognized in:
- CHANGELOG.md
- README.md contributors section
- GitHub contributors page

Thank you for contributing to AI Chat UI Kit! 🎉
