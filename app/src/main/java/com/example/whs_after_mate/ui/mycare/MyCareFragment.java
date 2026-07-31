package com.example.whs_after_mate.ui.mycare;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;

import com.example.whs_after_mate.databinding.FragmentMycareBinding;

public class MyCareFragment extends Fragment {

    private FragmentMycareBinding binding;

    public View onCreateView(@NonNull LayoutInflater inflater,
                             ViewGroup container, Bundle savedInstanceState) {
        MyCareViewModel myCareViewModel =
                new ViewModelProvider(this).get(MyCareViewModel.class);

        binding = FragmentMycareBinding.inflate(inflater, container, false);
        View root = binding.getRoot();

        final TextView textView = binding.textMycare;
        myCareViewModel.getText().observe(getViewLifecycleOwner(), textView::setText);
        return root;
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }
}
