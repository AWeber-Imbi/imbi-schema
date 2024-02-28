SET search_path=v1;

CREATE TYPE automation_category_type
AS ENUM ('create-project');

COMMENT ON TYPE v1.automation_category_type IS 'Identifies the actions that an automation is available for';
