package com.innocence.server.modules.memo.service;

import com.innocence.server.common.exception.BusinessException;
import com.innocence.server.common.exception.ErrorCode;
import com.innocence.server.modules.account.domain.User;
import com.innocence.server.modules.account.mapper.UserMapper;
import com.innocence.server.modules.memo.domain.MemoCardRow;
import com.innocence.server.modules.memo.domain.MemoCheckItem;
import com.innocence.server.modules.memo.domain.MemoRecord;
import com.innocence.server.modules.memo.dto.request.MemoCheckItemRequest;
import com.innocence.server.modules.memo.dto.request.SaveMemoRequest;
import com.innocence.server.modules.memo.dto.response.MemoCardResponse;
import com.innocence.server.modules.memo.dto.response.MemoCheckItemResponse;
import com.innocence.server.modules.memo.dto.response.MemoSummaryResponse;
import com.innocence.server.modules.memo.mapper.MemoMapper;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@Service
public class MemoService {

    private static final int MAX_PAGE_SIZE = 50;
    private static final int MAX_TITLE_LENGTH = 128;
    private static final int MAX_CONTENT_LENGTH = 5000;
    private static final int MAX_CHECK_ITEM_COUNT = 30;
    private static final int MAX_CHECK_ITEM_LENGTH = 255;
    private static final DateTimeFormatter DATE_TIME_FORMATTER =
            DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");

    private final MemoMapper memoMapper;
    private final UserMapper userMapper;

    public MemoService(
            MemoMapper memoMapper,
            UserMapper userMapper
    ) {
        this.memoMapper = memoMapper;
        this.userMapper = userMapper;
    }

    @Transactional(readOnly = true)
    public List<MemoCardResponse> listMemos(Long userId, Integer pageNo, Integer pageSize) {
        requireUser(userId);
        int normalizedPageNo = pageNo == null || pageNo < 1 ? 1 : pageNo;
        int normalizedPageSize = pageSize == null || pageSize < 1
                ? 20
                : Math.min(pageSize, MAX_PAGE_SIZE);
        int offset = (normalizedPageNo - 1) * normalizedPageSize;

        List<MemoCardRow> rows = memoMapper.findMemoCardsByUserId(
                userId,
                normalizedPageSize,
                offset
        );
        return buildMemoCards(rows);
    }

    @Transactional(readOnly = true)
    public MemoCardResponse getMemo(Long userId, Long memoId) {
        requireUser(userId);
        MemoRecord memo = requireMemo(userId, memoId);
        return buildMemoCard(memo);
    }

    @Transactional
    public MemoCardResponse createMemo(Long userId, SaveMemoRequest request) {
        requireUser(userId);
        NormalizedMemo normalizedMemo = normalizeMemo(request);

        MemoRecord memoRecord = new MemoRecord();
        memoRecord.setUserId(userId);
        memoRecord.setTitle(normalizedMemo.title());
        memoRecord.setContentText(normalizedMemo.content());
        memoRecord.setSortNo(defaultNumber(memoMapper.findMaxSortNoByUserId(userId)) + 1);
        memoMapper.insertMemo(memoRecord);
        saveCheckItems(memoRecord.getId(), normalizedMemo.checkItems());
        return buildMemoCard(requireMemo(userId, memoRecord.getId()));
    }

    @Transactional
    public MemoCardResponse updateMemo(Long userId, Long memoId, SaveMemoRequest request) {
        requireUser(userId);
        MemoRecord memoRecord = requireMemo(userId, memoId);
        NormalizedMemo normalizedMemo = normalizeMemo(request);

        memoRecord.setTitle(normalizedMemo.title());
        memoRecord.setContentText(normalizedMemo.content());
        memoMapper.updateMemo(memoRecord);
        memoMapper.deleteCheckItemsByMemoId(memoId);
        saveCheckItems(memoId, normalizedMemo.checkItems());
        return buildMemoCard(requireMemo(userId, memoId));
    }

    @Transactional
    public boolean deleteMemo(Long userId, Long memoId) {
        requireUser(userId);
        requireMemo(userId, memoId);
        memoMapper.deleteCheckItemsByMemoId(memoId);
        return memoMapper.deleteMemoByIdAndUserId(memoId, userId) > 0;
    }

    @Transactional(readOnly = true)
    public MemoSummaryResponse getSummary(Long userId, int limit) {
        requireUser(userId);
        List<MemoCardRow> rows = memoMapper.findMemoCardsByUserId(
                userId,
                Math.max(limit, 0),
                0
        );
        MemoSummaryResponse response = new MemoSummaryResponse();
        response.setTotalCount(defaultNumber(memoMapper.countMemosByUserId(userId)));
        response.setList(buildMemoCards(rows));
        return response;
    }

    private List<MemoCardResponse> buildMemoCards(List<MemoCardRow> rows) {
        List<MemoCardResponse> responses = new ArrayList<>();
        for (MemoCardRow row : rows) {
            responses.add(buildMemoCard(row));
        }
        return responses;
    }

