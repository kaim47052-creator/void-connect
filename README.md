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

> **Ранняя стадия разработки.** Это прототип. Доступна только отладочная предварительная Android-сборка для тестирования, не предназначенная для обычного использования.

## Состояние

| Возможность | Состояние |
| --- | --- |
| Основа Flutter для Windows и Android | Стартовая структура |
| Тёмная тема и адаптивные карточки | Реализовано в прототипе |
| Переключение RU/EN | Реализовано; действует до перезапуска |
| Анализ, тесты и сборки в GitHub Actions | Настроено |
| Библиотека приложений, поиск и запуск | MVP для Windows и Android; ждёт ручной проверки новой Android-сборки |
| Синхронизация между устройствами | Запланировано |
| Плавные переходы и настройка анимаций | Запланировано |
| Плагины с контролем разрешений | Запланировано |
| Обновления и восстановление | Запланировано |

Библиотека показывает только выбранные пользователем приложения. На Windows список доступных элементов берётся из ярлыков меню «Пуск», на Android — из приложений с экраном запуска. Широкое разрешение `QUERY_ALL_PACKAGES` не запрашивается. Карточки синхронизации, плагинов и обновлений пока показывают направления разработки и не выполняют системные операции.

Добавляйте приложение через кнопку в библиотеке, запускайте его кнопкой ▶ и удаляйте из личного списка кнопкой с минусом. Поиск фильтрует сохранённые записи по названию и системному идентификатору. Если приложение удалено или ярлык перемещён, запуск сообщает о недоступности; запись можно удалить вручную.

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

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build windows --release
flutter build apk --debug
```

Windows собирается на Windows с C++ toolchain. APK в CI подписан отладочным ключом и предназначен для проверки. Публикация в магазинах и автоматическое обновление пользователей не настроены.

## Структура

```text
lib/
  app/                         # Приложение и выбранный язык
  core/
    l10n/                      # Стартовые строки RU/EN
    modules/                   # Метаданные карточек
    theme/                     # Визуальный стиль
  features/
    launcher/
      data/                    # Адаптеры Windows и Android
      domain/                  # Модель приложения
      presentation/            # Стартовый экран и библиотека
android/                       # Нативная оболочка Android
windows/                       # Нативная оболочка Windows
test/                          # Язык и адаптивность
docs/                          # Архитектура, ADR и план
.github/                       # CI и шаблоны
```

Android ID `dev.voidconnect.void_connect` — временный. До публикации его необходимо утвердить вместе с подписанием приложения.

## Участие и лицензия

Начните с [Issues](https://github.com/kaim47052-creator/void-connect/issues) и [CONTRIBUTING.md](CONTRIBUTING.md). Не публикуйте секреты и личные данные в задачах и логах.

Лицензия пока не выбрана. Публичный доступ сам по себе не предоставляет разрешение на использование и распространение кода. Условия необходимо определить до внешнего распространения.

<sub>Void Connect · Windows + Android · Early development</sub>
