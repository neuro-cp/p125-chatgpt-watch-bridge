package local.watchbridge;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;

/**
 * Receives the watch's standard VOICE_COMMAND intent and foregrounds ChatGPT.
 */
public final class VoiceCommandBridgeActivity extends Activity {
    private static final String CHATGPT_PACKAGE = "com.openai.chatgpt";
    private static final String TAG = "ChatGPTWatchBridge";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        launchChatGpt();
    }

    @Override
    protected void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        launchChatGpt();
    }

    private void launchChatGpt() {
        try {
            startActivity(new Intent(Intent.ACTION_ASSIST).setPackage(CHATGPT_PACKAGE));
            Log.i(TAG, "Started ChatGPT assistant activity");
        } catch (RuntimeException failure) {
            Log.e(TAG, "Unable to start ChatGPT", failure);
        }
        // Keep this activity visible long enough for Android to commit the transition.
        new Handler(Looper.getMainLooper()).postDelayed(this::finish, 500);
    }
}
