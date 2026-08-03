package com.example.whs_after_mate.ui.auth;

import android.os.Handler;
import android.os.Looper;
import android.util.Patterns;

import androidx.lifecycle.LiveData;
import androidx.lifecycle.MutableLiveData;
import androidx.lifecycle.ViewModel;

public class ResetPasswordViewModel extends ViewModel {

    private final MutableLiveData<Boolean> isLoading = new MutableLiveData<>(false);
    private final MutableLiveData<Boolean> resetSuccess = new MutableLiveData<>();
    private final MutableLiveData<String> errorMessage = new MutableLiveData<>();
    private final MutableLiveData<String> emailError = new MutableLiveData<>();

    /**
     * Returns whether a password reset operation is currently in progress.
     */
    public LiveData<Boolean> getIsLoading() {
        return isLoading;
    }

    /**
     * Returns whether the reset link was successfully sent.
     */
    public LiveData<Boolean> getResetSuccess() {
        return resetSuccess;
    }

    /**
     * Returns any error messages that should be displayed as a Toast.
     */
    public LiveData<String> getErrorMessage() {
        return errorMessage;
    }

    /**
     * Returns the validation error for the email field.
     */
    public LiveData<String> getEmailError() {
        return emailError;
    }

    /**
     * Attempts to send a password reset link to the provided email.
     *
     * @param email The email address to send the link to.
     */
    public void sendResetLink(String email) {
        // Reset state before starting a new attempt
        emailError.setValue(null);
        errorMessage.setValue(null);
        resetSuccess.setValue(null);

        if (!isEmailValid(email)) {
            emailError.setValue("유효한 이메일을 입력해주세요.");
            return;
        }

        isLoading.setValue(true);

        // Simulate network delay for sending reset email
        new Handler(Looper.getMainLooper()).postDelayed(() -> {
            isLoading.setValue(false);
            // TODO: Replace with actual password reset logic
            resetSuccess.setValue(true);
        }, 2000);
    }

    private boolean isEmailValid(String email) {
        return email != null && Patterns.EMAIL_ADDRESS.matcher(email).matches();
    }
}
