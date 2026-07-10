package com.innocence.server.modules.memo.dto.request;

public class MemoCheckItemRequest {

    private String itemText;
    private Boolean checked;

    public String getItemText() {
        return itemText;
    }

    public void setItemText(String itemText) {
        this.itemText = itemText;
    }

    public Boolean getChecked() {
        return checked;
    }

    public void setChecked(Boolean checked) {
        this.checked = checked;
    }
}
