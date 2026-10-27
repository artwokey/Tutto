package com.rene.tutto;

import android.app.Activity;
import android.graphics.Color;
import android.graphics.Insets;
import android.os.Build;
import android.os.Bundle;
import android.view.View;
import android.view.WindowInsets;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.FrameLayout;
import android.window.OnBackInvokedCallback;
import android.window.OnBackInvokedDispatcher;

/**
 * Punktezähler für Tutto — schlanke WebView-Hülle, die den Punkteblock aus den App-Assets lädt.
 * Der Spielstand liegt im localStorage der WebView und bleibt so erhalten.
 */
public class MainActivity extends Activity {

    private static final int FELT = Color.rgb(15, 61, 46);   // #0f3d2e
    private WebView web;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        if (Build.VERSION.SDK_INT >= 21) {
            getWindow().setStatusBarColor(FELT);
            getWindow().setNavigationBarColor(FELT);
        }

        web = new WebView(this);
        web.setBackgroundColor(FELT);
        WebSettings s = web.getSettings();
        s.setJavaScriptEnabled(true);
        s.setDomStorageEnabled(true);                       // localStorage
        s.setAllowFileAccess(true);
        s.setTextZoom(100);                                 // System-Schriftgröße bricht das Layout nicht

        web.setWebViewClient(new WebViewClient());
        web.setWebChromeClient(new WebChromeClient());

        // Ab Android 15 zeichnet die App randlos: Status-/Navigationsleiste und Tastatur freihalten
        FrameLayout root = new FrameLayout(this);
        root.setBackgroundColor(FELT);
        root.addView(web);
        if (Build.VERSION.SDK_INT >= 35) {
            root.setOnApplyWindowInsetsListener(new View.OnApplyWindowInsetsListener() {
                @Override
                public WindowInsets onApplyWindowInsets(View v, WindowInsets insets) {
                    Insets i = insets.getInsets(WindowInsets.Type.systemBars()
                            | WindowInsets.Type.displayCutout() | WindowInsets.Type.ime());
                    v.setPadding(i.left, i.top, i.right, i.bottom);
                    return WindowInsets.CONSUMED;
                }
            });
        }
        setContentView(root);

        // Ab Android 13 kommt die Zurück-Geste hierüber (onBackPressed wird ab Ziel-API 36 nicht mehr gerufen)
        if (Build.VERSION.SDK_INT >= 33) {
            getOnBackInvokedDispatcher().registerOnBackInvokedCallback(
                    OnBackInvokedDispatcher.PRIORITY_DEFAULT,
                    new OnBackInvokedCallback() {
                        @Override
                        public void onBackInvoked() { handleBack(); }
                    });
        }

        if (savedInstanceState == null) {
            web.loadUrl("file:///android_asset/app/index.html");
        }
    }

    @Override
    protected void onSaveInstanceState(Bundle outState) {
        super.onSaveInstanceState(outState);
        web.saveState(outState);
    }

    @Override
    protected void onRestoreInstanceState(Bundle savedInstanceState) {
        super.onRestoreInstanceState(savedInstanceState);
        web.restoreState(savedInstanceState);
    }

    @Override
    public void onBackPressed() {
        handleBack();
    }

    // Zurück zuerst an die Web-App geben (Dialog schließen, Menü öffnen …), sonst App schließen
    private void handleBack() {
        web.evaluateJavascript("window.tuttoBack ? String(window.tuttoBack()) : 'false'", new ValueCallback<String>() {
            @Override
            public void onReceiveValue(String handled) {
                if (!"\"true\"".equals(handled)) finish();
            }
        });
    }
}
