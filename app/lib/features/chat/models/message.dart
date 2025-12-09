import 'package:flutter/material.dart';

enum MessageRole {
  user,
  assistant,
  system,
}

enum MessageContentType {
  text,
  buttons,
  select,
  multiSelect,
  textInput,
  dateInput,
  loading,
}

/// Base class for message content
abstract class MessageContent {
  final MessageContentType type;
  
  const MessageContent(this.type);
  
  Map<String, dynamic> toJson();
  factory MessageContent.fromJson(Map<String, dynamic> json) {
    final type = MessageContentType.values.firstWhere(
      (e) => e.toString() == json['type'],
    );
    
    switch (type) {
      case MessageContentType.text:
        return TextContent.fromJson(json);
      case MessageContentType.buttons:
        return ButtonsContent.fromJson(json);
      case MessageContentType.select:
        return SelectContent.fromJson(json);
      case MessageContentType.multiSelect:
        return MultiSelectContent.fromJson(json);
      case MessageContentType.textInput:
        return TextInputContent.fromJson(json);
      case MessageContentType.dateInput:
        return DateInputContent.fromJson(json);
      case MessageContentType.loading:
        return LoadingContent.fromJson(json);
    }
  }
}

/// Text content
class TextContent extends MessageContent {
  final String text;
  
  const TextContent(this.text) : super(MessageContentType.text);
  
  @override
  Map<String, dynamic> toJson() => {
    'type': type.toString(),
    'text': text,
  };
  
  factory TextContent.fromJson(Map<String, dynamic> json) {
    return TextContent(json['text'] as String);
  }
}

/// Button options
class ButtonOption {
  final String id;
  final String label;
  final IconData? icon;
  final Color? color;
  
  const ButtonOption({
    required this.id,
    required this.label,
    this.icon,
    this.color,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'icon': icon?.codePoint,
    'color': color?.value,
  };
  
  factory ButtonOption.fromJson(Map<String, dynamic> json) {
    return ButtonOption(
      id: json['id'] as String,
      label: json['label'] as String,
      icon: json['icon'] != null ? IconData(json['icon'] as int, fontFamily: 'MaterialIcons') : null,
      color: json['color'] != null ? Color(json['color'] as int) : null,
    );
  }
}

/// Buttons content
class ButtonsContent extends MessageContent {
  final String? prompt;
  final List<ButtonOption> buttons;
  final String? selectedButtonId;
  
  const ButtonsContent({
    this.prompt,
    required this.buttons,
    this.selectedButtonId,
  }) : super(MessageContentType.buttons);
  
  ButtonsContent copyWith({String? selectedButtonId}) {
    return ButtonsContent(
      prompt: prompt,
      buttons: buttons,
      selectedButtonId: selectedButtonId,
    );
  }
  
  @override
  Map<String, dynamic> toJson() => {
    'type': type.toString(),
    'prompt': prompt,
    'buttons': buttons.map((b) => b.toJson()).toList(),
    'selectedButtonId': selectedButtonId,
  };
  
  factory ButtonsContent.fromJson(Map<String, dynamic> json) {
    return ButtonsContent(
      prompt: json['prompt'] as String?,
      buttons: (json['buttons'] as List).map((b) => ButtonOption.fromJson(b)).toList(),
      selectedButtonId: json['selectedButtonId'] as String?,
    );
  }
}

/// Select option
class SelectOption {
  final String id;
  final String label;
  final String? description;
  
  const SelectOption({
    required this.id,
    required this.label,
    this.description,
  });
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'description': description,
  };
  
  factory SelectOption.fromJson(Map<String, dynamic> json) {
    return SelectOption(
      id: json['id'] as String,
      label: json['label'] as String,
      description: json['description'] as String?,
    );
  }
}

/// Select content (single select)
class SelectContent extends MessageContent {
  final String? prompt;
  final List<SelectOption> options;
  final String? selectedOptionId;
  
  const SelectContent({
    this.prompt,
    required this.options,
    this.selectedOptionId,
  }) : super(MessageContentType.select);
  
  SelectContent copyWith({String? selectedOptionId}) {
    return SelectContent(
      prompt: prompt,
      options: options,
      selectedOptionId: selectedOptionId,
    );
  }
  
  @override
  Map<String, dynamic> toJson() => {
    'type': type.toString(),
    'prompt': prompt,
    'options': options.map((o) => o.toJson()).toList(),
    'selectedOptionId': selectedOptionId,
  };
  
  factory SelectContent.fromJson(Map<String, dynamic> json) {
    return SelectContent(
      prompt: json['prompt'] as String?,
      options: (json['options'] as List).map((o) => SelectOption.fromJson(o)).toList(),
      selectedOptionId: json['selectedOptionId'] as String?,
    );
  }
}

/// Multi-select content
class MultiSelectContent extends MessageContent {
  final String? prompt;
  final List<SelectOption> options;
  final Set<String> selectedOptionIds;
  
  const MultiSelectContent({
    this.prompt,
    required this.options,
    this.selectedOptionIds = const {},
  }) : super(MessageContentType.multiSelect);
  
