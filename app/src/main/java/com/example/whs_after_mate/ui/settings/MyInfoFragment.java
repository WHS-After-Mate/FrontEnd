package com.example.whs_after_mate.ui.settings;

import android.content.res.ColorStateList;
import android.os.Bundle;
import android.text.Editable;
import android.text.InputType;
import android.text.TextWatcher;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.fragment.NavHostFragment;

import com.example.whs_after_mate.R;
import com.example.whs_after_mate.databinding.FragmentMyInfoBinding;
import com.google.android.material.chip.Chip;

public class MyInfoFragment extends Fragment {

    private FragmentMyInfoBinding binding;

    private boolean previousPasswordVisible = false;
    private boolean newPasswordVisible = false;

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater,
                              @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        MyInfoViewModel viewModel = new ViewModelProvider(this).get(MyInfoViewModel.class);

        binding = FragmentMyInfoBinding.inflate(inflater, container, false);
        View root = binding.getRoot();

        binding.buttonBack.setOnClickListener(v ->
                NavHostFragment.findNavController(this).navigateUp());

        bindProfile(viewModel);
        bindMemberInfo(viewModel);
        bindInterestGoals(viewModel);
        bindPasswordFields();

        addAutoHyphenFormatter(binding.textBirth, 4, 2, 2);
        addAutoHyphenFormatter(binding.textPhone, 3, 4, 4);

        binding.buttonSave.setOnClickListener(v ->
                Toast.makeText(requireContext(), R.string.my_info_saved_toast, Toast.LENGTH_SHORT).show());

        return root;
    }

    private void bindProfile(MyInfoViewModel viewModel) {
        String userName = viewModel.getUserName();
        binding.textAvatar.setText(userName.substring(0, 1));
        binding.textProfileName.setText(getString(R.string.user_name_honorific, userName));
    }

    private void bindMemberInfo(MyInfoViewModel viewModel) {
        binding.textName.setText(viewModel.getUserName());
        binding.textBirth.setText(viewModel.getBirthDate());
        binding.textEmail.setText(viewModel.getEmail());
        binding.textPhone.setText(viewModel.getPhoneNumber());
    }

    private void bindInterestGoals(MyInfoViewModel viewModel) {
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

    private void bindPasswordFields() {
        applyPasswordVisibility(binding.textPrevPassword, binding.togglePrevPassword, previousPasswordVisible);
        applyPasswordVisibility(binding.textNewPassword, binding.toggleNewPassword, newPasswordVisible);

        binding.togglePrevPassword.setOnClickListener(v -> {
            previousPasswordVisible = !previousPasswordVisible;
            applyPasswordVisibility(binding.textPrevPassword, binding.togglePrevPassword, previousPasswordVisible);
        });

        binding.toggleNewPassword.setOnClickListener(v -> {
            newPasswordVisible = !newPasswordVisible;
            applyPasswordVisibility(binding.textNewPassword, binding.toggleNewPassword, newPasswordVisible);
        });
    }

    private void applyPasswordVisibility(EditText editText, ImageView toggle, boolean visible) {
        int selectionStart = editText.getSelectionStart();
        int selectionEnd = editText.getSelectionEnd();

        if (visible) {
            editText.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD);
            toggle.setImageResource(R.drawable.ic_eye_active);
        } else {
            editText.setInputType(InputType.TYPE_CLASS_TEXT | InputType.TYPE_TEXT_VARIATION_PASSWORD);
            toggle.setImageResource(R.drawable.ic_eye_inactive);
        }

        if (selectionStart >= 0 && selectionEnd >= 0) {
            editText.setSelection(selectionStart, selectionEnd);
        }
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

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }
}
