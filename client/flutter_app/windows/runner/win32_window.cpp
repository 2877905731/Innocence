#include "win32_window.h"

#include <algorithm>

#include <dwmapi.h>
#include <flutter_windows.h>
#include <shellapi.h>

#include "resource.h"

namespace {

/// Window attribute that enables dark mode window decorations.
///
/// Redefined in case the developer's machine has a Windows SDK older than
/// version 10.0.22000.0.
/// See: https://docs.microsoft.com/windows/win32/api/dwmapi/ne-dwmapi-dwmwindowattribute
#ifndef DWMWA_USE_IMMERSIVE_DARK_MODE
#define DWMWA_USE_IMMERSIVE_DARK_MODE 20
#endif

#ifndef DWMWA_WINDOW_CORNER_PREFERENCE
#define DWMWA_WINDOW_CORNER_PREFERENCE 33
#endif

#ifndef DWMWA_SYSTEMBACKDROP_TYPE
#define DWMWA_SYSTEMBACKDROP_TYPE 38
#endif

enum ACCENT_STATE {
  ACCENT_DISABLED = 0,
  ACCENT_ENABLE_GRADIENT = 1,
  ACCENT_ENABLE_TRANSPARENTGRADIENT = 2,
  ACCENT_ENABLE_BLURBEHIND = 3,
  ACCENT_ENABLE_ACRYLICBLURBEHIND = 4
};

struct ACCENT_POLICY {
  int accent_state;
  int accent_flags;
  int gradient_color;
  int animation_id;
};

struct WINDOWCOMPOSITIONATTRIBDATA {
  int attribute;
  PVOID data;
  SIZE_T size_of_data;
};

constexpr int kWindowCompositionAccentPolicy = 19;
constexpr int kWidgetWidth = 560;
constexpr int kWidgetMinWidth = 520;
constexpr int kWidgetMaxWidth = 980;
constexpr int kWidgetHeight = 920;
constexpr int kWidgetMinHeight = 380;
constexpr int kWidgetMaxHeight = 940;
constexpr int kPageDefaultWidth = 1260;
constexpr int kPageDefaultHeight = 860;
constexpr int kPageMinWidth = 1080;
constexpr int kPageMinHeight = 760;
constexpr int kMiniWidgetWidth = 132;
constexpr int kMiniWidgetHeight = 156;
constexpr int kAuthWidth = 860;
constexpr int kAuthHeight = 980;
constexpr int kWidgetMarginRight = 32;
constexpr int kWidgetMarginTop = 24;
constexpr int kWidgetSnapThreshold = 28;
constexpr DWORD kAcrylicTint = 0x92707070;
constexpr int kWindowCornerRound = 2;
constexpr UINT kTrayIconMessage = WM_APP + 1;
constexpr UINT_PTR kTrayIconId = 1;
constexpr const wchar_t kWindowStateRegKey[] =
    L"Software\\Innocence\\WindowState";

using SetWindowCompositionAttribute =
    BOOL(WINAPI*)(HWND, WINDOWCOMPOSITIONATTRIBDATA*);

constexpr const wchar_t kWindowClassName[] = L"FLUTTER_RUNNER_WIN32_WINDOW";

// The number of Win32Window objects that currently exist.
static int g_active_window_count = 0;

using EnableNonClientDpiScaling = BOOL __stdcall(HWND hwnd);

DWORD AcrylicTintForEffect(const std::string& desktop_effect) {
  if (desktop_effect == "soft_glass") {
    return 0x847A7A7A;
  }
  if (desktop_effect == "focus_glow") {
    return 0x9A777C82;
  }
  return kAcrylicTint;
}

int ClampInt(int value, int min_value, int max_value) {
  return std::min(std::max(value, min_value), max_value);
}

// Scale helper to convert logical scaler values to physical using passed in
// scale factor
int Scale(int source, double scale_factor) {
  return static_cast<int>(source * scale_factor);
}

// Dynamically loads the |EnableNonClientDpiScaling| from the User32 module.
// This API is only needed for PerMonitor V1 awareness mode.
void EnableFullDpiSupportIfAvailable(HWND hwnd) {
  HMODULE user32_module = LoadLibraryA("User32.dll");
  if (!user32_module) {
    return;
  }
  auto enable_non_client_dpi_scaling =
      reinterpret_cast<EnableNonClientDpiScaling*>(
          GetProcAddress(user32_module, "EnableNonClientDpiScaling"));
  if (enable_non_client_dpi_scaling != nullptr) {
    enable_non_client_dpi_scaling(hwnd);
  }
  FreeLibrary(user32_module);
}

}  // namespace

