package com.example.whs_after_mate.ui.onboarding;

import android.view.View;

import androidx.annotation.NonNull;
import androidx.viewpager2.widget.ViewPager2;

public class ZoomFadePageTransformer implements ViewPager2.PageTransformer {

    private static final float MIN_SCALE = 0.85f;
    private static final float MIN_ALPHA = 0.5f;

    @Override
    public void transformPage(@NonNull View view, float position) {
        if (position < -1 || position > 1) {
            view.setAlpha(0f);
            return;
        }

        float scaleFactor = Math.max(MIN_SCALE, 1 - Math.abs(position));
        float vertMargin = view.getHeight() * (1 - scaleFactor) / 2;
        float horzMargin = view.getWidth() * (1 - scaleFactor) / 2;
        view.setTranslationX(position < 0 ? horzMargin - vertMargin / 2 : -horzMargin + vertMargin / 2);
        view.setScaleX(scaleFactor);
        view.setScaleY(scaleFactor);
        view.setAlpha(MIN_ALPHA + (scaleFactor - MIN_SCALE) / (1 - MIN_SCALE) * (1 - MIN_ALPHA));
    }
}
