BEGIN;

SELECT plan(20);

-- create some fixtures

SELECT lives_ok(
  $$INSERT INTO v1.namespaces (id, name, created_by, slug, icon_class) VALUES (1, 'test_namespace', 'test_user', 'test_slug', 'test_icon_class')$$,
  'create namespace');
SELECT lives_ok(
  $$INSERT INTO v1.project_types (id, name, plural_name, created_by, slug) VALUES (1, 'test_project_type', 'tests', 'test_user', 'test_slug')$$,
  'create project type');
SELECT lives_ok(
  $$INSERT INTO v1.projects (id, namespace_id, project_type_id, created_by, name, slug) VALUES (1, 1, 1, 'test_user', 'test_project_1', 'test_slug_1')$$,
  'create first project');

-- now we can start testing

SELECT col_is_pk('v1', 'project_notes', ARRAY['project_id', 'created_at', 'created_by'], 'PK is (project_id, created_at, created_by)');

SELECT lives_ok(
    $$INSERT INTO v1.project_notes (project_id, content, created_by) VALUES (1, 'some text content', 'test_user')$$,
    'create a valid note');
SELECT ok(updated_at IS NULL, 'updated_at is NULL for new note') FROM v1.project_notes WHERE project_id = 1 AND created_by = 'test_user';
SELECT ok(updated_by IS NULL, 'updated_by is NULL for new note') FROM v1.project_notes WHERE project_id = 1 AND created_by = 'test_user';

SELECT throws_ok(
    $$INSERT INTO v1.project_notes (project_id, content, created_by) VALUES (2, 'some text content', 'test_user')$$,
    '23503', NULL, 'INSERT fails for nonexistent project ID');
SELECT throws_ok(
    $$INSERT INTO v1.project_notes (project_id, content, created_by) VALUES (NULL, 'some text content', 'text_user')$$,
    '23502', NULL, 'INSERT fails with NULL project_id');
SELECT throws_ok(
    $$INSERT INTO v1.project_notes (project_id, content, created_by) VALUES (1, NULL, 'text_user')$$,
    '23502', NULL, 'INSERT fails with NULL content');
SELECT throws_ok(
    $$INSERT INTO v1.project_notes (project_id, content, created_by, created_at) VALUES (1, 'some text content', 'test_user', NULL)$$,
    '23502', NULL, 'INSERT fails with NULL created_at');
SELECT throws_ok(
    $$INSERT INTO v1.project_notes (project_id, content, created_by) VALUES (1, 'some text content', NULL)$$,
    '23502', NULL, 'INSERT fails with NULL created_by');

SET ROLE TO reader;
SELECT lives_ok($$SELECT * FROM v1.project_notes$$, 'reader can read notes');
SELECT throws_ok(
    $$INSERT INTO v1.project_notes (project_id, content, created_by) VALUES (1, 'some text', 'me')$$,
    '42501', NULL, 'reader cannot create a note');
SELECT throws_ok(
    $$UPDATE v1.project_notes SET content = 'other content'$$, '42501', NULL, 'reader cannot update notes');
SELECT throws_ok($$DELETE FROM v1.project_notes$$, '42501', NULL, 'reader cannot delete notes');

SET ROLE TO writer;
SELECT lives_ok($$SELECT * FROM v1.project_notes$$, 'writer can read notes');
SELECT lives_ok(
    $$INSERT INTO v1.project_notes (project_id, content, created_by) VALUES (1, 'inserted', 'me')$$,
    'writer can insert notes');
SELECT lives_ok(
    $$UPDATE v1.project_notes SET content = 'to be deleted' WHERE created_by = 'me' AND content = 'inserted'$$,
    'writer can update notes');
SELECT lives_ok($$DELETE FROM v1.project_notes WHERE content = 'to be deleted'$$, 'writer can delete notes');

SELECT * FROM finish();

ROLLBACK;