// Manages the Win32Window's window class registration.
class WindowClassRegistrar {
 public:
  ~WindowClassRegistrar() = default;

  // Returns the singleton registrar instance.
  static WindowClassRegistrar* GetInstance() {
    if (!instance_) {
      instance_ = new WindowClassRegistrar();
    }
    return instance_;
  }

  // Returns the name of the window class, registering the class if it hasn't
  // previously been registered.
  const wchar_t* GetWindowClass();

  // Unregisters the window class. Should only be called if there are no
  // instances of the window.
  void UnregisterWindowClass();

 private:
  WindowClassRegistrar() = default;

  static WindowClassRegistrar* instance_;

  bool class_registered_ = false;
};

WindowClassRegistrar* WindowClassRegistrar::instance_ = nullptr;

const wchar_t* WindowClassRegistrar::GetWindowClass() {
  if (!class_registered_) {
    WNDCLASS window_class{};
    window_class.hCursor = LoadCursor(nullptr, IDC_ARROW);
    window_class.lpszClassName = kWindowClassName;
    window_class.style = CS_HREDRAW | CS_VREDRAW;
    window_class.cbClsExtra = 0;
    window_class.cbWndExtra = 0;
    window_class.hInstance = GetModuleHandle(nullptr);
    window_class.hIcon =
        LoadIcon(window_class.hInstance, MAKEINTRESOURCE(IDI_APP_ICON));
    window_class.hbrBackground = 0;
    window_class.lpszMenuName = nullptr;
    window_class.lpfnWndProc = Win32Window::WndProc;
    RegisterClass(&window_class);
    class_registered_ = true;
  }
  return kWindowClassName;
}

void WindowClassRegistrar::UnregisterWindowClass() {
  UnregisterClass(kWindowClassName, nullptr);
  class_registered_ = false;
}

Win32Window::Win32Window() {
  ++g_active_window_count;
}

Win32Window::~Win32Window() {
  --g_active_window_count;
  Destroy();
}

bool Win32Window::Create(const std::wstring& title,
                         const Point& origin,
                         const Size& size) {
  Destroy();

  const wchar_t* window_class =
      WindowClassRegistrar::GetInstance()->GetWindowClass();

  const POINT target_point = {static_cast<LONG>(origin.x),
                              static_cast<LONG>(origin.y)};
  HMONITOR monitor = MonitorFromPoint(target_point, MONITOR_DEFAULTTONEAREST);
  UINT dpi = FlutterDesktopGetDpiForMonitor(monitor);
  double scale_factor = dpi / 96.0;

  HWND window = CreateWindow(
      window_class, title.c_str(), WS_OVERLAPPEDWINDOW,
      Scale(origin.x, scale_factor), Scale(origin.y, scale_factor),
      Scale(size.width, scale_factor), Scale(size.height, scale_factor),
      nullptr, nullptr, GetModuleHandle(nullptr), this);

  if (!window) {
    return false;
  }

  UpdateTheme(window);
  ApplyDesktopWidgetChrome(window);
  AddTrayIcon(window);

  return OnCreate();
}

bool Win32Window::Show() {
  return ShowWindow(window_handle_, SW_SHOWNORMAL);
}

// static
LRESULT CALLBACK Win32Window::WndProc(HWND const window,
                                      UINT const message,
                                      WPARAM const wparam,
                                      LPARAM const lparam) noexcept {
  if (message == WM_NCCREATE) {
    auto window_struct = reinterpret_cast<CREATESTRUCT*>(lparam);
    SetWindowLongPtr(window, GWLP_USERDATA,
                     reinterpret_cast<LONG_PTR>(window_struct->lpCreateParams));

    auto that = static_cast<Win32Window*>(window_struct->lpCreateParams);
    EnableFullDpiSupportIfAvailable(window);
    that->window_handle_ = window;
  } else if (Win32Window* that = GetThisFromHandle(window)) {
    return that->MessageHandler(window, message, wparam, lparam);
  }

  return DefWindowProc(window, message, wparam, lparam);
}

