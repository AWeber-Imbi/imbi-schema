BEGIN;

SELECT plan(36);

-- fixtures
SELECT lives_ok($$INSERT INTO v1.project_types (id, name, plural_name, created_by, slug)
                  VALUES (1, 'project-type', 'tests', 'test_user', 'test_slug')$$,
                'create project type');
SELECT lives_ok($$INSERT INTO v1.project_fact_types (id, name, project_type_ids, created_by)
                  VALUES (1, 'first-fact-type', ARRAY[1], 'test_user')$$,
                'create project fact type');
SELECT lives_ok($$INSERT INTO v1.project_fact_types (id, name, project_type_ids, created_by)
                  VALUES (2, 'second-fact-type', ARRAY[1], 'test_user')$$,
                'Create another project fact type');
SELECT lives_ok($$INSERT INTO v1.integrations (name, api_endpoint)
                  VALUES ('integration-1', 'https://example.com/integration-1')$$,
                'create first integration');
SELECT lives_ok($$INSERT INTO v1.integration_notifications (integration_name, notification_name, id_pattern)
                  VALUES ('integration-1', 'notification-1', '/id')$$,
                'create first notification');

-- functionality tests
SELECT lives_ok($$INSERT INTO v1.notification_rules (fact_type_id, integration_name, notification_name, pattern)
                  VALUES (1, 'integration-1', 'notification-1', '/id')$$, 'Insert valid notification rule');

SELECT ok(created_at IS NOT NULL, 'created_at is NOT NULL for the new notification rule')
  FROM v1.notification_rules
 WHERE fact_type_id = 1
   AND integration_name = 'integration-1'
   AND notification_name = 'notification-1';

SELECT ok(created_by IS NOT NULL, 'created_by is NOT NULL for the new notification rule')
  FROM v1.notification_rules
 WHERE fact_type_id = 1
   AND integration_name = 'integration-1'
   AND notification_name = 'notification-1';

SELECT ok(last_modified_at IS NULL, 'last_modified_at is NULL for the new notification rule')
  FROM v1.notification_rules
 WHERE fact_type_id = 1
   AND integration_name = 'integration-1'
   AND notification_name = 'notification-1';

SELECT ok(last_modified_by IS NULL, 'last_modified_by is NULL for the new notification rule')
  FROM v1.notification_rules
 WHERE fact_type_id = 1
   AND integration_name = 'integration-1'
   AND notification_name = 'notification-1';


SELECT throws_ok($$INSERT INTO v1.notification_rules (fact_type_id, integration_name, notification_name, pattern)
                   VALUES (1, 'integration-1', 'notification-1', '/id')$$,
                 '23505', NULL, 'INSERT fails on duplicate');

SELECT throws_ok($$INSERT INTO v1.notification_rules (integration_name, notification_name, pattern)
                   VALUES ('integration-1', 'notification-1', '/id')$$,
                 '23502', NULL, 'INSERT fails without fact_type_id');

SELECT throws_ok($$INSERT INTO v1.notification_rules (fact_type_id, notification_name, pattern)
                   VALUES (1, 'notification-1', '/id')$$,
                 '23502', NULL, 'INSERT fails without integration_name');

SELECT throws_ok($$INSERT INTO v1.notification_rules (fact_type_id, integration_name, pattern)
                   VALUES (1, 'notification-1', '/id')$$,
                 '23502', NULL, 'INSERT fails without notification_name');

SELECT throws_ok($$INSERT INTO v1.notification_rules (fact_type_id, integration_name, notification_name)
                   VALUES (1, 'integration-1', 'notification-1')$$,
                 '23502', NULL, 'INSERT fails without pattern');

SELECT lives_ok($$INSERT INTO v1.project_fact_types (id, name, project_type_ids, created_by)
                  VALUES (3, 'third-fact-type', ARRAY[1], 'test_user')$$,
                'Create another project fact type');
SELECT lives_ok($$INSERT INTO v1.notification_rules (fact_type_id, integration_name, notification_name, pattern)
                  VALUES (3, 'integration-1', 'notification-1', '/id')$$,
                'Insert another notification rule');
SELECT lives_ok($$DELETE FROM v1.project_fact_types WHERE id = 3$$, 'Delete new project fact type');
SELECT ok(COUNT(*) = 0, 'Delete cascades from project_fact_types')
  FROM v1.notification_rules
 WHERE fact_type_id = 3;

SELECT lives_ok($$INSERT INTO v1.integration_notifications (integration_name, notification_name, id_pattern)
                  VALUES ('integration-1', 'notification-2', '/id')$$,
                'Create another notification');
SELECT lives_ok($$INSERT INTO v1.notification_rules (fact_type_id, integration_name, notification_name, pattern)
                  VALUES (1, 'integration-1', 'notification-2', '/id')$$,
                'Insert another notification rule');
SELECT lives_ok($$DELETE FROM v1.integration_notifications
                   WHERE integration_name = 'integration-1'
                     AND notification_name = 'notification-2'$$,
                'Delete new notification');
SELECT ok(COUNT(*) = 0, 'Delete cascades from integration_notifications')
  FROM v1.notification_rules
 WHERE integration_name = 'integration-1'
   AND notification_name = 'notification-2';
SELECT ok(COUNT(*) = 1, 'Delete does not cascade from integration_notifications to other rules')
  FROM v1.notification_rules
 WHERE integration_name = 'integration-1'
   AND notification_name = 'notification-1';

-- permission tests
SET ROLE TO reader;
SELECT lives_ok($$SELECT * FROM v1.notification_rules$$, 'reader can read');
SELECT throws_ok($$INSERT INTO v1.notification_rules (fact_type_id, integration_name, notification_name, pattern)
                   VALUES (1, 'integration-1', 'notification-1', '/id')$$, '42501', NULL, 'reader cannot insert');
SELECT throws_ok($$UPDATE v1.notification_rules SET fact_type_id = 1 WHERE fact_type_id = 1$$,
                 '42501', NULL, 'reader cannot update');
SELECT throws_ok($$DELETE FROM v1.notification_rules WHERE fact_type_id = 9999$$,
                 '42501', NULL, 'reader cannot delete');

SET ROLE TO writer;
SELECT lives_ok($$SELECT * FROM v1.notification_rules$$, 'writer can read');
SELECT throws_ok($$INSERT INTO v1.notification_rules (fact_type_id, integration_name, notification_name, pattern)
                   VALUES (1, 'integration-1', 'notification-1', '/id')$$, '42501', NULL, 'writer cannot insert');
SELECT throws_ok($$UPDATE v1.notification_rules SET fact_type_id = 1 WHERE fact_type_id = 1$$,
                 '42501', NULL, 'writer cannot update');
SELECT throws_ok($$DELETE FROM v1.notification_rules WHERE fact_type_id = 9999$$,
                 '42501', NULL, 'writer cannot delete');

SET ROLE TO admin;
SELECT lives_ok($$SELECT * FROM v1.notification_rules$$, 'admin can read');
SELECT lives_ok($$INSERT INTO v1.notification_rules (fact_type_id, integration_name, notification_name, pattern)
                   VALUES (2, 'integration-1', 'notification-1', '/id')$$, 'admin can insert');
SELECT lives_ok($$UPDATE v1.notification_rules SET fact_type_id = 1 WHERE fact_type_id = 1$$, 'admin can update');
SELECT lives_ok($$DELETE FROM v1.notification_rules WHERE fact_type_id = 2$$, 'admin can delete');

SELECT *
  FROM finish();
ROLLBACK;