    private MemoCardResponse buildMemoCard(MemoRecord memo) {
        MemoCardResponse response = new MemoCardResponse();
        response.setMemoId(memo.getId());
        response.setTitle(defaultText(memo.getTitle()));
        response.setContent(defaultText(memo.getContentText()));
        response.setUpdateTime(formatDateTime(memo.getUpdateTime()));

        List<MemoCheckItem> checkItems = memoMapper.findCheckItemsByMemoId(memo.getId());
        List<MemoCheckItemResponse> itemResponses = new ArrayList<>();
        int checkedCount = 0;
        for (MemoCheckItem item : checkItems) {
            MemoCheckItemResponse itemResponse = new MemoCheckItemResponse();
            itemResponse.setId(item.getId());
            itemResponse.setItemText(defaultText(item.getItemText()));
            itemResponse.setChecked(defaultNumber(item.getCheckedFlag()) == 1);
            itemResponse.setSortNo(defaultNumber(item.getSortNo()));
            itemResponses.add(itemResponse);
            if (itemResponse.isChecked()) {
                checkedCount++;
            }
        }

        response.setCheckItems(itemResponses);
        response.setTotalItemCount(itemResponses.size());
        response.setCheckedItemCount(checkedCount);
        return response;
    }

    private MemoCardResponse buildMemoCard(MemoCardRow row) {
        MemoCardResponse response = new MemoCardResponse();
        response.setMemoId(row.getId());
        response.setTitle(defaultText(row.getTitle()));
        response.setContent(defaultText(row.getContentText()));
        response.setTotalItemCount(defaultNumber(row.getTotalItemCount()));
        response.setCheckedItemCount(defaultNumber(row.getCheckedItemCount()));
        response.setUpdateTime(formatDateTime(row.getUpdateTime()));
        response.setCheckItems(new ArrayList<>());
        return response;
    }

    private void saveCheckItems(Long memoId, List<NormalizedCheckItem> checkItems) {
        int sortNo = 0;
        for (NormalizedCheckItem checkItem : checkItems) {
            MemoCheckItem memoCheckItem = new MemoCheckItem();
            memoCheckItem.setMemoId(memoId);
            memoCheckItem.setItemText(checkItem.itemText());
            memoCheckItem.setCheckedFlag(checkItem.checked() ? 1 : 0);
            memoCheckItem.setSortNo(sortNo++);
            memoMapper.insertCheckItem(memoCheckItem);
        }
    }

    private MemoRecord requireMemo(Long userId, Long memoId) {
        if (memoId == null || memoId <= 0) {
            throw new BusinessException(ErrorCode.BAD_REQUEST, "Memo id is required.");
        }
        MemoRecord memo = memoMapper.findMemoByIdAndUserId(memoId, userId);
        if (memo == null) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "The memo was not found.");
        }
        return memo;
    }

    private User requireUser(Long userId) {
        User user = userMapper.findUserById(userId);
        if (user == null || defaultNumber(user.getStatus()) != 1) {
            throw new BusinessException(ErrorCode.NOT_FOUND, "The selected user was not found.");
        }
        return user;
    }

    private NormalizedMemo normalizeMemo(SaveMemoRequest request) {
        String title = request == null ? "" : defaultText(request.getTitle());
        String content = request == null ? "" : defaultText(request.getContent());
        if (title.length() > MAX_TITLE_LENGTH) {
            throw new BusinessException(
                    ErrorCode.BAD_REQUEST,
                    "Memo title cannot exceed 128 characters."
            );
        }
        if (content.length() > MAX_CONTENT_LENGTH) {
            throw new BusinessException(
                    ErrorCode.BAD_REQUEST,
                    "Memo content cannot exceed 5000 characters."
            );
        }

        List<NormalizedCheckItem> normalizedItems = new ArrayList<>();
        List<MemoCheckItemRequest> sourceItems =
                request == null ? new ArrayList<>() : request.getCheckItemList();
        if (sourceItems.size() > MAX_CHECK_ITEM_COUNT) {
            throw new BusinessException(
                    ErrorCode.BAD_REQUEST,
                    "A memo can contain up to 30 checklist items."
            );
        }
        for (MemoCheckItemRequest item : sourceItems) {
            String itemText = item == null ? "" : defaultText(item.getItemText());
            if (itemText.isEmpty()) {
                continue;
            }
            if (itemText.length() > MAX_CHECK_ITEM_LENGTH) {
                throw new BusinessException(
                        ErrorCode.BAD_REQUEST,
                        "Each checklist item cannot exceed 255 characters."
                );
            }
            normalizedItems.add(new NormalizedCheckItem(
                    itemText,
                    item != null && Boolean.TRUE.equals(item.getChecked())
            ));
        }

        if (title.isEmpty() && content.isEmpty() && normalizedItems.isEmpty()) {
            throw new BusinessException(
                    ErrorCode.BAD_REQUEST,
                    "Memo content cannot be empty."
            );
        }

        return new NormalizedMemo(title, content, normalizedItems);
    }

    private int defaultNumber(Integer value) {
        return value == null ? 0 : Math.max(value, 0);
    }

    private String defaultText(String value) {
        return value == null ? "" : value.trim();
    }

    private String formatDateTime(LocalDateTime value) {
        if (value == null) {
            return "";
        }
        return value.format(DATE_TIME_FORMATTER);
    }

    private record NormalizedMemo(
            String title,
            String content,
            List<NormalizedCheckItem> checkItems
    ) {
    }

    private record NormalizedCheckItem(
            String itemText,
            boolean checked
    ) {
    }
}
