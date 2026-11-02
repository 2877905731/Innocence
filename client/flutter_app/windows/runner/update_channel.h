#ifndef INNOCENCE_UPDATE_CHANNEL_H_
#define INNOCENCE_UPDATE_CHANNEL_H_
#include <windows.h>
#include <shellapi.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>
#include <filesystem>
#include <regex>
#include <vector>
#include <stdexcept>

inline std::wstring UpdateWide(const std::string& value) {
  int size = MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, value.data(), static_cast<int>(value.size()), nullptr, 0);
  if (size <= 0) return L"";
  std::wstring wide(size, L'\0');
  MultiByteToWideChar(CP_UTF8, MB_ERR_INVALID_CHARS, value.data(), static_cast<int>(value.size()), wide.data(), size);
  return wide;
}
inline std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>>
CreateUpdateChannel(flutter::BinaryMessenger* messenger) {
  auto channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      messenger, "innocence/updates", &flutter::StandardMethodCodec::GetInstance());
  channel->SetMethodCallHandler([](const auto& call, auto result) {
    using flutter::EncodableValue;
    if (call.method_name() == "info") {
      result->Success(EncodableValue(flutter::EncodableMap{
        {EncodableValue("platform"), EncodableValue("windows")},
        {EncodableValue("arch"), EncodableValue("x64")},
        {EncodableValue("version"), EncodableValue(std::to_string(FLUTTER_VERSION_MAJOR) + "." + std::to_string(FLUTTER_VERSION_MINOR) + "." + std::to_string(FLUTTER_VERSION_PATCH))},
        {EncodableValue("build"), EncodableValue(static_cast<int64_t>(FLUTTER_VERSION_BUILD))}}));
      return;
    }
    if (call.method_name() != "install") { result->NotImplemented(); return; }
    try {
      const auto* args = call.arguments() ? std::get_if<flutter::EncodableMap>(call.arguments()) : nullptr;
      if (!args) throw std::runtime_error("args");
      auto path = std::get<std::string>(args->at(EncodableValue("path")));
      auto version = std::get<std::string>(args->at(EncodableValue("version")));
      const auto& number = args->at(EncodableValue("build"));
      int64_t build = std::holds_alternative<int32_t>(number) ? std::get<int32_t>(number) : std::get<int64_t>(number);
      if (build <= FLUTTER_VERSION_BUILD || build > 65535 || !std::regex_match(version, std::regex("[0-9]{1,4}\\.[0-9]{1,4}\\.[0-9]{1,4}"))) throw std::runtime_error("version");
      wchar_t temp[MAX_PATH + 1]{};
      if (!GetTempPathW(MAX_PATH, temp)) throw std::runtime_error("temp");
      auto file = std::filesystem::canonical(UpdateWide(path));
      auto directory = std::filesystem::canonical(std::filesystem::path(temp) / L"innocence-updates");
      if (file.parent_path() != directory || !std::regex_match(file.filename().string(), std::regex("[a-f0-9-]{36}\\.exe"))) throw std::runtime_error("path");
      DWORD ignored = 0, length = GetFileVersionInfoSizeW(file.c_str(), &ignored);
      if (!length || length > 1048576) throw std::runtime_error("metadata");
      std::vector<uint8_t> data(length);
      if (!GetFileVersionInfoW(file.c_str(), 0, length, data.data())) throw std::runtime_error("metadata");
      VS_FIXEDFILEINFO* info = nullptr; UINT info_size = 0;
      if (!VerQueryValueW(data.data(), L"\\", reinterpret_cast<void**>(&info), &info_size) || info_size < sizeof(VS_FIXEDFILEINFO)) throw std::runtime_error("metadata");
      std::string actual = std::to_string(HIWORD(info->dwProductVersionMS)) + "." + std::to_string(LOWORD(info->dwProductVersionMS)) + "." + std::to_string(HIWORD(info->dwProductVersionLS));
      if (actual != version || LOWORD(info->dwProductVersionLS) != build) throw std::runtime_error("metadata");
      // Inno Setup asks the user to close the app, then preserves its data directory.
      if (reinterpret_cast<intptr_t>(ShellExecuteW(nullptr, L"open", file.c_str(), nullptr, directory.c_str(), SW_SHOWNORMAL)) <= 32) throw std::runtime_error("launch");
      result->Success(EncodableValue("installerOpened"));
    } catch (...) { result->Error("update_failed", "Update package or installer is unavailable."); }
  });
  return channel;
}
#endif
