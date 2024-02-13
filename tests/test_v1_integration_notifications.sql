BEGIN;

SELECT plan(27);

-- fixtures
SELECT lives_ok($$INSERT INTO v1.project_types (id, name, plural_name, created_by, slug)
                  VALUES (1, 'test_project_type', 'tests', 'test_user', 'test_slug')$$,
                'create project type');
SELECT lives_ok($$INSERT INTO v1.project_fact_types (id, name, project_type_ids, created_by)
                  VALUES (1, 'test_project_fact_type', ARRAY[1], 'test_user')$$,
                'create project fact type');
SELECT lives_ok($$INSERT INTO v1.integrations (name, api_endpoint)
                  VALUES ('integration-1', 'https://example.com/integration-1')$$,
                'create first integration');

-- functionality tests
SELECT lives_ok($$INSERT INTO v1.integration_notifications (integration_name, notification_name, id_pattern)
                  VALUES ('integration-1', 'notification-1', '/id')$$,
                'create valid integration notification');

SELECT ok(created_at IS NOT NULL, 'created_at is NOT NULL for the new notification')
  FROM v1.integration_notifications
 WHERE integration_name = 'integration-1'
   AND notification_name = 'notification-1';

SELECT ok(created_by IS NOT NULL, 'created_by is NOT NULL for the new notification')
  FROM v1.integration_notifications
 WHERE integration_name = 'integration-1'
   AND notification_name = 'notification-1';

SELECT ok(last_modified_at IS NULL, 'last_modified_at is NULL for the new notification')
  FROM v1.integration_notifications
 WHERE integration_name = 'integration-1'
   AND notification_name = 'notification-1';

SELECT ok(last_modified_by IS NULL, 'last_modified_by is NULL for the new notification')
  FROM v1.integration_notifications
 WHERE integration_name = 'integration-1'
   AND notification_name = 'notification-1';

SELECT ok(documentation IS NULL, 'documentation link is NULL for the new notification')
  FROM v1.integration_notifications
 WHERE integration_name = 'integration-1'
   AND notification_name = 'notification-1';

SELECT ok(verification_token IS NULL, 'verification_token is NULL for the new notification')
  FROM v1.integration_notifications
 WHERE integration_name = 'integration-1'
   AND notification_name = 'notification-1';

SELECT ok(default_action = 'process', 'default for a new notification is to process the notification')
  FROM v1.integration_notifications
 WHERE integration_name = 'integration-1'
   AND notification_name = 'notification-1';

SELECT throws_ok($$INSERT INTO v1.integration_notifications (integration_name, notification_name, id_pattern)
                   VALUES ('integration-1', 'notification-1', '/id')$$,
                 '23505', NULL, 'INSERT fails on duplicate');

SELECT throws_ok($$INSERT INTO v1.integration_notifications (integration_name, id_pattern)
                   VALUES ('integration-1', '/id')$$,
                 '23502', NULL, 'INSERT fails without notification_name');

SELECT throws_ok($$INSERT INTO v1.integration_notifications (integration_name, notification_name)
                   VALUES ('integration-1', 'notification-1')$$,
                 '23502', NULL, 'INSERT fails without id_pattern');

SELECT throws_ok($$UPDATE v1.integration_notifications SET default_action = 'unknown-action-type'$$,
                 '22P02', NULL, 'UPDATE fails with invalid default action');

-- permission tests
SET ROLE TO reader;
SELECT lives_ok($$SELECT * FROM v1.integration_notifications$$, 'reader can read');
SELECT throws_ok($$INSERT INTO v1.integration_notifications (integration_name, notification_name, id_pattern)
                   VALUES ('integration-1', 'notification', '/id')$$, '42501', NULL, 'reader cannot insert');
SELECT throws_ok($$UPDATE v1.integration_notifications SET id_pattern = '/id'$$, '42501', NULL, 'reader cannot update');
SELECT throws_ok($$DELETE FROM v1.integration_notifications$$, '42501', NULL, 'reader cannot delete');

SET ROLE TO writer;
SELECT lives_ok($$SELECT * FROM v1.integration_notifications$$, 'writer can read');
SELECT throws_ok($$INSERT INTO v1.integration_notifications (integration_name, notification_name, id_pattern)
                   VALUES ('integration-1', 'notification', '/id')$$, '42501', NULL, 'writer cannot insert');
SELECT throws_ok($$UPDATE v1.integration_notifications SET id_pattern = '/id'$$, '42501', NULL, 'writer cannot update');
SELECT throws_ok($$DELETE FROM v1.integration_notifications$$, '42501', NULL, 'writer cannot delete');

SET ROLE TO admin;
SELECT lives_ok($$SELECT * FROM v1.integration_notifications$$, 'admin can read');
SELECT lives_ok($$INSERT INTO v1.integration_notifications (integration_name, notification_name, id_pattern)
                  VALUES ('integration-1', 'notification', '/id')$$, 'admin can insert');
SELECT lives_ok($$UPDATE v1.integration_notifications
                     SET id_pattern = '/id'
                   WHERE notification_name = 'notification'$$, 'admin can update');
SELECT lives_ok($$DELETE FROM v1.integration_notifications
                   WHERE notification_name = 'notification'$$, 'admin can delete');

SELECT *
  FROM finish();
ROLLBACK;
