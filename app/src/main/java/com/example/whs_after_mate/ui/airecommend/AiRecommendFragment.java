package com.example.whs_after_mate.ui.airecommend;

import android.content.res.ColorStateList;
import android.graphics.Typeface;
import android.os.Bundle;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.Fragment;
import androidx.lifecycle.ViewModelProvider;
import androidx.navigation.fragment.NavHostFragment;

import com.example.whs_after_mate.R;
import com.example.whs_after_mate.databinding.FragmentAiRecommendBinding;
import com.example.whs_after_mate.databinding.ItemConsultBinding;
import com.example.whs_after_mate.databinding.ItemReasonBinding;
import com.example.whs_after_mate.databinding.ItemRecentCareBinding;
import com.google.android.material.chip.ChipGroup;

import java.util.List;

public class AiRecommendFragment extends Fragment {

    private FragmentAiRecommendBinding binding;

    @Override
    public View onCreateView(@NonNull LayoutInflater inflater,
                              @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        AiRecommendViewModel viewModel = new ViewModelProvider(this).get(AiRecommendViewModel.class);

        binding = FragmentAiRecommendBinding.inflate(inflater, container, false);
        View root = binding.getRoot();

        binding.buttonBack.setOnClickListener(v ->
                NavHostFragment.findNavController(this).navigateUp());

        bindHeading(viewModel);
        bindSelectedConcernTags(viewModel);
        bindRecommendation(viewModel);
        bindReasons(viewModel);
        bindRecentCare(viewModel);
        bindFitConcernTags(viewModel);
        bindConsult(viewModel);

        return root;
    }

    private void bindHeading(AiRecommendViewModel viewModel) {
        binding.textHeading.setText(getString(R.string.ai_recommend_heading, viewModel.getUserName()));
    }

    private void bindRecommendation(AiRecommendViewModel viewModel) {
        binding.textRecommendCareTitle.setText(viewModel.getRecommendCareTitle());
        binding.textRecommendMeta.setText(viewModel.getRecommendMeta());
        binding.textLastCare.setText(viewModel.getLastCareSummary());
    }

    private void bindReasons(AiRecommendViewModel viewModel) {
        LinearLayout container = binding.containerReasons;
        container.removeAllViews();

        LayoutInflater inflater = LayoutInflater.from(requireContext());
        for (String reason : viewModel.getReasons()) {
            ItemReasonBinding row = ItemReasonBinding.inflate(inflater, container, false);
            row.textReason.setText(reason);
            container.addView(row.getRoot());
        }
    }

    private void bindRecentCare(AiRecommendViewModel viewModel) {
        LinearLayout container = binding.containerRecentCare;
        container.removeAllViews();

        LayoutInflater inflater = LayoutInflater.from(requireContext());
        List<RecentCareItem> items = viewModel.getRecentCareItems();
        for (int i = 0; i < items.size(); i++) {
            if (i > 0) {
                container.addView(createDivider());
            }

            RecentCareItem item = items.get(i);
            ItemRecentCareBinding row = ItemRecentCareBinding.inflate(inflater, container, false);

            int color = ContextCompat.getColor(requireContext(), item.colorRes);
            row.dotRecentCare.setBackgroundTintList(ColorStateList.valueOf(color));

            row.textRecentCareName.setText(item.name);
            row.textRecentCareBrand.setText(getString(R.string.ai_recommend_brand_dot, item.brand));
            row.textRecentCareDays.setText(getString(R.string.ai_recommend_days_elapsed, item.daysAgo));

            container.addView(row.getRoot());
        }
    }

    private void bindSelectedConcernTags(AiRecommendViewModel viewModel) {
        ChipGroup chipGroup = binding.chipGroupConcerns;
        chipGroup.removeAllViews();

        int textColor = ContextCompat.getColor(requireContext(), R.color.white);
        Typeface typeface = Typeface.create("sans-serif-black", Typeface.NORMAL);

        for (String tag : viewModel.getSelectedConcerns()) {
            chipGroup.addView(createTag(tag, R.drawable.bg_tag_selected, textColor, typeface));
        }
    }

    private void bindFitConcernTags(AiRecommendViewModel viewModel) {
        ChipGroup chipGroup = binding.chipGroupFit;
        chipGroup.removeAllViews();

        int textColor = ContextCompat.getColor(requireContext(), R.color.whs_black);

        for (String tag : viewModel.getRelatedConcerns()) {
            chipGroup.addView(createTag(tag, R.drawable.bg_tag_fit, textColor, Typeface.DEFAULT_BOLD));
        }
    }

    private TextView createTag(String text, int backgroundRes, int textColor, Typeface typeface) {
        TextView tag = new TextView(requireContext());
        tag.setText(text);
        tag.setBackgroundResource(backgroundRes);
        tag.setGravity(Gravity.CENTER);
        tag.setTextColor(textColor);
        tag.setTextSize(13f);
        tag.setTypeface(typeface);
        tag.setElevation(dp(3f));
        int paddingHorizontal = (int) dp(16f);
        int paddingVertical = (int) dp(10f);
        tag.setPadding(paddingHorizontal, paddingVertical, paddingHorizontal, paddingVertical);
        return tag;
    }

    private void bindConsult(AiRecommendViewModel viewModel) {
        LinearLayout container = binding.containerConsult;
        container.removeAllViews();

        ClinicContact contact = viewModel.getSavedClinicContact();
        if (contact == null) {
            return;
        }

        LayoutInflater inflater = LayoutInflater.from(requireContext());

        ItemConsultBinding kakaoButton = ItemConsultBinding.inflate(inflater, container, false);
        kakaoButton.iconConsult.setImageResource(R.drawable.ic_kakao);
        kakaoButton.iconConsult.setImageTintList(null);
        kakaoButton.textConsultName.setText(getString(R.string.ai_recommend_consult_kakao, contact.name));
        kakaoButton.getRoot().setOnClickListener(v ->
                Toast.makeText(requireContext(), R.string.ai_recommend_consult_toast, Toast.LENGTH_SHORT).show());
        ((LinearLayout.LayoutParams) kakaoButton.getRoot().getLayoutParams()).setMarginEnd((int) dp(10f));
        container.addView(kakaoButton.getRoot());

        ItemConsultBinding callButton = ItemConsultBinding.inflate(inflater, container, false);
        callButton.iconConsult.setImageResource(R.drawable.ic_call);
        callButton.iconConsult.setImageTintList(ColorStateList.valueOf(ContextCompat.getColor(requireContext(), R.color.white)));
        callButton.textConsultName.setText(getString(R.string.ai_recommend_consult_call, contact.name));
        callButton.getRoot().setOnClickListener(v ->
                Toast.makeText(requireContext(), R.string.ai_recommend_call_toast, Toast.LENGTH_SHORT).show());
        container.addView(callButton.getRoot());
    }

    private float dp(float value) {
        return getResources().getDisplayMetrics().density * value;
    }

    private View createDivider() {
        View divider = new View(requireContext());
        int oneDp = Math.round(getResources().getDisplayMetrics().density);
        int marginDp = Math.round(getResources().getDisplayMetrics().density * 14f);

        LinearLayout.LayoutParams params =
                new LinearLayout.LayoutParams(LinearLayout.LayoutParams.MATCH_PARENT, oneDp);
        params.topMargin = marginDp;
        params.bottomMargin = marginDp;
        divider.setLayoutParams(params);
        divider.setBackgroundColor(ContextCompat.getColor(requireContext(), R.color.divider));
        return divider;
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }
}
