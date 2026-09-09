package com.innocence.server.modules.sync.domain;

import java.time.LocalDateTime;

public class SyncImportOperationRecord {

    private Long id;
    private Long userId;
    private String localProfileId;
    private String operationId;
    private String aggregateType;
    private String aggregateId;
    private String operationType;
    private String status;
    private String message;
    private String serverAggregateId;
    private LocalDateTime createTime;
    private LocalDateTime updateTime;

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public Long getUserId() { return userId; }
    public void setUserId(Long userId) { this.userId = userId; }
    public String getLocalProfileId() { return localProfileId; }
    public void setLocalProfileId(String localProfileId) { this.localProfileId = localProfileId; }
    public String getOperationId() { return operationId; }
    public void setOperationId(String operationId) { this.operationId = operationId; }
    public String getAggregateType() { return aggregateType; }
    public void setAggregateType(String aggregateType) { this.aggregateType = aggregateType; }
    public String getAggregateId() { return aggregateId; }
    public void setAggregateId(String aggregateId) { this.aggregateId = aggregateId; }
    public String getOperationType() { return operationType; }
    public void setOperationType(String operationType) { this.operationType = operationType; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public String getMessage() { return message; }
    public void setMessage(String message) { this.message = message; }
    public String getServerAggregateId() { return serverAggregateId; }
    public void setServerAggregateId(String serverAggregateId) { this.serverAggregateId = serverAggregateId; }
    public LocalDateTime getCreateTime() { return createTime; }
    public void setCreateTime(LocalDateTime createTime) { this.createTime = createTime; }
    public LocalDateTime getUpdateTime() { return updateTime; }
    public void setUpdateTime(LocalDateTime updateTime) { this.updateTime = updateTime; }
}
