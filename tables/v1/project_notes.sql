SET SEARCH_PATH TO v1;

DROP TABLE IF EXISTS project_notes;

CREATE TABLE project_notes (
    id            SERIAL                   NOT NULL  PRIMARY KEY,
    project_id    INTEGER                  NOT NULL,
    created_by    TEXT                     NOT NULL,
    created_at    TIMESTAMP WITH TIME ZONE NOT NULL  DEFAULT CURRENT_TIMESTAMP,
    content       TEXT                     NOT NULL,
    updated_by    TEXT,
    updated_at    TIMESTAMP WITH TIME ZONE,
    UNIQUE (project_id, created_at, created_by),
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE ON UPDATE CASCADE
);

COMMENT ON TABLE project_notes IS 'Stores notes about a project';
COMMENT ON COLUMN project_notes.id IS 'Surrogate key for URLs and linking';
COMMENT ON COLUMN project_notes.project_id IS 'The project ID';
COMMENT ON COLUMN project_notes.created_by IS 'The user that created the note';
COMMENT ON COLUMN project_notes.created_at IS 'Time that the note was created';
COMMENT ON COLUMN project_notes.content IS 'Textual content of the note';
COMMENT ON COLUMN project_notes.updated_by IS 'The user that last updated the note';
COMMENT ON COLUMN project_notes.updated_at IS 'Time that the note was last updated or NULL';

GRANT SELECT ON project_notes TO reader;
GRANT SELECT, INSERT, UPDATE, DELETE ON project_notes TO writer;
