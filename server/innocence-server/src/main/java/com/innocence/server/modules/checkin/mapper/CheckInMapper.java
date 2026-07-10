package com.innocence.server.modules.checkin.mapper;

import com.innocence.server.modules.checkin.domain.CheckInFailRecord;
import com.innocence.server.modules.checkin.domain.CheckInRecord;
import com.innocence.server.modules.checkin.domain.CheckInSummary;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import java.time.LocalDate;

@Mapper
public interface CheckInMapper {

    CheckInRecord findCheckInRecordByUserIdAndDate(@Param("userId") Long userId, @Param("checkInDate") LocalDate checkInDate);

    CheckInSummary findCheckInSummaryByUserId(@Param("userId") Long userId);

    CheckInFailRecord findCheckInFailRecordByUserIdAndDate(@Param("userId") Long userId, @Param("checkInDate") LocalDate checkInDate);

    Integer countCheckInRecordsByUserId(@Param("userId") Long userId);

    void insertCheckInRecord(CheckInRecord record);

    void insertCheckInSummary(CheckInSummary summary);

    void updateCheckInSummary(CheckInSummary summary);

    void upsertCheckInFailRecord(CheckInFailRecord failRecord);

    int deleteCheckInFailRecordByUserIdAndDate(@Param("userId") Long userId, @Param("checkInDate") LocalDate checkInDate);
}
