package com.example.whs_after_mate.ui.mycare;

import android.content.res.ColorStateList;
import android.graphics.Typeface;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.fragment.app.Fragment;

import com.example.whs_after_mate.R;
import com.example.whs_after_mate.databinding.FragmentMycareBinding;
import com.example.whs_after_mate.databinding.ItemCalendarDayBinding;
import com.example.whs_after_mate.databinding.ItemCareHistoryRowBinding;
import com.example.whs_after_mate.databinding.ItemFilterChipBinding;
import com.example.whs_after_mate.databinding.ItemHistoryCardBinding;

import java.time.LocalDate;
import java.time.YearMonth;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class MyCareFragment extends Fragment {

    private static final int GRID_CELL_COUNT = 42;
    private static final Map<LocalDate, List<CareEntry>> MOCK_CARE_ENTRIES = new LinkedHashMap<>();

    static {
        MOCK_CARE_ENTRIES.put(LocalDate.of(2026, 7, 12), Collections.singletonList(
                new CareEntry("왐 디톡스 프로그램", "윔", "윔 센터", R.color.wim, 2)));
        MOCK_CARE_ENTRIES.put(LocalDate.of(2026, 7, 19), Collections.singletonList(
                new CareEntry("브라이트닝 케어", "더나", "더나 의원", R.color.derna, 3)));
        MOCK_CARE_ENTRIES.put(LocalDate.of(2026, 7, 26), Collections.singletonList(
                new CareEntry("울쎄라 리프팅", "엠레드", "엠레드 클리닉", R.color.amred, 1)));
        MOCK_CARE_ENTRIES.put(LocalDate.of(2026, 7, 28), Collections.singletonList(
                new CareEntry("브라이트닝 부스터", "엠레드", "엠레드 클리닉", R.color.amred, 2)));
        MOCK_CARE_ENTRIES.put(LocalDate.now().plusDays(7), Collections.singletonList(
                new CareEntry("피코슈어 토닝", "엠레드", "엠레드 클리닉", R.color.amred, 3)));
    }

    private FragmentMycareBinding binding;
    private ItemCalendarDayBinding[] cells;
    private YearMonth displayedMonth;
    private LocalDate selectedDate;
    private Integer historyFilterColorRes;

    @Nullable
    @Override
    public View onCreateView(@NonNull LayoutInflater inflater,
                              @Nullable ViewGroup container, @Nullable Bundle savedInstanceState) {
        binding = FragmentMycareBinding.inflate(inflater, container, false);
        return binding.getRoot();
    }

    @Override
    public void onViewCreated(@NonNull View view, @Nullable Bundle savedInstanceState) {
        super.onViewCreated(view, savedInstanceState);

        cells = new ItemCalendarDayBinding[]{
                binding.cell0, binding.cell1, binding.cell2, binding.cell3, binding.cell4,
                binding.cell5, binding.cell6, binding.cell7, binding.cell8, binding.cell9,
                binding.cell10, binding.cell11, binding.cell12, binding.cell13, binding.cell14,
                binding.cell15, binding.cell16, binding.cell17, binding.cell18, binding.cell19,
                binding.cell20, binding.cell21, binding.cell22, binding.cell23, binding.cell24,
                binding.cell25, binding.cell26, binding.cell27, binding.cell28, binding.cell29,
                binding.cell30, binding.cell31, binding.cell32, binding.cell33, binding.cell34,
                binding.cell35, binding.cell36, binding.cell37, binding.cell38, binding.cell39,
                binding.cell40, binding.cell41,
        };

        displayedMonth = YearMonth.now();
        selectedDate = LocalDate.now();

        binding.btnPrevMonth.setOnClickListener(v -> {
            displayedMonth = displayedMonth.minusMonths(1);
            renderCalendar();
        });
        binding.btnNextMonth.setOnClickListener(v -> {
            displayedMonth = displayedMonth.plusMonths(1);
            renderCalendar();
        });

        renderCalendar();
        updateHistoryCard();
        setupFilterChips();
        renderHistoryList();
        setupSegmentTabs();
    }

    private void renderCalendar() {
        binding.textMonthYear.setText(getString(R.string.mycare_month_year_format,
                displayedMonth.getYear(), displayedMonth.getMonthValue()));

        LocalDate firstOfMonth = displayedMonth.atDay(1);
        int leadingBlanks = firstOfMonth.getDayOfWeek().getValue() % 7; // 일요일(SUNDAY)=0
        int daysInMonth = displayedMonth.lengthOfMonth();

        for (int i = 0; i < GRID_CELL_COUNT; i++) {
            int dayOfMonth = i - leadingBlanks + 1;
            ItemCalendarDayBinding cell = cells[i];

            if (dayOfMonth < 1 || dayOfMonth > daysInMonth) {
                cell.dayNumber.setText(null);
                cell.dayNumber.setBackground(null);
                cell.dayDot.setVisibility(View.INVISIBLE);
                cell.getRoot().setOnClickListener(null);
                continue;
            }

            LocalDate cellDate = displayedMonth.atDay(dayOfMonth);

            cell.dayNumber.setText(String.valueOf(dayOfMonth));
            cell.dayNumber.setTextColor(ContextCompat.getColor(requireContext(), R.color.whs_black));

            boolean isSelected = cellDate.equals(selectedDate);
            cell.dayNumber.setTypeface(null, isSelected ? Typeface.BOLD : Typeface.NORMAL);
            cell.dayNumber.setBackgroundResource(isSelected ? R.drawable.bg_today_pill : 0);

            List<CareEntry> entries = MOCK_CARE_ENTRIES.get(cellDate);
            if (entries != null && !entries.isEmpty()) {
                int color = ContextCompat.getColor(requireContext(), entries.get(0).colorRes);
                cell.dayDot.setBackgroundTintList(ColorStateList.valueOf(color));
                cell.dayDot.setVisibility(View.VISIBLE);
            } else {
                cell.dayDot.setVisibility(View.INVISIBLE);
            }

            cell.getRoot().setOnClickListener(v -> {
                selectedDate = cellDate;
                renderCalendar();
                updateHistoryCard();
            });
        }

        boolean needsSixthRow = leadingBlanks + daysInMonth > 35;
        binding.rowSix.setVisibility(needsSixthRow ? View.VISIBLE : View.GONE);
    }

    private void updateHistoryCard() {
        binding.historyItemsContainer.removeAllViews();

        List<CareEntry> entries = MOCK_CARE_ENTRIES.get(selectedDate);
        if (entries == null || entries.isEmpty()) {
            binding.historyCard.setVisibility(View.GONE);
            binding.historyEmptyState.setVisibility(View.VISIBLE);
            return;
        }
        binding.historyCard.setVisibility(View.VISIBLE);
        binding.historyEmptyState.setVisibility(View.GONE);
        binding.textHistoryTitle.setText(getString(R.string.mycare_history_title_format,
                selectedDate.getMonthValue(), selectedDate.getDayOfMonth()));

        LayoutInflater inflater = LayoutInflater.from(requireContext());
        int rowSpacing = (int) (getResources().getDisplayMetrics().density * 10f);

        for (CareEntry entry : entries) {
            ItemCareHistoryRowBinding row =
                    ItemCareHistoryRowBinding.inflate(inflater, binding.historyItemsContainer, false);
            row.historyItemTitle.setText(entry.title);
            row.historyItemBusiness.setText(entry.business);
            row.historyItemDot.setBackgroundTintList(
                    ColorStateList.valueOf(ContextCompat.getColor(requireContext(), entry.colorRes)));

            if (binding.historyItemsContainer.getChildCount() > 0) {
                ((ViewGroup.MarginLayoutParams) row.getRoot().getLayoutParams()).topMargin = rowSpacing;
            }
            binding.historyItemsContainer.addView(row.getRoot());
        }
    }

    private void setupFilterChips() {
        binding.filterChipRow.removeAllViews();
        LayoutInflater inflater = LayoutInflater.from(requireContext());

        addFilterChip(inflater, getString(R.string.mycare_filter_all), null);
        addFilterChip(inflater, "엠레드", R.color.amred);
        addFilterChip(inflater, "더나", R.color.derna);
        addFilterChip(inflater, "윔", R.color.wim);
    }

    private void addFilterChip(LayoutInflater inflater, String label, @Nullable Integer colorRes) {
        ItemFilterChipBinding chip = ItemFilterChipBinding.inflate(inflater, binding.filterChipRow, false);
        chip.chipLabel.setText(label);

        if (colorRes != null) {
            chip.chipDot.setVisibility(View.VISIBLE);
            chip.chipDot.setBackgroundTintList(
                    ColorStateList.valueOf(ContextCompat.getColor(requireContext(), colorRes)));
        } else {
            chip.chipDot.setVisibility(View.GONE);
        }

        chip.getRoot().setOnClickListener(v -> {
            historyFilterColorRes = colorRes;
            setupFilterChips();
            renderHistoryList();
        });

        applyChipSelectedStyle(chip, isSameFilter(colorRes));
        binding.filterChipRow.addView(chip.getRoot());
    }

    private boolean isSameFilter(@Nullable Integer colorRes) {
        return historyFilterColorRes == null ? colorRes == null : historyFilterColorRes.equals(colorRes);
    }

    private void applyChipSelectedStyle(ItemFilterChipBinding chip, boolean selected) {
        chip.getRoot().setBackgroundResource(
                selected ? R.drawable.bg_filter_chip_selected : R.drawable.bg_filter_chip_unselected);
        chip.chipLabel.setTextColor(ContextCompat.getColor(requireContext(),
                selected ? R.color.white : R.color.text_secondary));
        chip.chipLabel.setTypeface(null, selected ? Typeface.BOLD : Typeface.NORMAL);
    }

    private void renderHistoryList() {
        binding.historyListContainer.removeAllViews();

        List<Map.Entry<LocalDate, CareEntry>> flattened = new ArrayList<>();
        for (Map.Entry<LocalDate, List<CareEntry>> dateEntries : MOCK_CARE_ENTRIES.entrySet()) {
            for (CareEntry entry : dateEntries.getValue()) {
                if (historyFilterColorRes == null || historyFilterColorRes == entry.colorRes) {
                    flattened.add(new java.util.AbstractMap.SimpleEntry<>(dateEntries.getKey(), entry));
                }
            }
        }
        flattened.sort(Comparator.comparing((Map.Entry<LocalDate, CareEntry> e) -> e.getKey()).reversed());

        if (flattened.isEmpty()) {
            binding.historyListEmptyState.setVisibility(View.VISIBLE);
            return;
        }
        binding.historyListEmptyState.setVisibility(View.GONE);

        LayoutInflater inflater = LayoutInflater.from(requireContext());
        LocalDate today = LocalDate.now();
        int cardSpacing = (int) (getResources().getDisplayMetrics().density * 12f);

        for (Map.Entry<LocalDate, CareEntry> dated : flattened) {
            LocalDate date = dated.getKey();
            CareEntry entry = dated.getValue();

            ItemHistoryCardBinding card =
                    ItemHistoryCardBinding.inflate(inflater, binding.historyListContainer, false);
            card.cardBrand.setText(entry.brand);
            card.cardTitle.setText(entry.title);
            card.cardDateInfo.setText(getString(R.string.mycare_date_visit_format,
                    date.getMonthValue(), date.getDayOfMonth(), entry.visitNumber));
            card.cardDot.setBackgroundTintList(
                    ColorStateList.valueOf(ContextCompat.getColor(requireContext(), entry.colorRes)));

            boolean isUpcoming = date.isAfter(today);
            card.cardStatusBadge.setText(isUpcoming
                    ? R.string.mycare_status_scheduled
                    : R.string.mycare_status_completed);

            if (binding.historyListContainer.getChildCount() > 0) {
                ((ViewGroup.MarginLayoutParams) card.getRoot().getLayoutParams()).topMargin = cardSpacing;
            }
            binding.historyListContainer.addView(card.getRoot());
        }
    }

    private void setupSegmentTabs() {
        TextView[] tabs = new TextView[]{binding.tabCalendar, binding.tabHistory, binding.tabVoucher};
        for (TextView tab : tabs) {
            tab.setOnClickListener(v -> selectTab(tabs, tab));
        }
    }

    private void selectTab(TextView[] tabs, TextView selected) {
        for (TextView tab : tabs) {
            boolean isSelected = tab == selected;
            tab.setBackgroundResource(isSelected ? R.drawable.bg_segment_selected : 0);
            tab.setTextColor(ContextCompat.getColor(requireContext(),
                    isSelected ? R.color.whs_black : R.color.text_secondary));
            tab.setTypeface(null, isSelected ? Typeface.BOLD : Typeface.NORMAL);
        }

        binding.calendarTabContent.setVisibility(selected == binding.tabCalendar ? View.VISIBLE : View.GONE);
        binding.historyTabContent.setVisibility(selected == binding.tabHistory ? View.VISIBLE : View.GONE);
    }

    @Override
    public void onDestroyView() {
        super.onDestroyView();
        binding = null;
    }

    private static final class CareEntry {
        final String title;
        final String brand;
        final String business;
        final int colorRes;
        final int visitNumber;

        CareEntry(String title, String brand, String business, int colorRes, int visitNumber) {
            this.title = title;
            this.brand = brand;
            this.business = business;
            this.colorRes = colorRes;
            this.visitNumber = visitNumber;
        }
    }
}
