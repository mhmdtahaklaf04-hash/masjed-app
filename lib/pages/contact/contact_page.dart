import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/settings_provider.dart';
import '../../models/settings_model.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<SettingsProvider>().fetch());
  }

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Widget _tile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تماس با ما')),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, _) {
          final SettingsModel s = settingsProvider.settings;
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _tile(Icons.location_on_outlined, 'آدرس', s.address, () => _launch(s.mapUrl)),
              _tile(Icons.phone_outlined, 'تلفن تماس', s.phone,
                  () => _launch('tel:${s.phone.replaceAll('-', '')}')),
              _tile(Icons.chat_outlined, 'واتساپ', 'ارسال پیام در واتساپ',
                  () => _launch('https://wa.me/${s.whatsapp}')),
              _tile(Icons.send_outlined, 'تلگرام', '@${s.telegram}',
                  () => _launch('https://t.me/${s.telegram}')),
              _tile(Icons.camera_alt_outlined, 'اینستاگرام', '@${s.instagram}',
                  () => _launch('https://instagram.com/${s.instagram}')),
              _tile(Icons.language_outlined, 'وب‌سایت', s.website,
                  () => _launch('https://${s.website}')),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _launch(s.mapUrl),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 180,
                    color: Colors.grey.shade300,
                    alignment: Alignment.center,
                    child: const Text(
                      'مشاهده موقعیت هیئت روی نقشه\n(ضربه بزنید)',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
