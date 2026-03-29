import 'package:flutter/material.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.tune_outlined, size: 20, color: Colors.grey),
            SizedBox(width: 8),
            Text("Ajustes del post", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              //Selector de Privacidad (Botones de opción)
              _buildPrivacySelector(),
              
              const Divider(height: 32),

              //Switch: Comentarios
              _buildSwitchTile(
                title: "Desactivar comentarios",
                subtitle: "Limitar interacción en este post",
                value: _disableComments,
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

  Widget _buildPrivacySelector() {
    return Row(
      children: [
        _PrivacyOption(
          label: 'Público',
          icon: Icons.public,
          isActive: _activePrivacy == 'Público',
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
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      activeColor: Colors.cyan,
      contentPadding: EdgeInsets.zero,
    );
  }
}

// Widget privado para los botones de Privacidad
class _PrivacyOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _PrivacyOption({
    required this.label,
    required this.icon,
    required this.isActive,
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
            color: isActive ? Colors.cyan.withOpacity(0.1) : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive ? Colors.cyan : Colors.grey[200]!,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isActive ? Colors.cyan : Colors.grey),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(
                color: isActive ? Colors.cyan : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              )),
            ],
          ),
        ),
      ),
    );
  }
}