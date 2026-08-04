package com.example.whs_after_mate.ui.onboarding;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.fragment.app.FragmentActivity;
import androidx.viewpager2.adapter.FragmentStateAdapter;

import java.util.List;

public class OnboardingPagerAdapter extends FragmentStateAdapter {

    private final List<OnboardingPage> pages;

    public OnboardingPagerAdapter(@NonNull FragmentActivity activity, List<OnboardingPage> pages) {
        super(activity);
        this.pages = pages;
    }

    @NonNull
    @Override
    public Fragment createFragment(int position) {
        OnboardingPage page = pages.get(position);
        return OnboardingPageFragment.newInstance(
                page.imageRes, page.title, page.subtitle, page.textAtTop, page.fitCenter);
    }

    @Override
    public int getItemCount() {
        return pages.size();
    }

    public static class OnboardingPage {
        final int imageRes;
        final String title;
        final String subtitle;
        final boolean textAtTop;
        final boolean fitCenter;

        public OnboardingPage(int imageRes, String title, String subtitle, boolean textAtTop, boolean fitCenter) {
            this.imageRes = imageRes;
            this.title = title;
            this.subtitle = subtitle;
            this.textAtTop = textAtTop;
            this.fitCenter = fitCenter;
        }
    }
}
