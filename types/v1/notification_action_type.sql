SET search_path=v1;

CREATE TYPE notification_action_type AS ENUM ('ignore', 'process');

COMMENT ON TYPE notification_action_type IS 'Used to indicate the action type for a notification or field';