LRESULT
Win32Window::MessageHandler(HWND hwnd,
                            UINT const message,
                            WPARAM const wparam,
                            LPARAM const lparam) noexcept {
  switch (message) {
    case WM_DESTROY:
      window_handle_ = nullptr;
      Destroy();
      if (quit_on_close_) {
        PostQuitMessage(0);
      }
      return 0;

    case WM_DPICHANGED: {
      auto newRectSize = reinterpret_cast<RECT*>(lparam);
      LONG newWidth = newRectSize->right - newRectSize->left;
      LONG newHeight = newRectSize->bottom - newRectSize->top;

      SetWindowPos(hwnd, nullptr, newRectSize->left, newRectSize->top, newWidth,
                   newHeight, SWP_NOZORDER | SWP_NOACTIVATE);

      return 0;
    }
    case WM_SIZE: {
      if (wparam == SIZE_MINIMIZED &&
          (window_mode_ == "widget" || window_mode_ == "mini")) {
        ShowWindow(hwnd, SW_RESTORE);
        SetWindowMode("mini");
        return 0;
      }
      RECT rect = GetClientArea();
      if (child_content_ != nullptr) {
        // Size and position the child window.
        MoveWindow(child_content_, rect.left, rect.top, rect.right - rect.left,
                   rect.bottom - rect.top, TRUE);
      }
      if (!updating_window_position_ && window_mode_ == "page" &&
          wparam != SIZE_MINIMIZED) {
        RECT window_rect = {};
        if (GetWindowRect(hwnd, &window_rect)) {
          page_width_ = ClampInt(window_rect.right - window_rect.left,
                                 kPageMinWidth, 4096);
          page_height_ = ClampInt(window_rect.bottom - window_rect.top,
                                  kPageMinHeight, 4096);
          page_x_ = window_rect.left;
          page_y_ = window_rect.top;
          has_custom_auth_bounds_ = true;
          SaveWindowState();
        }
      }
      if (!updating_window_position_ && window_mode_ == "widget" &&
          wparam != SIZE_MINIMIZED) {
        RECT window_rect = {};
        if (GetWindowRect(hwnd, &window_rect)) {
          widget_width_ = ClampInt(window_rect.right - window_rect.left,
                                   kWidgetMinWidth, kWidgetMaxWidth);
          widget_height_ = ClampInt(window_rect.bottom - window_rect.top,
                                    kWidgetMinHeight, kWidgetMaxHeight);
          has_custom_widget_size_ = true;
          lock_widget_size_to_content_ = false;
          SaveWindowState();
        }
      }
      return 0;
    }

    case WM_MOVE:
      if (!updating_window_position_) {
        if (window_mode_ == "widget" || window_mode_ == "mini") {
          UpdateStoredWidgetPosition(hwnd);
        } else if (window_mode_ == "page") {
          RECT window_rect = {};
          if (GetWindowRect(hwnd, &window_rect)) {
            page_x_ = window_rect.left;
            page_y_ = window_rect.top;
            has_custom_auth_bounds_ = true;
            SaveWindowState();
          }
        }
      }
      return 0;

    case WM_EXITSIZEMOVE:
      if (window_mode_ == "auth" || window_mode_ == "page") {
        has_custom_auth_bounds_ = true;
        if (window_mode_ == "page") {
          RECT window_rect = {};
          if (GetWindowRect(hwnd, &window_rect)) {
            page_width_ = ClampInt(window_rect.right - window_rect.left,
                                   kPageMinWidth, 4096);
            page_height_ = ClampInt(window_rect.bottom - window_rect.top,
                                    kPageMinHeight, 4096);
            page_x_ = window_rect.left;
            page_y_ = window_rect.top;
            SaveWindowState();
          }
        }
      }
      if (dragging_widget_) {
        dragging_widget_ = false;
        SnapWidgetToWorkArea(hwnd);
      }
      return 0;

    case WM_ACTIVATE:
      if (child_content_ != nullptr) {
        SetFocus(child_content_);
      }
      return 0;

    case WM_DWMCOLORIZATIONCOLORCHANGED:
      UpdateTheme(hwnd);
      return 0;

    case kTrayIconMessage:
      if (lparam == WM_LBUTTONDBLCLK || lparam == WM_LBUTTONUP) {
        if (window_mode_ == "mini") {
          SetWindowMode("widget");
        }
        ShowWindow(hwnd, SW_SHOWNORMAL);
        SetForegroundWindow(hwnd);
      }
      return 0;
  }

  return DefWindowProc(window_handle_, message, wparam, lparam);
}

