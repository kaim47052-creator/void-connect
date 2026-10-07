# Сторонние компоненты

MIT в `LICENSE` относится к коду Void Connect. Лицензии сторонних компонентов сохраняются отдельно.

- Flutter/Dart и используемые пакеты: их уведомления включаются Flutter в `data/flutter_assets/NOTICES.Z` в Windows ZIP и `assets/flutter_assets/NOTICES.Z` внутри APK. Flutter распространяется по BSD-3-Clause; см. [официальный LICENSE](https://github.com/flutter/flutter/blob/3.47.5/LICENSE).
- Windows ZIP включает оригинальные `msvcp140.dll`, `vcruntime140.dll`, `vcruntime140_1.dll` из установленного Microsoft Visual C++ Redistributable. Они остаются под условиями Microsoft и не перелицензируются в MIT. [Правила распространения Microsoft](https://learn.microsoft.com/en-us/cpp/windows/redistributing-visual-cpp-files?view=msvc-170).
- GitHub Actions и средства сборки не входят в исполняемый код приложения.
