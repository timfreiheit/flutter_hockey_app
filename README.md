# flutter_hockey_app

Flutter Hockey App Plugin

## Integration

add the packages to your dependencies.
At the moment ``` pub ``` is not supported

```
dependencies:
    flutter_hockey_app:
        git: git@github.com:timfreiheit/flutter_hockey_app.git
```

main.dart:
```dart
import 'package:flutter_hockey_app/flutter_hockey_app.dart';

void main() {
  HockeyAppClient.init(appId: "XXXXX");
  HockeyAppClient.runInZone(() {
    runApp(new MyApp());
  });
}


```

``` HockeyAppClient.init("XXX") ``` is optional if you prefer to initialize the native HockeyAppSDK in platform specific code.

