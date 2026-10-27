package com.rene.tutto;

import android.app.Activity;
import android.graphics.Color;
import android.os.Build;
import android.os.Bundle;
import android.webkit.ValueCallback;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

/**
 * Tutto — schlanke WebView-Hülle, die den Punkteblock aus den App-Assets lädt.
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

        setContentView(web);

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

    // Zurück-Taste zuerst an die Web-App geben (Dialog schließen, Menü öffnen …)
    @Override
    public void onBackPressed() {
        web.evaluateJavascript("window.tuttoBack ? String(window.tuttoBack()) : 'false'", new ValueCallback<String>() {
            @Override
            public void onReceiveValue(String handled) {
                if (!"\"true\"".equals(handled)) MainActivity.super.onBackPressed();
            }
        });
    }
}
