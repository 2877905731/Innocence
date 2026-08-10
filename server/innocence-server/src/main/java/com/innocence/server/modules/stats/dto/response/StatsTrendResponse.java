package com.innocence.server.modules.stats.dto.response;

import java.util.ArrayList;
import java.util.List;

public class StatsTrendResponse {

    private List<String> xAxis = new ArrayList<>();
    private List<StatsTrendSeriesResponse> series = new ArrayList<>();

    public List<String> getXAxis() {
        return xAxis;
    }

    public void setXAxis(List<String> xAxis) {
        this.xAxis = xAxis == null ? new ArrayList<>() : xAxis;
    }

    public List<StatsTrendSeriesResponse> getSeries() {
        return series;
    }

    public void setSeries(List<StatsTrendSeriesResponse> series) {
        this.series = series == null ? new ArrayList<>() : series;
    }
}
