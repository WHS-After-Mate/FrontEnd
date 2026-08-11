package com.example.whs_after_mate.ui.auth;

import android.os.Bundle;
import android.text.TextUtils;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;

import com.example.whs_after_mate.databinding.FragmentResetPasswordBinding;

public class ResetPasswordFragment extends Fragment {

    private FragmentResetPasswordBinding binding;
    private ResetPasswordViewModel viewModel;

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
            if (validateInput(email)) {
                viewModel.sendResetLink(email);
            }
        });
    }

    private void observeViewModel() {
        // 로딩 상태 관찰
        viewModel.getIsLoading().observe(getViewLifecycleOwner(), isLoading -> {
            binding.btnSendResetLink.setEnabled(!isLoading);
            binding.btnSendResetLink.setText(isLoading ? "전송 중..." : "재설정 링크 보내기");
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
