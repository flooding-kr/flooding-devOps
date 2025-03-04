apt install postgresql

sudo su - postgres
# alter user postgres with password '$DB_PASSWORD';

vim /etc/postgresql/16/main/postgresql.conf
# listen_addresses = "*"

vim /etc/postgresql/16/main/pg_hba.conf
# host  all all 0.0.0.0/0 md5
# local all all           md5

sudo systemctl restart postgresql
sudo ufw allow 5432/tcp