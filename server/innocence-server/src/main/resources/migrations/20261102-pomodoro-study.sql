-- Apply once, before deploying the cumulative study-record endpoint.
ALTER TABLE study_timer_record
  ADD COLUMN client_pomodoro_key VARCHAR(160) NULL,
  ADD UNIQUE KEY uk_study_timer_pomodoro (user_id, client_pomodoro_key);
