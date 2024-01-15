SET search_path=v1;

CREATE TYPE notification_filter_operation_type AS ENUM ('==', '!=');

COMMENT ON TYPE notification_filter_operation_type IS 'Used to indicate the comparison operation for a notification filter';
