SET search_path=v1;

CREATE TABLE IF NOT EXISTS project_secrets (
  project_id        INTEGER                     NOT NULL,
  name              TEXT                        NOT NULL,
  value             TEXT                        NOT NULL,
  created_at        TIMESTAMP WITH TIME ZONE    NOT NULL    DEFAULT CURRENT_TIMESTAMP,
  created_by        TEXT                        NOT NULL,
  last_modified_at  TIMESTAMP WITH TIME ZONE,
  last_modified_by  TEXT,
  PRIMARY KEY (project_id, name),
  FOREIGN KEY (project_id) REFERENCES projects (id) ON UPDATE CASCADE ON DELETE CASCADE
);

COMMENT ON TABLE project_secrets IS 'Stores encrypted secrets for a project';
COMMENT ON COLUMN project_secrets.project_id IS 'The project ID';
COMMENT ON COLUMN project_secrets.name IS 'The secret name';
COMMENT ON COLUMN project_secrets.value IS 'The encrypted secret value';
COMMENT ON COLUMN project_secrets.created_at IS 'When the record was created at';
COMMENT ON COLUMN project_secrets.created_by IS 'The user created the record';
COMMENT ON COLUMN project_secrets.last_modified_at IS 'When the record was last modified';
COMMENT ON COLUMN project_secrets.last_modified_by IS 'The user that last modified the record';

GRANT SELECT ON project_secrets TO reader;
GRANT SELECT, INSERT, UPDATE, DELETE ON project_secrets TO writer;