void Win32Window::Destroy() {
  OnDestroy();

  if (window_handle_) {
    RemoveTrayIcon(window_handle_);
    DestroyWindow(window_handle_);
    window_handle_ = nullptr;
  }
  if (g_active_window_count == 0) {
    WindowClassRegistrar::GetInstance()->UnregisterWindowClass();
  }
}

Win32Window* Win32Window::GetThisFromHandle(HWND const window) noexcept {
  return reinterpret_cast<Win32Window*>(
      GetWindowLongPtr(window, GWLP_USERDATA));
}

void Win32Window::SetChildContent(HWND content) {
  child_content_ = content;
  SetParent(content, window_handle_);
  RECT frame = GetClientArea();

  MoveWindow(content, frame.left, frame.top, frame.right - frame.left,
             frame.bottom - frame.top, true);

  SetFocus(child_content_);
}

RECT Win32Window::GetClientArea() {
  RECT frame;
  GetClientRect(window_handle_, &frame);
  return frame;
}

HWND Win32Window::GetHandle() {
  return window_handle_;
}

void Win32Window::SetAlwaysOnTop(bool always_on_top) {
  always_on_top_ = always_on_top;
  UpdateTopMostState();
}

void Win32Window::SetDesktopEffect(const std::string& desktop_effect) {
  desktop_effect_ = desktop_effect;
  if (window_handle_ != nullptr) {
    ApplyDesktopBackdrop(window_handle_);
  }
}

void Win32Window::SetWidgetHeight(int logical_height) {
  if (!lock_widget_size_to_content_) {
    return;
  }
  widget_height_ = ClampInt(logical_height, kWidgetMinHeight, kWidgetMaxHeight);
  if (!has_custom_widget_size_) {
    widget_width_ = kWidgetWidth;
  }
  SaveWindowState();
  if (window_handle_ != nullptr && window_mode_ == "widget") {
    PositionDesktopWidget(window_handle_, widget_height_);
  }
}

void Win32Window::SetWindowMode(const std::string& mode) {
  const std::string previous_mode = window_mode_;
  if (mode == "widget") {
    window_mode_ = "widget";
  } else if (mode == "mini") {
    window_mode_ = "mini";
  } else if (mode == "page") {
    window_mode_ = "page";
  } else {
    window_mode_ = "auth";
  }
  dragging_widget_ = false;
  if (previous_mode == window_mode_ && window_handle_ == nullptr) {
    return;
  }
  if (window_handle_ == nullptr) {
    OnWindowModeChanged(window_mode_);
    return;
  }

  UpdateWindowFrame(window_handle_);
  ApplyDesktopBackdrop(window_handle_);
  if (window_mode_ == "widget") {
    PositionDesktopWidget(window_handle_, widget_height_);
    OnWindowModeChanged(window_mode_);
    return;
  }
  if (window_mode_ == "mini") {
    PositionMiniWidget(window_handle_);
    OnWindowModeChanged(window_mode_);
    return;
  }
  if (window_mode_ == "page") {
    PositionPageWindow(window_handle_);
    OnWindowModeChanged(window_mode_);
    return;
  }

  has_custom_auth_bounds_ = false;
  PositionAuthWindow(window_handle_);
  OnWindowModeChanged(window_mode_);
}

void Win32Window::BeginWindowDrag() {
  if (window_handle_ == nullptr) {
    return;
  }

  dragging_widget_ = true;
  ReleaseCapture();
  SendMessage(window_handle_, WM_NCLBUTTONDOWN, HTCAPTION, 0);
}

void Win32Window::ResetWidgetPosition() {
  has_custom_position_ = false;
  dragging_widget_ = false;
  if (window_handle_ != nullptr) {
    if (window_mode_ == "mini") {
      PositionMiniWidget(window_handle_);
    } else {
      PositionDesktopWidget(window_handle_, widget_height_);
    }
  }
}

void Win32Window::HideWindowToTray() {
  if (window_handle_ == nullptr) {
    return;
  }

  ShowWindow(window_handle_, SW_HIDE);
}

