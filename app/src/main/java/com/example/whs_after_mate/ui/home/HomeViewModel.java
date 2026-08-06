package com.example.whs_after_mate.ui.home;

import androidx.lifecycle.ViewModel;

import com.example.whs_after_mate.R;

import java.util.Arrays;
import java.util.List;

public class HomeViewModel extends ViewModel {

    private final String userName = "지수";
    private final String dateLabel = "7월 31일 · 울쎄라 리프팅 5일차";
    private final String brandLabel = "엠레드 · 오늘의 사후관리";
    private final String careTitle = "울쎄라 리프팅 · 5일차 케어";
    private final String careSubtitle = "회복기 중반, 오늘 지켜야 할 점을 확인해보세요";
    private final String recommendTitle = "브라이트닝 부스터 케어";
    private final String recommendSubtitle = "울쎄라 시술 후 남을 수 있는 색소침착 예방을 위해 추천드려요";

    private final List<VoucherItem> voucherItems = Arrays.asList(
            new VoucherItem("엠레드 울쎄라 3회권", 1, 3, R.color.amred),
            new VoucherItem("더나 입술 필러", 1, 3, R.color.derna),
            new VoucherItem("윔 지방분해 3회권", 2, 3, R.color.wim)
    );

    public String getUserName() {
        return userName;
    }

    public String getDateLabel() {
        return dateLabel;
    }

    public String getBrandLabel() {
        return brandLabel;
    }

    public String getCareTitle() {
        return careTitle;
    }

    public String getCareSubtitle() {
        return careSubtitle;
    }

    public String getRecommendTitle() {
        return recommendTitle;
    }

    public String getRecommendSubtitle() {
        return recommendSubtitle;
    }

    public List<VoucherItem> getVoucherItems() {
        return voucherItems;
    }
}
