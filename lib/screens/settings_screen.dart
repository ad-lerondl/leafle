import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_state.dart';
import '../theme/colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  String _formatHour(int hour) => '${hour.toString().padLeft(2, '0')}:00';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: kForestPrimary,
        foregroundColor: Colors.white,
      ),
      body: Consumer<AppState>(
        builder: (context, appState, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Rappels',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kForestPrimary),
              ),
              const SizedBox(height: 8),
              Card(
                child: SwitchListTile.adaptive(
                  secondary: const Icon(Icons.notifications_none),
                  title: const Text('Notification quotidienne'),
                  subtitle: const Text('Recevoir un rappel au début de votre journée Leafle'),
                  value: appState.notificationsEnabled,
                  onChanged: (enabled) => appState.setNotificationsEnabled(enabled),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Journée Leafle',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kForestPrimary),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('Début de la journée'),
                  subtitle: Text('Les routines se réinitialisent chaque jour à ${_formatHour(appState.dayStartHour)}'),
                  trailing: DropdownButton<int>(
                    value: appState.dayStartHour,
                    underline: const SizedBox.shrink(),
                    items: List.generate(
                      24,
                      (hour) => DropdownMenuItem<int>(
                        value: hour,
                        child: Text(_formatHour(hour)),
                      ),
                    ),
                    onChanged: (hour) {
                      if (hour != null) appState.setDayStartHour(hour);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Cette heure s’applique aux routines, aux dépendances et à la note de journée. Elle utilise l’heure locale de votre appareil.',
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
              const SizedBox(height: 28),
              const Text(
                'Informations',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kForestPrimary),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Déclaration de confidentialité'),
                  trailing: const Icon(Icons.open_in_new, size: 20),
                  onTap: () async {
                    final uri = Uri.parse('https://alapps-leafle.netlify.app/privacy/');
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
