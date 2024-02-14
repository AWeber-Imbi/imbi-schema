SET SEARCH_PATH TO v1;

CREATE TABLE IF NOT EXISTS automations_graph
(
    automation_id INTEGER NOT NULL,
    dependency_id INTEGER NOT NULL,
    PRIMARY KEY (automation_id, dependency_id),
    FOREIGN KEY (automation_id) REFERENCES automations (id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (dependency_id) REFERENCES automations (id) ON DELETE CASCADE ON UPDATE CASCADE,
    CHECK ( automation_id != dependency_id )
);

COMMENT ON TABLE automations_graph IS 'Dependency graph for automations';

COMMENT ON COLUMN automations_graph.automation_id IS 'Surrogate ID of the automation that depends on `dependency`';
COMMENT ON COLUMN automations_graph.dependency_id IS 'Surrogate ID of the automation that `automation_slug` depends on';

GRANT SELECT ON automations_graph TO reader;
GRANT SELECT, INSERT, UPDATE, DELETE ON automations_graph TO admin;

