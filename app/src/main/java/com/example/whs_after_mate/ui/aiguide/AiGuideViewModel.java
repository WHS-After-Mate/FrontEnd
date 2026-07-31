package com.example.whs_after_mate.ui.aiguide;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

public class AiGuideViewModel extends ViewModel {

    private final MutableLiveData<String> mText;

    public AiGuideViewModel() {
        mText = new MutableLiveData<>();
        mText.setValue("This is AI Guide fragment");
    }

    public LiveData<String> getText() {
        return mText;
    }
}
