BEGIN;

SELECT plan(13);

-- structural tests
SELECT col_is_pk('v1', 'components', 'package_url', 'PK IS (package_url)');

-- permission tests
SET ROLE TO reader;
SELECT lives_ok($$SELECT * FROM v1.components$$, 'reader can read');
SELECT throws_ok($$INSERT INTO v1.components (package_url, name, created_by)
                   VALUES ('pkg:whatever', 'whatever', 'me')$$,
                 '42501', NULL, 'reader cannot insert');
SELECT throws_ok($$UPDATE v1.components SET name = name$$, '42501', NULL, 'reader cannot update');
SELECT throws_ok($$DELETE FROM v1.components$$, '42501', NULL, 'reader cannot delete');

SET ROLE TO writer;
SELECT lives_ok($$SELECT * FROM v1.components$$, 'writer can read');
SELECT throws_ok($$INSERT INTO v1.components (package_url, name, created_by)
                   VALUES ('pkg:whatever', 'whatever', 'me')$$,
                 '42501', NULL, 'writer cannot insert');
SELECT throws_ok($$UPDATE v1.components SET name = name$$, '42501', NULL, 'writer cannot update');
SELECT throws_ok($$DELETE FROM v1.components$$, '42501', NULL, 'writer cannot delete');

SET ROLE TO admin;
SELECT lives_ok($$SELECT * FROM v1.components$$, 'admin can read');
SELECT lives_ok($$INSERT INTO v1.components (package_url, name, created_by)
                  VALUES ('pkg:whatever', 'whatever', 'admin')$$, 'admin can write');
SELECT lives_ok($$UPDATE v1.components SET name = name$$, 'admin can update');
SELECT lives_ok($$DELETE FROM v1.components$$, 'admin can delete');

SELECT *
  FROM finish();
ROLLBACK;
