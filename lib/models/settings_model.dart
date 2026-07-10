/// تنظیمات سراسری برنامه که از پنل مدیریت قابل تغییر است:
/// شماره کارت، اطلاعات تماس، لوگو و رنگ‌های اصلی/ثانویه برنامه.
/// این سند به‌صورت یک رکورد واحد (id ثابت) در collection «settings» ذخیره می‌شود.
class SettingsModel {
  final String cardNumber;
  final String cardHolderName;
  final String address;
  final String mapUrl;
  final String phone;
  final String whatsapp;
  final String telegram;
  final String instagram;
  final String website;
  final String logoUrl;
  final String primaryColorHex;
  final String secondaryColorHex;

  const SettingsModel({
    this.cardNumber = '6037-9975-XXXX-XXXX',
    this.cardHolderName = 'هیئت بابالحوائج زمان‌آباد',
    this.address = 'زمان‌آباد - هیئت بابالحوائج',
    this.mapUrl = 'https://maps.google.com/?q=زمان‌آباد',
    this.phone = '021-XXXXXXXX',
    this.whatsapp = '98XXXXXXXXXX',
    this.telegram = 'cheragh_heyat',
    this.instagram = 'cheragh_heyat',
    this.website = 'cheragh-heyat.ir',
    this.logoUrl = '',
    this.primaryColorHex = '',
    this.secondaryColorHex = '',
  });

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      cardNumber: map['cardNumber'] ?? '6037-9975-XXXX-XXXX',
      cardHolderName: map['cardHolderName'] ?? 'هیئت بابالحوائج زمان‌آباد',
      address: map['address'] ?? 'زمان‌آباد - هیئت بابالحوائج',
      mapUrl: map['mapUrl'] ?? 'https://maps.google.com/?q=زمان‌آباد',
      phone: map['phone'] ?? '021-XXXXXXXX',
      whatsapp: map['whatsapp'] ?? '98XXXXXXXXXX',
      telegram: map['telegram'] ?? 'cheragh_heyat',
      instagram: map['instagram'] ?? 'cheragh_heyat',
      website: map['website'] ?? 'cheragh-heyat.ir',
      logoUrl: map['logoUrl'] ?? '',
      primaryColorHex: map['primaryColorHex'] ?? '',
      secondaryColorHex: map['secondaryColorHex'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cardNumber': cardNumber,
      'cardHolderName': cardHolderName,
      'address': address,
      'mapUrl': mapUrl,
      'phone': phone,
      'whatsapp': whatsapp,
      'telegram': telegram,
      'instagram': instagram,
      'website': website,
      'logoUrl': logoUrl,
      'primaryColorHex': primaryColorHex,
      'secondaryColorHex': secondaryColorHex,
    };
  }

  SettingsModel copyWith({
    String? cardNumber,
    String? cardHolderName,
    String? address,
    String? mapUrl,
    String? phone,
    String? whatsapp,
    String? telegram,
    String? instagram,
    String? website,
    String? logoUrl,
    String? primaryColorHex,
    String? secondaryColorHex,
  }) {
    return SettingsModel(
      cardNumber: cardNumber ?? this.cardNumber,
      cardHolderName: cardHolderName ?? this.cardHolderName,
      address: address ?? this.address,
      mapUrl: mapUrl ?? this.mapUrl,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      telegram: telegram ?? this.telegram,
      instagram: instagram ?? this.instagram,
      website: website ?? this.website,
      logoUrl: logoUrl ?? this.logoUrl,
      primaryColorHex: primaryColorHex ?? this.primaryColorHex,
      secondaryColorHex: secondaryColorHex ?? this.secondaryColorHex,
    );
  }
}
