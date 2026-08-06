package com.example.whs_after_mate.ui.settings;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.fragment.NavHostFragment;

import com.example.whs_after_mate.R;
import com.example.whs_after_mate.databinding.FragmentSettingsBinding;

public class SettingsFragment extends Fragment {

    private FragmentSettingsBinding binding;

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater,
                              @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        SettingsViewModel settingsViewModel = new ViewModelProvider(this).get(SettingsViewModel.class);

        binding = FragmentSettingsBinding.inflate(inflater, container, false);
        View root = binding.getRoot();

        String userName = settingsViewModel.getUserName();
        binding.textAvatar.setText(userName.substring(0, 1));
        binding.textProfileName.setText(getString(R.string.user_name_honorific, userName));
        binding.textProfileEmail.setText(settingsViewModel.getEmail());

        binding.rowProfile.setOnClickListener(v ->
                NavHostFragment.findNavController(this).navigate(R.id.action_navigation_settings_to_myInfoFragment));

        binding.buttonLogout.setOnClickListener(v ->
                Toast.makeText(requireContext(), R.string.settings_logout, Toast.LENGTH_SHORT).show());

        return root;
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }
}