void Win32Window::SetQuitOnClose(bool quit_on_close) {
  quit_on_close_ = quit_on_close;
}

bool Win32Window::OnCreate() {
  LoadWindowState();
  // No-op; provided for subclasses.
  return true;
}

void Win32Window::OnDestroy() {
  // No-op; provided for subclasses.
}

void Win32Window::UpdateTheme(HWND const window) {
  BOOL enable_dark_mode = TRUE;
  DwmSetWindowAttribute(window, DWMWA_USE_IMMERSIVE_DARK_MODE,
                        &enable_dark_mode, sizeof(enable_dark_mode));
}

void Win32Window::ApplyDesktopWidgetChrome(HWND const window) {
  UpdateWindowFrame(window);
  ApplyDesktopBackdrop(window);
  PositionAuthWindow(window);
}

void Win32Window::UpdateWindowFrame(HWND const window) {
  LONG_PTR style = GetWindowLongPtr(window, GWL_STYLE);
  style &= ~(WS_MAXIMIZEBOX | WS_CAPTION);
  style |= WS_MINIMIZEBOX | WS_SYSMENU | WS_THICKFRAME;
  SetWindowLongPtr(window, GWL_STYLE, style);

  LONG_PTR ex_style = GetWindowLongPtr(window, GWL_EXSTYLE);
  ex_style &= ~WS_EX_LAYERED;
  if (window_mode_ == "widget" || window_mode_ == "mini") {
    ex_style |= WS_EX_TOOLWINDOW;
    ex_style &= ~WS_EX_APPWINDOW;
  } else {
    ex_style &= ~WS_EX_TOOLWINDOW;
    ex_style |= WS_EX_APPWINDOW;
  }
  SetWindowLongPtr(window, GWL_EXSTYLE, ex_style);
}

void Win32Window::ApplyDesktopBackdrop(HWND const window) {
  const int corner_preference = kWindowCornerRound;
  DwmSetWindowAttribute(window, DWMWA_WINDOW_CORNER_PREFERENCE,
                        &corner_preference, sizeof(corner_preference));

  const bool is_desktop_shell_mode =
      window_mode_ == "widget" || window_mode_ == "mini";
  MARGINS margins =
      is_desktop_shell_mode ? MARGINS{-1} : MARGINS{0, 0, 0, 0};
  DwmExtendFrameIntoClientArea(window, &margins);

  HMODULE user32_module = GetModuleHandleA("user32.dll");
  auto set_window_composition_attribute =
      reinterpret_cast<SetWindowCompositionAttribute>(GetProcAddress(
          user32_module, "SetWindowCompositionAttribute"));
  if (set_window_composition_attribute != nullptr) {
    ACCENT_POLICY accent = {};
    if (is_desktop_shell_mode) {
      accent.accent_state = ACCENT_ENABLE_ACRYLICBLURBEHIND;
      accent.accent_flags = 2;
      accent.gradient_color =
          static_cast<int>(AcrylicTintForEffect(desktop_effect_));
    } else {
      accent.accent_state = ACCENT_DISABLED;
      accent.accent_flags = 0;
      accent.gradient_color = 0;
    }

    WINDOWCOMPOSITIONATTRIBDATA data = {};
    data.attribute = kWindowCompositionAccentPolicy;
    data.data = &accent;
    data.size_of_data = sizeof(accent);
    set_window_composition_attribute(window, &data);
  }
}

void Win32Window::AddTrayIcon(HWND const window) {
  if (tray_icon_added_) {
    return;
  }

  NOTIFYICONDATAW data = {};
  data.cbSize = sizeof(NOTIFYICONDATAW);
  data.hWnd = window;
  data.uID = kTrayIconId;
  data.uFlags = NIF_MESSAGE | NIF_ICON | NIF_TIP;
  data.uCallbackMessage = kTrayIconMessage;
  data.hIcon = LoadIcon(GetModuleHandle(nullptr), MAKEINTRESOURCE(IDI_APP_ICON));
  wcscpy_s(data.szTip, L"Innocence");

  if (Shell_NotifyIconW(NIM_ADD, &data)) {
    data.uVersion = NOTIFYICON_VERSION_4;
    Shell_NotifyIconW(NIM_SETVERSION, &data);
    tray_icon_added_ = true;
  }
}

