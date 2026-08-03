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

import com.example.whs_after_mate.R;
import com.example.whs_after_mate.databinding.FragmentLoginBinding;

import static android.content.Context.INPUT_METHOD_SERVICE;

public class LoginFragment extends Fragment {

    private FragmentLoginBinding binding;
    private LoginViewModel loginViewModel;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        binding = FragmentLoginBinding.inflate(inflater, container, false);
        return binding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        // Initialize ViewModel
        loginViewModel = new ViewModelProvider(this).get(LoginViewModel.class);

        setupListeners();
        observeViewModel();
    }

    /**
     * Set up UI component listeners.
     */
    private void setupListeners() {
        binding.btnLogin.setOnClickListener(v -> {
            hideKeyboard();
            String email = binding.etLoginEmail.getText().toString().trim();
            String password = binding.etLoginPassword.getText().toString().trim();
            loginViewModel.login(email, password);
        });

        binding.tvForgotPassword.setOnClickListener(v -> {
            Navigation.findNavController(v).navigate(R.id.action_loginFragment_to_resetPasswordFragment);
        });

        binding.tvGoToSignUp.setOnClickListener(v -> {
            Navigation.findNavController(v).navigate(R.id.action_loginFragment_to_signUpFragment);
        });
    }

    /**
     * Observe LiveData from the ViewModel to update the UI.
     */
    private void observeViewModel() {
        // Observe form validation state
        loginViewModel.getLoginFormState().observe(getViewLifecycleOwner(), loginFormState -> {
            if (loginFormState == null) return;

            // Set or clear errors
            binding.etLoginEmail.setError(loginFormState.getUsernameError());
            binding.etLoginPassword.setError(loginFormState.getPasswordError());
        });

        // Observe loading state
        loginViewModel.getIsLoading().observe(getViewLifecycleOwner(), isLoading -> {
            if (isLoading != null) {
                binding.pbLoginLoading.setVisibility(isLoading ? View.VISIBLE : View.GONE);
                setInputsEnabled(!isLoading);
            }
        });

        // Observe login success
        loginViewModel.getLoginSuccess().observe(getViewLifecycleOwner(), isSuccess -> {
            if (Boolean.TRUE.equals(isSuccess)) {
                Toast.makeText(requireContext(), "로그인 성공", Toast.LENGTH_SHORT).show();
                Navigation.findNavController(requireView()).navigate(R.id.action_loginFragment_to_navigation_home);
            }
        });

        // Observe error messages
        loginViewModel.getErrorMessage().observe(getViewLifecycleOwner(), error -> {
            if (error != null) {
                Toast.makeText(requireContext(), error, Toast.LENGTH_SHORT).show();
            }
        });
    }

    /**
     * Enables or disables input fields based on the loading state.
     */
    private void setInputsEnabled(boolean enabled) {
        binding.btnLogin.setEnabled(enabled);
        binding.etLoginEmail.setEnabled(enabled);
        binding.etLoginPassword.setEnabled(enabled);
        binding.tvForgotPassword.setEnabled(enabled);
        binding.tvGoToSignUp.setEnabled(enabled);
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
