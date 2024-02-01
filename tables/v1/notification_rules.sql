SET SEARCH_PATH TO v1;

CREATE TABLE IF NOT EXISTS notification_rules (
    fact_type_id      INTEGER                   NOT NULL,
    integration_name  TEXT                      NOT NULL,
    notification_name TEXT                      NOT NULL,
    pattern           TEXT                      NOT NULL,
    created_at        TIMESTAMP WITH TIME ZONE  NOT NULL  DEFAULT CURRENT_TIMESTAMP,
    created_by        TEXT                      NOT NULL  DEFAULT 'system',
    last_modified_at  TIMESTAMP WITH TIME ZONE,
    last_modified_by  TEXT,
    PRIMARY KEY (fact_type_id, integration_name, notification_name),
    FOREIGN KEY (fact_type_id) REFERENCES project_fact_types (id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (integration_name, notification_name)
            REFERENCES integration_notifications (integration_name, notification_name)
            ON DELETE CASCADE ON UPDATE CASCADE
);

COMMENT ON TABLE notification_rules IS 'Fact update rules for notifications from Integrated Applications';

COMMENT ON COLUMN notification_rules.fact_type_id IS 'ID of the project fact to update';
COMMENT ON COLUMN notification_rules.integration_name IS 'Name of the integrated application that sends the notification';
COMMENT ON COLUMN notification_rules.notification_name IS 'Name of the notification this rule applies to';
COMMENT ON COLUMN notification_rules.pattern IS 'JSON pointer to the value in the notification to use as the fact value';
COMMENT ON COLUMN notification_rules.created_at IS 'When the record was created at';
COMMENT ON COLUMN notification_rules.created_by IS 'The user that created the record';
COMMENT ON COLUMN notification_rules.last_modified_at IS 'When the record was was last modified at';
COMMENT ON COLUMN notification_rules.last_modified_by IS 'The user that last modified the record';

GRANT SELECT ON notification_rules TO reader;
GRANT SELECT, INSERT, UPDATE, DELETE ON notification_rules TO admin;