void Win32Window::RemoveTrayIcon(HWND const window) {
  if (!tray_icon_added_) {
    return;
  }

  NOTIFYICONDATAW data = {};
  data.cbSize = sizeof(NOTIFYICONDATAW);
  data.hWnd = window;
  data.uID = kTrayIconId;
  Shell_NotifyIconW(NIM_DELETE, &data);
  tray_icon_added_ = false;
}

RECT Win32Window::GetMonitorWorkArea(HWND const window) const {
  RECT work_area = {};
  HMONITOR monitor = MonitorFromWindow(window, MONITOR_DEFAULTTONEAREST);
  MONITORINFO monitor_info = {};
  monitor_info.cbSize = sizeof(MONITORINFO);
  if (GetMonitorInfo(monitor, &monitor_info)) {
    return monitor_info.rcWork;
  }

  SystemParametersInfo(SPI_GETWORKAREA, 0, &work_area, 0);
  return work_area;
}

void Win32Window::UpdateStoredWidgetPosition(HWND const window) {
  RECT window_rect = {};
  if (!GetWindowRect(window, &window_rect)) {
    return;
  }

  widget_x_ = window_rect.left;
  widget_y_ = window_rect.top;
  has_custom_position_ = true;
}

void Win32Window::SnapWidgetToWorkArea(HWND const window) {
  if (window_mode_ != "widget" && window_mode_ != "mini") {
    return;
  }

  RECT work_area = GetMonitorWorkArea(window);
  RECT window_rect = {};
  if (!GetWindowRect(window, &window_rect)) {
    return;
  }

  int target_x = window_rect.left;
  int target_y = window_rect.top;
  const int current_width =
      window_mode_ == "mini" ? kMiniWidgetWidth : widget_width_;
  const int current_height =
      window_mode_ == "mini" ? kMiniWidgetHeight : widget_height_;
  const int max_x = std::max(work_area.left, work_area.right - current_width);
  const int max_y = std::max(work_area.top, work_area.bottom - current_height);

  const int right_anchor =
      work_area.right - current_width - kWidgetMarginRight;
  const int left_anchor = work_area.left + kWidgetMarginRight;
  const int top_anchor = work_area.top + kWidgetMarginTop;

  if (std::abs(window_rect.left - left_anchor) <= kWidgetSnapThreshold) {
    target_x = left_anchor;
  } else if (std::abs(window_rect.left - right_anchor) <= kWidgetSnapThreshold) {
    target_x = right_anchor;
  }

  if (std::abs(window_rect.top - top_anchor) <= kWidgetSnapThreshold) {
    target_y = top_anchor;
  }

  target_x = ClampInt(target_x, static_cast<int>(work_area.left), max_x);
  target_y = ClampInt(target_y, static_cast<int>(work_area.top), max_y);

  updating_window_position_ = true;
  SetWindowPos(window, always_on_top_ ? HWND_TOPMOST : HWND_NOTOPMOST, target_x,
               target_y, current_width, current_height,
               SWP_NOACTIVATE | SWP_SHOWWINDOW | SWP_FRAMECHANGED);
  updating_window_position_ = false;

  widget_x_ = target_x;
  widget_y_ = target_y;
  has_custom_position_ = true;
}

void Win32Window::PositionAuthWindow(HWND const window) {
  if (window_mode_ == "page") {
    PositionPageWindow(window);
    return;
  }

  if (window_mode_ == "auth" && has_custom_auth_bounds_) {
    SetWindowPos(window, always_on_top_ ? HWND_TOPMOST : HWND_NOTOPMOST, 0, 0,
                 0, 0,
                 SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE |
                     SWP_SHOWWINDOW | SWP_FRAMECHANGED);
    return;
  }

  const HWND insert_after = always_on_top_ ? HWND_TOPMOST : HWND_NOTOPMOST;
  RECT work_area = GetMonitorWorkArea(window);
  const int work_width = static_cast<int>(work_area.right - work_area.left);
  const int work_height = static_cast<int>(work_area.bottom - work_area.top);
  const int auth_x = static_cast<int>(work_area.left) +
                     std::max(0, (work_width - kAuthWidth) / 2);
  const int auth_y = static_cast<int>(work_area.top) +
                     std::max(0, (work_height - kAuthHeight) / 2);

  updating_window_position_ = true;
  SetWindowPos(window, insert_after, auth_x, auth_y, kAuthWidth, kAuthHeight,
               SWP_NOACTIVATE | SWP_SHOWWINDOW | SWP_FRAMECHANGED);
  updating_window_position_ = false;
}

