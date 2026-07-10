#include "flutter_window.h"

#include <optional>
#include <string>

#include "flutter/generated_plugin_registrant.h"

namespace {

constexpr const wchar_t kStartupRunKey[] =
    L"Software\\Microsoft\\Windows\\CurrentVersion\\Run";
constexpr const wchar_t kStartupValueName[] = L"Innocence";

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
  RegisterDesktopWidgetChannel();
  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();
  Show();

  return true;
}

void FlutterWindow::OnDestroy() {
  desktop_widget_channel_.reset();
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

void FlutterWindow::OnWindowModeChanged(const std::string& mode) {
  NotifyWindowModeChanged(mode);
}

void FlutterWindow::RegisterDesktopWidgetChannel() {
  desktop_widget_channel_ =
      std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
          flutter_controller_->engine()->messenger(),
          "innocence/desktop_widget",
          &flutter::StandardMethodCodec::GetInstance());

  desktop_widget_channel_->SetMethodCallHandler(
      [this](const flutter::MethodCall<flutter::EncodableValue>& call,
             std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>>
                 result) {
        if (call.method_name() == "setAlwaysOnTop") {
          const auto* arguments =
              std::get_if<flutter::EncodableMap>(call.arguments());
          bool enabled = true;
          if (arguments != nullptr) {
            const auto found =
                arguments->find(flutter::EncodableValue("enabled"));
            if (found != arguments->end()) {
              if (const auto value =
                      std::get_if<bool>(&found->second)) {
                enabled = *value;
              }
            }
          }
          SetAlwaysOnTop(enabled);
          result->Success();
          return;
        }

        if (call.method_name() == "setAutoStart") {
          const auto* arguments =
              std::get_if<flutter::EncodableMap>(call.arguments());
          bool enabled = false;
          if (arguments != nullptr) {
            const auto found =
                arguments->find(flutter::EncodableValue("enabled"));
            if (found != arguments->end()) {
              if (const auto value = std::get_if<bool>(&found->second)) {
                enabled = *value;
              }
            }
          }
          if (SetAutoStart(enabled)) {
            result->Success();
            return;
          }
          result->Error("auto_start_failed",
                        "Failed to update the Windows startup entry.");
          return;
        }

        if (call.method_name() == "setDesktopEffect") {
          const auto* arguments =
              std::get_if<flutter::EncodableMap>(call.arguments());
          std::string effect = "immersive_glass";
          if (arguments != nullptr) {
            const auto found =
                arguments->find(flutter::EncodableValue("effect"));
            if (found != arguments->end()) {
              if (const auto value =
                      std::get_if<std::string>(&found->second)) {
                effect = *value;
              }
            }
          }
          SetDesktopEffect(effect);
          result->Success();
          return;
        }

        if (call.method_name() == "setWindowHeight") {
          const auto* arguments =
              std::get_if<flutter::EncodableMap>(call.arguments());
          double logical_height = 920.0;
          if (arguments != nullptr) {
            const auto found =
                arguments->find(flutter::EncodableValue("height"));
            if (found != arguments->end()) {
              if (const auto value = std::get_if<double>(&found->second)) {
                logical_height = *value;
              } else if (const auto integer_value =
                             std::get_if<int>(&found->second)) {
                logical_height = static_cast<double>(*integer_value);
              }
            }
          }
          SetWidgetHeight(static_cast<int>(logical_height));
          result->Success();
          return;
        }

        if (call.method_name() == "setWindowMode") {
          const auto* arguments =
              std::get_if<flutter::EncodableMap>(call.arguments());
          std::string mode = "auth";
          if (arguments != nullptr) {
            const auto found =
                arguments->find(flutter::EncodableValue("mode"));
            if (found != arguments->end()) {
              if (const auto value =
                      std::get_if<std::string>(&found->second)) {
                mode = *value;
              }
            }
          }
          SetWindowMode(mode);
          result->Success();
          return;
        }

        if (call.method_name() == "startWindowDrag") {
          BeginWindowDrag();
          result->Success();
          return;
        }

        if (call.method_name() == "resetWindowPosition") {
          ResetWidgetPosition();
          result->Success();
          return;
        }

        if (call.method_name() == "hideWindow") {
          HideWindowToTray();
          result->Success();
          return;
        }

        if (call.method_name() == "closeWindow") {
          CloseWindow();
          result->Success();
          return;
        }

        result->NotImplemented();
      });
}

void FlutterWindow::NotifyWindowModeChanged(const std::string& mode) {
  if (!desktop_widget_channel_) {
    return;
  }

  auto arguments = std::make_unique<flutter::EncodableValue>(
      flutter::EncodableMap{
          {flutter::EncodableValue("mode"), flutter::EncodableValue(mode)},
      });
  desktop_widget_channel_->InvokeMethod("windowModeChanged",
                                        std::move(arguments));
}

bool FlutterWindow::SetAutoStart(bool enabled) {
  HKEY run_key = nullptr;
  const LSTATUS open_status =
      RegCreateKeyExW(HKEY_CURRENT_USER, kStartupRunKey, 0, nullptr, 0,
                      KEY_SET_VALUE, nullptr, &run_key, nullptr);
  if (open_status != ERROR_SUCCESS) {
    return false;
  }

  bool success = false;
  if (enabled) {
    wchar_t executable_path[MAX_PATH];
    const DWORD path_length =
        GetModuleFileNameW(nullptr, executable_path, MAX_PATH);
    if (path_length > 0 && path_length < MAX_PATH) {
      std::wstring command_line = L"\"";
      command_line += executable_path;
      command_line += L"\"";
      const auto* raw_bytes = reinterpret_cast<const BYTE*>(
          command_line.c_str());
      const DWORD raw_size = static_cast<DWORD>(
          (command_line.size() + 1) * sizeof(wchar_t));
      success = RegSetValueExW(run_key, kStartupValueName, 0, REG_SZ, raw_bytes,
                               raw_size) == ERROR_SUCCESS;
    }
  } else {
    const LSTATUS delete_status = RegDeleteValueW(run_key, kStartupValueName);
    success =
        delete_status == ERROR_SUCCESS || delete_status == ERROR_FILE_NOT_FOUND;
  }

  RegCloseKey(run_key);
  return success;
}

void FlutterWindow::CloseWindow() {
  if (GetHandle() == nullptr) {
    return;
  }
  PostMessage(GetHandle(), WM_CLOSE, 0, 0);
}
