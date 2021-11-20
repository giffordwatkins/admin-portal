# eFinance

<p align="center">
    <img src="https://github.com/invoiceninja/flutter-mobile/blob/master/samples/screenshots/1.png" alt="Dashboard" width="200"/>
    <img src="https://github.com/invoiceninja/flutter-mobile/blob/master/samples/screenshots/2.png" alt="View Invoice" width="200"/>
    <img src="https://github.com/invoiceninja/flutter-mobile/blob/master/samples/screenshots/3.png" alt="List Invoice" width="200"/>
    <img src="https://github.com/invoiceninja/flutter-mobile/blob/master/samples/screenshots/4.png" alt="New Invoice" width="200"/>
</p>

## Setting up the app

- Initialize the config file

    `cp lib/.env.dart.example lib/.env.dart`

- Support running the code unsigned on Android

    `cp android/app/build.gradle.dev android/app/build.gradle`

- Run the app

    `flutter run`

## Code generation
- Run `flutter packages pub run build_runner build --delete-conflicting-outputs` to regenerate the model files. It will also remove the old generated files so conflicts are avoided..

## Tests
- Run `flutter drive --target=test_driver/all_it.dart` to run the tests
    
## Code Signing
- Run `cp android/app/build.gradle.prod android/app/build.gradle` to support running the code signed
- Run `cp android/key.properties.example android/key.properties` to create the keys file
- Run `keytool -genkey -v -keystore key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias invoiceninja` to generate a key to be able to sign the android application.
- Update `android/key.properties` according to the parameters you entered in previous command when you generated the key 
- Open a new Firebase project from your console. Firebase is used for authentication.
    - Inside the project go to Authentication and enable at least one method.
    - After go to add a new Android application. For the package name add `com.invoiceninja.flutter`
    - Press "Register App" button.
    - Download "google-services.json" and put it in `android/app` directory.
