package com.example.whs_after_mate.ui.auth;

import android.content.res.ColorStateList;
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

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.fragment.NavHostFragment;

import com.example.whs_after_mate.R;
import com.example.whs_after_mate.databinding.FragmentSignUpBinding;
import com.google.android.material.chip.Chip;

public class SignUpFragment extends Fragment {

    private FragmentSignUpBinding binding;
    private SignUpViewModel viewModel;
    private boolean passwordVisible = false;
    private boolean confirmPasswordVisible = false;
    private boolean passwordMatchCheckArmed = false;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater,
                             @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        binding = FragmentSignUpBinding.inflate(inflater, container, false);
        return binding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        viewModel = new ViewModelProvider(this).get(SignUpViewModel.class);

        setupClickListeners();
        observeViewModel();
        setupAutoHyphenFormatters();
        setupEmailValidation();
        setupPasswordMatchValidation();
        bindInterestGoals();
    }

    private void setupClickListeners() {
        // 뒤로가기 버튼
        binding.btnBack.setOnClickListener(v -> {
            if (getActivity() != null) {
                getActivity().onBackPressed();
            }
        });

        // 가입하기 버튼
        binding.btnSignUp.setOnClickListener(v -> {
            passwordMatchCheckArmed = true;
            boolean passwordsMatch = checkPasswordsMatch();
            if (validateInput() && passwordsMatch) {
                String name = binding.etName.getText().toString().trim();
                String email = binding.etEmail.getText().toString().trim();
                String phone = binding.etPhone.getText().toString().trim();
                String password = binding.etPassword.getText().toString().trim();

                viewModel.signUp(name, email, phone, password);
            }
        });

        // 비밀번호 보기/숨기기 토글
        binding.ivPasswordToggle.setOnClickListener(v -> {
            passwordVisible = !passwordVisible;
            applyPasswordVisibility(binding.etPassword, binding.ivPasswordToggle, passwordVisible);
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

    private void setupAutoHyphenFormatters() {
        addAutoHyphenFormatter(binding.etBirth, 4, 2, 2);
        addAutoHyphenFormatter(binding.etPhone, 3, 4, 4);
    }

    private void addAutoHyphenFormatter(EditText editText, int... groupSizes) {
        int digitTotal = 0;
        for (int size : groupSizes) {
            digitTotal += size;
        }
        final int maxDigits = digitTotal;

        editText.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void afterTextChanged(Editable s) {
                String formatted = formatWithHyphens(s.toString(), groupSizes, maxDigits);
                if (formatted.contentEquals(s)) {
                    return;
                }
                editText.removeTextChangedListener(this);
                editText.setText(formatted);
                editText.setSelection(formatted.length());
                editText.addTextChangedListener(this);
            }
        });
    }

    private String formatWithHyphens(String input, int[] groupSizes, int maxDigits) {
        StringBuilder digits = new StringBuilder();
        for (int i = 0; i < input.length() && digits.length() < maxDigits; i++) {
            char c = input.charAt(i);
            if (Character.isDigit(c)) {
                digits.append(c);
            }
        }

        StringBuilder formatted = new StringBuilder();
        int consumed = 0;
        for (int size : groupSizes) {
            if (consumed >= digits.length()) {
                break;
            }
            if (formatted.length() > 0) {
                formatted.append('-');
            }
            int end = Math.min(consumed + size, digits.length());
            formatted.append(digits, consumed, end);
            consumed = end;
        }
        return formatted.toString();
    }

    private void setupEmailValidation() {
        binding.etEmail.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
            }

            @Override
            public void afterTextChanged(Editable s) {
                String email = s.toString().trim();
                if (!email.isEmpty() && !Patterns.EMAIL_ADDRESS.matcher(email).matches()) {
                    binding.etEmail.setError("올바른 이메일 형식이 아니에요.");
                } else {
                    binding.etEmail.setError(null);
                }
            }
        });
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

        binding.etPassword.addTextChangedListener(matchWatcher);
        binding.etConfirmPassword.addTextChangedListener(matchWatcher);
    }

    private boolean checkPasswordsMatch() {
        String password = binding.etPassword.getText().toString();
        String confirmPassword = binding.etConfirmPassword.getText().toString();
        boolean matches = confirmPassword.equals(password);

        if (!matches) {
            binding.etConfirmPassword.setError("비밀번호가 일치하지 않아요.");
        } else {
            binding.etConfirmPassword.setError(null);
        }
        return matches;
    }

    private void bindInterestGoals() {
        ColorStateList chipBackground = ContextCompat.getColorStateList(requireContext(), R.color.selector_chip_background);
        ColorStateList chipText = ContextCompat.getColorStateList(requireContext(), R.color.selector_chip_text);
        ColorStateList chipStroke = ContextCompat.getColorStateList(requireContext(), R.color.selector_chip_stroke);
        float cornerRadius = getResources().getDisplayMetrics().density * 20f;
        float strokeWidth = getResources().getDisplayMetrics().density * 1f;

        for (String goal : viewModel.getInterestGoals()) {
            Chip chip = new Chip(requireContext());
            chip.setText(goal);
            chip.setCheckable(true);
            chip.setChecked(viewModel.getSelectedGoals().contains(goal));
            chip.setChipBackgroundColor(chipBackground);
            chip.setTextColor(chipText);
            chip.setChipStrokeColor(chipStroke);
            chip.setChipStrokeWidth(strokeWidth);
            chip.setChipCornerRadius(cornerRadius);
            chip.setCheckedIconVisible(false);
            chip.setEnsureMinTouchTargetSize(false);
            chip.setTextSize(14f);
            chip.setOnCheckedChangeListener((buttonView, isChecked) -> {
                if (isChecked) {
                    viewModel.getSelectedGoals().add(goal);
                } else {
                    viewModel.getSelectedGoals().remove(goal);
                }
            });
            binding.chipGroupInterest.addView(chip);
        }
    }

    private void observeViewModel() {
        // 로딩 상태 관찰
        viewModel.getIsLoading().observe(getViewLifecycleOwner(), isLoading -> {
            binding.btnSignUp.setEnabled(!isLoading);
            binding.btnSignUp.setText(isLoading ? "가입 중..." : "가입하고 시작하기");
        });

        // 에러 메시지 관찰
        viewModel.getErrorMessage().observe(getViewLifecycleOwner(), error -> {
            if (error != null) {
                binding.etEmail.setError(error);
            }
        });

        // 가입 성공 여부 관찰
        viewModel.getSignUpSuccess().observe(getViewLifecycleOwner(), isSuccess -> {
            if (isSuccess) {
                NavHostFragment.findNavController(this)
                        .navigate(R.id.action_navigation_sign_up_to_navigation_login);
            }
        });
    }

    private boolean validateInput() {
        if (TextUtils.isEmpty(binding.etName.getText())) {
            binding.etName.setError("이름을 입력해주세요.");
            return false;
        }
        String email = binding.etEmail.getText().toString().trim();
        if (TextUtils.isEmpty(email)) {
            binding.etEmail.setError("이메일을 입력해주세요.");
            return false;
        }
        if (!Patterns.EMAIL_ADDRESS.matcher(email).matches()) {
            binding.etEmail.setError("올바른 이메일 형식이 아니에요.");
            return false;
        }
        if (TextUtils.isEmpty(binding.etPhone.getText())) {
            binding.etPhone.setError("휴대폰 번호를 입력해주세요.");
            return false;
        }
        if (TextUtils.isEmpty(binding.etPassword.getText())) {
            binding.etPassword.setError("비밀번호를 입력해주세요.");
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
