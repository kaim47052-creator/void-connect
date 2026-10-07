<div align="center">

![Void Connect](docs/assets/banner.png)

**Единый интерфейс. Связанные устройства. Пространство для расширений.**

![Stage](https://img.shields.io/badge/status-early_development-8B5CF6?style=flat-square)
![Flutter](https://img.shields.io/badge/Flutter-Windows_%2B_Android-38BDF8?style=flat-square)
![Languages](https://img.shields.io/badge/interface-RU_%2F_EN-A78BFA?style=flat-square)
[![CI](https://github.com/kaim47052-creator/void-connect/actions/workflows/flutter-ci.yml/badge.svg)](https://github.com/kaim47052-creator/void-connect/actions/workflows/flutter-ci.yml)

[План разработки](docs/ROADMAP.md) · [Архитектура v0.1](docs/ARCHITECTURE.md) · [Задачи](https://github.com/kaim47052-creator/void-connect/issues) · [Участие](CONTRIBUTING.md)

</div>

## О проекте

**Void Connect** — многофункциональная кроссплатформенная экосистема и лаунчер для **Windows и Android**, создаваемая на Flutter.

Цель — единый современный интерфейс, синхронизация между устройствами, поддержка множества языков, плавные анимации, модульная архитектура, обновления и расширяемость через плагины.

> **Ранняя стадия разработки.** Это прототип. Подготавливаются подписанный Android APK для прямого скачивания и Windows ZIP. Прежние опубликованные preview содержат отладочные APK.

## Состояние

| Возможность | Состояние |
| --- | --- |
| Основа Flutter для Windows и Android | Стартовая структура |
| Тёмная тема и адаптивные карточки | Реализовано в прототипе |
| Локализация RU/EN и сохранение языка | ARB / Flutter gen-l10n; выбор сохраняется между запусками |
| Анализ, тесты и сборки в GitHub Actions | Настроено |
| Библиотека приложений, поиск и запуск | MVP; базовые сценарии проверены на Windows и подтверждены пользователем на Android |
| Синхронизация между устройствами | Запланировано |
| Переходы и доступность | Затухание состояний, системное отключение анимаций, клавиатура и крупный текст |
| Плагины с контролем разрешений | Запланировано |
| Обновления и восстановление | Запланировано |

Библиотека показывает только выбранные пользователем приложения. На Windows список доступных элементов берётся из ярлыков меню «Пуск», на Android — из приложений с экраном запуска. Широкое разрешение `QUERY_ALL_PACKAGES` не запрашивается. Карточки синхронизации, плагинов и обновлений пока показывают направления разработки и не выполняют системные операции.

Добавляйте приложение через кнопку в библиотеке, запускайте его кнопкой ▶ и удаляйте из личного списка кнопкой с минусом. Поиск фильтрует сохранённые записи по названию и системному идентификатору. Если приложение удалено или ярлык перемещён, запуск сообщает о недоступности; запись можно удалить вручную.

Windows использует отображаемые имена ярлыков меню «Пуск». Результаты и границы ручной проверки описаны в [отчёте Windows](docs/testing/windows-smoke-2026-10-05.md).

Ctrl+F переводит фокус в поиск (физическая клавиша F, включая другие раскладки), Escape очищает запрос. Tab/Shift+Tab перемещают фокус, Enter открывает список, Escape закрывает диалог и возвращает фокус на кнопку добавления. Кнопки запуска и удаления озвучивают название приложения.

Состояния библиотеки меняются затуханием за 180 мс. При системном отключении анимаций переходы пропускаются, индикатор загрузки становится статичным. Android использует флаг Flutter; Windows читает настройку анимаций ОС при запуске, возврате в приложение и уведомлении об её изменении. [Отчёт доступности](docs/testing/accessibility-2026-10-05.md) описывает автоматические проверки и оставшиеся проверки на устройствах.

## Запуск

Требуются Flutter **3.47.5** (stable), Git и инструменты целевой платформы. Версия закреплена в CI.

```sh
git clone https://github.com/kaim47052-creator/void-connect.git
cd void-connect
flutter doctor
flutter pub get
flutter run -d windows
```

Для Android запустите эмулятор или подключите устройство, найдите его идентификатор через `flutter devices` и выполните `flutter run -d <device-id>`.

- Windows: [Visual Studio с Desktop development with C++](https://docs.flutter.dev/platform-integration/windows/setup).
- Android: [Android SDK и настройка устройства](https://docs.flutter.dev/platform-integration/android/setup). Лицензии SDK принимает владелец среды.
- Flutter: [официальная установка](https://docs.flutter.dev/install/manual).

## Проверки и сборки

Инструкции [установки](docs/INSTALL.md) и [подготовки выпуска](docs/RELEASING.md), [список изменений](CHANGELOG.md). Android release собирается локально через `scripts/Build-SignedAndroid.ps1`; без параметров подписи release-сборка завершится ошибкой. Debug APK в CI сохраняется для тестов.

```sh
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test
flutter build windows --release
flutter build apk --debug
```

Windows собирается на Windows с C++ toolchain. APK в CI подписан отладочным ключом и предназначен для проверки. Публикация в магазинах и автоматическое обновление пользователей не настроены.

Нативные проверки выполняются отдельно: `flutter test integration_test/platform_smoke_test.dart -d windows` или `-d <android-device-id>`. Они используют настоящий каталог и хранилище настроек. Для Android используйте отдельное тестовое устройство/профиль: Flutter устанавливает тестовый APK и удаляет пакет после проверки. Сохраните данные существующей установки перед запуском. В Windows создаётся временная запись библиотеки, которая удаляется в `finally`; выбранный язык восстанавливается. Если язык ещё не сохранён, тест проверяет только его чтение и отклонение неверного кода.

Результаты полного прогона: [2026-10-07](docs/testing/full-tests-2026-10-07.md).

## Структура

```text
lib/
  app/                         # Приложение и выбранный язык
  core/
    l10n/                      # RU/EN ARB-каталоги и сгенерированные строки
    settings/                  # Сохранение настроек через платформенный канал
    modules/                   # Метаданные карточек
    motion/                    # Переходы и системная настройка движения
    theme/                     # Визуальный стиль
  features/
    launcher/
      data/                    # Адаптеры Windows и Android
      domain/                  # Модель приложения
      presentation/            # Стартовый экран и библиотека
android/                       # Нативная оболочка Android
windows/                       # Нативная оболочка Windows
test/                          # Язык, клавиатура, доступность и адаптивность
integration_test/              # Настоящие платформенные каналы и запуск UI
docs/                          # Архитектура, ADR и план
.github/                       # CI и шаблоны
```

Android ID для v0.1 сохраняется `dev.voidconnect.void_connect`. Название приложения — Void Connect, Windows EXE — `VoidConnect.exe`. Канал предварительного распространения и подписи зафиксированы в [ADR 0002](docs/adr/0002-preview-distribution.md).

## Участие и лицензия

Начните с [Issues](https://github.com/kaim47052-creator/void-connect/issues) и [CONTRIBUTING.md](CONTRIBUTING.md). Не публикуйте секреты и личные данные в задачах и логах.

Код Void Connect распространяется по [MIT](LICENSE). Уведомления и лицензии сторонних компонентов сохраняются отдельно: [THIRD_PARTY_NOTICES](THIRD_PARTY_NOTICES.md).

<sub>Void Connect · Windows + Android · Early development</sub>
