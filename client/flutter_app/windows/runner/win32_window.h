#ifndef RUNNER_WIN32_WINDOW_H_
#define RUNNER_WIN32_WINDOW_H_

#include <windows.h>

#include <functional>
#include <memory>
#include <string>

// A class abstraction for a high DPI-aware Win32 Window. Intended to be
// inherited from by classes that wish to specialize with custom
// rendering and input handling
class Win32Window {
 public:
  struct Point {
    unsigned int x;
    unsigned int y;
    Point(unsigned int x, unsigned int y) : x(x), y(y) {}
  };

  struct Size {
    unsigned int width;
    unsigned int height;
    Size(unsigned int width, unsigned int height)
        : width(width), height(height) {}
  };

  Win32Window();
  virtual ~Win32Window();

  // Creates a win32 window with |title| that is positioned and sized using
  // |origin| and |size|. New windows are created on the default monitor. Window
  // sizes are specified to the OS in physical pixels, hence to ensure a
  // consistent size this function will scale the inputted width and height as
  // as appropriate for the default monitor. The window is invisible until
  // |Show| is called. Returns true if the window was created successfully.
  bool Create(const std::wstring& title, const Point& origin, const Size& size);

  // Show the current window. Returns true if the window was successfully shown.
  bool Show();

  // Release OS resources associated with window.
  void Destroy();

  // Inserts |content| into the window tree.
  void SetChildContent(HWND content);

  // Returns the backing Window handle to enable clients to set icon and other
  // window properties. Returns nullptr if the window has been destroyed.
  HWND GetHandle();

  // Update whether the window should stay above other windows.
  void SetAlwaysOnTop(bool always_on_top);

  // Update the native desktop shell effect.
  void SetDesktopEffect(const std::string& desktop_effect);

  // Resize the desktop widget while keeping it anchored to the top-right.
  void SetWidgetHeight(int logical_height);

  // Switch between the wider auth window and the compact desktop widget.
  void SetWindowMode(const std::string& mode);

  // Start dragging the widget from a Flutter-defined drag region.
  void BeginWindowDrag();

  // Return the widget to its default anchored position.
  void ResetWidgetPosition();

  // Hide the window while keeping the tray icon alive.
  void HideWindowToTray();

  // If true, closing this window will quit the application.
  void SetQuitOnClose(bool quit_on_close);

  // Return a RECT representing the bounds of the current client area.
  RECT GetClientArea();

 protected:
  // Processes and route salient window messages for mouse handling,
  // size change and DPI. Delegates handling of these to member overloads that
  // inheriting classes can handle.
  virtual LRESULT MessageHandler(HWND window,
                                 UINT const message,
                                 WPARAM const wparam,
                                 LPARAM const lparam) noexcept;

  // Called when CreateAndShow is called, allowing subclass window-related
  // setup. Subclasses should return false if setup fails.
  virtual bool OnCreate();

  // Called when Destroy is called.
  virtual void OnDestroy();

  // Called whenever the native window mode changes.
  virtual void OnWindowModeChanged(const std::string& mode) {}

 private:
  friend class WindowClassRegistrar;

  // OS callback called by message pump. Handles the WM_NCCREATE message which
  // is passed when the non-client area is being created and enables automatic
  // non-client DPI scaling so that the non-client area automatically
  // responds to changes in DPI. All other messages are handled by
  // MessageHandler.
  static LRESULT CALLBACK WndProc(HWND const window,
                                  UINT const message,
                                  WPARAM const wparam,
                                  LPARAM const lparam) noexcept;

  // Retrieves a class instance pointer for |window|
  static Win32Window* GetThisFromHandle(HWND const window) noexcept;

  // Update the window frame's theme to match the system theme.
  static void UpdateTheme(HWND const window);

  // Apply the desktop style, including rounded corners and backdrop.
  void ApplyDesktopWidgetChrome(HWND const window);

  void ApplyDesktopBackdrop(HWND const window);
  void AddTrayIcon(HWND const window);
  void RemoveTrayIcon(HWND const window);
  void PositionAuthWindow(HWND const window);
  void PositionPageWindow(HWND const window);
  void PositionDesktopWidget(HWND const window, int logical_height);
  void PositionMiniWidget(HWND const window);
  void UpdateWindowFrame(HWND const window);
  RECT GetMonitorWorkArea(HWND const window) const;
  void SnapWidgetToWorkArea(HWND const window);
  void UpdateStoredWidgetPosition(HWND const window);
  void LoadWindowState();
  void SaveWindowState() const;

  void UpdateTopMostState();

  bool quit_on_close_ = false;
  bool always_on_top_ = true;
  std::string window_mode_ = "auth";
  std::string desktop_effect_ = "immersive_glass";
  int widget_width_ = 560;
  int widget_height_ = 920;
  bool has_custom_position_ = false;
  bool has_custom_auth_bounds_ = false;
  bool has_custom_widget_size_ = false;
  bool lock_widget_size_to_content_ = true;
  bool window_state_loaded_ = false;
  bool dragging_widget_ = false;
  bool updating_window_position_ = false;
  bool tray_icon_added_ = false;
  int widget_x_ = 0;
  int widget_y_ = 0;
  int page_width_ = 1260;
  int page_height_ = 860;
  int page_x_ = 0;
  int page_y_ = 0;

  // window handle for top level window.
  HWND window_handle_ = nullptr;

  // window handle for hosted content.
  HWND child_content_ = nullptr;
};

#endif  // RUNNER_WIN32_WINDOW_H_
