package com.example.whs_after_mate.ui.auth;

import android.os.Handler;
import android.os.Looper;

import java.util.HashSet;
import java.util.Set;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

public class LoginViewModel extends ViewModel {

    // 1. 로그인 진행 상태 정의
    public enum LoginStatus {
        IDLE, LOADING, SUCCESS, ERROR
    }

    // 상태 관리 (캡슐화 적용)
    private final MutableLiveData<LoginStatus> _loginStatus = new MutableLiveData<>(LoginStatus.IDLE);
    public LiveData<LoginStatus> getLoginStatus() { return _loginStatus; }

    private final MutableLiveData<String> _errorMessage = new MutableLiveData<>();
    public LiveData<String> getErrorMessage() { return _errorMessage; }

    // 2. 사용자 입력 데이터 관리
    private final MutableLiveData<String> email = new MutableLiveData<>("");
    private final MutableLiveData<String> password = new MutableLiveData<>("");

    public MutableLiveData<String> getEmail() { return email; }
    public MutableLiveData<String> getPassword() { return password; }

    // 가상의 사용자 데이터베이스 (이메일 저장)
    private static final Set<String> registeredUsers = new HashSet<>();

    /**
     * 새로운 사용자를 가상 데이터베이스에 등록합니다.
     * @param email 유저 이메일
     * @param password 유저 비밀번호
     * @return 등록 성공 여부 (이미 존재하면 false)
     */
    public static boolean registerNewUser(String email, String password) {
        if (registeredUsers.contains(email)) {
            return false;
        }
        registeredUsers.add(email);
        return true;
    }

    /**
     * 3. 로그인 비즈니스 로직
     * @param email 유저 이메일
     * @param password 유저 비밀번호
     */
    public void login(String email, String password) {
        // 로딩 상태 시작
        _loginStatus.setValue(LoginStatus.LOADING);

        // 유효성 검사 (간단한 예시)
        if (email == null || email.isEmpty() || password == null || password.isEmpty()) {
            _errorMessage.setValue("이메일과 비밀번호를 모두 입력해주세요.");
            _loginStatus.setValue(LoginStatus.ERROR);
            return;
        }

        // 모의(Mock) 네트워크 통신 비동기 처리 (2초 지연)
        new Handler(Looper.getMainLooper()).postDelayed(() -> {
            // 등록된 유저인지 확인
            if (registeredUsers.contains(email)) {
                _loginStatus.setValue(LoginStatus.SUCCESS);
            } else if (email.contains("@") && password.length() >= 4) {
                // 기존 로직 유지 (테스트용)
                _loginStatus.setValue(LoginStatus.SUCCESS);
            } else {
                _errorMessage.setValue("아이디 또는 비밀번호가 올바르지 않습니다.");
                _loginStatus.setValue(LoginStatus.ERROR);
            }
        }, 2000);
    }
}
