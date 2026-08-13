package com.example.whs_after_mate.ui.airecommend;

import androidx.lifecycle.ViewModel;

import com.example.whs_after_mate.R;

import java.util.Arrays;
import java.util.List;

public class AiRecommendViewModel extends ViewModel {

    private final String userName = "지수";

    private final List<String> selectedConcerns = Arrays.asList("리프팅", "색소침착 개선");

    private final String recommendCareTitle = "브라이트닝 부스터 케어";
    private final String recommendMeta = "더나 클리닉 · 권장 시점 2~3주 후";
    private final String lastCareSummary = "최근 관리: 울쎄라 · 21일 전";

    private final List<String> reasons = Arrays.asList(
            "색소침착 개선에 도움이 돼요.",
            "피부 톤을 환하게 밝혀줘요.",
            "울쎄라 시술 후 회복 관리에 도움이 돼요."
    );

    private final List<RecentCareItem> recentCareItems = Arrays.asList(
            new RecentCareItem("울쎄라", "엠레드", 21, R.color.amred),
            new RecentCareItem("인모드", "더나", 44, R.color.derna)
    );

    private final List<String> relatedConcerns = Arrays.asList("피부톤 관리", "색소 관리", "톤 업 관리");

    private final List<ClinicContact> clinicContacts = Arrays.asList(
            new ClinicContact("엠레드 클리닉", false),
            new ClinicContact("더나 클리닉", true),
            new ClinicContact("윔 센터", false)
    );

    public String getUserName() {
        return userName;
    }

    public List<String> getSelectedConcerns() {
        return selectedConcerns;
    }

    public String getRecommendCareTitle() {
        return recommendCareTitle;
    }

    public String getRecommendMeta() {
        return recommendMeta;
    }

    public String getLastCareSummary() {
        return lastCareSummary;
    }

    public List<String> getReasons() {
        return reasons;
    }

    public List<RecentCareItem> getRecentCareItems() {
        return recentCareItems;
    }

    public List<String> getRelatedConcerns() {
        return relatedConcerns;
    }

    public ClinicContact getSavedClinicContact() {
        for (ClinicContact contact : clinicContacts) {
            if (contact.hasSavedData) {
                return contact;
            }
        }
        return null;
    }
}
