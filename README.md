# Imbi DDL

Canonical location for the PostgreSQL Imbi DDL.

## ERD

![ERD](erd.png)

## Docker Image

There is a Dockerfile that creates an image that can be used for testing against Imbi database.

Example use in `docker-compose.yaml`:

```yaml
%YAML 1.2
---
Imbi:
  image: aweber/imbi-postgres:latest
  ports:
    - 5432
```

## Extending or Editing

The [MANIFEST](MANIFEST) file contains all of the files that are used to construct the DDL that is used for the Imbi system. It should be edited for any files that are added or removed. The files are ordered properly for dependency in the MANIFEST file and care should be taken to ensure it stays that way.

## Testing

The [Makefile](Makefile) contains all of the glue required to tests against your DDL. All files ending in `.sql` will be lint checked using [sqlint](https://github.com/purcell/sqlint).

Tests are written using [pgTap](http://pgxn.org/dist/pgtap/doc/pgtap.html) and all testing requirements are contained in the PostgreSQL container specified in the [docker-compose.yaml](docker-compose.yaml).

The [plpgsql_check](https://github.com/okbob/plpgsql_check) extension is installed and should be used as part of your pgTAP tests. For example, the following example checks to ensure the function exists and that there are no linting errors:

```sql
BEGIN;
SELECT plan( 2 );

SELECT has_function('v1'::NAME, 'project_score'::NAME);

SELECT is_empty(
    $$SELECT * FROM plpgsql_check_function('v1.project_score(INTEGER)');$$,
    'v1.project_score/1 has no plpgsql_check errors');

SELECT * FROM finish();
ROLLBACK;
```

To ensure your environment is ready for running tests run `make bootstrap` and then run `make test`. Test output will be sent to the console and recorded in [JUnit output](https://www.ibm.com/support/knowledgecenter/en/SSQ2R2_9.5.1/com.ibm.rsar.analysis.codereview.cobol.doc/topics/cac_useresults_junit.html) in the `reports/junit_output.xml` file.

## .gitkeep Files

`.gitkeep` files can and should be removed once you add a file to an empty directory.
