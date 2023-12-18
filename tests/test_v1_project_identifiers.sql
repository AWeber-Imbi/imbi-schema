BEGIN;

SELECT plan(32);

-- fixtures

SELECT lives_ok(
  $$INSERT INTO v1.namespaces (id, name, created_by, slug, icon_class) VALUES (1, 'test_namespace', 'test_user', 'test_slug', 'test_icon_class')$$,
  'create namespace');
SELECT lives_ok(
  $$INSERT INTO v1.project_types (id, name, plural_name, created_by, slug) VALUES (1, 'test_project_type', 'tests', 'test_user', 'test_slug')$$,
  'create project type');
SELECT lives_ok(
  $$INSERT INTO v1.projects (id, namespace_id, project_type_id, created_by, name, slug) VALUES (1, 1, 1, 'test_user', 'test_project_1', 'test_slug_1')$$,
  'create first project');
SELECT lives_ok(
  $$INSERT INTO v1.projects (id, namespace_id, project_type_id, created_by, name, slug) VALUES (2, 1, 1, 'test_user', 'test_project_2', 'test_slug_2')$$,
  'create second project');
SELECT lives_ok(
  $$INSERT INTO v1.projects (id, namespace_id, project_type_id, created_by, name, slug) VALUES (3, 1, 1, 'test_user', 'test_project_3', 'test_slug_3')$$,
  'create third project');
SELECT lives_ok(
  $$INSERT INTO v1.integrations (name, api_endpoint) VALUES ('integration-1', 'https://example.com/integration-1')$$,
  'create first integration');
SELECT lives_ok(
  $$INSERT INTO v1.integrations (name, api_endpoint) VALUES ('integration-2', 'https://example.com/integration-2')$$,
  'create second integration');
SELECT lives_ok(
  $$INSERT INTO v1.integrations (name, api_endpoint) VALUES ('integration-3', 'https://example.com/integration-3')$$,
  'create third integration');

SELECT lives_ok(
  $$
  INSERT INTO v1.project_identifiers (external_id, integration_name, project_id)
                              VALUES ('project-2', 'integration-2', 2),
                                     ('project-3', 'integration-3', 3)
  $$,
  'create project identifiers');

-- tests

SELECT lives_ok(
    $$INSERT INTO v1.project_identifiers(external_id, integration_name, project_id)
      VALUES ('project-1', 'integration-1', 1)$$,
    'create valid project identifier');
SELECT ok(created_at IS NOT NULL, 'created_at is NOT NULL for new identifier')
  FROM v1.project_identifiers
 WHERE integration_name = 'integration-1'
   AND project_id = 1;
SELECT ok(created_by IS NOT NULL, 'created_by is NOT NULL for new identifier')
  FROM v1.project_identifiers
 WHERE integration_name = 'integrations-1'
   AND project_id = 1;
SELECT ok(last_modified_at IS NULL, 'last_modified_at is NULL for new identifier')
  FROM v1.project_identifiers
 WHERE integration_name = 'integrations-1'
    AND project_id = 1;
SELECT ok(last_modified_by IS NULL, 'last_modified_by is NULL for new identifier')
  FROM v1.project_identifiers
 WHERE integration_name = 'integrations-1'
    AND project_id = 1;

SELECT throws_ok(
    $$INSERT INTO v1.project_identifiers (external_id, integration_name, project_id)
      VALUES ('project-1', 'integration-1', 1)$$,
               '23505', NULL, 'INSERT fails on duplicate');
SELECT throws_ok(
    $$INSERT INTO v1.project_identifiers (integration_name, project_id)
      VALUES ('integration-1', 1)$$,
    '23502', NULL, 'INSERT fails without external_id');
SELECT throws_ok(
    $$INSERT INTO v1.project_identifiers (external_id, integration_name, project_id)
      VALUES (NULL, 'integration-1', 1)$$,
    '23502', NULL, 'INSERT fails with NULL external_id');
SELECT throws_ok(
    $$INSERT INTO v1.project_identifiers (external_id, integration_name, project_id)
      VALUES ('whatever', 'integration-1', 100)$$,
    '23503', NULL, 'INSERT fails with unknown project_id');
SELECT throws_ok(
    $$INSERT INTO v1.project_identifiers (external_id, integration_name, project_id)
      VALUES ('whatever', 'imbi', 1)$$,
    '23503', NULL, 'INSERT fails with invalid integration_name');

SELECT lives_ok($$DELETE FROM v1.projects WHERE id = 2$$, 'delete second project');
SELECT ok(COUNT(project_id) = 0, 'project deletion cascades')
  FROM v1.project_identifiers
 WHERE project_id = 2;

SELECT lives_ok($$DELETE FROM v1.integrations WHERE name = 'integration-3'$$, 'delete second integration');
SELECT ok(COUNT(project_id) = 0, 'integration deletion cascades')
  FROM v1.project_identifiers
 WHERE project_id = 3;

-- reader can read
SET ROLE TO reader;
SELECT lives_ok($$SELECT * FROM v1.project_identifiers$$, 'reader can read');
SELECT throws_ok($$INSERT INTO v1.project_identifiers(external_id, integration_name, project_id)
                   VALUES ('whatever', 'whatever', 1)$$, '42501', NULL, 'reader cannot insert');
SELECT throws_ok($$UPDATE v1.project_identifiers SET integration_name = 'github'$$, '42501', NULL, 'reader cannot update');
SELECT throws_ok($$DELETE FROM v1.project_identifiers WHERE integration_name = 'github'$$, '42501', NULL, 'reader cannot delete');

-- writer can write
SET ROLE TO writer;
SELECT lives_ok($$SELECT * FROM v1.project_identifiers$$, 'writer can read');
SELECT lives_ok($$INSERT INTO v1.project_identifiers(external_id, integration_name, project_id)
                  VALUES ('whatever', 'integration-2', 1)$$, 'writer can insert');
SELECT lives_ok($$UPDATE v1.project_identifiers SET external_id = 'whatever'$$, 'writer can update');
SELECT lives_ok($$DELETE FROM v1.project_identifiers WHERE integration_name = 'github'$$, 'writer can delete');

-- admin can write
SET ROLE TO admin;
SELECT lives_ok($$SELECT * FROM v1.project_identifiers$$, 'admin can read');
SELECT lives_ok($$INSERT INTO v1.project_identifiers(external_id, integration_name, project_id)
                  VALUES ('whatever', 'integration-2', 3)$$, 'admin can insert');
SELECT lives_ok($$UPDATE v1.project_identifiers SET external_id = 'whatever'$$, 'admin can update');
SELECT lives_ok($$DELETE FROM v1.project_identifiers WHERE integration_name = 'github'$$, 'admin can delete');


SELECT * FROM finish();
ROLLBACK;
