package com.innocence.server.modules.memo.dto.request;

import java.util.ArrayList;
import java.util.List;

public class SaveMemoRequest {

    private String title;
    private String content;
    private List<MemoCheckItemRequest> checkItemList = new ArrayList<>();

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

    public List<MemoCheckItemRequest> getCheckItemList() {
        return checkItemList;
    }

    public void setCheckItemList(List<MemoCheckItemRequest> checkItemList) {
        this.checkItemList = checkItemList == null ? new ArrayList<>() : checkItemList;
    }
}
