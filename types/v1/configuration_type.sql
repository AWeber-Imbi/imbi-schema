SET search_path=v1;

CREATE TYPE configuration_type AS ENUM ('ssm');

COMMENT ON TYPE configuration_type IS 'Used to indicate the configuration system of a project';
