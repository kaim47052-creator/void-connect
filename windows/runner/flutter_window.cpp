#include "flutter_window.h"

#include <windows.h>

#include <filesystem>
#include <fstream>
#include <optional>
#include <set>
#include <string>
#include <system_error>
#include <variant>
#include <vector>

#include <shellapi.h>
#include <shlobj.h>
#include <shobjidl.h>
#include <wrl/client.h>

#include "flutter/generated_plugin_registrant.h"

namespace {

using flutter::EncodableList;
using flutter::EncodableMap;
using flutter::EncodableValue;

std::string Utf8FromWide(const std::wstring& value) {
  if (value.empty()) return {};
  const int length = WideCharToMultiByte(CP_UTF8, 0, value.data(),
                                        static_cast<int>(value.size()), nullptr,
                                        0, nullptr, nullptr);
  std::string result(length, '\0');
  WideCharToMultiByte(CP_UTF8, 0, value.data(),
                      static_cast<int>(value.size()), result.data(), length,
                      nullptr, nullptr);
  return result;
}

std::wstring WideFromUtf8(const std::string& value) {
  if (value.empty()) return {};
  const int length = MultiByteToWideChar(CP_UTF8, 0, value.data(),
                                         static_cast<int>(value.size()),
                                         nullptr, 0);
  std::wstring result(length, L'\0');
  MultiByteToWideChar(CP_UTF8, 0, value.data(),
                      static_cast<int>(value.size()), result.data(), length);
  return result;
}

std::optional<std::filesystem::path> KnownFolderPath(REFKNOWNFOLDERID folder) {
  PWSTR raw_path = nullptr;
  if (FAILED(SHGetKnownFolderPath(folder, KF_FLAG_DEFAULT, nullptr, &raw_path))) {
    return std::nullopt;
  }
  std::filesystem::path path(raw_path);
  CoTaskMemFree(raw_path);
  return path;
}

std::optional<std::filesystem::path> AppLibraryFile() {
  const auto roaming = KnownFolderPath(FOLDERID_RoamingAppData);
  if (!roaming) return std::nullopt;
  return *roaming / L"VoidConnect" / L"app-library.txt";
}

std::optional<std::filesystem::path> LanguageSettingsFile() {
  const auto roaming = KnownFolderPath(FOLDERID_RoamingAppData);
  if (!roaming) return std::nullopt;
  return *roaming / L"VoidConnect" / L"language.txt";
}

std::optional<std::string> ReadLanguage() {
  const auto path = LanguageSettingsFile();
  if (!path) return std::nullopt;
  std::ifstream input(*path, std::ios::binary);
  std::string language;
  if (!std::getline(input, language)) return std::nullopt;
  if (language == "ru" || language == "en") return language;
  return std::nullopt;
}

bool WriteLanguage(const std::string& language) {
  if (language != "ru" && language != "en") return false;
  const auto path = LanguageSettingsFile();
  if (!path) return false;
  std::error_code error;
  std::filesystem::create_directories(path->parent_path(), error);
  if (error) return false;
  std::ofstream output(*path, std::ios::binary | std::ios::trunc);
  if (!output) return false;
  output << language << "\n";
  return output.good();
}

void HandleSettingsCall(
    const flutter::MethodCall<EncodableValue>& call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  if (call.method_name() == "getLanguage") {
    const auto language = ReadLanguage();
    result->Success(language ? EncodableValue(*language) : EncodableValue());
    return;
  }
  if (call.method_name() == "setLanguage") {
    const auto* arguments = std::get_if<EncodableMap>(call.arguments());
    if (!arguments) {
      result->Error("invalid_argument", "Language code is required");
      return;
    }
    const auto language_entry = arguments->find(EncodableValue("languageCode"));
    if (language_entry == arguments->end() ||
        !std::holds_alternative<std::string>(language_entry->second)) {
      result->Error("invalid_argument", "Language code is required");
      return;
    }
    const auto language = std::get<std::string>(language_entry->second);
    if (language != "ru" && language != "en") {
      result->Error("invalid_argument", "Unsupported language");
      return;
    }
    if (!WriteLanguage(language)) {
      result->Error("storage_failed", "The language preference could not be saved");
      return;
    }
    result->Success();
    return;
  }
  result->NotImplemented();
}

std::vector<std::string> ReadSavedApps() {
  std::vector<std::string> app_ids;
  const auto path = AppLibraryFile();
  if (!path) return app_ids;
  std::ifstream input(*path, std::ios::binary);
  std::string line;
  while (std::getline(input, line)) {
    if (!line.empty() && line.back() == '\r') line.pop_back();
    if (!line.empty()) app_ids.push_back(line);
  }
  return app_ids;
}

bool WriteSavedApps(const std::set<std::string>& app_ids) {
  const auto path = AppLibraryFile();
  if (!path) return false;
  std::error_code error;
  std::filesystem::create_directories(path->parent_path(), error);
  if (error) return false;
  std::ofstream output(*path, std::ios::binary | std::ios::trunc);
  if (!output) return false;
  for (const auto& app_id : app_ids) output << app_id << "\n";
  return output.good();
}

std::wstring ShortcutName(const std::filesystem::path& path) {
  Microsoft::WRL::ComPtr<IShellLinkW> shell_link;
  if (FAILED(CoCreateInstance(CLSID_ShellLink, nullptr, CLSCTX_INPROC_SERVER,
                              IID_PPV_ARGS(&shell_link)))) {
    return path.stem().wstring();
  }
  Microsoft::WRL::ComPtr<IPersistFile> persist_file;
  if (FAILED(shell_link.As(&persist_file)) ||
      FAILED(persist_file->Load(path.c_str(), STGM_READ))) {
    return path.stem().wstring();
  }
  wchar_t description[512] = {};
  if (SUCCEEDED(shell_link->GetDescription(description, ARRAYSIZE(description))) &&
      description[0] != L'\0') {
    return description;
  }
  return path.stem().wstring();
}

EncodableList ListStartMenuApps() {
  EncodableList apps;
  std::set<std::wstring> seen;
  const KNOWNFOLDERID roots[] = {FOLDERID_Programs, FOLDERID_CommonPrograms};
  for (const auto root_id : roots) {
    const auto root = KnownFolderPath(root_id);
    if (!root || !std::filesystem::exists(*root)) continue;
    std::error_code error;
    std::filesystem::recursive_directory_iterator iterator(
        *root, std::filesystem::directory_options::skip_permission_denied,
        error);
    const std::filesystem::recursive_directory_iterator end;
    while (iterator != end) {
      const auto path = iterator->path();
      iterator.increment(error);
      if (error) {
        error.clear();
        continue;
      }
      if (!std::filesystem::is_regular_file(path, error) || error) {
        error.clear();
        continue;
      }
      if (_wcsicmp(path.extension().c_str(), L".lnk") != 0 ||
          !seen.insert(path.native()).second) {
        continue;
      }
      const auto id = Utf8FromWide(path.wstring());
      const auto name = Utf8FromWide(ShortcutName(path));
      apps.emplace_back(EncodableMap{
          {EncodableValue("id"), EncodableValue(id)},
          {EncodableValue("name"), EncodableValue(name)},
      });
    }
  }
  return apps;
}

void HandleAppLibraryCall(
    const flutter::MethodCall<EncodableValue>& call,
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result) {
  if (call.method_name() == "listApps") {
    result->Success(EncodableValue(ListStartMenuApps()));
    return;
  }
  if (call.method_name() == "getSavedApps") {
    EncodableList saved_apps;
    for (const auto& app_id : ReadSavedApps()) {
      saved_apps.emplace_back(EncodableValue(app_id));
    }
    result->Success(EncodableValue(std::move(saved_apps)));
    return;
  }
  if (call.method_name() == "addApp" || call.method_name() == "removeApp" ||
      call.method_name() == "launchApp") {
    const auto* arguments = std::get_if<EncodableMap>(call.arguments());
    if (!arguments) {
      result->Error("invalid_argument", "App identifier is required");
      return;
    }
    const auto id_entry = arguments->find(EncodableValue("id"));
    if (id_entry == arguments->end() ||
        !std::holds_alternative<std::string>(id_entry->second)) {
      result->Error("invalid_argument", "App identifier is required");
      return;
    }
    const std::string app_id = std::get<std::string>(id_entry->second);
    if (call.method_name() == "launchApp") {
      const auto path = WideFromUtf8(app_id);
      if (_wcsicmp(std::filesystem::path(path).extension().c_str(), L".lnk") !=
          0) {
        result->Error("invalid_argument", "Only Start Menu shortcuts can be opened");
        return;
      }
      const auto response = ShellExecuteW(nullptr, L"open", path.c_str(),
                                          nullptr, nullptr, SW_SHOWNORMAL);
      if (reinterpret_cast<INT_PTR>(response) <= 32) {
        result->Error("app_not_found", "The Start Menu shortcut could not be opened");
      } else {
        result->Success(EncodableValue(true));
      }
      return;
    }

    std::set<std::string> app_ids;
    for (const auto& saved_id : ReadSavedApps()) app_ids.insert(saved_id);
    if (call.method_name() == "addApp") {
      app_ids.insert(app_id);
    } else {
      app_ids.erase(app_id);
    }
    if (!WriteSavedApps(app_ids)) {
      result->Error("storage_failed", "The app library could not be saved");
      return;
    }
    result->Success();
    return;
  }
  result->NotImplemented();
}

}  // namespace

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());
  app_library_channel_ = std::make_unique<flutter::MethodChannel<EncodableValue>>(
      flutter_controller_->engine()->messenger(), "void_connect/app_library",
      &flutter::StandardMethodCodec::GetInstance());
  app_library_channel_->SetMethodCallHandler(HandleAppLibraryCall);
  settings_channel_ = std::make_unique<flutter::MethodChannel<EncodableValue>>(
      flutter_controller_->engine()->messenger(), "void_connect/settings",
      &flutter::StandardMethodCodec::GetInstance());
  settings_channel_->SetMethodCallHandler(HandleSettingsCall);
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}
