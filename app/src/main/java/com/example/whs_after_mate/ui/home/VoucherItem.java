package com.example.whs_after_mate.ui.home;

import androidx.annotation.ColorRes;

public class VoucherItem {

    public final String title;
    public final int remainingCount;
    public final int totalCount;
    @ColorRes
    public final int colorRes;

    public VoucherItem(String title, int remainingCount, int totalCount, @ColorRes int colorRes) {
        this.title = title;
        this.remainingCount = remainingCount;
        this.totalCount = totalCount;
        this.colorRes = colorRes;
    }

    public float progressRatio() {
        return totalCount == 0 ? 0f : (float) remainingCount / (float) totalCount;
    }
}
