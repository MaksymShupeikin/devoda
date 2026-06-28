import 'package:flutter/widgets.dart';

/// Hand-written localization (UK + EN), no code generation — fits the project's
/// "no codegen" rule. Each getter returns the string for the current locale.
///
/// Feature enums (categories, report conditions) localize their own labels via
/// [isUk] so this core class doesn't depend on features.
class AppLocalizations {
  const AppLocalizations(this.locale);

  final Locale locale;

  static const List<Locale> supportedLocales = [Locale('uk'), Locale('en')];
  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  bool get isUk => locale.languageCode == 'uk';

  String _(String uk, String en) => isUk ? uk : en;

  // ---- General ----
  String get close => _('Закрити', 'Close');
  String get cancel => _('Скасувати', 'Cancel');
  String get tryAgain => _('Спробуйте ще раз', 'Try again');

  // ---- Map controls ----
  String get whereAmI => _('Де я', 'Where am I');
  String get refresh => _('Оновити', 'Refresh');
  String get downloadOfflineMap =>
      _('Завантажити офлайн-карту', 'Download offline map');
  String get account => _('Акаунт', 'Account');
  String get add => _('Додати', 'Add');

  // ---- Map actions ----
  String get enableLocation => _(
    'Увімкніть геолокацію, щоб знайти себе на карті',
    'Turn on location to find yourself on the map',
  );
  String get pointAdded => _('Точку додано. Дякуємо!', 'Point added. Thank you!');
  String addCooldown(int minutes, String left) => _(
    'Можна додавати точку раз на $minutes хв. Зачекайте ще $left.',
    'You can add a point once every $minutes min. Please wait $left.',
  );
  String minutesShort(int n) => _('$n хв', '$n min');
  String secondsShort(int n) => _('$n с', '$n s');

  // ---- Placement ----
  String get placementHint => _(
    'Пересуньте карту так, щоб мітка вказувала на потрібне місце',
    'Move the map so the pin points to the right place',
  );
  String get placementConfirm =>
      _('Мітка вказує на нове місце?', 'Does the pin point to the new place?');
  String get placeHere => _('Поставити тут', 'Place here');

  // ---- Add point ----
  String get newWaterPoint => _('Нова точка з водою', 'New water point');
  String get whichType => _('Який це тип?', 'Which type is it?');
  String get nameOptional => _('Назва (необовʼязково)', 'Name (optional)');
  String get nameHint =>
      _('Наприклад: Колонка на подвірʼї', 'For example: Pump in the yard');
  String get savePoint => _('Зберегти точку', 'Save point');

  // ---- Point details ----
  String get accessibility => _('Доступність', 'Accessibility');
  String get hasRamp => _('Є пандус/доступ', 'Ramp/access available');
  String get payment => _('Оплата', 'Payment');
  String get paid => _('Платно', 'Paid');
  String get free => _('Безкоштовно', 'Free');
  String get accessLabel => _('Доступ', 'Access');
  String get accessFree => _('Вільний', 'Open');
  String get accessPrivate => _('Приватний', 'Private');
  String get accessCustomers => _('Для клієнтів', 'For customers');
  String get openingHours => _('Години роботи', 'Opening hours');
  String get noData => _('Немає даних', 'No data');
  String get no => _('Ні', 'No');
  String get buildRoute => _('Прокласти маршрут', 'Get directions');
  String get cantOpenMaps =>
      _('Не вдалося відкрити додаток карт', 'Couldn’t open a maps app');

  // ---- Resilience services ----
  String get availableServices => _('Доступні послуги', 'Available services');
  String get svcHeat => _('Тепло', 'Heat');
  String get svcGenerator => _('Генератор', 'Generator');
  String get svcCharging => _('Зарядка', 'Charging');
  String get svcWater => _('Вода', 'Water');
  String get svcInternet => _('Інтернет', 'Internet');
  String get svcConnection => _('Зв’язок', 'Connection');
  String get svcFirstAid => _('Аптечка', 'First aid');

