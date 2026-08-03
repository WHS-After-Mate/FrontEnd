package com.example.whs_after_mate.ui.auth;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.InputMethodManager;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.Navigation;

import com.example.whs_after_mate.databinding.FragmentResetPasswordBinding;

import static android.content.Context.INPUT_METHOD_SERVICE;

public class ResetPasswordFragment extends Fragment {

    private FragmentResetPasswordBinding binding;
    private ResetPasswordViewModel resetPasswordViewModel;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        binding = FragmentResetPasswordBinding.inflate(inflater, container, false);
        return binding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        // Initialize ViewModel
        resetPasswordViewModel = new ViewModelProvider(this).get(ResetPasswordViewModel.class);

        setupListeners();
        observeViewModel();
    }

    /**
     * Set up UI component listeners.
     */
    private void setupListeners() {
        binding.btnBack.setOnClickListener(v -> {
            Navigation.findNavController(requireView()).popBackStack();
        });

        binding.btnSendResetLink.setOnClickListener(v -> {
            hideKeyboard();
            String email = binding.etResetEmail.getText().toString().trim();
            resetPasswordViewModel.sendResetLink(email);
        });
    }

    /**
     * Observe LiveData from the ViewModel to update the UI.
     */
    private void observeViewModel() {
        // Observe email validation error
        resetPasswordViewModel.getEmailError().observe(getViewLifecycleOwner(), error -> {
            binding.etResetEmail.setError(error);
        });

        // Observe loading state
        resetPasswordViewModel.getIsLoading().observe(getViewLifecycleOwner(), isLoading -> {
            if (isLoading != null) {
                binding.pbResetLoading.setVisibility(isLoading ? View.VISIBLE : View.GONE);
                setInputsEnabled(!isLoading);
            }
        });

        // Observe reset success
        resetPasswordViewModel.getResetSuccess().observe(getViewLifecycleOwner(), isSuccess -> {
            if (Boolean.TRUE.equals(isSuccess)) {
                Toast.makeText(requireContext(), "비밀번호 재설정 링크가 전송되었습니다.", Toast.LENGTH_SHORT).show();
                Navigation.findNavController(requireView()).navigateUp();
            }
        });

        // Observe error messages
        resetPasswordViewModel.getErrorMessage().observe(getViewLifecycleOwner(), error -> {
            if (error != null) {
                Toast.makeText(requireContext(), error, Toast.LENGTH_SHORT).show();
            }
        });
    }

    /**
     * Enables or disables input fields and buttons based on the loading state.
     */
    private void setInputsEnabled(boolean enabled) {
        binding.btnSendResetLink.setEnabled(enabled);
        binding.etResetEmail.setEnabled(enabled);
        binding.btnBack.setEnabled(enabled);
    }

    /**
     * Utility method to hide the soft keyboard.
     */
    private void hideKeyboard() {
        View view = requireActivity().getCurrentFocus();
        if (view != null) {
            InputMethodManager imm = (InputMethodManager) requireActivity().getSystemService(INPUT_METHOD_SERVICE);
            imm.hideSoftInputFromWindow(view.getWindowToken(), 0);
        }
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        // Nullify binding to avoid memory leaks
        binding = null;
    }
}
