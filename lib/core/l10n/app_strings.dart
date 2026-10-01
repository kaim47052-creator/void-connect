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
  String get modules => _ru ? 'Направления проекта' : 'Project directions';
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
