package com.example.whs_after_mate.ui.settings;

import androidx.lifecycle.ViewModel;

public class SettingsViewModel extends ViewModel {

    private final String userName = "지수";
    private final String email = "jisoo@example.com";

    public String getUserName() {
        return userName;
    }

    public String getEmail() {
        return email;
    }
}
