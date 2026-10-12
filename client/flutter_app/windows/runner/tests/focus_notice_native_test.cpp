#include "win32_window.h"

#include <shellapi.h>
#include <iostream>

// Exercise the production notification code. Never inject a balloon event or
// read other applications' notifications; observe only this fixture's callback.
class FocusNoticeWindow : public Win32Window {
 public:
  bool shown = false;
  bool hidden = false;

 protected:
  bool OnCreate() override { return true; }

  LRESULT MessageHandler(HWND window, UINT message, WPARAM wparam,
                         LPARAM lparam) noexcept override {
    // The fixture must not read or overwrite the user's saved window bounds.
    if (message == WM_MOVE || message == WM_SIZE) {
      return DefWindowProc(window, message, wparam, lparam);
    }
    if (message == WM_APP + 1) {
      if (LOWORD(lparam) == NIN_BALLOONSHOW) shown = true;
      if (LOWORD(lparam) == NIN_BALLOONHIDE ||
          LOWORD(lparam) == NIN_BALLOONTIMEOUT) hidden = true;
    }
    return Win32Window::MessageHandler(window, message, wparam, lparam);
  }
};

int main() {
  QUERY_USER_NOTIFICATION_STATE state;
  if (SUCCEEDED(SHQueryUserNotificationState(&state))) {
    std::cout << "userNotificationState=" << state << std::endl;
  }
  FocusNoticeWindow window;
  if (window.ShowFocusCompletion(true)) {
    std::cerr << "FAIL: notification accepted without a native window\n";
    return 1;
  }
  if (!window.Create(L"Innocence notification QA", {20, 20}, {380, 520})) {
    std::cerr << "FAIL: native window creation\n";
    return 1;
  }
  ShowWindow(window.GetHandle(), SW_HIDE);
  const bool accepted = window.ShowFocusCompletion(true);
  std::cout << "notificationAccepted=" << accepted << std::endl;
  const auto deadline = GetTickCount64() + 15000;
  while (GetTickCount64() < deadline && !window.hidden) {
    MSG message;
    while (PeekMessage(&message, nullptr, 0, 0, PM_REMOVE)) {
      TranslateMessage(&message);
      DispatchMessage(&message);
    }
    MsgWaitForMultipleObjects(0, nullptr, FALSE, 50, QS_ALLINPUT);
  }
  std::cout << "systemBalloonShow=" << window.shown << std::endl;
  std::cout << "systemBalloonHideOrTimeout=" << window.hidden << std::endl;
  window.Destroy();
  if (!accepted || !window.shown) {
    std::cerr << "FAIL: the system did not report displaying this notification\n";
    return 1;
  }
  std::cout << "PASS: production Windows completion notification displayed\n";
  return 0;
}
