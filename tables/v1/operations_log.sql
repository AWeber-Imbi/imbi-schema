SET search_path=v1, public, pg_catalog;

CREATE TABLE IF NOT EXISTS operations_log (
  id            BIGINT                    NOT NULL  GENERATED ALWAYS AS IDENTITY  PRIMARY KEY,
  occurred_at   TIMESTAMP WITH TIME ZONE  NOT NULL  DEFAULT CURRENT_TIMESTAMP,
  recorded_at   TIMESTAMP WITH TIME ZONE  NOT NULL  DEFAULT CURRENT_TIMESTAMP,
  recorded_by   TEXT                      NOT NULL,
  completed_at  TIMESTAMP WITH TIME ZONE,
  project_id    INTEGER,
  environment   TEXT                      NOT NULL,
  change_type   change_type               NOT NULL,
  description   TEXT                      NOT NULL,
  link          TEXT,
  notes         TEXT,
  performed_by  TEXT,
  ticket_slug   TEXT,
  version       TEXT,
  FOREIGN KEY (project_id) REFERENCES v1.projects (id) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (environment) REFERENCES v1.environments (name) ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY (performed_by) REFERENCES v1.users (username) ON UPDATE CASCADE ON DELETE SET NULL
);

COMMENT ON TABLE operations_log IS 'An audit log of entity operational changes';
COMMENT ON COLUMN operations_log.id IS 'A surrogate key for modifying and deleting the record';
COMMENT ON COLUMN operations_log.occurred_at IS 'When the change occurred (user input)';
COMMENT ON COLUMN operations_log.recorded_at IS 'When the record was created';
COMMENT ON COLUMN operations_log.recorded_by IS 'The authenticated user who recorded the change';
COMMENT ON COLUMN operations_log.performed_by IS 'Optional user to display (user input)';
COMMENT ON COLUMN operations_log.completed_at IS 'If specified, indicates the change occurred over a span of time';
COMMENT ON COLUMN operations_log.project_id IS 'The optional ID of the project for the change';
COMMENT ON COLUMN operations_log.environment IS 'The operational environment the change was made in';
COMMENT ON COLUMN operations_log.change_type IS 'The type of change that was made';
COMMENT ON COLUMN operations_log.description IS 'The single line description of the change';
COMMENT ON COLUMN operations_log.link IS 'An optional link for additional context to the ops log entry';
COMMENT ON COLUMN operations_log.notes IS 'Optional notes for the change in markdown format';
COMMENT ON COLUMN operations_log.ticket_slug IS 'An optional slug of the ticket that the change was made for';
COMMENT ON COLUMN operations_log.version IS 'An optional version that the change was made for';

CREATE INDEX ON operations_log (performed_by);
CREATE INDEX ON operations_log (project_id);
CREATE INDEX ON operations_log (recorded_at);

GRANT SELECT ON operations_log TO reader;
GRANT SELECT, INSERT, UPDATE, DELETE ON operations_log TO writer;
