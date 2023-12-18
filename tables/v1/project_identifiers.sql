SET SEARCH_PATH TO v1;

CREATE TABLE IF NOT EXISTS project_identifiers (
    external_id       TEXT NOT NULL,
    integration_name  TEXT NOT NULL,
    project_id        INT NOT NULL,
    created_at        TIMESTAMP WITH TIME ZONE  NOT NULL  DEFAULT CURRENT_TIMESTAMP,
    created_by        TEXT                      NOT NULL  DEFAULT 'system',
    last_modified_at  TIMESTAMP WITH TIME ZONE,
    last_modified_by  TEXT,
    PRIMARY KEY (integration_name, project_id),
    FOREIGN KEY (integration_name) REFERENCES v1.integrations (name) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (project_id) REFERENCES v1.projects (id) ON UPDATE CASCADE ON DELETE CASCADE
);

COMMENT ON TABLE project_identifiers IS 'Surrogate identifiers for Imbi projects';

COMMENT ON COLUMN project_identifiers.external_id IS 'Identifier for the project in `integration_name`';
COMMENT ON COLUMN project_identifiers.integration_name IS 'Name of the application that owns this identifier';
COMMENT ON COLUMN project_identifiers.project_id IS 'Imbi project that the identifier refers to';
COMMENT ON COLUMN project_identifiers.created_at IS 'When the record was created at';
COMMENT ON COLUMN project_identifiers.created_by IS 'The user that created the application';
COMMENT ON COLUMN project_identifiers.last_modified_at IS 'When the record was was last modified at';
COMMENT ON COLUMN project_identifiers.last_modified_by IS 'The user that last modified the record';

GRANT SELECT ON project_identifiers TO reader;
GRANT SELECT, INSERT, UPDATE, DELETE ON project_identifiers to writer;
GRANT SELECT, INSERT, UPDATE, DELETE ON project_identifiers to admin;