void Win32Window::PositionPageWindow(HWND const window) {
  if (has_custom_auth_bounds_) {
    updating_window_position_ = true;
    SetWindowPos(window, always_on_top_ ? HWND_TOPMOST : HWND_NOTOPMOST, page_x_,
                 page_y_, page_width_, page_height_,
                 SWP_NOACTIVATE | SWP_SHOWWINDOW | SWP_FRAMECHANGED);
    updating_window_position_ = false;
    return;
  }

  const HWND insert_after = always_on_top_ ? HWND_TOPMOST : HWND_NOTOPMOST;
  RECT work_area = GetMonitorWorkArea(window);
  const int work_width = static_cast<int>(work_area.right - work_area.left);
  const int work_height = static_cast<int>(work_area.bottom - work_area.top);
  const int target_width = page_width_;
  const int target_height = page_height_;
  const int auth_x = static_cast<int>(work_area.left) +
                     std::max(0, (work_width - target_width) / 2);
  const int auth_y = static_cast<int>(work_area.top) +
                     std::max(0, (work_height - target_height) / 2);

  updating_window_position_ = true;
  SetWindowPos(window, insert_after, auth_x, auth_y, target_width, target_height,
               SWP_NOACTIVATE | SWP_SHOWWINDOW | SWP_FRAMECHANGED);
  updating_window_position_ = false;

  page_x_ = auth_x;
  page_y_ = auth_y;
  page_width_ = target_width;
  page_height_ = target_height;
  has_custom_auth_bounds_ = true;
  SaveWindowState();
}

void Win32Window::PositionDesktopWidget(HWND const window, int logical_height) {
  const HWND insert_after = always_on_top_ ? HWND_TOPMOST : HWND_NOTOPMOST;
  RECT work_area = GetMonitorWorkArea(window);
  const int target_width = ClampInt(widget_width_, kWidgetMinWidth, kWidgetMaxWidth);
  int widget_x = work_area.right - target_width - kWidgetMarginRight;
  int widget_y = work_area.top + kWidgetMarginTop;

  if (has_custom_position_) {
    const int max_x = std::max(work_area.left, work_area.right - target_width);
    const int max_y = std::max(work_area.top, work_area.bottom - logical_height);
    widget_x = ClampInt(widget_x_, static_cast<int>(work_area.left), max_x);
    widget_y = ClampInt(widget_y_, static_cast<int>(work_area.top), max_y);
  }

  updating_window_position_ = true;
  SetWindowPos(window, insert_after, widget_x, widget_y, target_width,
               logical_height,
               SWP_NOACTIVATE | SWP_SHOWWINDOW | SWP_FRAMECHANGED);
  updating_window_position_ = false;

  widget_width_ = target_width;
  widget_x_ = widget_x;
  widget_y_ = widget_y;
  if (!has_custom_position_) {
    has_custom_position_ = true;
  }
  has_custom_widget_size_ = true;
  SaveWindowState();
}

void Win32Window::PositionMiniWidget(HWND const window) {
  const HWND insert_after = always_on_top_ ? HWND_TOPMOST : HWND_NOTOPMOST;
  RECT work_area = GetMonitorWorkArea(window);
  int widget_x = work_area.right - kMiniWidgetWidth - kWidgetMarginRight;
  int widget_y = work_area.top + kWidgetMarginTop;

  if (has_custom_position_) {
    const int max_x = std::max(
        static_cast<int>(work_area.left),
        static_cast<int>(work_area.right) - kMiniWidgetWidth);
    const int max_y = std::max(
        static_cast<int>(work_area.top),
        static_cast<int>(work_area.bottom) - kMiniWidgetHeight);
    widget_x = ClampInt(widget_x_, static_cast<int>(work_area.left), max_x);
    widget_y = ClampInt(widget_y_, static_cast<int>(work_area.top), max_y);
  }

  updating_window_position_ = true;
  SetWindowPos(window, insert_after, widget_x, widget_y, kMiniWidgetWidth,
               kMiniWidgetHeight,
               SWP_NOACTIVATE | SWP_SHOWWINDOW | SWP_FRAMECHANGED);
  updating_window_position_ = false;

  widget_x_ = widget_x;
  widget_y_ = widget_y;
  if (!has_custom_position_) {
    has_custom_position_ = true;
  }
  SaveWindowState();
}

