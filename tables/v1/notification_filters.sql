SET SEARCH_PATH TO v1;

CREATE TABLE IF NOT EXISTS notification_filters (
  filter_name        TEXT                               NOT NULL,
  integration_name   TEXT                               NOT NULL,
  notification_name  TEXT                               NOT NULL,
  pattern            TEXT                               NOT NULL,
  operation          notification_filter_operation_type NOT NULL,
  value              TEXT                               NOT NULL,
  action             notification_action_type           NOT NULL,
  created_at         TIMESTAMP WITH TIME ZONE           NOT NULL  DEFAULT CURRENT_TIMESTAMP,
  created_by         TEXT                               NOT NULL  DEFAULT 'system',
  last_modified_at   TIMESTAMP WITH TIME ZONE,
  last_modified_by   TEXT,
     PRIMARY KEY (filter_name, integration_name, notification_name),
     FOREIGN KEY (integration_name) REFERENCES integrations (name) ON DELETE CASCADE ON UPDATE CASCADE,
     FOREIGN KEY (integration_name, notification_name)
  REFERENCES integration_notifications (integration_name, notification_name)
          ON DELETE CASCADE
          ON UPDATE CASCADE
);

COMMENT ON TABLE notification_filters IS 'Accept/reject filters for incoming notifications';

COMMENT ON COLUMN notification_filters.filter_name IS 'Human-readable name of the filter';
COMMENT ON COLUMN notification_filters.integration_name IS 'Name of the integrated application that sends the notification';
COMMENT ON COLUMN notification_filters.notification_name IS 'Human-readable name of the notification that this filter applies to';
COMMENT ON COLUMN notification_filters.pattern IS 'JSON pointer to the property in the notification that this filter evaluates';
COMMENT ON COLUMN notification_filters.operation IS 'Evaluation operation';
COMMENT ON COLUMN notification_filters.value IS 'Evaluation value';
COMMENT ON COLUMN notification_filters.action IS 'Action to apply if the filter evaluation matches';
COMMENT ON COLUMN notification_filters.created_at IS 'When the record was created at';
COMMENT ON COLUMN notification_filters.created_by IS 'The user that created the record';
COMMENT ON COLUMN notification_filters.last_modified_at IS 'When the record was was last modified at';
COMMENT ON COLUMN notification_filters.last_modified_by IS 'The user that last modified the record';

GRANT SELECT ON notification_filters TO reader;
GRANT SELECT, INSERT, UPDATE, DELETE ON notification_filters TO admin;
