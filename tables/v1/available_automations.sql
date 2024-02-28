SET SEARCH_PATH TO v1;

CREATE TABLE IF NOT EXISTS available_automations
(
    automation_id   INTEGER NOT NULL REFERENCES automations (id) ON DELETE CASCADE ON UPDATE CASCADE,
    project_type_id INTEGER NOT NULL REFERENCES project_types (id) ON DELETE CASCADE ON UPDATE CASCADE,
    PRIMARY KEY (automation_id, project_type_id)
);

COMMENT ON TABLE available_automations IS 'Automations that are available to each project type';
COMMENT ON COLUMN available_automations.automation_id IS '(PK) the automation';
COMMENT ON COLUMN available_automations.project_type_id IS '(PK) the project type that the automation can be run for';

GRANT SELECT ON available_automations TO reader;
GRANT SELECT, INSERT, UPDATE, DELETE ON available_automations TO admin;

