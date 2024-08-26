BEGIN;

SELECT plan(19);

-- fixtures
INSERT INTO v1.components(package_url, name, created_by)
VALUES ('pkg:first', 'first package', 'me'),
       ('pkg:second', 'second package', 'me');

-- structural checks
SELECT col_is_pk('v1', 'component_versions', ARRAY ['package_url', 'version'], '(package_url, version) is PK');
SELECT fk_ok('v1', 'component_versions', 'package_url', 'v1', 'components', 'package_url', 'package_url is FK');
SELECT col_is_unique('v1', 'component_versions', 'id', 'id is UNIQUE');

-- functionality tests
SELECT lives_ok($$INSERT INTO v1.component_versions(package_url, version)
                  VALUES ('pkg:first', '1'),
                         ('pkg:second', '1'), ('pkg:second', '2')$$);
SELECT lives_ok($$DELETE FROM v1.components WHERE package_url = 'pkg:second'$$);
SELECT results_eq($$SELECT COUNT(id)::INT AS c FROM v1.component_versions$$, ARRAY [1]);
SELECT results_eq($$SELECT status FROM v1.component_versions$$, ARRAY ['Unscored'::v1.component_version_status_type]);

-- permission tests
SET ROLE TO reader;
SELECT lives_ok($$SELECT * FROM v1.component_versions$$, 'reader can read');
SELECT throws_ok($$INSERT INTO v1.component_versions (package_url, version)
                   VALUES ('pkg:first', '2')$$, '42501', NULL, 'reader cannot insert');
SELECT throws_ok($$UPDATE v1.component_versions SET package_url = package_url$$,
                 '42501', NULL, 'reader cannot update');
SELECT throws_ok($$DELETE FROM v1.component_versions$$, '42501', NULL, 'reader cannot delete');

SET ROLE TO writer;
SELECT lives_ok($$SELECT * FROM v1.component_versions$$, 'writer can read');
SELECT throws_ok($$INSERT INTO v1.component_versions (package_url, version)
                   VALUES ('pkg:first', '2')$$, '42501', NULL, 'writer cannot insert');
SELECT throws_ok($$UPDATE v1.component_versions SET package_url = package_url$$,
                 '42501', NULL, 'writer cannot update');
SELECT throws_ok($$DELETE FROM v1.component_versions$$, '42501', NULL, 'writer cannot delete');

SET ROLE TO admin;
SELECT lives_ok($$SELECT * FROM v1.component_versions$$, 'admin can read');
SELECT lives_ok($$INSERT INTO v1.component_versions (package_url, version)
                   VALUES ('pkg:first', '2')$$, 'admin can insert');
SELECT lives_ok($$UPDATE v1.component_versions SET package_url = package_url$$, 'admin can update');
SELECT lives_ok($$DELETE FROM v1.component_versions$$, 'admin can delete');


SELECT *
  FROM finish();
ROLLBACK;
