package com.example.whs_after_mate.ui.auth;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

public class LoginViewModel extends ViewModel {

    // 1. 상태를 관리할 LiveData들 (Fragment가 관찰함)
    private final MutableLiveData<Boolean> isLoading = new MutableLiveData<>(false);
    private final MutableLiveData<String> loginErrorMessage = new MutableLiveData<>();
    private final MutableLiveData<Boolean> loginSuccess = new MutableLiveData<>(false);

    // 외부에서는 읽기만 가능하도록 LiveData로 노출 (캡슐화)
    public LiveData<Boolean> getIsLoading() {
        return isLoading;
    }

    public LiveData<String> getLoginErrorMessage() {
        return loginErrorMessage;
    }

    public LiveData<Boolean> getLoginSuccess() {
        return loginSuccess;
    }

    /**
     * 실제 로그인 로직 수행
     */
    public void login(String email, String password) {
        // 로그인 시작: 로딩 상태로 변경
        isLoading.setValue(true);
        loginErrorMessage.setValue(null);

        // TODO: 실제 서버 API 통신 로직이 들어갈 자리 (비동기 처리 필요)
        // 여기서는 예시를 위해 2초 후 성공했다고 가정하는 시뮬레이션
        new android.os.Handler().postDelayed(() -> {
            isLoading.setValue(false); // 로딩 종료

            if ("test@test.com".equals(email) && "1234".equals(password)) {
                loginSuccess.setValue(true);
            } else {
                loginErrorMessage.setValue("이메일 또는 비밀번호가 일치하지 않습니다.");
            }
        }, 2000);
    }
}
