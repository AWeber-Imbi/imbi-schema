SET SEARCH_PATH TO v1;

CREATE TABLE IF NOT EXISTS v1.components
(
    package_url      TEXT                     NOT NULL PRIMARY KEY,
    name             TEXT                     NOT NULL,
    status           component_status_type    NOT NULL DEFAULT 'Active',
    home_page        TEXT,
    icon_class       TEXT                              DEFAULT 'fas fa-save',
    active_version   TEXT                              DEFAULT NULL,
    created_at       TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by       TEXT                     NOT NULL,
    last_modified_by TEXT,
    last_modified_at TIMESTAMP WITH TIME ZONE
);

COMMENT ON TABLE v1.components IS 'Software that Imbi projects use / depend on / bundle';
COMMENT ON COLUMN v1.components.package_url IS 'Uniquely identifies the component. This is a Package URL (purl) without a version component';
COMMENT ON COLUMN v1.components.name IS 'Human-readable name of this component';
COMMENT ON COLUMN v1.components.status IS 'Global status for all versions of this component';
COMMENT ON COLUMN v1.components.home_page IS 'Optional home page for this component';
COMMENT ON COLUMN v1.components.icon_class IS 'Font Awesome UI icon class';
COMMENT ON COLUMN v1.components.active_version IS 'Version expression for the "active" version of this component. This is a sem-ver range if the first character is a tilde or caret; otherwise, it is an exact version string';
COMMENT ON COLUMN v1.components.created_at IS 'When was this component added';
COMMENT ON COLUMN v1.components.created_by IS 'Who added this component';
COMMENT ON COLUMN v1.components.last_modified_at IS 'When was this component last modified';
COMMENT ON COLUMN v1.components.last_modified_by IS 'Who modified this component last';

GRANT SELECT ON v1.components TO reader;
GRANT SELECT ON v1.components TO writer;
GRANT SELECT, INSERT, UPDATE, DELETE ON v1.components TO admin;
