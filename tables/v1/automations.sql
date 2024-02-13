SET SEARCH_PATH TO v1;

CREATE TABLE IF NOT EXISTS automations
(
    id               SERIAL                   NOT NULL UNIQUE,
    name             TEXT                     NOT NULL,
    slug             TEXT                     NOT NULL,
    integration_name TEXT                     NOT NULL,
    callable         TEXT                     NOT NULL,
    categories       automation_category_type[],
    created_at       TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by       TEXT                     NOT NULL DEFAULT 'system',
    last_modified_at TIMESTAMP WITH TIME ZONE,
    last_modified_by TEXT,
    PRIMARY KEY (slug, integration_name),
    FOREIGN KEY (integration_name) REFERENCES v1.integrations (name) ON DELETE CASCADE ON UPDATE CASCADE,
    UNIQUE (integration_name, name)
);

COMMENT ON TABLE automations IS 'Automations exposed for Connected Applications';

COMMENT ON COLUMN automations.id IS 'Surrogate key for dependency tracking';
COMMENT ON COLUMN automations.name IS 'Display name of the automation';
COMMENT ON COLUMN automations.slug IS '(PK) Slug for the automation that is unique within the namespace of the Connected Application';
COMMENT ON COLUMN automations.integration_name IS '(PK) Name of the Connected Application';
COMMENT ON COLUMN automations.callable IS 'Python import spec for the function that implements this automation';
COMMENT ON COLUMN automations.categories IS 'Array of categories that this automation is available for';

GRANT SELECT ON automations TO reader;
GRANT SELECT, INSERT, UPDATE, DELETE ON automations TO admin;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE "automations_id_seq" TO admin;
