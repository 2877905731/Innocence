package com.innocence.server.modules.memo.dto.response;

import java.util.ArrayList;
import java.util.List;

public class MemoSummaryResponse {

    private int totalCount;
    private List<MemoCardResponse> list = new ArrayList<>();

    public int getTotalCount() {
        return totalCount;
    }

    public void setTotalCount(int totalCount) {
        this.totalCount = totalCount;
    }

    public List<MemoCardResponse> getList() {
        return list;
    }

    public void setList(List<MemoCardResponse> list) {
        this.list = list == null ? new ArrayList<>() : list;
    }
}
