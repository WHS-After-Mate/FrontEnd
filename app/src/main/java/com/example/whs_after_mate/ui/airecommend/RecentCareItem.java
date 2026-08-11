package com.example.whs_after_mate.ui.airecommend;

import androidx.annotation.ColorRes;

public class RecentCareItem {

    public final String name;
    public final String brand;
    public final int daysAgo;
    @ColorRes
    public final int colorRes;

    public RecentCareItem(String name, String brand, int daysAgo, @ColorRes int colorRes) {
        this.name = name;
        this.brand = brand;
        this.daysAgo = daysAgo;
        this.colorRes = colorRes;
    }
}
