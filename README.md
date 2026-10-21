# ChatGPT Watch Bridge

An Android proof of concept for watches that send `android.intent.action.VOICE_COMMAND` through the Android Bluetooth stack. When selected in Android's voice-command chooser, the bridge launches ChatGPT's declared `android.intent.action.ASSIST` entry point.

## What it demonstrates

- A TJ08/P125-style watch trigger can reach a normal Android activity without modifying watch firmware or Da Fit.
- An app can register as a `VOICE_COMMAND` handler alongside Google and Alexa.
- ChatGPT can be selected as Android's Digital Assistant and exposes a bound `VoiceInteractionService`.

## Important limitation

This does **not** start a ChatGPT Voice conversation automatically. The installed ChatGPT app does not expose a documented third-party action for "start Voice," and its Voice control was not available as an accessibility node during testing. The bridge intentionally avoids screen-coordinate tapping and UI injection.

The watch-trigger chooser is owned by Android Bluetooth. On some devices it does not offer a persistent default selection, so the user may have to select **ChatGPT Watch Bridge** for each trigger.

## Privacy and scope

The bridge declares no runtime permissions. It has no networking, audio capture, storage, accessibility service, or Da Fit integration. It does not modify ChatGPT, Da Fit, or watch firmware.

## Install

Build and install a signed debug APK, then trigger the watch voice action and select **ChatGPT Watch Bridge** in Android's chooser.

The included `build.ps1` was used with Android SDK Build Tools 35, Android API 35, and JDK 25. It is a local development helper rather than a reproducible release pipeline.

## Project layout

```
app/                         Android manifest, Java activity, and resources
build.ps1                    Local manual APK build helper
```

## Status

Proof of concept complete for the Bluetooth-to-Android handoff. Automatic in-app ChatGPT Voice launch remains unresolved without a supported ChatGPT intent.
