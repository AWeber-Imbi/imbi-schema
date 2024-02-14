BEGIN;

SELECT plan(18);

-- fixtures
SELECT lives_ok($$INSERT INTO v1.integrations (name, api_endpoint)
                  VALUES ('integration-1', 'https://example.com/integration-1')$$,
                'create integration');
SELECT lives_ok($$INSERT INTO v1.project_types (id, created_by, name, slug, plural_name)
                  VALUES (1, 'me', 'HTTP API', 'http-api', 'HTTP APIs')$$,
                'create project type');
SELECT lives_ok($$INSERT INTO v1.automations (id, name, slug, integration_name, callable)
                  VALUES (1, 'Do stuff', 'do-stuff', 'integration-1', 'imbi.automations.gitlab:create_project')$$,
                'create automation');

-- structural tests
SELECT col_is_pk('v1', 'available_automations', ARRAY ['automation_id', 'project_type_id'],
                 'PK is (automation_id, project_type_id)');
SELECT fk_ok('v1', 'available_automations', 'automation_id',
             'v1', 'automations', 'id');
SELECT fk_ok('v1', 'available_automations', 'project_type_id',
             'v1', 'project_types', 'id');

-- permission tests
SET ROLE TO reader;
SELECT lives_ok($$SELECT * FROM v1.available_automations$$, 'reader can read');
SELECT throws_ok($$INSERT INTO v1.available_automations (automation_id, project_type_id) VALUES (1, 1)$$,
                 '42501', NULL, 'reader cannot insert');
SELECT throws_ok($$UPDATE v1.available_automations SET automation_id = automation_id$$, '42501', NULL,
                 'reader cannot update');
SELECT throws_ok($$DELETE FROM v1.available_automations$$, '42501', NULL, 'reader cannot delete');

SET ROLE TO writer;
SELECT lives_ok($$SELECT * FROM v1.available_automations$$, 'writer can read');
SELECT throws_ok($$INSERT INTO v1.available_automations (automation_id, project_type_id) VALUES (1, 1)$$,
                 '42501', NULL, 'writer cannot insert');
SELECT throws_ok($$UPDATE v1.available_automations SET automation_id = automation_id$$, '42501', NULL,
                 'writer cannot update');
SELECT throws_ok($$DELETE FROM v1.available_automations$$, '42501', NULL, 'writer cannot delete');

SET ROLE TO admin;
SELECT lives_ok($$SELECT * FROM v1.available_automations$$, 'admin can read');
SELECT lives_ok($$INSERT INTO v1.available_automations (automation_id, project_type_id) VALUES (1, 1)$$,
                'admin can insert');
SELECT lives_ok($$UPDATE v1.available_automations SET automation_id = automation_id$$,
                'admin can update');
SELECT lives_ok($$DELETE FROM v1.available_automations$$, 'admin can delete');

SELECT *
  FROM finish();

ROLLBACK;
