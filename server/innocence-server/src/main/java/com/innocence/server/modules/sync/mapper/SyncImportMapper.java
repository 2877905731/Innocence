package com.innocence.server.modules.sync.mapper;

import com.innocence.server.modules.sync.domain.SyncImportOperationRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface SyncImportMapper {

    SyncImportOperationRecord findByUserIdAndOperationId(
            @Param("userId") Long userId,
            @Param("operationId") String operationId
    );

    String findServerAggregateId(
            @Param("userId") Long userId,
            @Param("localProfileId") String localProfileId,
            @Param("aggregateType") String aggregateType,
            @Param("aggregateId") String aggregateId
    );

    void upsertOperation(SyncImportOperationRecord record);
}