  MultiSelectContent copyWith({Set<String>? selectedOptionIds}) {
    return MultiSelectContent(
      prompt: prompt,
      options: options,
      selectedOptionIds: selectedOptionIds ?? this.selectedOptionIds,
    );
  }
  
  @override
  Map<String, dynamic> toJson() => {
    'type': type.toString(),
    'prompt': prompt,
    'options': options.map((o) => o.toJson()).toList(),
    'selectedOptionIds': selectedOptionIds.toList(),
  };
  
  factory MultiSelectContent.fromJson(Map<String, dynamic> json) {
    return MultiSelectContent(
      prompt: json['prompt'] as String?,
      options: (json['options'] as List).map((o) => SelectOption.fromJson(o)).toList(),
      selectedOptionIds: Set<String>.from(json['selectedOptionIds'] as List),
    );
  }
}

/// Text input content
class TextInputContent extends MessageContent {
  final String? prompt;
  final String? placeholder;
  final String? value;
  final int? maxLines;
  
  const TextInputContent({
    this.prompt,
    this.placeholder,
    this.value,
    this.maxLines = 1,
  }) : super(MessageContentType.textInput);
  
  TextInputContent copyWith({String? value}) {
    return TextInputContent(
      prompt: prompt,
      placeholder: placeholder,
      value: value,
      maxLines: maxLines,
    );
  }
  
  @override
  Map<String, dynamic> toJson() => {
    'type': type.toString(),
    'prompt': prompt,
    'placeholder': placeholder,
    'value': value,
    'maxLines': maxLines,
  };
  
  factory TextInputContent.fromJson(Map<String, dynamic> json) {
    return TextInputContent(
      prompt: json['prompt'] as String?,
      placeholder: json['placeholder'] as String?,
      value: json['value'] as String?,
      maxLines: json['maxLines'] as int?,
    );
  }
}

/// Date input content
class DateInputContent extends MessageContent {
  final String? prompt;
  final DateTime? selectedDate;
  final DateTime? minDate;
  final DateTime? maxDate;
  
  const DateInputContent({
    this.prompt,
    this.selectedDate,
    this.minDate,
    this.maxDate,
  }) : super(MessageContentType.dateInput);
  
  DateInputContent copyWith({DateTime? selectedDate}) {
    return DateInputContent(
      prompt: prompt,
      selectedDate: selectedDate,
      minDate: minDate,
      maxDate: maxDate,
    );
  }
  
  @override
  Map<String, dynamic> toJson() => {
    'type': type.toString(),
    'prompt': prompt,
    'selectedDate': selectedDate?.toIso8601String(),
    'minDate': minDate?.toIso8601String(),
    'maxDate': maxDate?.toIso8601String(),
  };
  
  factory DateInputContent.fromJson(Map<String, dynamic> json) {
    return DateInputContent(
      prompt: json['prompt'] as String?,
      selectedDate: json['selectedDate'] != null ? DateTime.parse(json['selectedDate']) : null,
      minDate: json['minDate'] != null ? DateTime.parse(json['minDate']) : null,
      maxDate: json['maxDate'] != null ? DateTime.parse(json['maxDate']) : null,
    );
  }
}

/// Loading content
class LoadingContent extends MessageContent {
  final String? text;
  
  const LoadingContent({this.text}) : super(MessageContentType.loading);
  
  @override
  Map<String, dynamic> toJson() => {
    'type': type.toString(),
    'text': text,
  };
  
  factory LoadingContent.fromJson(Map<String, dynamic> json) {
    return LoadingContent(text: json['text'] as String?);
  }
}

/// Message model
class Message {
  final String id;
  final MessageRole role;
  final List<MessageContent> contents;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  
  const Message({
    required this.id,
    required this.role,
    required this.contents,
    required this.timestamp,
    this.metadata,
  });
  
  Message copyWith({
    String? id,
    MessageRole? role,
    List<MessageContent>? contents,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return Message(
      id: id ?? this.id,
      role: role ?? this.role,
      contents: contents ?? this.contents,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role.toString(),
    'contents': contents.map((c) => c.toJson()).toList(),
    'timestamp': timestamp.toIso8601String(),
    'metadata': metadata,
  };
  
  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] as String,
      role: MessageRole.values.firstWhere((e) => e.toString() == json['role']),
      contents: (json['contents'] as List).map((c) => MessageContent.fromJson(c)).toList(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }
  
  /// Helper constructors for common message types
  factory Message.text({
    required String id,
    required MessageRole role,
    required String text,
    DateTime? timestamp,
  }) {
    return Message(
      id: id,
      role: role,
      contents: [TextContent(text)],
      timestamp: timestamp ?? DateTime.now(),
    );
  }
  
  factory Message.loading({
    required String id,
    String? text,
    DateTime? timestamp,
  }) {
    return Message(
      id: id,
      role: MessageRole.assistant,
      contents: [LoadingContent(text: text)],
      timestamp: timestamp ?? DateTime.now(),
    );
  }
}
