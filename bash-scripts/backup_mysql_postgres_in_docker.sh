#!/bin/bash

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/home/medstack/sql-backups/$DATE"
PG_USER="postgres"

mkdir -p "$BACKUP_DIR"

find_env_files() {
   find /var/lib/docker/zfs/graph -type f -path "*/var/www/*/.env" 2>/dev/null
}

extract_db_credentials() {
   local env_file=$1
   local app_path=$(echo "$env_file" | grep -o '/var/www/[^/]*')
   local app_name=$(basename "$app_path")
   
   echo "=== $app_name ==="
   grep -E "^DB_(CONNECTION|HOST|PORT|DATABASE|USERNAME|PASSWORD)=" "$env_file"
   echo ""
}

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
    local service_dir="$BACKUP_DIR/$service"
    mkdir -p "$service_dir"
    
    declare -A seen_configs
    
    while IFS= read -r env_file; do
        if grep -q "DB_HOST=$service" "$env_file"; then
            local db_user=$(grep "^DB_USERNAME=" "$env_file" | cut -d '=' -f2 | tr -d ' \t\n\r')
            local db_pass=$(grep "^DB_PASSWORD=" "$env_file" | cut -d '=' -f2 | tr -d ' \t\n\r')
            local db_name=$(grep "^DB_DATABASE=" "$env_file" | cut -d '=' -f2 | tr -d ' \t\n\r')
            
            local config_key="${db_name}:${db_user}"
            
            if [[ -z "${seen_configs[$config_key]}" ]]; then
                seen_configs[$config_key]=1
                local backup_file="$service_dir/mysql_${service}_${db_name}.sql.gz"
                echo "Backing up MySQL database: $service/$db_name with user $db_user"
                docker exec $(docker ps -q -f name="${service}") mysqldump --host="$service" -u"$db_user" -p"$db_pass" "$db_name" | gzip > "$backup_file"
            fi
        fi
    done < <(find /var/lib/docker/zfs/graph -type f -path "*/var/www/*/.env")
}

mysql_get_databases() {
   local service=$1
   declare -A seen_dbs
   
   while IFS= read -r env_file; do
       if grep -q "DB_HOST=$service" "$env_file"; then
           local db_name=$(grep "^DB_DATABASE=" "$env_file" | cut -d '=' -f2 | tr -d ' \t\n\r')
           if [[ -z "${seen_dbs[$db_name]}" ]]; then
               seen_dbs[$db_name]=1
               echo "$db_name"
           fi
       fi
   done < <(find /var/lib/docker/zfs/graph -type f -path "*/var/www/*/.env")
}

pg_backup_database() {
   local service=$1
   local db=$2
   local service_dir="$BACKUP_DIR/$service"
   mkdir -p "$service_dir"
   local backup_file="$service_dir/postgresql_${service}_${db}.sql.gz"
   
   echo "Backing up PostgreSQL database: $service/$db"
   docker exec $(docker ps -q -f name="${service}") pg_dump -U "$PG_USER" \
       --clean --if-exists --no-owner --no-acl "$db" | gzip > "$backup_file"
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
                   mysql_backup_database "$service"
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
   echo "Creating backup directory: $BACKUP_DIR"
   
   echo "Finding and extracting database credentials from .env files:"
   env_files=$(find_env_files)
   for file in $env_files; do
       extract_db_credentials "$file"
   done
   
   echo "Starting database backups..."
   backup_databases "mysql"
   backup_databases "postgres"
   echo "All backups completed"
   echo "Backup location: $BACKUP_DIR"
}

main
