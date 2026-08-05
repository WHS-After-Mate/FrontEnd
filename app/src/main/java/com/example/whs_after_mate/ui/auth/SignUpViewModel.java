package com.example.whs_after_mate.ui.auth;

import android.os.Handler;
import android.os.Looper;
import android.util.Patterns;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

public class SignUpViewModel extends ViewModel {

    private final MutableLiveData<SignUpFormState> signUpFormState = new MutableLiveData<>();
    private final MutableLiveData<Boolean> isLoading = new MutableLiveData<>(false);
    private final MutableLiveData<Boolean> signUpSuccess = new MutableLiveData<>();
    private final MutableLiveData<String> errorMessage = new MutableLiveData<>();

    /**
     * Returns the current state of the sign-up form, including validation errors.
     */
    public LiveData<SignUpFormState> getSignUpFormState() {
        return signUpFormState;
    }

    /**
     * Returns whether a sign-up operation is currently in progress.
     */
    public LiveData<Boolean> getIsLoading() {
        return isLoading;
    }

    /**
     * Returns whether the sign-up was successful.
     */
    public LiveData<Boolean> getSignUpSuccess() {
        return signUpSuccess;
    }

    /**
     * Returns any error messages that should be displayed to the user.
     */
    public LiveData<String> getErrorMessage() {
        return errorMessage;
    }

    /**
     * Attempts to sign up a new user with the provided details.
     * Performs validation before starting the operation.
     */
    public void signUp(String name, String email, String phone, String password) {
        // Reset state before starting a new attempt to avoid stale UI feedback
        signUpFormState.setValue(new SignUpFormState(null, null, null, null));
        errorMessage.setValue(null);
        signUpSuccess.setValue(null);

        if (name == null || name.isEmpty()) {
            signUpFormState.setValue(new SignUpFormState("이름을 입력해주세요.", null, null, null));
            return;
        }
        if (!isEmailValid(email)) {
            signUpFormState.setValue(new SignUpFormState(null, "유효한 이메일을 입력해주세요.", null, null));
            return;
        }
        if (phone == null || phone.isEmpty()) {
            signUpFormState.setValue(new SignUpFormState(null, null, "전화번호를 입력해주세요.", null));
            return;
        }
        if (password == null || password.length() < 6) {
            signUpFormState.setValue(new SignUpFormState(null, null, null, "비밀번호는 6자 이상이어야 합니다."));
            return;
        }

        isLoading.setValue(true);

        // Simulate network delay for registration
        new Handler(Looper.getMainLooper()).postDelayed(() -> {
            isLoading.setValue(false);

            // Fix: Register the user in the shared mock database in LoginViewModel
            if (LoginViewModel.registerNewUser(email, password)) {
                signUpSuccess.setValue(true);
            } else {
                errorMessage.setValue("이미 등록된 이메일입니다.");
            }
        }, 2000);
    }

    private boolean isEmailValid(String email) {
        return email != null && Patterns.EMAIL_ADDRESS.matcher(email).matches();
    }

    /**
     * State object for the sign-up form validation results.
     */
    public static class SignUpFormState {
        @androidx.annotation.Nullable
        private final String nameError;
        @androidx.annotation.Nullable
        private final String emailError;
        @androidx.annotation.Nullable
        private final String phoneError;
        @androidx.annotation.Nullable
        private final String passwordError;

        SignUpFormState(@androidx.annotation.Nullable String nameError, @androidx.annotation.Nullable String emailError,
                        @androidx.annotation.Nullable String phoneError, @androidx.annotation.Nullable String passwordError) {
            this.nameError = nameError;
            this.emailError = emailError;
            this.phoneError = phoneError;
            this.passwordError = passwordError;
        }

        @androidx.annotation.Nullable
        public String getNameError() {
            return nameError;
        }

        @androidx.annotation.Nullable
        public String getEmailError() {
            return emailError;
        }

        @androidx.annotation.Nullable
        public String getPhoneError() {
            return phoneError;
        }

        @androidx.annotation.Nullable
        public String getPasswordError() {
            return passwordError;
        }
    }
}
