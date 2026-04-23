import 'package:flutter/material.dart';
import 'package:spotly/core/themes/spotly_colors.dart';
import '../../../../core/utils/theme_utils.dart';

// Este es solo para la sección de ajustes en la pantalla de publicación
class PostSettingsPanel extends StatefulWidget {
  final Function(String) onPrivacyChanged;
  final Function(bool) onCommentsDisabledChanged;

  const PostSettingsPanel({
    super.key,
    required this.onPrivacyChanged,
    required this.onCommentsDisabledChanged,
  });

  @override
  State<PostSettingsPanel> createState() => _PostSettingsPanelState();
}

class _PostSettingsPanelState extends State<PostSettingsPanel> {
  String _activePrivacy = 'Público';
  bool _disableComments = false;

  @override
  Widget build(BuildContext context) {
    final dark = ThemeUtils.isDark(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.tune_outlined, size: 20, color: dark ? Colors.white70 : Colors.grey),
            const SizedBox(width: 8),
            Text(
              "Ajustes del post", 
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: dark ? Colors.white : Colors.black
              )
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: dark ? Colors.white.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: dark ? Colors.white10 : Colors.grey[200]!),
          ),
          child: Column(
            children: [
              //Selector de Privacidad
              _buildPrivacySelector(dark),
              
              Divider(height: 32, color: dark ? Colors.white10 : Colors.grey[200]),

              //Switch: Comentarios
              _buildSwitchTile(
                title: "Desactivar comentarios",
                subtitle: "Limitar interacción en este post",
                value: _disableComments,
                dark: dark,
                onChanged: (val) {
                  setState(() => _disableComments = val);
                  widget.onCommentsDisabledChanged(val);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacySelector(bool dark) {
    return Row(
      children: [
        _PrivacyOption(
          label: 'Público',
          icon: Icons.public,
          isActive: _activePrivacy == 'Público',
          dark: dark,
          onTap: () {
            setState(() => _activePrivacy = 'Público');
            widget.onPrivacyChanged('Público');
          },
        ),
        const SizedBox(width: 12),
        _PrivacyOption(
          label: 'Amigos',
          icon: Icons.group_outlined,
          isActive: _activePrivacy == 'Amigos',
          dark: dark,
          onTap: () {
            setState(() => _activePrivacy = 'Amigos');
            widget.onPrivacyChanged('Amigos');
          },
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required bool dark,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(
        title, 
        style: TextStyle(
          fontSize: 14, 
          fontWeight: FontWeight.w600,
          color: dark ? Colors.white : Colors.black
        )
      ),
      subtitle: Text(
        subtitle, 
        style: TextStyle(
          fontSize: 12, 
          color: dark ? Colors.white38 : Colors.grey
        )
      ),
      activeColor: SpotlyColors.accent(dark),
      contentPadding: EdgeInsets.zero,
    );
  }
}

class _PrivacyOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final bool dark;
  final VoidCallback onTap;

  const _PrivacyOption({
    required this.label,
    required this.icon,
    required this.isActive,
    required this.dark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive 
                ? SpotlyColors.accent(dark).withOpacity(0.1)
                : (dark ? Colors.white.withOpacity(0.05) : Colors.grey[50]),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? SpotlyColors.accent(dark) : (dark ? Colors.white10 : Colors.grey[200]!),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon, 
                color: isActive ? SpotlyColors.accent(dark) : (dark ? Colors.white38 : Colors.grey)
              ),
              const SizedBox(height: 4),
              Text(
                label, 
                style: TextStyle(
                  color: isActive ? SpotlyColors.accent(dark) : (dark ? Colors.white38 : Colors.grey),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}