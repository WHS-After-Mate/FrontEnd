package com.example.whs_after_mate.ui.auth;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

public class ResetPasswordViewModel extends ViewModel {

    private final MutableLiveData<String> mText;

    public ResetPasswordViewModel() {
        mText = new MutableLiveData<>();
        mText.setValue("This is reset password fragment");
    }

    public LiveData<String> getText() {
        return mText;
    }
}
