BEGIN;

SELECT plan(28);

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
SELECT lives_ok($$INSERT INTO v1.integration_notifications (integration_name, notification_name, id_pattern)
                  VALUES ('integration-1', 'notification-1', '/id')$$,
                'create first notification');

-- functionality tests
SELECT lives_ok($$INSERT INTO v1.notification_filters (integration_name, notification_name, filter_name,
                                                       pattern, operation, value, action)
                  VALUES ('integration-1', 'notification-1', 'filter-1', '/enabled', '==', 'true', 'process')$$,
                'create valid notification filter');
SELECT throws_ok($$INSERT INTO v1.notification_filters (integration_name, notification_name, filter_name,
                                                        pattern, operation, value, action)
                   VALUES ('integration-1', 'notification-1', 'filter-1', '/enabled', '==', 'true', 'process')$$,
                 '23505', NULL, 'INSERT fails on duplicate');

SELECT lives_ok($$INSERT INTO v1.integrations (name, api_endpoint)
                  VALUES ('integration-2', 'https://example.com/integration-2')$$,
                'create temporary integration');
SELECT lives_ok($$INSERT INTO v1.integration_notifications (integration_name, notification_name, id_pattern)
                  VALUES ('integration-2', 'notification-2', '/id')$$,
                'create temporary notification');
SELECT lives_ok($$INSERT INTO v1.notification_filters (integration_name, notification_name, filter_name,
                                                       pattern, operation, value, action)
                  VALUES ('integration-2', 'notification-2', 'filter', '/enabled', '==', 'false', 'ignore')$$,
                'create a temporary filter');

SELECT lives_ok($$INSERT INTO v1.integration_notifications (integration_name, notification_name, id_pattern)
                  VALUES ('integration-2', 'notification-3', '/id')$$,
                'create another temporary notification');
SELECT lives_ok($$INSERT INTO v1.notification_filters (integration_name, notification_name, filter_name,
                                                       pattern, operation, value, action)
                  VALUES ('integration-2', 'notification-3', 'filter', '/enabled', '!=', 'true', 'ignore')$$,
                'create a temporary filter');

SELECT lives_ok($$DELETE FROM v1.integration_notifications
                   WHERE integration_name = 'integration-2'
                     AND notification_name = 'notification-3'$$,
                'deleting newest notification');

SELECT ok(COUNT(*) = 0, 'Notification filter removed by cascade from integration_notifications')
  FROM v1.notification_filters
 WHERE integration_name = 'integration-2'
   AND notification_name = 'notification-3';

SELECT ok(COUNT(*) = 1, 'Unrelated notification filter not removed by cascade from integration_notifications')
  FROM v1.notification_filters
 WHERE integration_name = 'integration-2';

SELECT lives_ok($$DELETE FROM v1.integrations WHERE name = 'integration-2'$$, 'deleting other notification');

SELECT ok(COUNT(*) = 0, 'Notification filter removed by cascade from integrations')
  FROM v1.notification_filters
 WHERE integration_name = 'integration-2';

-- permission tests
SET ROLE TO reader;
SELECT lives_ok($$SELECT * FROM v1.notification_filters$$, 'reader can read');
SELECT throws_ok($$INSERT INTO v1.notification_filters (integration_name, notification_name, filter_name,
                                                        pattern, operation, value, action)
                   VALUES ('integration-1', 'notification-1', 'filter', '/id', '==', '112233', 'ignore')$$,
                 '42501', NULL, 'reader cannot insert');
SELECT throws_ok($$UPDATE v1.notification_filters SET filter_name = 'filter'$$, '42501', NULL, 'reader cannot update');
SELECT throws_ok($$DELETE FROM v1.notification_filters$$, '42501', NULL, 'reader cannot delete');

SET ROLE TO writer;
SELECT lives_ok($$SELECT * FROM v1.notification_filters$$, 'writer can read');
SELECT throws_ok($$INSERT INTO v1.notification_filters (integration_name, notification_name, filter_name,
                                                        pattern, operation, value, action)
                   VALUES ('integration-1', 'notification-1', 'filter', '/id', '==', '112233', 'ignore')$$,
                 '42501', NULL, 'writer cannot insert');
SELECT throws_ok($$UPDATE v1.notification_filters SET filter_name = 'filter'$$, '42501', NULL, 'writer cannot update');
SELECT throws_ok($$DELETE FROM v1.notification_filters$$, '42501', NULL, 'writer cannot delete');

SET ROLE TO admin;
SELECT lives_ok($$SELECT * FROM v1.notification_filters$$, 'admin can read');
SELECT lives_ok($$INSERT INTO v1.notification_filters (integration_name, notification_name, filter_name,
                                                       pattern, operation, value, action)
                  VALUES ('integration-1', 'notification-1', 'filter', '/id', '==', '112233', 'ignore')$$,
                'admin can insert');
SELECT lives_ok($$UPDATE v1.notification_filters
                     SET filter_name = 'filter-3'
                   WHERE filter_name = 'filter'$$, 'admin can update');
SELECT lives_ok($$DELETE FROM v1.notification_filters
                   WHERE filter_name = 'filter-3'$$, 'admin can delete');


SELECT *
  FROM finish();
ROLLBACK;
