-- Existing installations: apply once before deploying the new server.
ALTER TABLE study_timer_record
  ADD COLUMN pomodoro_elapsed_offset_seconds INT NOT NULL DEFAULT 0,
  ADD COLUMN pomodoro_completed_base_count INT NOT NULL DEFAULT 0;
