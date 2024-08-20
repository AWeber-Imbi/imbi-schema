SET SEARCH_PATH TO v1;

CREATE TYPE component_version_status_type
    AS ENUM ('Deprecated',
             'Forbidden',
             'Outdated',
             'Unscored',
             'Up-to-date');

COMMENT ON TYPE v1.component_version_status_type IS 'Status of a specific version of a component with respect to components.active_version';
