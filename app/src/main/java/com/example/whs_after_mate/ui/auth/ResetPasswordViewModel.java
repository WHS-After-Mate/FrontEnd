package com.example.whs_after_mate.ui.auth;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

public class ResetPasswordViewModel extends ViewModel {

    // 1. 상태를 관리할 LiveData들
    private final MutableLiveData<Boolean> isLoading = new MutableLiveData<>(false);
    private final MutableLiveData<String> errorMessage = new MutableLiveData<>();
    private final MutableLiveData<String> successMessage = new MutableLiveData<>();

    public LiveData<Boolean> getIsLoading() {
        return isLoading;
    }

    public LiveData<String> getErrorMessage() {
        return errorMessage;
    }

    public LiveData<String> getSuccessMessage() {
        return successMessage;
    }

    /**
     * 비밀번호 재설정 링크 전송 로직
     */
    public void sendResetLink(String email) {
        isLoading.setValue(true);
        errorMessage.setValue(null);
        successMessage.setValue(null);

        // TODO: 실제 서버 API 호출 (Firebase Auth 등)
        // 시뮬레이션: 1.5초 후 결과 반환
        new android.os.Handler().postDelayed(() -> {
            isLoading.setValue(false);

            if (email.contains("@")) { // 간단한 이메일 형식 체크 예시
                successMessage.setValue(email + "주소로 재설정 링크를 보냈습니다.");
            } else {
                errorMessage.setValue("유효하지 않은 이메일 형식입니다.");
            }
        }, 1500);
    }
}
