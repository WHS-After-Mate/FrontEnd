package com.example.whs_after_mate.ui.onboarding;

import android.content.Intent;
import android.content.res.ColorStateList;
import android.os.Bundle;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.LinearLayout;

import androidx.appcompat.app.AppCompatActivity;
import androidx.core.content.ContextCompat;
import androidx.viewpager2.widget.ViewPager2;

import com.example.whs_after_mate.MainActivity;
import com.example.whs_after_mate.R;
import com.example.whs_after_mate.databinding.ActivityOnboardingBinding;

import java.util.ArrayList;
import java.util.List;

public class OnboardingActivity extends AppCompatActivity {

    private ActivityOnboardingBinding binding;
    private final List<ImageView> dots = new ArrayList<>();
    private int pageCount;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        binding = ActivityOnboardingBinding.inflate(getLayoutInflater());
        setContentView(binding.getRoot());

        List<OnboardingPagerAdapter.OnboardingPage> pages = new ArrayList<>();
        pages.add(new OnboardingPagerAdapter.OnboardingPage(
                R.drawable.img_onboarding_1,
                getString(R.string.onboarding_title_1),
                getString(R.string.onboarding_subtitle_1),
                true, false));
        pages.add(new OnboardingPagerAdapter.OnboardingPage(
                R.drawable.img_onboarding_2,
                getString(R.string.onboarding_title_2),
                getString(R.string.onboarding_subtitle_2),
                false, true));
        pages.add(new OnboardingPagerAdapter.OnboardingPage(
                R.drawable.img_onboarding_3,
                getString(R.string.onboarding_title_3),
                getString(R.string.onboarding_subtitle_3),
                false, false));

        pageCount = pages.size();
        binding.viewPager.setAdapter(new OnboardingPagerAdapter(this, pages));
        binding.viewPager.setPageTransformer(new ZoomFadePageTransformer());
        setUpDots();

        binding.viewPager.registerOnPageChangeCallback(new ViewPager2.OnPageChangeCallback() {
            @Override
            public void onPageSelected(int position) {
                updateDots(position);
                updateButton(position);
            }
        });
        updateButton(0);

        binding.btnNext.setOnClickListener(v -> {
            int current = binding.viewPager.getCurrentItem();
            if (current < pageCount - 1) {
                binding.viewPager.setCurrentItem(current + 1, true);
            } else {
                startActivity(new Intent(this, MainActivity.class));
                finish();
            }
        });
    }

    private void setUpDots() {
        dots.clear();
        binding.dotsContainer.removeAllViews();
        int margin = getResources().getDimensionPixelSize(R.dimen.onboarding_dot_margin);
        for (int i = 0; i < pageCount; i++) {
            ImageView dot = new ImageView(this);
            LinearLayout.LayoutParams params = new LinearLayout.LayoutParams(
                    ViewGroup.LayoutParams.WRAP_CONTENT, ViewGroup.LayoutParams.WRAP_CONTENT);
            params.setMargins(margin, 0, margin, 0);
            dot.setLayoutParams(params);
            dots.add(dot);
            binding.dotsContainer.addView(dot);
        }
        updateDots(0);
    }

    private void updateDots(int selectedPosition) {
        for (int i = 0; i < dots.size(); i++) {
            dots.get(i).setImageResource(
                    i == selectedPosition ? R.drawable.dot_indicator_active : R.drawable.dot_indicator_inactive);
        }
    }

    private void updateButton(int position) {
        boolean isLastPage = position == pageCount - 1;
        int bgColorRes = position == 0 ? R.color.whs_black : R.color.onboarding_button_bg_alt;
        binding.btnNext.setBackgroundTintList(ColorStateList.valueOf(ContextCompat.getColor(this, bgColorRes)));
        binding.btnNext.setText(isLastPage ? R.string.onboarding_start : R.string.onboarding_next);
    }
}
