package com.example.whs_after_mate.ui.auth;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import java.util.Arrays;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Set;

public class SignUpViewModel extends ViewModel {

    // 1. 상태를 관리할 LiveData들
    private final MutableLiveData<Boolean> isLoading = new MutableLiveData<>(false);
    private final MutableLiveData<String> errorMessage = new MutableLiveData<>();
    private final MutableLiveData<Boolean> signUpSuccess = new MutableLiveData<>(false);

    private final List<String> interestGoals = Arrays.asList(
            "리프팅·탄력", "모공·피지 관리", "보습·장벽 강화", "색소침착 개선",
            "얼굴 윤곽·볼륨", "제모", "두피 관리",
            "바디라인·체형 관리", "붓기 케어", "컨디션·대사 관리"
    );

    private final Set<String> selectedGoals = new LinkedHashSet<>();

    public LiveData<Boolean> getIsLoading() {
        return isLoading;
    }

    public LiveData<String> getErrorMessage() {
        return errorMessage;
    }

    public LiveData<Boolean> getSignUpSuccess() {
        return signUpSuccess;
    }

    public List<String> getInterestGoals() {
        return interestGoals;
    }

    public Set<String> getSelectedGoals() {
        return selectedGoals;
    }

    /**
     * 회원가입 로직 수행
     */
    public void signUp(String name, String email, String phone, String password) {
        isLoading.setValue(true);
        errorMessage.setValue(null);

        // TODO: 실제 서버 API 호출 (Firebase Auth, Retrofit 등)
        // 시뮬레이션: 2초 후 결과 반환
        new android.os.Handler().postDelayed(() -> {
            isLoading.setValue(false);

            // 가입 조건 시뮬레이션 (간단히 이메일에 @가 포함되어 있으면 성공)
            if (email.contains("@") && password.length() >= 6) {
                signUpSuccess.setValue(true);
            } else if (password.length() < 6) {
                errorMessage.setValue("비밀번호는 6자리 이상이어야 합니다.");
            } else {
                errorMessage.setValue("유효하지 않은 이메일 형식입니다.");
            }
        }, 2000);
    }
}
