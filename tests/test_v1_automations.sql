BEGIN;

SELECT plan(17);

-- fixtures
SELECT lives_ok($$INSERT INTO v1.integrations (name, api_endpoint)
                  VALUES ('integration-1', 'https://example.com/integration-1')$$,
                'create integration');

-- structural tests
SELECT col_is_pk('v1', 'automations', ARRAY ['slug', 'integration_name'], 'PK is (slug, integration_name)');
SELECT col_is_unique('v1', 'automations', 'id', '(id) is UNIQUE');
SELECT col_is_unique('v1', 'automations', ARRAY ['integration_name', 'name'], '(integration_name, name) is UNIQUE');
SELECT fk_ok('v1', 'automations', 'integration_name',
             'v1', 'integrations', 'name');

-- permission tests
SET ROLE TO reader;
SELECT lives_ok($$SELECT * FROM v1.automations$$, 'reader can read');
SELECT throws_ok($$INSERT INTO v1.automations (name, slug, integration_name, callable)
                   VALUES ('Do stuff', 'do-stuff', 'integration-1', 'imbi.automations.gitlab:create_project')$$,
                 '42501', NULL, 'reader cannot insert');
SELECT throws_ok($$UPDATE v1.automations SET name = name$$, '42501', NULL, 'reader cannot update');
SELECT throws_ok($$DELETE FROM v1.automations$$, '42501', NULL, 'reader cannot delete');

SET ROLE TO writer;
SELECT lives_ok($$SELECT * FROM v1.automations$$, 'writer can read');
SELECT throws_ok($$INSERT INTO v1.automations (name, slug, integration_name, callable)
                   VALUES ('Do stuff', 'do-stuff', 'integration-1', 'imbi.automations.gitlab:create_project')$$,
                 '42501', NULL, 'writer cannot insert');
SELECT throws_ok($$UPDATE v1.automations SET name = name$$, '42501', NULL, 'writer cannot update');
SELECT throws_ok($$DELETE FROM v1.automations$$, '42501', NULL, 'writer cannot delete');

SET ROLE TO admin;
SELECT lives_ok($$SELECT * FROM v1.automations$$, 'admin can read');
SELECT lives_ok($$INSERT INTO v1.automations (name, slug, integration_name, callable)
                   VALUES ('Do stuff', 'do-stuff', 'integration-1', 'imbi.automations.gitlab:create_project')$$,
                'admin can insert');
SELECT lives_ok($$UPDATE v1.automations SET name = name$$, 'admin can update');
SELECT lives_ok($$DELETE FROM v1.automations$$, 'admin can delete');

SELECT *
  FROM finish();

ROLLBACK;
