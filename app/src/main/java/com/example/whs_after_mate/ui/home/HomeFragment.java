package com.example.whs_after_mate.ui.home;

import android.content.res.ColorStateList;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.fragment.NavHostFragment;

import com.example.whs_after_mate.R;
import com.example.whs_after_mate.databinding.FragmentHomeBinding;
import com.example.whs_after_mate.databinding.ItemVoucherBinding;

public class HomeFragment extends Fragment {

    private FragmentHomeBinding binding;

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater,
                              @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        HomeViewModel homeViewModel = new ViewModelProvider(this).get(HomeViewModel.class);

        binding = FragmentHomeBinding.inflate(inflater, container, false);
        View root = binding.getRoot();

        bindHeader(homeViewModel);
        bindTodayCare(homeViewModel);
        bindRecommendation(homeViewModel);
        bindVouchers(homeViewModel);

        binding.buttonRecommendDetail.setOnClickListener(v ->
                NavHostFragment.findNavController(this).navigate(R.id.action_navigation_home_to_aiRecommendFragment));

        return root;
    }

    private void bindHeader(HomeViewModel homeViewModel) {
        String userName = homeViewModel.getUserName();
        binding.textDateLabel.setText(homeViewModel.getDateLabel());
        binding.textGreeting.setText(getString(R.string.home_greeting, userName));
        binding.textAvatar.setText(userName.substring(0, 1));
    }

    private void bindTodayCare(HomeViewModel homeViewModel) {
        binding.textBrandLabel.setText(homeViewModel.getBrandLabel());
        binding.textCareTitle.setText(homeViewModel.getCareTitle());
        binding.textCareSubtitle.setText(homeViewModel.getCareSubtitle());
    }

    private void bindRecommendation(HomeViewModel homeViewModel) {
        binding.textRecommendTitle.setText(homeViewModel.getRecommendTitle());
        binding.textRecommendSubtitle.setText(homeViewModel.getRecommendSubtitle());
    }

    private void bindVouchers(HomeViewModel homeViewModel) {
        LinearLayout container = binding.containerVouchers;
        container.removeAllViews();

        LayoutInflater inflater = LayoutInflater.from(requireContext());
        for (VoucherItem item : homeViewModel.getVoucherItems()) {
            ItemVoucherBinding row = ItemVoucherBinding.inflate(inflater, container, false);

            int color = ContextCompat.getColor(requireContext(), item.colorRes);
            ColorStateList tint = ColorStateList.valueOf(color);
            row.dotVoucher.setBackgroundTintList(tint);
            row.progressFill.setBackgroundTintList(tint);

            row.textVoucherTitle.setText(item.title);
            row.textVoucherRemaining.setText(
                    getString(R.string.home_voucher_remaining, item.remainingCount));

            float ratio = item.progressRatio();
            LinearLayout.LayoutParams fillParams = (LinearLayout.LayoutParams) row.progressFill.getLayoutParams();
            fillParams.weight = ratio;
            row.progressFill.setLayoutParams(fillParams);

            LinearLayout.LayoutParams spacerParams = (LinearLayout.LayoutParams) row.progressSpacer.getLayoutParams();
            spacerParams.weight = 1f - ratio;
            row.progressSpacer.setLayoutParams(spacerParams);

            container.addView(row.getRoot());
        }
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }
}
