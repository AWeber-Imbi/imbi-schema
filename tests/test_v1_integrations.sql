BEGIN;

SELECT plan(15);

SELECT col_is_pk('v1', 'integrations', ARRAY['name'], 'PK is (name)');

SELECT lives_ok(
    $$INSERT INTO v1.integrations (name, api_endpoint)
      VALUES ('integration-1', 'https://example.com/integration-1')$$,
    'create a valid integration');
SELECT ok(created_at IS NOT NULL, 'created_at is NOT NULL for new integration')
  FROM v1.integrations
 WHERE name = 'gitlab';
SELECT ok(created_by IS NOT NULL, 'created_by is NOT NULL for new integration')
  FROM v1.integrations
 WHERE name = 'gitlab';
SELECT ok(last_modified_at IS NULL, 'last_modified_at is NULL for new integration')
  FROM v1.integrations
 WHERE name = 'gitlab';
SELECT ok(last_modified_by IS NULL, 'last_modified_by is NULL for new integration')
  FROM v1.integrations
 WHERE name = 'gitlab';

SELECT throws_ok(
    $$INSERT INTO v1.integrations (name) VALUES ('whatever')$$,
    '23502', NULL, 'INSERT fails without api_endpoint');

-- reader can read
SET ROLE TO reader;
SELECT lives_ok($$SELECT * FROM v1.integrations$$, 'reader can read');
SELECT throws_ok($$INSERT INTO v1.integrations (name, api_endpoint) VALUES ('whatever', 'https://example.com')$$, '42501', NULL, 'reader cannot insert');
SELECT throws_ok($$UPDATE v1.integrations SET name = 'github'$$, '42501', NULL, 'reader cannot update');
SELECT throws_ok($$DELETE FROM v1.integrations WHERE name = 'github'$$, '42501', NULL, 'reader cannot delete');

-- writer can only read
SET ROLE TO writer;
SELECT lives_ok($$SELECT * FROM v1.integrations$$, 'writer can read');
SELECT throws_ok($$INSERT INTO v1.integrations (name, api_endpoint) VALUES ('whatever', 'https://example.com')$$, '42501', NULL, 'write cannot insert');
SELECT throws_ok($$UPDATE v1.integrations SET name = 'github'$$, '42501', NULL, 'writer cannot update');
SELECT throws_ok($$DELETE FROM v1.integrations WHERE name = 'github'$$, '42501', NULL, 'writer cannot delete');

-- admin can write
SET ROLE TO admin;
SELECT lives_ok($$SELECT * FROM v1.integrations$$, 'admin can read');
SELECT lives_ok($$INSERT INTO v1.integrations (name, api_endpoint) VALUES ('whatever', 'https://example.com')$$, 'admin can insert');
SELECT lives_ok($$UPDATE v1.integrations SET name = 'integration-2' WHERE name = 'whatever'$$, 'admin can update');
SELECT lives_ok($$DELETE FROM v1.integrations WHERE name = 'github'$$, 'admin can delete');


SELECT * FROM finish();
ROLLBACK;
