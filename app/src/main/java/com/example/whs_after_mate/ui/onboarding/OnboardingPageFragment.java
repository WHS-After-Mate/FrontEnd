package com.example.whs_after_mate.ui.onboarding;

import android.graphics.Paint;
import android.os.Bundle;
import android.util.TypedValue;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.Fragment;

import com.example.whs_after_mate.databinding.FragmentOnboardingPageBinding;

public class OnboardingPageFragment extends Fragment {

    private static final String ARG_IMAGE_RES = "arg_image_res";
    private static final String ARG_TITLE = "arg_title";
    private static final String ARG_SUBTITLE = "arg_subtitle";
    private static final String ARG_TEXT_AT_TOP = "arg_text_at_top";
    private static final String ARG_FIT_CENTER = "arg_fit_center";

    private FragmentOnboardingPageBinding binding;

    public static OnboardingPageFragment newInstance(int imageRes, String title, String subtitle,
                                                       boolean textAtTop, boolean fitCenter) {
        Bundle args = new Bundle();
        args.putInt(ARG_IMAGE_RES, imageRes);
        args.putString(ARG_TITLE, title);
        args.putString(ARG_SUBTITLE, subtitle);
        args.putBoolean(ARG_TEXT_AT_TOP, textAtTop);
        args.putBoolean(ARG_FIT_CENTER, fitCenter);

        OnboardingPageFragment fragment = new OnboardingPageFragment();
        fragment.setArguments(args);
        return fragment;
    }

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater, @Nullable ViewGroup container,
                              @Nullable Bundle savedInstanceState) {
        binding = FragmentOnboardingPageBinding.inflate(inflater, container, false);
        return binding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        Bundle args = requireArguments();
        int imageRes = args.getInt(ARG_IMAGE_RES);
        boolean textAtTop = args.getBoolean(ARG_TEXT_AT_TOP);
        boolean fitCenter = args.getBoolean(ARG_FIT_CENTER);

        binding.ivPage.setImageResource(imageRes);
        if (fitCenter) {
            binding.ivPage.setScaleType(ImageView.ScaleType.FIT_START);
            int paddingH = (int) TypedValue.applyDimension(
                    TypedValue.COMPLEX_UNIT_DIP, 48f, getResources().getDisplayMetrics());
            int paddingTop = (int) TypedValue.applyDimension(
                    TypedValue.COMPLEX_UNIT_DIP, 56f, getResources().getDisplayMetrics());
            binding.ivPage.setPadding(paddingH, paddingTop, paddingH, 0);
        } else {
            binding.ivPage.setScaleType(ImageView.ScaleType.CENTER_CROP);
        }

        if (textAtTop) {
            binding.groupTop.setVisibility(View.VISIBLE);
            binding.tvTitleTop.setText(args.getString(ARG_TITLE));
            binding.tvSubtitleTop.setText(args.getString(ARG_SUBTITLE));
            boldenStroke(binding.tvTitleTop, 0.7f);
            boldenStroke(binding.tvSubtitleTop, 0.5f);
        } else {
            binding.vBottomScrim.setVisibility(View.VISIBLE);
            binding.groupBottom.setVisibility(View.VISIBLE);
            binding.tvTitleBottom.setText(args.getString(ARG_TITLE));
            binding.tvSubtitleBottom.setText(args.getString(ARG_SUBTITLE));
        }
    }

    private void boldenStroke(TextView textView, float strokeWidthDp) {
        float strokeWidthPx = TypedValue.applyDimension(
                TypedValue.COMPLEX_UNIT_DIP, strokeWidthDp, getResources().getDisplayMetrics());
        textView.getPaint().setStyle(Paint.Style.FILL_AND_STROKE);
        textView.getPaint().setStrokeWidth(strokeWidthPx);
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }
}
