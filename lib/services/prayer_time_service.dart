import 'package:adhan/adhan.dart';

class PrayerTimesResult {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime sunset;
  final DateTime maghrib;
  final DateTime midnight;

  PrayerTimesResult({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.sunset,
    required this.maghrib,
    required this.midnight,
  });
}

/// سرویس محاسبه اوقات شرعی بر اساس موقعیت جغرافیایی
/// در صورت نبود دسترسی به GPS، از مختصات پیش‌فرض شهر استفاده می‌شود.
class PrayerTimeService {
  PrayerTimesResult calculate({
    required double latitude,
    required double longitude,
    DateTime? date,
  }) {
    final coordinates = Coordinates(latitude, longitude);
    final params = CalculationMethod.tehran.getParameters();
    params.madhab = Madhab.shafi;

    final d = date ?? DateTime.now();
    final dateComponents = DateComponents(d.year, d.month, d.day);
    final prayerTimes = PrayerTimes(coordinates, dateComponents, params);
    final sunnah = SunnahTimes(prayerTimes);

    return PrayerTimesResult(
      fajr: prayerTimes.fajr,
      sunrise: prayerTimes.sunrise,
      dhuhr: prayerTimes.dhuhr,
      sunset: prayerTimes.maghrib,
      maghrib: prayerTimes.maghrib,
      midnight: sunnah.lastThirdOfTheNight,
    );
  }
}
