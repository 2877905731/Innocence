package com.innocence.server.modules.memo.dto.response;

import java.util.ArrayList;
import java.util.List;

public class MemoCardResponse {

    private Long memoId;
    private String title;
    private String content;
    private int totalItemCount;
    private int checkedItemCount;
    private String updateTime;
    private List<MemoCheckItemResponse> checkItems = new ArrayList<>();

    public Long getMemoId() {
        return memoId;
    }

    public void setMemoId(Long memoId) {
        this.memoId = memoId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getContent() {
        return content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public int getTotalItemCount() {
        return totalItemCount;
    }

    public void setTotalItemCount(int totalItemCount) {
        this.totalItemCount = totalItemCount;
    }

    public int getCheckedItemCount() {
        return checkedItemCount;
    }

    public void setCheckedItemCount(int checkedItemCount) {
        this.checkedItemCount = checkedItemCount;
    }

    public String getUpdateTime() {
        return updateTime;
    }

    public void setUpdateTime(String updateTime) {
        this.updateTime = updateTime;
    }

    public List<MemoCheckItemResponse> getCheckItems() {
        return checkItems;
    }

    public void setCheckItems(List<MemoCheckItemResponse> checkItems) {
        this.checkItems = checkItems == null ? new ArrayList<>() : checkItems;
    }
}
