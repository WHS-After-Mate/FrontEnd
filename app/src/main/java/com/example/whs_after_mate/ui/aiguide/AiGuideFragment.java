package com.example.whs_after_mate.ui.aiguide;

import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;

import com.example.whs_after_mate.databinding.FragmentAiguideBinding;

public class AiGuideFragment extends Fragment {

    private FragmentAiguideBinding binding;

    public View onCreateView(@NonNull LayoutInflater inflater,
                             ViewGroup container, Bundle savedInstanceState) {
        AiGuideViewModel aiGuideViewModel =
                new ViewModelProvider(this).get(AiGuideViewModel.class);

        binding = FragmentAiguideBinding.inflate(inflater, container, false);
        View root = binding.getRoot();

        final TextView textView = binding.textAiguide;
        aiGuideViewModel.getText().observe(getViewLifecycleOwner(), textView::setText);
        return root;
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }
}
