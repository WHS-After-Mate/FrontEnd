package com.example.whs_after_mate.ui.auth;

import android.os.Bundle;
import android.text.Editable;
import android.text.InputType;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.Patterns;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;

import com.example.whs_after_mate.R;
import com.example.whs_after_mate.databinding.FragmentResetPasswordBinding;

public class ResetPasswordFragment extends Fragment {

    private FragmentResetPasswordBinding binding;
    private ResetPasswordViewModel viewModel;
    private boolean newPasswordVisible = false;
    private boolean confirmPasswordVisible = false;
    private boolean passwordMatchCheckArmed = false;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater,
                             @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        binding = FragmentResetPasswordBinding.inflate(inflater, container, false);
        return binding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        viewModel = new ViewModelProvider(this).get(ResetPasswordViewModel.class);

        setupClickListeners();
        observeViewModel();
        setupFieldValidationState();
        setupPasswordMatchValidation();
    }

    private void setupClickListeners() {
        // 뒤로가기 버튼
        binding.btnBack.setOnClickListener(v -> {
            if (getActivity() != null) {
                getActivity().onBackPressed();
            }
        });

        // 재설정 링크 보내기 버튼
        binding.btnSendResetLink.setOnClickListener(v -> {
            String email = binding.etEmail.getText().toString().trim();
            passwordMatchCheckArmed = true;
            boolean passwordsMatch = checkPasswordsMatch();
            if (validateInput(email) && passwordsMatch) {
                viewModel.sendResetLink(email);
            }
        });

        // 새 비밀번호 보기/숨기기 토글
        binding.ivNewPasswordToggle.setOnClickListener(v -> {
            newPasswordVisible = !newPasswordVisible;
            applyPasswordVisibility(binding.etNewPassword, binding.ivNewPasswordToggle, newPasswordVisible);
        });

        binding.ivConfirmPasswordToggle.setOnClickListener(v -> {
            confirmPasswordVisible = !confirmPasswordVisible;
            applyPasswordVisibility(binding.etConfirmPassword, binding.ivConfirmPasswordToggle, confirmPasswordVisible);
        });
    }

    private void applyPasswordVisibility(EditText editText, ImageView toggle, boolean visible) {
        int selectionStart = editText.getSelectionStart();
        int selectionEnd = editText.getSelectionEnd();

        if (visible) {
            editText.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD);
            toggle.setImageResource(R.drawable.ic_eye_open);
        } else {
            editText.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);
            toggle.setImageResource(R.drawable.ic_eye_alpha);
        }

        if (selectionStart >= 0 && selectionEnd >= 0) {
            editText.setSelection(selectionStart, selectionEnd);
        }
    }

    private void setupFieldValidationState() {
        setButtonEnabled(binding.btnSendCode, false);
        setButtonEnabled(binding.btnVerifyCode, false);

        binding.etEmail.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void afterTextChanged(Editable s) {
                boolean valid = Patterns.EMAIL_ADDRESS.matcher(s.toString().trim()).matches();
                setButtonEnabled(binding.btnSendCode, valid);
            }
        });

        binding.etAuthCode.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void afterTextChanged(Editable s) {
                setButtonEnabled(binding.btnVerifyCode, !TextUtils.isEmpty(s.toString().trim()));
            }
        });
    }

    private void setButtonEnabled(View button, boolean enabled) {
        button.setEnabled(enabled);
        button.setAlpha(enabled ? 1f : 0.5f);
    }

    private void setupPasswordMatchValidation() {
        TextWatcher matchWatcher = new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void afterTextChanged(Editable s) {
                if (passwordMatchCheckArmed) {
                    checkPasswordsMatch();
                }
            }
        };

        binding.etNewPassword.addTextChangedListener(matchWatcher);
        binding.etConfirmPassword.addTextChangedListener(matchWatcher);
    }

    private boolean checkPasswordsMatch() {
        String newPassword = binding.etNewPassword.getText().toString();
        String confirmPassword = binding.etConfirmPassword.getText().toString();
        boolean matches = confirmPassword.equals(newPassword);

        if (!matches) {
            binding.etConfirmPassword.setError("비밀번호가 일치하지 않아요.");
        } else {
            binding.etConfirmPassword.setError(null);
        }
        return matches;
    }

    private void observeViewModel() {
        // 로딩 상태 관찰
        viewModel.getIsLoading().observe(getViewLifecycleOwner(), isLoading -> {
            binding.btnSendResetLink.setEnabled(!isLoading);
            binding.btnSendResetLink.setText(isLoading ? "전송 중..." : "비밀번호 변경하기");
        });

        // 에러 메시지 관찰
        viewModel.getErrorMessage().observe(getViewLifecycleOwner(), error -> {
            if (error != null) {
                binding.etEmail.setError(error);
            }
        });

        // 성공 메시지 관찰
        viewModel.getSuccessMessage().observe(getViewLifecycleOwner(), success -> {
            if (success != null) {
                Toast.makeText(getContext(), success, Toast.LENGTH_LONG).show();
                // 성공 시 뒤로 가거나 다른 화면으로 이동 가능
            }
        });
    }

    private boolean validateInput(String email) {
        if (TextUtils.isEmpty(email)) {
            binding.etEmail.setError("이메일을 입력해주세요.");
            return false;
        }
        return true;
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }
}
