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
import com.example.whs_after_mate.databinding.FragmentLoginBinding;

public class LoginFragment extends Fragment {

    private FragmentLoginBinding binding;
    private LoginViewModel loginViewModel;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater,
                             @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        // 1. View Binding을 통한 레이아웃 인플레이트 (화면 그리기)
        binding = FragmentLoginBinding.inflate(inflater, container, false);
        return binding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        // ViewModel 초기화
        loginViewModel = new ViewModelProvider(this).get(LoginViewModel.class);

        // 2. 사용자 입력 및 버튼 클릭 이벤트 처리
        setupClickListeners();

        // 3. ViewModel 상태 관찰 (Livedata Observer 설정)
        observeViewModel();
    }

    private void observeViewModel() {
        // 로딩 상태 관찰: 로그인 중일 때 버튼 비활성화 등 처리
        loginViewModel.getIsLoading().observe(getViewLifecycleOwner(), isLoading -> {
            binding.btnLogin.setEnabled(!isLoading);
            binding.btnLogin.setText(isLoading ? "로그인 중..." : "로그인");
        });

        // 에러 메시지 관찰
        loginViewModel.getLoginErrorMessage().observe(getViewLifecycleOwner(), errorMessage -> {
            if (errorMessage != null) {
                binding.etPassword.setError(errorMessage);
            }
        });

        // 로그인 성공 여부 관찰
        loginViewModel.getLoginSuccess().observe(getViewLifecycleOwner(), isSuccess -> {
            if (isSuccess) {
                NavHostFragment.findNavController(this)
                        .navigate(R.id.action_navigation_login_to_navigation_home);
            }
        });
    }

    private void setupClickListeners() {
        // 로그인 버튼 클릭
        binding.btnLogin.setOnClickListener(v -> {
            if (validateInput()) {
                String email = binding.etEmail.getText().toString();
                String password = binding.etPassword.getText().toString();
                loginViewModel.login(email, password);
            }
        });

        // 비밀번호 찾기 클릭
        binding.tvForgotPassword.setOnClickListener(v ->
                NavHostFragment.findNavController(this)
                        .navigate(R.id.action_navigation_login_to_navigation_reset_password));

        // 회원가입 안내 클릭
        binding.tvSignUpGuide.setOnClickListener(v ->
                NavHostFragment.findNavController(this)
                        .navigate(R.id.action_navigation_login_to_navigation_sign_up));
    }

    private boolean validateInput() {
        String email = binding.etEmail.getText().toString().trim();
        String password = binding.etPassword.getText().toString().trim();

        if (TextUtils.isEmpty(email)) {
            binding.etEmail.setError("이메일을 입력해주세요.");
            return false;
        }

        if (TextUtils.isEmpty(password)) {
            binding.etPassword.setError("비밀번호를 입력해주세요.");
            return false;
        }

        return true;
    }

    // 3. 화면 생명주기 관리: 메모리 누수 방지를 위한 바인딩 해제
    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }
}
