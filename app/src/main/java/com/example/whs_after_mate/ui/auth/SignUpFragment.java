package com.example.whs_after_mate.ui.auth;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.fragment.NavHostFragment;

import com.example.whs_after_mate.R;
import com.example.whs_after_mate.databinding.FragmentSignUpBinding;

public class SignUpFragment extends Fragment {

    private FragmentSignUpBinding binding;
    private SignUpViewModel viewModel;

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
            if (validateInput()) {
                String name = binding.etName.getText().toString().trim();
                String email = binding.etEmail.getText().toString().trim();
                String phone = binding.etPhone.getText().toString().trim();
                String password = binding.etPassword.getText().toString().trim();
                
                viewModel.signUp(name, email, phone, password);
            }
        });
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
        if (TextUtils.isEmpty(binding.etEmail.getText())) {
            binding.etEmail.setError("이메일을 입력해주세요.");
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
