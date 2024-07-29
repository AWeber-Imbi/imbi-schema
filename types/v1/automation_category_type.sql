SET search_path=v1;

CREATE TYPE automation_category_type
AS ENUM ('create-project',
         'create-project-dependency',
         'remove-project-dependency');

COMMENT ON TYPE v1.automation_category_type IS 'Identifies the actions that an automation is available for';
