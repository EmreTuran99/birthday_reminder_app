
enum TextFonts {
  meowScript("MeowScript"),
  nunitoSans("NunitoSans");

  const TextFonts(this.fontName);
  final String fontName;
}

enum LoadingStatus {
  loading,
  failed,
  succeeded
}

enum ZodiacSign {

  aries("Aries", "Koç"),
  taurus("Taurus", "Boğa"),
  gemini("Gemini", "İkizler"),
  cancer("Cancer", "Yengeç"),
  leo("Leo", "Aslan"),
  virgo("Virgo", "Başak"),
  libra("Libra", "Terazi"),
  scorpio("Scorpio", "Akrep"),
  sagittarius("Sagittarius", "Yay"),
  capricorn("Capricorn", "Oğlak"),
  aquarius("Aquarius", "Kova"),
  pisces("Pisces", "Balık");

  const ZodiacSign(this.engName, this.turName);
  final String engName;
  final String turName;
} extension ZodiacSignExtension on ZodiacSign {

  static ZodiacSign getZodiacSignFromDate(DateTime dateTime){
    
    if (dateTime.month == 1) {
      if (dateTime.day >= 21) {
        return ZodiacSign.aquarius;
      }
      else {
        return ZodiacSign.capricorn;
      }
    }
    else if (dateTime.month == 2) {
      if (dateTime.day >= 20) {
        return ZodiacSign.pisces;
      }
      else {
        return ZodiacSign.aquarius;
      }
    }
    else if (dateTime.month == 3) {
      if (dateTime.day >= 21) {
        return ZodiacSign.aries;
      }
      else {
        return ZodiacSign.pisces;
      }
    }
    else if (dateTime.month == 4) {
      if (dateTime.day >= 21) {
        return ZodiacSign.taurus;
      }
      else {
        return ZodiacSign.aries;
      }
    }
    else if (dateTime.month == 5) {
      if (dateTime.day >= 22) {
        return ZodiacSign.gemini;
      }
      else {
        return ZodiacSign.taurus;
      }
    }
    else if (dateTime.month == 6) {
      if (dateTime.day >= 22) {
        return ZodiacSign.cancer;
      }
      else {
        return ZodiacSign.gemini;
      }
    }
    else if (dateTime.month == 7) {
      if (dateTime.day >= 23) {
        return ZodiacSign.leo;
      }
      else {
        return ZodiacSign.cancer;
      }
    }
    else if (dateTime.month == 8) {
      if (dateTime.day >= 23) {
        return ZodiacSign.virgo;
      }
      else {
        return ZodiacSign.leo;
      }
    }
    else if (dateTime.month == 9) {
      if (dateTime.day >= 24) {
        return ZodiacSign.libra;
      }
      else {
        return ZodiacSign.virgo;
      }
    }
    else if (dateTime.month == 10) {
      if (dateTime.day >= 24) {
        return ZodiacSign.scorpio;
      }
      else {
        return ZodiacSign.libra;
      }
    }
    else if (dateTime.month == 11) {
      if (dateTime.day >= 23) {
        return ZodiacSign.sagittarius;
      }
      else {
        return ZodiacSign.scorpio;
      }
    }
    else{
      if (dateTime.day >= 22) {
        return ZodiacSign.capricorn;
      }
      else {
        return ZodiacSign.sagittarius;
      }
    }
  }

  static ZodiacSign getZodiacSignFromEngName(String engName){

    for (var zodiacSign in ZodiacSign.values) {
      if(zodiacSign.engName == engName){
        return zodiacSign;
      }
    }

    return ZodiacSign.capricorn;
  }
}
