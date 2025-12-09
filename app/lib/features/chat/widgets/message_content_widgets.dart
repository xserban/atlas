import 'package:flutter/material.dart';
import '../models/message.dart';

/// Text message content widget
class TextMessageContent extends StatelessWidget {
  final TextContent content;
  final Color textColor;
  
  const TextMessageContent({
    Key? key,
    required this.content,
    required this.textColor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return SelectableText(
      content.text,
      style: TextStyle(color: textColor, fontSize: 15),
    );
  }
}

/// Buttons message content widget
class ButtonsMessageContent extends StatelessWidget {
  final ButtonsContent content;
  final Function(String) onButtonPressed;
  
  const ButtonsMessageContent({
    Key? key,
    required this.content,
    required this.onButtonPressed,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (content.prompt != null) ...[
          Text(
            content.prompt!,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: content.buttons.map((button) {
            final isSelected = content.selectedButtonId == button.id;
            
            return ElevatedButton.icon(
              onPressed: content.selectedButtonId == null 
                ? () => onButtonPressed(button.id)
                : null,
              icon: button.icon != null 
                ? Icon(button.icon, size: 18) 
                : const SizedBox.shrink(),
              label: Text(button.label),
              style: ElevatedButton.styleFrom(
                backgroundColor: isSelected 
                  ? (button.color ?? theme.colorScheme.primary)
                  : theme.colorScheme.surface,
                foregroundColor: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
                elevation: isSelected ? 4 : 1,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// Select message content widget
class SelectMessageContent extends StatelessWidget {
  final SelectContent content;
  final Function(String) onOptionSelected;
  
  const SelectMessageContent({
    Key? key,
    required this.content,
    required this.onOptionSelected,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (content.prompt != null) ...[
          Text(
            content.prompt!,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: content.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isSelected = content.selectedOptionId == option.id;
              final isLast = index == content.options.length - 1;
              
              return Column(
                children: [
                  ListTile(
                    title: Text(option.label),
                    subtitle: option.description != null 
                      ? Text(option.description!) 
                      : null,
                    leading: Radio<String>(
                      value: option.id,
                      groupValue: content.selectedOptionId,
                      onChanged: content.selectedOptionId == null 
                        ? (value) {
                            if (value != null) onOptionSelected(value);
                          }
                        : null,
                    ),
                    selected: isSelected,
                    enabled: content.selectedOptionId == null,
                  ),
                  if (!isLast) Divider(height: 1, color: theme.colorScheme.outline),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Multi-select message content widget
class MultiSelectMessageContent extends StatefulWidget {
  final MultiSelectContent content;
  final Function(Set<String>) onOptionsChanged;
  
  const MultiSelectMessageContent({
    Key? key,
    required this.content,
    required this.onOptionsChanged,
  }) : super(key: key);
  
  @override
  State<MultiSelectMessageContent> createState() => _MultiSelectMessageContentState();
}

class _MultiSelectMessageContentState extends State<MultiSelectMessageContent> {
  late Set<String> selectedIds;
  
  @override
  void initState() {
    super.initState();
    selectedIds = Set.from(widget.content.selectedOptionIds);
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.content.prompt != null) ...[
          Text(
            widget.content.prompt!,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
        ],
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: widget.content.options.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              final isSelected = selectedIds.contains(option.id);
              final isLast = index == widget.content.options.length - 1;
              
              return Column(
                children: [
                  CheckboxListTile(
                    title: Text(option.label),
                    subtitle: option.description != null 
                      ? Text(option.description!) 
                      : null,
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        if (value == true) {
                          selectedIds.add(option.id);
                        } else {
                          selectedIds.remove(option.id);
                        }
                      });
                      widget.onOptionsChanged(selectedIds);
                    },
                  ),
                  if (!isLast) Divider(height: 1, color: theme.colorScheme.outline),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

/// Text input message content widget
class TextInputMessageContent extends StatefulWidget {
  final TextInputContent content;
  final Function(String) onTextSubmitted;
  
  const TextInputMessageContent({
    Key? key,
    required this.content,
    required this.onTextSubmitted,
  }) : super(key: key);
  
  @override
  State<TextInputMessageContent> createState() => _TextInputMessageContentState();
}

class _TextInputMessageContentState extends State<TextInputMessageContent> {
  late TextEditingController controller;
  
  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.content.value);
  }
  
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.content.prompt != null) ...[
          Text(
            widget.content.prompt!,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: widget.content.placeholder,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  widget.onTextSubmitted(controller.text);
                }
              },
            ),
          ),
          maxLines: widget.content.maxLines,
          onSubmitted: widget.onTextSubmitted,
        ),
      ],
    );
  }
}

/// Date input message content widget
class DateInputMessageContent extends StatelessWidget {
  final DateInputContent content;
  final Function(DateTime) onDateSelected;
  
  const DateInputMessageContent({
    Key? key,
    required this.content,
    required this.onDateSelected,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (content.prompt != null) ...[
          Text(
            content.prompt!,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
        ],
        OutlinedButton.icon(
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: content.selectedDate ?? DateTime.now(),
              firstDate: content.minDate ?? DateTime(2000),
              lastDate: content.maxDate ?? DateTime(2100),
            );
            
            if (date != null) {
              onDateSelected(date);
            }
          },
          icon: const Icon(Icons.calendar_today),
          label: Text(
            content.selectedDate != null
              ? '${content.selectedDate!.day}/${content.selectedDate!.month}/${content.selectedDate!.year}'
              : 'Select a date',
          ),
        ),
      ],
    );
  }
}

/// Loading message content widget
class LoadingMessageContent extends StatelessWidget {
  final LoadingContent content;
  
  const LoadingMessageContent({
    Key? key,
    required this.content,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        if (content.text != null) ...[
          const SizedBox(width: 12),
          Text(content.text!),
        ],
      ],
    );
  }
}
