package com.innocence.server.modules.memo.mapper;

import com.innocence.server.modules.memo.domain.MemoCardRow;
import com.innocence.server.modules.memo.domain.MemoCheckItem;
import com.innocence.server.modules.memo.domain.MemoRecord;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.util.List;

@Mapper
public interface MemoMapper {

    List<MemoCardRow> findMemoCardsByUserId(
            @Param("userId") Long userId,
            @Param("limit") Integer limit,
            @Param("offset") Integer offset
    );

    Integer countMemosByUserId(@Param("userId") Long userId);

    MemoRecord findMemoByIdAndUserId(
            @Param("memoId") Long memoId,
            @Param("userId") Long userId
    );

    List<MemoCheckItem> findCheckItemsByMemoId(@Param("memoId") Long memoId);

    Integer findMaxSortNoByUserId(@Param("userId") Long userId);

    void insertMemo(MemoRecord memoRecord);

    int updateMemo(MemoRecord memoRecord);

    int deleteMemoByIdAndUserId(
            @Param("memoId") Long memoId,
            @Param("userId") Long userId
    );

    int deleteCheckItemsByMemoId(@Param("memoId") Long memoId);

    void insertCheckItem(MemoCheckItem checkItem);
}
