// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get tagline => 'Единый интерфейс. Связанные устройства.';

  @override
  String get early => 'Ранняя разработка';

  @override
  String get intro =>
      'Экосистема и лаунчер для Windows и Android. Сегодня — основа интерфейса. Дальше — ваши устройства, модули и расширения.';

  @override
  String get libraryTitle => 'Библиотека приложений';

  @override
  String get searchApps => 'Найти приложение';

  @override
  String get addApp => 'Добавить приложение';

  @override
  String get add => 'Добавить';

  @override
  String get added => 'Добавлено';

  @override
  String get done => 'Готово';

  @override
  String get launch => 'Запустить';

  @override
  String get removeApp => 'Убрать из библиотеки';

  @override
  String get libraryEmpty =>
      'Добавьте приложения из списка, чтобы они появились здесь.';

  @override
  String get noAppsAvailable => 'Подходящие приложения не найдены.';

  @override
  String get noSearchResults => 'По запросу ничего не найдено.';

  @override
  String get appUnavailable => 'Приложение недоступно или уже удалено.';

  @override
  String get appLaunchFailed => 'Не удалось запустить приложение.';

  @override
  String get libraryLoadFailed => 'Не удалось загрузить библиотеку приложений.';

  @override
  String get librarySaveFailed => 'Не удалось сохранить изменения библиотеки.';

  @override
  String get libraryUnavailable =>
      'Библиотека приложений недоступна на этой платформе.';

  @override
  String get retry => 'Повторить';

  @override
  String get modules => 'Дальше по плану';

  @override
  String get planned => 'Запланировано';

  @override
  String get launcher => 'Лаунчер';

  @override
  String get launcherDetail => 'Библиотека и запуск приложений';

  @override
  String get sync => 'Устройства';

  @override
  String get syncDetail => 'Безопасная синхронизация между устройствами';

  @override
  String get plugins => 'Плагины';

  @override
  String get pluginsDetail => 'Расширения с контролем разрешений';

  @override
  String get updates => 'Обновления';

  @override
  String get updatesDetail => 'Проверка пакетов и восстановление';

  @override
  String get footer =>
      'Прототип интерфейса · Функции модулей ещё не реализованы';

  @override
  String get language => 'Язык интерфейса';

  @override
  String get languageSaveFailed =>
      'Не удалось сохранить язык. После перезапуска будет выбран язык устройства.';
}
