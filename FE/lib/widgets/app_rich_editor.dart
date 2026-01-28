import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class AppRichEditor extends StatelessWidget {
  final String label;
  final QuillController controller;
  final double? height;

  const AppRichEditor({
    super.key,
    required this.label,
    required this.controller,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
        ],
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              // Toolbar
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: QuillSimpleToolbar(
                  controller: controller,
                  config: const QuillSimpleToolbarConfig(
                    showFontFamily: false,
                    showFontSize: false,
                    showSearchButton: false,
                    showSubscript: false,
                    showSuperscript: false,
                    showStrikeThrough: false,
                    showInlineCode: false,
                    showColorButton: false,
                    showBackgroundColorButton: false,
                    showListCheck: false,
                    showCodeBlock: false,
                    showQuote: false,
                    showIndent: false,
                    showLink: false,
                    showUndo: false,
                    showRedo: false,
                    showDirection: false,
                    multiRowsDisplay: false,
                    toolbarSectionSpacing: 0,
                  ),
                ),
              ),
              // Editor
              SizedBox(
                height: height ?? 150,
                child: QuillEditor.basic(
                  controller: controller,
                  config: const QuillEditorConfig(
                    autoFocus: false,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
