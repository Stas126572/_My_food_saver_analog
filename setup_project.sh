#!/bin/bash

# Удаляем старое, если мешает, и создаем чистое дерево
rm -rf app .github
mkdir -p app/src/main/assets
mkdir -p app/src/main/java/com/example/wasm
mkdir -p .github/workflows

# Файлы настроек
cat <<EOF > settings.gradle
rootProject.name = "MyWasmApp"
include ':app'
EOF

cat <<EOF > build.gradle
buildscript {
    repositories { google(); mavenCentral() }
    dependencies { classpath 'com.android.tools.build:gradle:8.1.0' }
}
allprojects {
    repositories { google(); mavenCentral() }
}
EOF

cat <<EOF > app/build.gradle
plugins { id 'com.android.application' }
android {
    namespace 'com.example.wasm'
    compileSdk 33
    defaultConfig {
        applicationId "com.example.wasm"
        minSdk 24
        targetSdk 33
        versionCode 1
        versionName "1.0"
    }
}
EOF

# Манифест
cat <<EOF > app/src/main/AndroidManifest.xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://android.com">
    <application android:label="Wasm App" android:hasCode="true">
        <activity android:name=".MainActivity" android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
EOF

# Java код
cat <<EOF > app/src/main/java/com/example/wasm/MainActivity.java
package com.example.wasm;
import android.app.Activity;
import android.os.Bundle;
import android.webkit.WebView;
import android.webkit.WebSettings;

public class MainActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        WebView v = new WebView(this);
        WebSettings s = v.getSettings();
        s.setJavaScriptEnabled(true);
        s.setAllowFileAccess(true);
        s.setAllowUniversalAccessFromFileURLs(true);
        setContentView(v);
        v.loadUrl("file:///android_asset/index.html");
    }
}
EOF

# GitHub Action
cat <<EOF > .github/workflows/android.yml
name: Build APK
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: set up JDK 17
        uses: actions/setup-java@v4
        with:
          java-version: '17'
          distribution: 'temurin'
      - name: Setup Gradle
        run: gradle wrapper
      - name: Build APK
        run: ./gradlew assembleDebug
      - name: Upload APK
        uses: actions/upload-artifact@v4
        with:
          name: my-apk
          path: app/build/outputs/apk/debug/app-debug.apk
EOF

echo "Done! Папки и конфиги созданы."
