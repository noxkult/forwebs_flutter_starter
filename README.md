# forwebs_flutter_starter

재사용 가능한 Flutter 공용 기능 모음입니다.

## 다른 프로젝트에서 사용하기

`pubspec.yaml`에 Git dependency를 추가합니다.

```yaml
dependencies:
  forwebs_flutter_starter:
    git:
      url: https://github.com/noxkult/forwebs_flutter_starter.git
      ref: main
```

```bash
flutter pub get
```

## WebView 사용법

```dart
import 'package:flutter/material.dart';
import 'package:forwebs_flutter_starter/forwebs_flutter_starter.dart';

Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => const WebViewScreen(
      url: 'https://example.com/terms',
    ),
  ),
);
```

`WebViewScreen`은 HTTP/HTTPS URL을 전체 화면으로 표시하며, 로딩 상태,
오류 및 다시 시도, WebView 내부 뒤로가기를 기본으로 처리합니다.

## Android 설정

사용하는 앱의 `android/app/src/main/AndroidManifest.xml`에 인터넷 권한이
없다면 추가합니다.

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

## iOS 설정

HTTPS 주소는 별도 설정 없이 사용할 수 있습니다. HTTP 주소를 사용한다면
iOS의 App Transport Security 설정이 추가로 필요할 수 있습니다.
