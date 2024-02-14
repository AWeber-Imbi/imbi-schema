BEGIN;

SELECT plan(19);

-- fixtures
SELECT lives_ok($$INSERT INTO v1.integrations (name, api_endpoint)
                  VALUES ('integration-1', 'https://example.com/integration-1')$$,
                'create integration');
SELECT lives_ok($$INSERT INTO v1.automations (id, name, slug, integration_name, callable)
                  VALUES (1, 'Do stuff', 'do-stuff', 'integration-1', 'imbi.automations.gitlab:create_project')$$,
                'create first automation');
SELECT lives_ok($$INSERT INTO v1.automations (id, name, slug, integration_name, callable)
                  VALUES (2, 'Do more stuff', 'do-more-stuff', 'integration-1', 'imbi.automations.gitlab:do_stuff')$$,
                'create second automation');

-- structural tests
SELECT col_is_pk('v1', 'automations_graph', ARRAY ['automation_id', 'dependency_id'],
                 'PK is (automation_id, dependency_id)');
SELECT fk_ok('v1', 'automations_graph', 'automation_id',
             'v1', 'automations', 'id');
SELECT fk_ok('v1', 'automations_graph', 'dependency_id',
             'v1', 'automations', 'id');
SELECT throws_ok($$INSERT INTO v1.automations_graph (automation_id, dependency_id) VALUES (1, 1)$$,
                 '23514', NULL, 'automation cannot depend on itself');

-- permission tests
SET ROLE TO reader;
SELECT lives_ok($$SELECT * FROM v1.automations_graph$$, 'reader can read');
SELECT throws_ok($$INSERT INTO v1.automations_graph (automation_id, dependency_id) VALUES (1, 2)$$,
                 '42501', NULL, 'reader cannot insert');
SELECT throws_ok($$UPDATE v1.automations_graph SET automation_id = automation_id$$, '42501', NULL,
                 'reader cannot update');
SELECT throws_ok($$DELETE FROM v1.automations_graph$$, '42501', NULL, 'reader cannot delete');

SET ROLE TO writer;
SELECT lives_ok($$SELECT * FROM v1.automations_graph$$, 'writer can read');
SELECT throws_ok($$INSERT INTO v1.automations_graph (automation_id, dependency_id) VALUES (1, 2)$$,
                 '42501', NULL, 'writer cannot insert');
SELECT throws_ok($$UPDATE v1.automations_graph SET automation_id = automation_id$$, '42501', NULL,
                 'writer cannot update');
SELECT throws_ok($$DELETE FROM v1.automations_graph$$, '42501', NULL, 'writer cannot delete');

SET ROLE TO admin;
SELECT lives_ok($$SELECT * FROM v1.automations_graph$$, 'admin can read');
SELECT lives_ok($$INSERT INTO v1.automations_graph (automation_id, dependency_id) VALUES (1, 2)$$,
                'admin can insert');
SELECT lives_ok($$UPDATE v1.automations_graph SET automation_id = automation_id$$, 'admin can update');
SELECT lives_ok($$DELETE FROM v1.automations_graph$$, 'admin can delete');

SELECT *
  FROM finish();

ROLLBACK;
