package com.example.whs_after_mate.ui.auth;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

public class SignUpViewModel extends ViewModel {

    // 1. 상태를 관리할 LiveData들
    private final MutableLiveData<Boolean> isLoading = new MutableLiveData<>(false);
    private final MutableLiveData<String> errorMessage = new MutableLiveData<>();
    private final MutableLiveData<Boolean> signUpSuccess = new MutableLiveData<>(false);

    public LiveData<Boolean> getIsLoading() {
        return isLoading;
    }

    public LiveData<String> getErrorMessage() {
        return errorMessage;
    }

    public LiveData<Boolean> getSignUpSuccess() {
        return signUpSuccess;
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
