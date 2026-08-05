package com.example.whs_after_mate.ui.auth;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.navigation.Navigation;

import com.example.whs_after_mate.R;
import com.example.whs_after_mate.databinding.FragmentLoginBinding;

public class LoginFragment extends Fragment {

    private FragmentLoginBinding binding;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                             @Nullable Bundle savedInstanceState) {
        // 1. FragmentLoginBinding을 사용하여 뷰를 생성하고 root 뷰를 반환
        binding = FragmentLoginBinding.inflate(inflater, container, false);
        return binding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        // 2. fragment_login.xml 내의 ID들을 바인딩으로 연결하여 이벤트 처리

        // 로그인 버튼 클릭 이벤트
        binding.btnLogin.setOnClickListener(v -> {
            String email = binding.etEmail.getText().toString().trim();
            String password = binding.etPassword.getText().toString().trim();

            // 아이디/비밀번호 유효성 검사
            if (email.isEmpty() || password.isEmpty()) {
                Toast.makeText(requireContext(), "아이디와 비밀번호를 입력해주세요", Toast.LENGTH_SHORT).show();
            } else {
                // 로그인 성공 처리
                Toast.makeText(requireContext(), "로그인 성공", Toast.LENGTH_SHORT).show();
                // TODO: 로그인 성공 후 메인 화면 이동 로직 (예: Navigation.findNavController(v).navigate(R.id.navigation_home))
            }
        });

        // 회원가입 텍스트 클릭 이벤트
        binding.tvSignUpGuide.setOnClickListener(v -> {
            // navigation_sign_up으로 이동하는 Navigation 처리
            Navigation.findNavController(v).navigate(R.id.navigation_sign_up);
        });

        // 비밀번호 재설정 텍스트 클릭 이벤트
        binding.tvForgotPassword.setOnClickListener(v -> {
            // navigation_reset_password으로 이동하는 Navigation 처리
            Navigation.findNavController(v).navigate(R.id.navigation_reset_password);
        });
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        // 3. binding = null을 명시하여 메모리 누수 방지
        binding = null;
    }
}
