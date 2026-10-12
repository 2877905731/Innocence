cmake_minimum_required(VERSION 3.14)
project(focus_notice_native_test LANGUAGES CXX RC)

get_filename_component(APP_DIR "${CMAKE_CURRENT_LIST_DIR}/../../.." ABSOLUTE)
set(FLUTTER_DIR "${APP_DIR}/windows/flutter/ephemeral")
file(WRITE "${CMAKE_CURRENT_BINARY_DIR}/focus_notice_icon.rc"
  "101 ICON \"${APP_DIR}/windows/runner/resources/app_icon.ico\"\n")
add_executable(focus_notice_native_test
  focus_notice_native_test.cpp
  "${CMAKE_CURRENT_BINARY_DIR}/focus_notice_icon.rc"
  "${APP_DIR}/windows/runner/win32_window.cpp")
target_compile_features(focus_notice_native_test PRIVATE cxx_std_17)
target_compile_definitions(focus_notice_native_test PRIVATE UNICODE _UNICODE NOMINMAX)
target_include_directories(focus_notice_native_test PRIVATE
  "${APP_DIR}/windows/runner" "${FLUTTER_DIR}")
target_link_libraries(focus_notice_native_test PRIVATE
  "${FLUTTER_DIR}/flutter_windows.dll.lib" dwmapi shell32 advapi32)
add_custom_command(TARGET focus_notice_native_test POST_BUILD
  COMMAND ${CMAKE_COMMAND} -E copy_if_different
  "${FLUTTER_DIR}/flutter_windows.dll"
  "$<TARGET_FILE_DIR:focus_notice_native_test>")
