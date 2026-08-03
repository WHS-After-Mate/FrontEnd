package com.example.whs_after_mate.ui.auth;

import android.os.Handler;
import android.os.Looper;
import android.util.Patterns;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

import java.util.HashMap;
import java.util.Map;

public class LoginViewModel extends ViewModel {

    // Shared mock database for the session to allow SignUp and Login to work together
    private static final Map<String, String> mockUserDatabase = new HashMap<>();

    static {
        // Pre-populate with a default test user
        mockUserDatabase.put("test@example.com", "password123");
    }

    private final MutableLiveData<LoginFormState> loginFormState = new MutableLiveData<>();
    private final MutableLiveData<Boolean> isLoading = new MutableLiveData<>(false);
    private final MutableLiveData<Boolean> loginSuccess = new MutableLiveData<>();
    private final MutableLiveData<String> errorMessage = new MutableLiveData<>();

    public LiveData<LoginFormState> getLoginFormState() {
        return loginFormState;
    }

    public LiveData<Boolean> getIsLoading() {
        return isLoading;
    }

    public LiveData<Boolean> getLoginSuccess() {
        return loginSuccess;
    }

    public LiveData<String> getErrorMessage() {
        return errorMessage;
    }

    /**
     * Static method to allow SignUpViewModel to register new users in the shared mock database.
     */
    public static boolean registerNewUser(String email, String password) {
        if (email == null || password == null) return false;
        String normalizedEmail = email.toLowerCase();
        if (mockUserDatabase.containsKey(normalizedEmail)) {
            return false;
        }
        mockUserDatabase.put(normalizedEmail, password);
        return true;
    }

    public void login(String email, String password) {
        // Reset states before starting a new attempt to avoid stale UI feedback
        loginFormState.setValue(new LoginFormState(null, null));
        errorMessage.setValue(null);
        loginSuccess.setValue(null);

        if (!isUserNameValid(email)) {
            loginFormState.setValue(new LoginFormState("유효한 이메일을 입력해주세요.", null));
            return;
        }
        if (!isPasswordValid(password)) {
            loginFormState.setValue(new LoginFormState(null, "비밀번호는 6자 이상이어야 합니다."));
            return;
        }

        isLoading.setValue(true);

        new Handler(Looper.getMainLooper()).postDelayed(() -> {
            isLoading.setValue(false);
            
            // Fix: Use case-insensitive matching and check against the shared mock database
            String storedPassword = mockUserDatabase.get(email.toLowerCase());
            if (password.equals(storedPassword)) {
                loginSuccess.setValue(true);
            } else {
                errorMessage.setValue("이메일 또는 비밀번호가 일치하지 않습니다.");
            }
        }, 2000);
    }

    private boolean isUserNameValid(String username) {
        return username != null && Patterns.EMAIL_ADDRESS.matcher(username).matches();
    }

    private boolean isPasswordValid(String password) {
        return password != null && password.trim().length() >= 6;
    }

    public static class LoginFormState {
        @androidx.annotation.Nullable
        private final String usernameError;
        @androidx.annotation.Nullable
        private final String passwordError;

        LoginFormState(@androidx.annotation.Nullable String usernameError, @androidx.annotation.Nullable String passwordError) {
            this.usernameError = usernameError;
            this.passwordError = passwordError;
        }

        @androidx.annotation.Nullable
        public String getUsernameError() {
            return usernameError;
        }

        @androidx.annotation.Nullable
        public String getPasswordError() {
            return passwordError;
        }
    }
}