  // ---- Reports ----
  String get whatState => _('Який зараз стан?', 'What’s the current state?');
  String get chooseStateHint => _(
    'Оберіть стан і повідомте іншим людям.',
    'Pick a state and let others know.',
  );
  String get detailsOptional => _('Деталі (необовʼязково)', 'Details (optional)');
  String get reportState => _('Повідомити про стан', 'Report the state');
  String get reportThanks =>
      _('Дякуємо! Ваше повідомлення додано.', 'Thank you! Your report was added.');
  String get reportFailed => _('Не вдалося надіслати', 'Couldn’t send');
  String reportsHistory(int count) =>
      _('Історія повідомлень ($count)', 'Reports history ($count)');
  String get loadHistoryFailed =>
      _('Не вдалося завантажити історію.', 'Couldn’t load the history.');
  String get noReportsYet =>
      _('Ще немає повідомлень. Будьте першим!', 'No reports yet. Be the first!');
  String get someUser => _('Користувач', 'User');
  String get you => _('Ви', 'You');
  String get reportNoWater =>
      _('Повідомити про відсутність води', 'Report no water source');

  // ---- Offline ----
  String get offlineTitle => _('Мапа без інтернету', 'Offline map');
  String get offlineDesc => _(
    'Завантажте карту навколо цього місця, щоб користуватися додатком '
        'без інтернету. Мітки вже зберігаються автоматично.',
    'Download the map around this place to use the app offline. '
        'Markers are already saved automatically.',
  );
  String radiusValue(int km) => _('Радіус: $km км', 'Radius: $km km');
  String downloadingPct(int pct) =>
      _('Завантаження… $pct%', 'Downloading… $pct%');
  String get offlineDone => _(
    'Готово! Карта збережена для офлайн-доступу.',
    'Done! The map is saved for offline use.',
  );
  String get downloadMap => _('Завантажити карту', 'Download map');
  String get downloadFailed => _(
    'Не вдалося завантажити. Перевірте інтернет та спробуйте знову.',
    'Download failed. Check your internet and try again.',
  );

  // ---- Onboarding ----
  String get onbSkip => _('Пропустити', 'Skip');
  String get onbNext => _('Далі', 'Next');
  String get onbStart => _('Зрозуміло, почати', 'Got it, start');
  String get onb1Title => _('Вода поруч із вами', 'Water near you');
  String get onb1Desc => _(
    'На карті одразу видно бювети, водокачки та автомати з водою поблизу.',
    'The map instantly shows fountains, pumps and water machines nearby.',
  );
  String get onb2Title => _('Маршрут в один крок', 'Directions in one step');
  String get onb2Desc => _(
    'Натисніть на мітку, перегляньте деталі та прокладіть маршрут через '
        'звичний додаток карт.',
    'Tap a pin, view the details and get directions in your usual maps app.',
  );
  String get onb3Title =>
      _('Додавайте та беріть із собою', 'Add and take with you');
  String get onb3Desc => _(
    'Позначте нове джерело води та завантажте карту, щоб вона працювала '
        'без інтернету.',
    'Mark a new water source and download the map so it works offline.',
  );

  // ---- Login ----
  String get registerTitle =>
      _('Зареєструйтесь, щоб\nдодавати точки', 'Register to\nadd points');
  String get phoneSubtitle => _(
    'Введіть номер телефону — ми надішлемо код у SMS. Реєстрація потрібна, '
        'щоб додавати нові точки на карту.',
    'Enter your phone number — we’ll send a code by SMS. Registration is '
        'required to add new points to the map.',
  );
  String get phoneLabel => _('Номер телефону', 'Phone number');
  String get getCode => _('Отримати код', 'Get the code');
  String get codeTitle => _('Введіть код з SMS', 'Enter the SMS code');
  String get codeSentTo => _('Ми надіслали код на номер\n', 'We sent a code to\n');
  String get codeLabel => _('Код підтвердження', 'Confirmation code');
  String get confirm => _('Підтвердити', 'Confirm');
  String get changeNumber => _('Змінити номер', 'Change number');
  String get resend => _('Надіслати ще раз', 'Resend');
  String get welcome => _('Вітаємо!', 'Welcome!');
  String get signedInMessage =>
      _('Ви успішно увійшли', 'You’ve signed in successfully');
  String get invalidCode =>
      _('Невірний або застарілий код. Спробуйте ще раз.',
          'Invalid or expired code. Try again.');
  String get loginFailed => _(
    'Не вдалося. Перевірте номер та інтернет і спробуйте знову.',
    'Failed. Check your number and internet and try again.',
  );

  // ---- Account ----
  String get signedInAs => _('Ви увійшли як', 'Signed in as');
  String get unknownNumber => _('Невідомий номер', 'Unknown number');
  String get signOut => _('Вийти з акаунту', 'Sign out');
  String get signedOutMessage => _('Ви вийшли з акаунту', 'You’ve signed out');
  String get language => _('Мова', 'Language');
}

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales
          .any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
