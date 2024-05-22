SET SEARCH_PATH TO v1;

CREATE TYPE component_status_type
         AS ENUM ('Active',
                  'Deprecated',
                  'Forbidden');

COMMENT ON TYPE v1.component_status_type IS 'Status of a software component regardless of version';
