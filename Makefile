REVISION = $(shell git rev-parse HEAD | cut -b 1-7)

.PHONY: bootstrap clean create ddl ready test

bootstrap: build
	@ ./bootstrap

build:
	@ mkdir -p build

clean:
	@ docker compose down --volumes --remove-orphans
	@ rm -rf build

ready: build
ifeq ($(shell docker compose ps postgres |grep -c healthy), 0)
	@ $(error Docker image for PostgreSQL is not running, perhaps you forget to run "make bootstrap" or you should "make clean" and try again)
endif

test: ready
	@ echo "Creating test schema"
	@ docker compose exec -T postgres /usr/bin/dropdb --if-exists ${REVISION} > /dev/null
	@ docker compose exec -T postgres /usr/bin/createdb ${REVISION} > /dev/null
	@ bin/build.sh build/ddl-${REVISION}.sql build/dml-${REVISION}.sql
	@ sleep 1
	@ docker compose exec -T postgres /usr/bin/psql -d ${REVISION} -f /build/ddl-${REVISION}.sql -X -v ON_ERROR_STOP=1 -q --pset=pager=off
	@ docker compose exec -T postgres /usr/bin/psql -d ${REVISION} -f /build/dml-${REVISION}.sql -X -v ON_ERROR_STOP=1 -q --pset=pager=off
	@ docker compose exec -T postgres /usr/bin/psql -d ${REVISION} -c "CREATE EXTENSION pgtap;" -X -q --pset=pager=off
	@ docker compose exec -T postgres /usr/bin/psql -d ${REVISION} -c "CREATE EXTENSION plpgsql_check;" -X -q --pset=pager=off
	@ echo "Running pgTAP Tests"
	@ docker compose exec -T postgres /usr/local/bin/pg_prove -v -f -d ${REVISION} tests/*.sql
	@ docker compose exec -T postgres /usr/bin/dropdb ${REVISION} > /dev/null || true
	@ rm build/d*l-${REVISION}.sql

install: ready
	@ echo "Creating schema"
	@ docker compose exec -T postgres /usr/bin/dropdb --if-exists imbi > /dev/null
	@ docker compose exec -T postgres /usr/bin/createdb imbi > /dev/null
	@ bin/build.sh build/ddl-imbi.sql build/dml-imbi.sql
	@ sleep 1
	@ docker compose exec -T postgres /usr/bin/psql -d imbi -f /build/ddl-imbi.sql -X -v ON_ERROR_STOP=1 -q --pset=pager=off
	@ docker compose exec -T postgres /usr/bin/psql -d imbi -f /build/dml-imbi.sql -X -v ON_ERROR_STOP=1 -q --pset=pager=off
	@ docker compose exec -T postgres /usr/bin/psql -d imbi -c "CREATE EXTENSION pgtap;" -X -q --pset=pager=off
	@ docker compose exec -T postgres /usr/bin/psql -d imbi -c "CREATE EXTENSION plpgsql_check;" -X -q --pset=pager=off
	@ rm build/d*l-imbi.sql
	@ echo "Schema installed into imbi"

ddl: build
	@ bin/build.sh build/ddl.sql build/dml.sql

.DEFAULT_GOAL = test
