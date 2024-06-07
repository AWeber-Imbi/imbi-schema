SET SEARCH_PATH TO v1;

CREATE TABLE IF NOT EXISTS v1.component_versions
(
    id          SERIAL UNIQUE NOT NULL,
    package_url TEXT          NOT NULL,
    version     TEXT          NOT NULL,
    PRIMARY KEY (package_url, version),
    UNIQUE (package_url, id),
    FOREIGN KEY (package_url) REFERENCES v1.components (package_url) ON DELETE CASCADE ON UPDATE CASCADE
);

COMMENT ON TABLE v1.component_versions IS 'Versions of a component that are/were in use by a project';
COMMENT ON COLUMN v1.component_versions.id IS 'Surrogate identifier for the version';
COMMENT ON COLUMN v1.component_versions.package_url IS 'Identifies the component (FK v1.components.package_url)';
COMMENT ON COLUMN v1.component_versions.version IS 'Version of the component bound to the surrogate ID';

GRANT SELECT ON v1.component_versions TO reader;
GRANT SELECT ON v1.component_versions TO writer;
GRANT SELECT, INSERT, UPDATE, DELETE ON v1.component_versions TO admin;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE v1.component_versions_id_seq TO admin;
