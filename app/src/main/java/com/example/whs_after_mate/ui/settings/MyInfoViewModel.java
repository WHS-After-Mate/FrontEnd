package com.example.whs_after_mate.ui.settings;

import androidx.lifecycle.ViewModel;

import java.util.Arrays;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

public class MyInfoViewModel extends ViewModel {

    private final String userName = "지수";
    private final String birthDate = "2000-01-04";
    private final String email = "abc@gmail.com";
    private final String phoneNumber = "010-1111-2222";

    private final List<String> interestGoals = Arrays.asList(
            "리프팅·탄력", "모공·피지 관리", "보습·장벽 강화", "색소침착 개선",
            "얼굴 윤곽·볼륨", "제모", "두피 관리",
            "바디라인·체형 관리", "붓기 케어", "컨디션·대사 관리"
    );

    private final Set<String> selectedGoals = new LinkedHashSet<>(Arrays.asList("리프팅·탄력", "붓기 케어"));

    public String getUserName() {
        return userName;
    }

    public String getBirthDate() {
        return birthDate;
    }

    public String getEmail() {
        return email;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public List<String> getInterestGoals() {
        return interestGoals;
    }

    public Set<String> getSelectedGoals() {
        return selectedGoals;
    }
}
