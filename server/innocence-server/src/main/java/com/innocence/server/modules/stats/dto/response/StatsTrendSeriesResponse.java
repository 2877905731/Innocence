package com.innocence.server.modules.stats.dto.response;

import java.util.ArrayList;
import java.util.List;

public class StatsTrendSeriesResponse {

    private String name;
    private List<Integer> data = new ArrayList<>();

    public StatsTrendSeriesResponse() {
    }

    public StatsTrendSeriesResponse(String name, List<Integer> data) {
        this.name = name;
        this.data = data == null ? new ArrayList<>() : data;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public List<Integer> getData() {
        return data;
    }

    public void setData(List<Integer> data) {
        this.data = data == null ? new ArrayList<>() : data;
    }
}
