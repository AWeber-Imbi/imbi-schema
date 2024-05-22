BEGIN;

SELECT plan(26);

-- fixtures
INSERT INTO v1.namespaces(id, created_by, name, slug, icon_class)
VALUES (1, 'test', 'Namespace', 'namespace', 'whatever');
INSERT INTO v1.project_types(id, created_by, name, plural_name, slug)
VALUES (1, 'test', 'Project Type', 'Project Types', 'project-type');
INSERT INTO v1.projects(id, namespace_id, project_type_id, created_by, name, slug)
VALUES (1, 1, 1, 'test', 'Some Project', 'some-project'),
       (2, 1, 1, 'test', 'Another Project', 'another-project');
INSERT INTO v1.components(package_url, name, created_by)
VALUES ('pkg:1', 'Component 1', 'me'),
       ('pkg:2', 'Component 2', 'me');
INSERT INTO v1.component_versions(id, package_url, version)
VALUES (1, 'pkg:1', '1.0.0'),
       (2, 'pkg:2', '2.0.0'),
       (3, 'pkg:1', '1.1.0');

INSERT INTO v1.project_components(project_id, package_url, version_id)
VALUES (1, 'pkg:1', 1),
       (1, 'pkg:2', 2);

-- structural tests
SELECT col_is_pk('v1', 'project_components', ARRAY ['project_id', 'version_id'], 'PK is (project_id, version_id)');
SELECT fk_ok('v1', 'project_components', 'project_id', 'v1', 'projects', 'id', 'project_id is FK to projects');
SELECT fk_ok('v1', 'project_components', ARRAY ['package_url', 'version_id'],
             'v1', 'component_versions', ARRAY ['package_url', 'id'],
             '(package_url, version_id) is FK to component_versions');

-- functionality tests
SELECT lives_ok($$UPDATE v1.component_versions
                     SET id = 0
                   WHERE id = 1$$, 'updated component version id');
SELECT results_eq($$SELECT project_id, version_id
                      FROM v1.project_components
                     ORDER BY version_id$$,
                  $$VALUES (1, 0), (1, 2)$$,
                  'component version id update cascaded');
SELECT lives_ok($$UPDATE v1.projects
                     SET id = 0
                   WHERE id = 1$$, 'updated project_id');
SELECT results_eq($$SELECT project_id, version_id
                      FROM v1.project_components
                     ORDER BY version_id$$,
                  $$VALUES (0, 0), (0, 2)$$,
                  'project id update cascaded');
SELECT lives_ok($$UPDATE v1.components
                     SET package_url = 'pkg:3'
                   WHERE package_url = 'pkg:2'$$,
                'component package_url updated');
SELECT results_eq($$SELECT project_id, version_id
                      FROM v1.project_components
                     WHERE package_url = 'pkg:3'$$,
                  $$VALUES (0, 2)$$,
                  'component package_url update cascaded');
SELECT throws_ok($$DELETE FROM v1.components WHERE package_url = 'pkg:3'$$,
                 '23503', NULL, 'cannot delete component with active versions');
SELECT lives_ok($$DELETE FROM v1.project_components
                   WHERE version_id IN (SELECT id
                                          FROM v1.component_versions
                                         WHERE package_url = 'pkg:3')$$,
                'remove active version(s) for package');
SELECT lives_ok($$DELETE FROM v1.components WHERE package_url = 'pkg:3'$$,
                'delete component without active versions');
SELECT lives_ok($$DELETE FROM v1.projects WHERE id = 0$$, 'deleted project');
SELECT results_eq($$SELECT COUNT(*)::INTEGER FROM v1.project_components$$, ARRAY [0],
                  'delete cascaded to project_components');

-- permission tests
SET ROLE TO reader;
SELECT lives_ok($$SELECT * FROM v1.project_components$$, 'reader can read');
SELECT throws_ok($$INSERT INTO v1.project_components (project_id, package_url, version_id)
                   VALUES (0, 'pkg:1', 0)$$,
                 '42501', NULL, 'reader cannot insert');
SELECT throws_ok($$UPDATE v1.project_components SET version_id = version_id$$,
                 '42501', NULL, 'reader cannot update');
SELECT throws_ok($$DELETE FROM v1.project_components$$, '42501', NULL, 'reader cannot delete');

SET ROLE TO writer;
SELECT lives_ok($$SELECT * FROM v1.project_components$$, 'writer can read');
SELECT throws_ok($$INSERT INTO v1.project_components (project_id, package_url, version_id)
                   VALUES (0, 'pkg:1', 0)$$,
                 '42501', NULL, 'writer cannot insert');
SELECT throws_ok($$UPDATE v1.project_components SET version_id = version_id$$,
                 '42501', NULL, 'writer cannot update');
SELECT throws_ok($$DELETE FROM v1.project_components$$, '42501', NULL, 'writer cannot delete');

SET ROLE TO admin;
SELECT lives_ok($$SELECT * FROM v1.project_components$$, 'admin can read');
SELECT lives_ok($$INSERT INTO v1.project_components (project_id, package_url, version_id)
                  VALUES (2, 'pkg:1', 3)$$,
                'admin can insert');
SELECT lives_ok($$UPDATE v1.project_components SET version_id = version_id$$, 'admin can update');
SELECT lives_ok($$DELETE FROM v1.project_components$$, 'admin can delete');

SELECT *
  FROM finish();
ROLLBACK;
