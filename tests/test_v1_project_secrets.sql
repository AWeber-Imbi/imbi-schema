BEGIN;

SELECT plan(12);

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

SELECT throws_ok(
  $$INSERT INTO v1.project_secrets (project_id, "name", value, created_by) VALUES (0, 'name', 'value', 'me')$$,
  23503, NULL, 'INSERT fails when providing nonexistent project ID');

SELECT throws_ok(
  $$INSERT INTO v1.project_secrets (project_id, "name", value, created_by) VALUES (NULL, 'name', 'value', 'me')$$,
  23502, NULL, 'INSERT fails when providing NULL project ID');

SELECT throws_ok(
  $$INSERT INTO v1.project_secrets (project_id, "name", value, created_by) VALUES (1, NULL, 'value', 'me')$$,
  23502, NULL, 'INSERT fails when providing NULL secret name');

SELECT throws_ok(
  $$INSERT INTO v1.project_secrets (project_id, "name", value, created_by) VALUES (1, 'name', NULL, 'me')$$,
  23502, NULL, 'INSERT fails when providing NULL secret value');

SELECT lives_ok(
  $$INSERT INTO v1.project_secrets (project_id, "name", value, created_by) VALUES (1, 'secret name', 'value', 'me')$$,
  'insert a secret for project 1');

SELECT throws_ok(
  $$INSERT INTO v1.project_secrets (project_id, "name", value, created_by) VALUES (1, 'secret name', 'value', 'me')$$,
  23505, NULL, 'INSERT duplicate secret name for project 1 fails');

SELECT lives_ok(
  $$INSERT INTO v1.project_secrets (project_id, "name", value, created_by) VALUES (2, 'secret name', 'value', 'me')$$,
  'INSERT same secret name for project 2 succeeds');

SELECT lives_ok(
  $$INSERT INTO v1.project_secrets (project_id, "name", value, created_by) VALUES (1, 'different secret name', 'value', 'me')$$,
  'INSERT different secret name for project 1 succeeds');

ROLLBACK;
