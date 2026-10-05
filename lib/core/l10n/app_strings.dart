import 'package:flutter/material.dart';

class AppStrings {
  const AppStrings(this.locale);

  static const supportedLocales = [Locale('ru'), Locale('en')];
  final Locale locale;
  bool get _ru => locale.languageCode == 'ru';

  String get tagline => _ru
      ? 'Единый интерфейс. Связанные устройства.'
      : 'One interface. Connected devices.';
  String get early => _ru ? 'Ранняя разработка' : 'Early development';
  String get intro => _ru
      ? 'Экосистема и лаунчер для Windows и Android. '
            'Сегодня — основа интерфейса. Дальше — ваши устройства, модули и расширения.'
      : 'An ecosystem and launcher for Windows and Android. '
            'Today: an interface foundation. Next: your devices, modules and extensions.';
  String get libraryTitle => _ru ? 'Библиотека приложений' : 'App library';
  String get searchApps => _ru ? 'Найти приложение' : 'Search apps';
  String get addApp => _ru ? 'Добавить приложение' : 'Add app';
  String get add => _ru ? 'Добавить' : 'Add';
  String get added => _ru ? 'Добавлено' : 'Added';
  String get done => _ru ? 'Готово' : 'Done';
  String get launch => _ru ? 'Запустить' : 'Launch';
  String get removeApp => _ru ? 'Убрать из библиотеки' : 'Remove from library';
  String get libraryEmpty => _ru
      ? 'Добавьте приложения из списка, чтобы они появились здесь.'
      : 'Add apps from the list to see them here.';
  String get noAppsAvailable => _ru
      ? 'Подходящие приложения не найдены.'
      : 'No launchable apps were found.';
  String get noSearchResults =>
      _ru ? 'По запросу ничего не найдено.' : 'No apps match your search.';
  String get appUnavailable => _ru
      ? 'Приложение недоступно или уже удалено.'
      : 'The app is unavailable or has been removed.';
  String get appLaunchFailed =>
      _ru ? 'Не удалось запустить приложение.' : 'Could not launch the app.';
  String get libraryLoadFailed => _ru
      ? 'Не удалось загрузить библиотеку приложений.'
      : 'Could not load the app library.';
  String get librarySaveFailed => _ru
      ? 'Не удалось сохранить изменения библиотеки.'
      : 'Could not save changes to the library.';
  String get libraryUnavailable => _ru
      ? 'Библиотека приложений недоступна на этой платформе.'
      : 'The app library is unavailable on this platform.';
  String get retry => _ru ? 'Повторить' : 'Retry';
  String get modules => _ru ? 'Дальше по плану' : 'Up next';
  String get planned => _ru ? 'Запланировано' : 'Planned';
  String get launcher => _ru ? 'Лаунчер' : 'Launcher';
  String get launcherDetail => _ru
      ? 'Библиотека и запуск приложений'
      : 'Application library and launching';
  String get sync => _ru ? 'Устройства' : 'Devices';
  String get syncDetail => _ru
      ? 'Безопасная синхронизация между устройствами'
      : 'Secure synchronization across devices';
  String get plugins => _ru ? 'Плагины' : 'Plugins';
  String get pluginsDetail => _ru
      ? 'Расширения с контролем разрешений'
      : 'Extensions with permission controls';
  String get updates => _ru ? 'Обновления' : 'Updates';
  String get updatesDetail => _ru
      ? 'Проверка пакетов и восстановление'
      : 'Package verification and recovery';
  String get footer => _ru
      ? 'Прототип интерфейса · Функции модулей ещё не реализованы'
      : 'Interface prototype · Module functionality is not implemented yet';
  String get language => _ru ? 'Язык интерфейса' : 'Interface language';
}
