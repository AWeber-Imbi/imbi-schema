SET SEARCH_PATH TO v1;

CREATE TABLE IF NOT EXISTS integrations (
    "name"            TEXT                      NOT NULL  PRIMARY KEY,
    created_at        TIMESTAMP WITH TIME ZONE  NOT NULL  DEFAULT CURRENT_TIMESTAMP,
    created_by        TEXT                      NOT NULL  DEFAULT 'system',
    last_modified_at  TIMESTAMP WITH TIME ZONE,
    last_modified_by  TEXT,
    api_endpoint      TEXT                      NOT NULL,
    api_secret        TEXT
);

COMMENT ON TABLE integrations IS 'Integrated Applications';

COMMENT ON COLUMN integrations.name IS 'The common name of the application';
COMMENT ON COLUMN integrations.created_at IS 'When the record was created at';
COMMENT ON COLUMN integrations.created_by IS 'The user that created the application';
COMMENT ON COLUMN integrations.last_modified_at IS 'When the record was was last modified at';
COMMENT ON COLUMN integrations.last_modified_by IS 'The user that last modified the record';
COMMENT ON COLUMN integrations.api_endpoint IS 'URL for the root of the application API';
COMMENT ON COLUMN integrations.api_secret IS 'Optional global secret for this application';

GRANT SELECT ON integrations TO reader;
GRANT SELECT, INSERT, UPDATE, DELETE ON integrations to admin;
