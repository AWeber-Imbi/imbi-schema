SET SEARCH_PATH TO v1;

DROP TABLE IF EXISTS project_notes;

CREATE TABLE project_notes (
    project_id INTEGER,
    recorded_by TEXT,
    recorded_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    content TEXT NOT NULL,
    updated_by TEXT,
    updated_at TIMESTAMP WITH TIME ZONE,
    PRIMARY KEY (project_id, recorded_at, recorded_by),
    FOREIGN KEY (project_id) REFERENCES projects(id) ON DELETE CASCADE ON UPDATE CASCADE
);

COMMENT ON TABLE project_notes IS 'Stores notes about a project';
COMMENT ON COLUMN project_notes.project_id IS 'The project ID';
COMMENT ON COLUMN project_notes.recorded_by IS 'The user that created the note';
COMMENT ON COLUMN project_notes.recorded_at IS 'Time that the note was created';
COMMENT ON COLUMN project_notes.content IS 'Textual content of the note';
COMMENT ON COLUMN project_notes.updated_by IS 'The user that last updated the note';
COMMENT ON COLUMN project_notes.updated_at IS 'Time that the note was last updated or NULL';

GRANT SELECT ON project_notes TO reader;
GRANT SELECT, INSERT, UPDATE, DELETE ON project_notes TO writer;
