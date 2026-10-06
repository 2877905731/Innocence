<p align="center">
  <img src="docs/design/logo/innocence-logo-v1-cutout.png" alt="Innocence Logo" width="180">
</p>

<h1 align="center">Innocence</h1>

<p align="center">A cross-platform companion for learning, self-discipline, focus, and teamwork</p>

<p align="center">
  <a href="README.md">简体中文</a> · <a href="README_EN.md">English</a>
</p>

<p align="center">
  <a href="LICENSE"><img src="https://img.shields.io/badge/license-AGPL--3.0-blue" alt="License: AGPL-3.0"></a>
  <img src="https://img.shields.io/badge/Flutter-stable-02569B?logo=flutter&logoColor=white" alt="Flutter: stable">
  <img src="https://img.shields.io/badge/Dart-%3E%3D3.4-0175C2?logo=dart&logoColor=white" alt="Dart: >=3.4">
  <img src="https://img.shields.io/badge/Java-21-ED8B00?logo=openjdk&logoColor=white" alt="Java: 21">
  <img src="https://img.shields.io/badge/Spring_Boot-3.3.2-6DB33F?logo=springboot&logoColor=white" alt="Spring Boot: 3.3.2">
  <img src="https://img.shields.io/badge/platform-Windows%20%7C%20Android-lightgrey" alt="Platform: Windows and Android">
</p>

Innocence is built with Flutter and Spring Boot and currently targets Windows desktop and mobile devices.

## Download v1.2.3

| Platform | Download | Scope |
|---|---|---|
| Windows x64 | [Installer](https://github.com/2877905731/Innocence/releases/download/v1.2.3/Innocence-v1.2.3-windows-x64-setup.exe) · [Portable ZIP](https://github.com/2877905731/Innocence/releases/download/v1.2.3/Innocence-v1.2.3-windows-x64-portable.zip) | Desktop edition; installer has no Authenticode signature |
| Android 7.0+ | [Offline APK](https://github.com/2877905731/Innocence/releases/download/v1.2.3/Innocence-v1.2.3-android-offline.apk) | Dedicated release signature; improved focus layout; remains offline |
| HarmonyOS tablet preview | [ARM64 tablet / x64 emulator HAPs](https://github.com/2877905731/Innocence/releases/tag/v1.2.3-harmonyos-preview.1) | Unsigned Debug; physical devices require a matching device profile and signing |

[Release notes](https://github.com/2877905731/Innocence/releases/tag/v1.2.3) · [SHA256 checksums](https://github.com/2877905731/Innocence/releases/download/v1.2.3/SHA256SUMS.txt) · [Changelog](CHANGELOG.md)

v1.2.3 refreshes Minimal White, focus dials, and the Android focus card. Windows adds a bring-your-own-key chat assistant. Android retains the official release signature and supports an in-place upgrade from v1.2.2 while preserving local data; it remains an offline edition without INTERNET permission.

Choose a language and explicitly enter offline mode on first launch. Android supports daily plans with a 24-hour clock picker, a full monthly calendar with batch templates, annual tasks and subtasks, focus, statistics, memos, and local settings. Data stays on the device and is removed by uninstalling or clearing app data. Earlier development APKs use a different signature and cannot be upgraded directly. Physical-device/OEM/Vulkan checks and online synchronization remain in progress.

## Current Status

- Adaptive Large, Medium, and Small Windows canvases with a Focus Orb.
- The official Innocence logo is used by Windows and Android.
- Windows retains Minimal White, Wabi-Sabi, Mid-Century Modern, and Liquid Glass themes. Android includes Minimal White and Liquid Glass visuals with Material 3 interaction components.
- A signed Android offline edition is available, including daily time ranges selected on a 24-hour clock.
- Core interaction foundations for authentication, profiles, settings, memos, statistics, notifications, friends, and teams.
- Backend business data is isolated by the currently authenticated user.
- Windows chat supports model discovery from an address and key, plus confirmed local actions. Live-provider and complete device checks remain pending.
- HarmonyOS tablets have an [unsigned development preview](https://github.com/2877905731/Innocence/releases/tag/v1.2.3-harmonyos-preview.1) with the full-screen PC layout. Physical-device signing, input, and business-data recovery remain pending.

## Repository Layout

```text
client/flutter_app/       Flutter client
server/innocence-server/  Spring Boot backend
docs/                     Product, contract, and troubleshooting documentation
infra/docker/             Local MySQL and Redis infrastructure
progress/                 Project progress and checkpoints
```

## Technology Stack

- Client: Flutter, Dart, Material 3, and shared_preferences
- Backend: Java 21, Spring Boot 3.3.2, MyBatis, MySQL 8, and Redis
- Platforms: Windows and Android

## Local Development

### Start the dependencies

From `infra/docker`, start `docker-compose.dev.yml`. The default ports are MySQL `3306` and Redis `6379`.

### Start the backend

```bash
cd server/innocence-server
mvn spring-boot:run
```

Java 21 and Maven 3.9 or later are required. The mail password is supplied through the `INNOCENCE_MAIL_PASSWORD` environment variable.

### Start the client

```bash
cd client/flutter_app
flutter pub get
flutter run -d windows
```

Build the Windows release:

```bash
flutter build windows --release
```

The output is written to `build/windows/x64/runner/Release/`.

## Documentation

- [Documentation index](docs/README.md)
- [Project plan](docs/planning/Innocence-项目计划书.md)
- [Windows adaptive desktop experience](docs/planning/Innocence-Windows自适应桌面体验.md)
- [Troubleshooting stale frontend changes](docs/troubleshooting/Innocence-前端修改未生效排查.md)

## License

Innocence is distributed under the [GNU Affero General Public License v3.0](LICENSE).

## Project

[github.com/2877905731/Innocence](https://github.com/2877905731/Innocence)
