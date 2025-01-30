#!/bin/bash

BACKUP_DIR="$HOME/sql-backups"
DATE=$(date +%Y%m%d_%H%M%S)
PG_USER="postgres"

mkdir -p "$BACKUP_DIR"

find_db_containers() {
    local db_type=$1
    case "$db_type" in
        "mysql")
            docker service ls --format "{{.Name}}" | grep -i "mysql"
            ;;
        "postgres")
            docker service ls --format "{{.Name}}" | grep -i "postgres"
            ;;
    esac
}

mysql_backup_database() {
    local service=$1
    local db=$2
    local backup_file="$BACKUP_DIR/mysql_${service}_${db}_${DATE}.sql"
    
    echo "Backing up MySQL database: $service/$db"
    docker exec $(docker ps -q -f name="${service}") mysqldump "$db" > "$backup_file"
    return $?
}

mysql_get_databases() {
    local service=$1
    docker exec $(docker ps -q -f name="${service}") mysql -N -e "SHOW DATABASES;" | \
        grep -Ev "^(information_schema|performance_schema|mysql|sys)$"
}

pg_backup_database() {
    local service=$1
    local db=$2
    local backup_file="$BACKUP_DIR/postgresql_${service}_${db}_${DATE}.sql"
    
    echo "Backing up PostgreSQL database: $service/$db"
    docker exec $(docker ps -q -f name="${service}") pg_dump -U "$PG_USER" \
        --clean --if-exists --no-owner --no-acl "$db" > "$backup_file"
    return $?
}

pg_get_databases() {
    local service=$1
    docker exec $(docker ps -q -f name="${service}") psql -U "$PG_USER" -t -A \
        -c "SELECT datname FROM pg_database WHERE datistemplate = false AND datname != 'postgres';"
}

backup_databases() {
    local db_type=$1
    local services=$(find_db_containers "$db_type")
    
    for service in $services; do
        echo "Processing $db_type service: $service"
        
        case "$db_type" in
            "mysql")
                local databases=$(mysql_get_databases "$service")
                for db in $databases; do
                    mysql_backup_database "$service" "$db"
                done
                ;;
            "postgres")
                local databases=$(pg_get_databases "$service")
                for db in $databases; do
                    pg_backup_database "$service" "$db"
                done
                ;;
        esac
    done
}

main() {
    echo "Starting backup process..."
    backup_databases "mysql"
    backup_databases "postgres"
    echo "All backups completed"
    echo "Backup location: $BACKUP_DIR"
}

main