SET SEARCH_PATH TO v1;

CREATE TABLE v1.project_components
(
    project_id INTEGER NOT NULL,
    package_url TEXT NOT NULL,
    version_id INTEGER NOT NULL,
    PRIMARY KEY (project_id, version_id),
    FOREIGN KEY (project_id) REFERENCES v1.projects (id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (package_url, version_id) REFERENCES v1.component_versions (package_url, id) ON DELETE RESTRICT ON UPDATE CASCADE
);

COMMENT ON TABLE v1.project_components IS 'Component versions for the active version of a project';
COMMENT ON COLUMN v1.project_components.project_id IS 'Project that includes this component version';
COMMENT ON COLUMN v1.project_components.package_url IS 'Identifies the component';
COMMENT ON COLUMN v1.project_components.version_id IS 'Identifies the distinct version of the component';

GRANT SELECT ON v1.project_components TO reader;
GRANT SELECT ON v1.project_components TO writer;
GRANT SELECT, INSERT, UPDATE, DELETE ON v1.project_components TO admin;