void Win32Window::UpdateTopMostState() {
  if (window_handle_ == nullptr) {
    return;
  }

  SetWindowPos(window_handle_, always_on_top_ ? HWND_TOPMOST : HWND_NOTOPMOST, 0,
               0, 0, 0,
               SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE | SWP_NOOWNERZORDER);
}

void Win32Window::LoadWindowState() {
  if (window_state_loaded_) {
    return;
  }

  window_state_loaded_ = true;
  HKEY state_key = nullptr;
  if (RegOpenKeyExW(HKEY_CURRENT_USER, kWindowStateRegKey, 0, KEY_QUERY_VALUE,
                    &state_key) != ERROR_SUCCESS) {
    return;
  }

  auto read_dword = [&](const wchar_t* name, DWORD& value) -> bool {
    DWORD type = REG_DWORD;
    DWORD size = sizeof(DWORD);
    return RegQueryValueExW(state_key, name, nullptr, &type,
                            reinterpret_cast<LPBYTE>(&value),
                            &size) == ERROR_SUCCESS &&
           type == REG_DWORD;
  };

  DWORD stored_value = 0;
  if (read_dword(L"WidgetHeight", stored_value)) {
    widget_height_ =
        ClampInt(static_cast<int>(stored_value), kWidgetMinHeight, kWidgetMaxHeight);
  }
  if (read_dword(L"WidgetWidth", stored_value)) {
    widget_width_ =
        ClampInt(static_cast<int>(stored_value), kWidgetMinWidth, kWidgetMaxWidth);
    has_custom_widget_size_ = true;
    lock_widget_size_to_content_ = false;
  } else {
    widget_width_ = kWidgetWidth;
  }
  if (read_dword(L"WidgetX", stored_value)) {
    widget_x_ = static_cast<int>(stored_value);
    has_custom_position_ = true;
  }
  if (read_dword(L"WidgetY", stored_value)) {
    widget_y_ = static_cast<int>(stored_value);
    has_custom_position_ = true;
  }
  if (!has_custom_widget_size_) {
    lock_widget_size_to_content_ = true;
  }
  if (read_dword(L"PageWidth", stored_value)) {
    page_width_ = ClampInt(static_cast<int>(stored_value), kPageMinWidth, 4096);
  } else {
    page_width_ = kPageDefaultWidth;
  }
  if (read_dword(L"PageHeight", stored_value)) {
    page_height_ =
        ClampInt(static_cast<int>(stored_value), kPageMinHeight, 4096);
  } else {
    page_height_ = kPageDefaultHeight;
  }
  if (read_dword(L"PageX", stored_value)) {
    page_x_ = static_cast<int>(stored_value);
    has_custom_auth_bounds_ = true;
  }
  if (read_dword(L"PageY", stored_value)) {
    page_y_ = static_cast<int>(stored_value);
    has_custom_auth_bounds_ = true;
  }

  RegCloseKey(state_key);
}

void Win32Window::SaveWindowState() const {
  HKEY state_key = nullptr;
  if (RegCreateKeyExW(HKEY_CURRENT_USER, kWindowStateRegKey, 0, nullptr, 0,
                      KEY_SET_VALUE, nullptr, &state_key, nullptr) !=
      ERROR_SUCCESS) {
    return;
  }

  auto write_dword = [&](const wchar_t* name, DWORD value) {
    RegSetValueExW(state_key, name, 0, REG_DWORD,
                   reinterpret_cast<const BYTE*>(&value), sizeof(DWORD));
  };

  write_dword(L"WidgetWidth", static_cast<DWORD>(widget_width_));
  write_dword(L"WidgetHeight", static_cast<DWORD>(widget_height_));
  write_dword(L"WidgetX", static_cast<DWORD>(widget_x_));
  write_dword(L"WidgetY", static_cast<DWORD>(widget_y_));
  write_dword(L"PageWidth", static_cast<DWORD>(page_width_));
  write_dword(L"PageHeight", static_cast<DWORD>(page_height_));
  write_dword(L"PageX", static_cast<DWORD>(page_x_));
  write_dword(L"PageY", static_cast<DWORD>(page_y_));

  RegCloseKey(state_key);
}
