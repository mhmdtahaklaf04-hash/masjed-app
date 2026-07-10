import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/color_utils.dart';
import '../../models/settings_model.dart';
import '../../providers/settings_provider.dart';
import '../../services/storage_service.dart';
import '../../widgets/loading_widget.dart';

class ManageSettingsPage extends StatefulWidget {
  const ManageSettingsPage({super.key});

  @override
  State<ManageSettingsPage> createState() => _ManageSettingsPageState();
}

class _ManageSettingsPageState extends State<ManageSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _cardNumberController;
  late TextEditingController _cardHolderController;
  late TextEditingController _addressController;
  late TextEditingController _mapUrlController;
  late TextEditingController _phoneController;
  late TextEditingController _whatsappController;
  late TextEditingController _telegramController;
  late TextEditingController _instagramController;
  late TextEditingController _websiteController;

  Color? _primaryColor;
  Color? _secondaryColor;
  File? _pickedLogo;
  String? _logoUrl;
  bool _isSaving = false;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _cardNumberController = TextEditingController();
    _cardHolderController = TextEditingController();
    _addressController = TextEditingController();
    _mapUrlController = TextEditingController();
    _phoneController = TextEditingController();
    _whatsappController = TextEditingController();
    _telegramController = TextEditingController();
    _instagramController = TextEditingController();
    _websiteController = TextEditingController();
    Future.microtask(() => context.read<SettingsProvider>().fetch());
  }

  void _fillFromSettings(SettingsModel s) {
    if (_initialized) return;
    _initialized = true;
    _cardNumberController.text = s.cardNumber;
    _cardHolderController.text = s.cardHolderName;
    _addressController.text = s.address;
    _mapUrlController.text = s.mapUrl;
    _phoneController.text = s.phone;
    _whatsappController.text = s.whatsapp;
    _telegramController.text = s.telegram;
    _instagramController.text = s.instagram;
    _websiteController.text = s.website;
    _primaryColor = ColorUtils.fromHex(s.primaryColorHex);
    _secondaryColor = ColorUtils.fromHex(s.secondaryColorHex);
    _logoUrl = s.logoUrl;
  }

  Future<void> _pickLogo() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _pickedLogo = File(picked.path));
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    String logoUrl = _logoUrl ?? '';
    if (_pickedLogo != null) {
      logoUrl = await StorageService().uploadFile(_pickedLogo!, AppConstants.storageLogo);
    }
    final newSettings = SettingsModel(
      cardNumber: _cardNumberController.text,
      cardHolderName: _cardHolderController.text,
      address: _addressController.text,
      mapUrl: _mapUrlController.text,
      phone: _phoneController.text,
      whatsapp: _whatsappController.text,
      telegram: _telegramController.text,
      instagram: _instagramController.text,
      website: _websiteController.text,
      logoUrl: logoUrl,
      primaryColorHex: _primaryColor != null ? ColorUtils.toHex(_primaryColor!) : '',
      secondaryColorHex: _secondaryColor != null ? ColorUtils.toHex(_secondaryColor!) : '',
    );
    final ok = await context.read<SettingsProvider>().save(newSettings);
    setState(() => _isSaving = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(ok ? 'تنظیمات ذخیره شد' : 'ذخیره‌سازی ناموفق بود')),
    );
  }

  Widget _colorPicker(String label, Color? selected, Color fallback, ValueChanged<Color> onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: ColorUtils.presetColors.map((c) {
            final isSelected = (selected ?? fallback).value == c.value;
            return GestureDetector(
              onTap: () => onSelect(c),
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: c,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('مدیریت تنظیمات')),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && !_initialized) return const LoadingWidget();
          _fillFromSettings(provider.settings);
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text('لوگوی برنامه', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: _pickedLogo != null
                            ? FileImage(_pickedLogo!) as ImageProvider
                            : (_logoUrl != null && _logoUrl!.isNotEmpty)
                                ? CachedNetworkImageProvider(_logoUrl!) as ImageProvider
                                : null,
                        child: (_pickedLogo == null && (_logoUrl == null || _logoUrl!.isEmpty))
                            ? const Icon(Icons.local_fire_department_rounded, size: 40)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 16,
                          child: IconButton(
                            icon: const Icon(Icons.edit, size: 16),
                            onPressed: _pickLogo,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _colorPicker('رنگ اصلی برنامه', _primaryColor, ColorUtils.presetColors[0],
                    (c) => setState(() => _primaryColor = c)),
                const SizedBox(height: 20),
                _colorPicker('رنگ ثانویه برنامه', _secondaryColor, ColorUtils.presetColors[6],
                    (c) => setState(() => _secondaryColor = c)),
                const SizedBox(height: 24),
                Text('پرداخت', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                TextFormField(controller: _cardNumberController, decoration: const InputDecoration(labelText: 'شماره کارت')),
                const SizedBox(height: 12),
                TextFormField(controller: _cardHolderController, decoration: const InputDecoration(labelText: 'نام صاحب حساب')),
                const SizedBox(height: 24),
                Text('اطلاعات تماس', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: 'آدرس')),
                const SizedBox(height: 12),
                TextFormField(controller: _mapUrlController, decoration: const InputDecoration(labelText: 'لینک نقشه (Google Maps)')),
                const SizedBox(height: 12),
                TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'تلفن تماس')),
                const SizedBox(height: 12),
                TextFormField(controller: _whatsappController, decoration: const InputDecoration(labelText: 'شماره واتساپ (بدون + یا صفر)')),
                const SizedBox(height: 12),
                TextFormField(controller: _telegramController, decoration: const InputDecoration(labelText: 'آیدی تلگرام (بدون @)')),
                const SizedBox(height: 12),
                TextFormField(controller: _instagramController, decoration: const InputDecoration(labelText: 'آیدی اینستاگرام (بدون @)')),
                const SizedBox(height: 12),
                TextFormField(controller: _websiteController, decoration: const InputDecoration(labelText: 'وب‌سایت (بدون https://)')),
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('ذخیره تنظیمات'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
