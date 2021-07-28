FROM gavinmroy/alpine-postgres:13.2-0
ENV POSTGRES_DB=postgres
ADD build/ddl.sql /docker-entrypoint-initdb.d/
