SET SEARCH_PATH to v1;

CREATE TABLE IF NOT EXISTS integration_notifications (
  notification_name  TEXT                      NOT NULL,
  integration_name   TEXT                      NOT NULL,
  id_pattern         TEXT                      NOT NULL,
  documentation      TEXT,
  verification_token TEXT,
  default_action     notification_action_type  NOT NULL  DEFAULT 'process',
  created_at         TIMESTAMP WITH TIME ZONE  NOT NULL  DEFAULT CURRENT_TIMESTAMP,
  created_by         TEXT                      NOT NULL  DEFAULT 'system',
  last_modified_at   TIMESTAMP WITH TIME ZONE,
  last_modified_by   TEXT,
  PRIMARY KEY (notification_name, integration_name),
  FOREIGN KEY (integration_name) REFERENCES integrations (name) ON DELETE CASCADE ON UPDATE CASCADE
);

COMMENT ON TABLE integration_notifications IS 'Notifications from Integrated Applications';

COMMENT ON COLUMN integration_notifications.notification_name IS 'Human-readable name of the notification';
COMMENT ON COLUMN integration_notifications.integration_name IS 'Name of the integrated application that sends this notification';
COMMENT ON COLUMN integration_notifications.id_pattern IS 'JSON pointer to the surrogate identifier in the notification';
COMMENT ON COLUMN integration_notifications.documentation IS 'Optional link to API documentation';
COMMENT ON COLUMN integration_notifications.verification_token IS 'Encrypted verification token for this specific notification';
COMMENT ON COLUMN integration_notifications.default_action IS 'Should this notification be ignored or processed by default';
COMMENT ON COLUMN integration_notifications.created_at IS 'When the record was created at';
COMMENT ON COLUMN integration_notifications.created_by IS 'The user that created the record';
COMMENT ON COLUMN integration_notifications.last_modified_at IS 'When the record was was last modified at';
COMMENT ON COLUMN integration_notifications.last_modified_by IS 'The user that last modified the record';

GRANT SELECT ON integration_notifications TO reader;
GRANT SELECT, INSERT, UPDATE, DELETE ON integration_notifications TO admin;
