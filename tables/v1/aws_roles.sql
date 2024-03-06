SET SEARCH_PATH TO v1;

CREATE TABLE IF NOT EXISTS aws_roles (
    role_arn      TEXT                      NOT NULL,
    environment   TEXT                      NOT NULL,
    namespace_id  INTEGER                   NOT NULL,
    created_at    TIMESTAMP WITH TIME ZONE  NOT NULL  DEFAULT CURRENT_TIMESTAMP,
    created_by    TEXT                      NOT NULL,
    PRIMARY KEY (role_arn, environment, namespace_id),
    UNIQUE (environment, namespace_id),
    FOREIGN KEY (environment) REFERENCES environments (name) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (namespace_id) REFERENCES namespaces (id) ON DELETE CASCADE ON UPDATE CASCADE
);

COMMENT ON TABLE aws_roles IS 'AWS roles with permissions in the given environment and namespace';

COMMENT ON COLUMN aws_roles.role_arn IS 'AWS ARN of the role';
COMMENT ON COLUMN aws_roles.environment IS 'Name of the environment this role is associated with';
COMMENT ON COLUMN aws_roles.namespace_id IS 'ID of the namespace this role is associated with';
COMMENT ON COLUMN aws_roles.created_at IS 'When the record was created at';
COMMENT ON COLUMN aws_roles.created_by IS 'The user that created the record';

GRANT SELECT ON aws_roles TO reader;
GRANT SELECT, INSERT, UPDATE, DELETE ON aws_roles TO admin;
