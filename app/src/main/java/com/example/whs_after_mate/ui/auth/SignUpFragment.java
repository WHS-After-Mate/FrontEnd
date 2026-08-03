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

import com.example.whs_after_mate.databinding.FragmentSignUpBinding;

import static android.content.Context.INPUT_METHOD_SERVICE;

public class SignUpFragment extends Fragment {

    private FragmentSignUpBinding binding;
    private SignUpViewModel signUpViewModel;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        binding = FragmentSignUpBinding.inflate(inflater, container, false);
        return binding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        // Initialize ViewModel
        signUpViewModel = new ViewModelProvider(this).get(SignUpViewModel.class);

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

        binding.btnSignUpSubmit.setOnClickListener(v -> {
            hideKeyboard();
            String name = binding.etSignUpName.getText().toString().trim();
            String email = binding.etSignUpEmail.getText().toString().trim();
            String phone = binding.etSignUpPhone.getText().toString().trim();
            String password = binding.etSignUpPassword.getText().toString().trim();

            signUpViewModel.signUp(name, email, phone, password);
        });
    }

    /**
     * Observe LiveData from the ViewModel to update the UI.
     */
    private void observeViewModel() {
        // Observe form validation state
        signUpViewModel.getSignUpFormState().observe(getViewLifecycleOwner(), formState -> {
            if (formState == null) return;

            // Set or clear errors for each field
            binding.etSignUpName.setError(formState.getNameError());
            binding.etSignUpEmail.setError(formState.getEmailError());
            binding.etSignUpPhone.setError(formState.getPhoneError());
            binding.etSignUpPassword.setError(formState.getPasswordError());
        });

        // Observe loading state
        signUpViewModel.getIsLoading().observe(getViewLifecycleOwner(), isLoading -> {
            if (isLoading != null) {
                binding.pbSignUpLoading.setVisibility(isLoading ? View.VISIBLE : View.GONE);
                setInputsEnabled(!isLoading);
            }
        });

        // Observe sign-up success
        signUpViewModel.getSignUpSuccess().observe(getViewLifecycleOwner(), isSuccess -> {
            if (Boolean.TRUE.equals(isSuccess)) {
                Toast.makeText(requireContext(), "회원가입이 완료되었습니다.", Toast.LENGTH_SHORT).show();
                Navigation.findNavController(requireView()).navigateUp();
            }
        });

        // Observe error messages
        signUpViewModel.getErrorMessage().observe(getViewLifecycleOwner(), error -> {
            if (error != null) {
                Toast.makeText(requireContext(), error, Toast.LENGTH_SHORT).show();
            }
        });
    }

    /**
     * Enables or disables input fields and buttons based on the loading state.
     */
    private void setInputsEnabled(boolean enabled) {
        binding.btnSignUpSubmit.setEnabled(enabled);
        binding.etSignUpName.setEnabled(enabled);
        binding.etSignUpEmail.setEnabled(enabled);
        binding.etSignUpPhone.setEnabled(enabled);
        binding.etSignUpPassword.setEnabled(enabled);
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
