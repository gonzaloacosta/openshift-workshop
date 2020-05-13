FROM docker.io/library/fedora:latest
RUN yum install -y postgresql-server
USER postgres
RUN /bin/initdb -D /var/lib/pgsql/data
RUN /usr/bin/pg_ctl start -D /var/lib/pgsql/data -s -o "-p 5432" -w -t 300 &&\
                /bin/psql --command "CREATE USER docker WITH SUPERUSER PASSWORD 'docker';" &&\
                /bin/createdb -O docker docker
RUN echo "host all  all    0.0.0.0/0  md5" >> /var/lib/pgsql/data/pg_hba.conf
RUN echo "listen_addresses='*'" >> /var/lib/pgsql/data/postgresql.conf
EXPOSE 5432
CMD ["/bin/postgres", "-D", "/var/lib/pgsql/data", "-c", "config_file=/var/lib/pgsql/data/postgresql.conf"]
