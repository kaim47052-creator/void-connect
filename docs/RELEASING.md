# Подготовка предварительного выпуска

Версия preview.4: приложение `0.1.0+4`, GitHub tag `v0.1.0-preview.4`. Android ID для v0.1 сохраняется `dev.voidconnect.void_connect`; название интерфейса и оболочек — Void Connect, EXE — `VoidConnect.exe`. Исходный код лицензирован MIT по решению владельца 2026-10-07.

## Android: локальный ключ

Ключ и пароль хранятся на D:, вне репозитория. Генератор создаёт PKCS12/RSA-3072 и пароль из криптографического генератора. Файлы доступны текущему пользователю, SYSTEM и локальным администраторам. Пароль записывается через Windows DPAPI (`Export-Clixml`); файл зависит от учётной записи и компьютера.

```powershell
.\scripts\New-AndroidSigningKey.ps1
.\scripts\Build-SignedAndroid.ps1
```

Генератор отказывается заменять существующие файлы. Сборка временно передаёт параметры подписи через окружение процесса и восстанавливает предыдущие значения в `finally`. Release без параметров подписи завершается ошибкой; debug в CI работает без приватного ключа.

Публичный SHA256 сертификата закреплён в `docs/releases/android-signing-certificate.sha256`. Пароль, приватный ключ и резервные копии не загружаются в GitHub. До публичного выпуска владелец должен сохранить отдельную приватную резервную копию ключа и восстановимого пароля. Просто копировать DPAPI-файл на другой компьютер недостаточно. Потеря постоянного ключа препятствует выпуску совместимых обновлений; [официальная документация Android](https://developer.android.com/studio/publish/app-signing).

## Проверка без удаления текущей установки

```powershell
.\scripts\Build-SignedAndroid.ps1 -Verification
```

Этот APK имеет отдельный ID `dev.voidconnect.void_connect.releasecheck` и название `Void Connect Check`, но использует тот же release-код и ключ. Его можно установить рядом с debug-версией и удалить после проверки, сохранив пользовательскую установку. После него **повторите обычную signed-сборку**, прежде чем упаковывать выпуск. Упаковщик проверяет ID, версию, отсутствие debug-флага и подпись и отклоняет проверочный APK.

## Windows и упаковка

```powershell
flutter test
flutter test integration_test/platform_smoke_test.dart -d windows
flutter build windows --release
.\scripts\Build-SignedAndroid.ps1
.\scripts\Package-Release.ps1
```

Упаковщик берёт EXE, все DLL и `data` из release bundle, добавляет оригинальные Microsoft runtime DLL из Visual Studio и документы. В пакет не попадает старый `void_connect.exe`. Для повторной упаковки используйте новый `-OutputDirectory`: существующая staging-папка не перезаписывается.

Результат на D:: APK, Windows ZIP, LICENSE, THIRD_PARTY_NOTICES, CHANGELOG, INSTALL, release-manifest.json и SHA256SUMS.txt. Приватные файлы не входят в пакет. QR для скачивания и привязки устройств отложены.

## GitHub Release

Создавайте предварительный **draft** на проверенном коммите. Загружайте только файлы пакета, сверяйте SHA256, результаты CI и smoke-проверки. Публичная публикация производится после сохранения резервной копии ключа и завершения проверки выпуска. CI продолжает выдавать debug APK и Windows bundle; production APK подписывается локально.

Не заменяйте assets старых опубликованных preview: у них другая подпись, и они остаются историческими тестовыми выпусками. Обновите changelog и документацию, укажите оставшиеся ручные проверки. [Официальная настройка подписи Flutter](https://docs.flutter.dev/deployment/android), [упаковка Windows](https://docs.flutter.dev/platform-integration/windows/building).
