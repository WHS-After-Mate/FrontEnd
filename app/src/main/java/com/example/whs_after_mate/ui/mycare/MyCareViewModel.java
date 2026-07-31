package com.example.whs_after_mate.ui.mycare;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

public class MyCareViewModel extends ViewModel {

    private final MutableLiveData<String> mText;

    public MyCareViewModel() {
        mText = new MutableLiveData<>();
        mText.setValue("This is My Care fragment");
    }

    public LiveData<String> getText() {
        return mText;
    }
}
