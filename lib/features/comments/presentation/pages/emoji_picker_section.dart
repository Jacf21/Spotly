part of 'comments_page.dart';

class _EmojiPickerSection extends StatelessWidget {
  final TextEditingController controller;

  const _EmojiPickerSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: EmojiPicker(
        onEmojiSelected: (_, emoji) {
          final text = controller.text;
          final selection = controller.selection;
          final newText = text.replaceRange(
            selection.start < 0 ? text.length : selection.start,
            selection.end < 0 ? text.length : selection.end,
            emoji.emoji,
          );
          controller.value = TextEditingValue(
            text: newText,
            selection: TextSelection.collapsed(
              offset: (selection.start < 0 ? text.length : selection.start) +
                  emoji.emoji.length,
            ),
          );
        },
        onBackspacePressed: () {
          final text = controller.text;
          if (text.isEmpty) return;
          controller.text = text.characters.skipLast(1).toString();
          controller.selection = TextSelection.collapsed(
            offset: controller.text.length,
          );
        },
        config: Config(
          height: 250,
          emojiViewConfig: EmojiViewConfig(
            backgroundColor: ThemeUtils.isDark(context)
                ? const Color(0xFF1C1C1E)
                : Colors.white,
          ),
          searchViewConfig: SearchViewConfig(
            backgroundColor: ThemeUtils.isDark(context)
                ? const Color(0xFF1C1C1E)
                : Colors.white,
          ),
          categoryViewConfig: CategoryViewConfig(
            backgroundColor: ThemeUtils.isDark(context)
                ? const Color(0xFF1C1C1E)
                : Colors.white,
            indicatorColor: SpotlyColors.accent(ThemeUtils.isDark(context)),
          ),
        ),
      ),
    );
  }
}
