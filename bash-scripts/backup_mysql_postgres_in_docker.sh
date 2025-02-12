# !/bin/bash

DATE=$(date +%Y%m%d_%H%M%S)
LINUX_USERNAME="ubuntu"
BACKUP_DIR="/home/$LINUX_USERNAME/sql-backups/$DATE"
PG_USER="postgres"
SERVER_NAME=$(hostname)
ENVIRONMENT="stage"
WEBHOOK_URL="WEBHOOK_HERE"

send_slack_notification() {
    local message="$1"
    curl -X POST -H 'Content-type: application/json' \
        --data "{\"text\":\"[$ENVIRONMENT][$SERVER_NAME] $message\"}" \
        $WEBHOOK_URL
}

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

find_local_containers() {
    local db_type=$1
    case "$db_type" in
        "mysql")
            docker ps --format "{{.Names}}" | grep -i "mysql"
            ;;
        "postgres")
            docker ps --format "{{.Names}}" | grep -i "postgres"
            ;;
    esac
}

mysql_backup_database() {
    local container=$1
    local service_dir="$BACKUP_DIR/$container"
    mkdir -p "$service_dir"

    declare -A seen_configs

    while IFS= read -r env_file; do
        if grep -q "DB_HOST=$container" "$env_file"; then
            local db_user=$(grep "^DB_USERNAME=" "$env_file" | cut -d '=' -f2 | tr -d ' \t\n\r')
            local db_pass=$(grep "^DB_PASSWORD=" "$env_file" | cut -d '=' -f2 | tr -d ' \t\n\r')
            local db_name=$(grep "^DB_DATABASE=" "$env_file" | cut -d '=' -f2 | tr -d ' \t\n\r')

            local config_key="${db_name}:${db_user}"

            if [[ -z "${seen_configs[$config_key]}" ]]; then
                seen_configs[$config_key]=1
                local backup_file="$service_dir/mysql_${container}_${db_name}.sql.gz"
                echo "Backing up MySQL database: $container/$db_name with user $db_user"

                docker exec "$container" mysqldump -u"$db_user" -p"$db_pass" "$db_name" | gzip > "$backup_file"
                if [ $? -ne 0 ]; then
                    send_slack_notification "Failed to backup MySQL database: $container/$db_name"
                fi
            fi
        fi
    done < <(find /var/lib/docker/zfs/graph -type f -path "*/var/www/*/.env")
}

mysql_get_databases() {
    local container=$1
    declare -A seen_dbs

    while IFS= read -r env_file; do
        if grep -q "DB_HOST=$container" "$env_file"; then
            local db_name=$(grep "^DB_DATABASE=" "$env_file" | cut -d '=' -f2 | tr -d ' \t\n\r')
            if [[ -z "${seen_dbs[$db_name]}" ]]; then
                seen_dbs[$db_name]=1
                echo "$db_name"
            fi
        fi
    done < <(find /var/lib/docker/zfs/graph -type f -path "*/var/www/*/.env")
}

pg_backup_database() {
    local container=$1
    local db=$2
    local service_dir="$BACKUP_DIR/$container"
    mkdir -p "$service_dir"
    local backup_file="$service_dir/postgresql_${container}_${db}.sql.gz"

    echo "Backing up PostgreSQL database: $container/$db"
    docker exec "$container" pg_dump -U "$PG_USER" \
        --clean --if-exists --no-owner --no-acl "$db" | gzip > "$backup_file"

    if [ $? -ne 0 ]; then
        send_slack_notification "Failed to backup PostgreSQL database: $container/$db"
    fi
    return $?
}

pg_get_databases() {
    local container=$1
    docker exec "$container" psql -U "$PG_USER" -t -A \
        -c "SELECT datname FROM pg_database WHERE datistemplate = false AND datname != 'postgres';"
}

backup_databases() {
    local db_type=$1
    local containers=$(find_local_containers "$db_type")

    for container in $containers; do
        echo "Processing $db_type container: $container"

        case "$db_type" in
            "mysql")
                local databases=$(mysql_get_databases "$container")
                for db in $databases; do
                    mysql_backup_database "$container"
                done
                ;;
            "postgres")
                local databases=$(pg_get_databases "$container")
                for db in $databases; do
                    pg_backup_database "$container" "$db"
                done
                ;;
        esac
    done
}

main() {
    if ! docker ps &>/dev/null; then
        echo "No local Docker containers found. Exiting."
        exit 0
    fi

    echo "Starting backup process on $SERVER_NAME..."
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

    send_slack_notification "Backup script completed execution successfully on $SERVER_NAME"
}

main

echo "Cleanup"
sudo find /home/$LINUX_USERNAME/sql-backups/ -mindepth 1 -maxdepth 1 -type d -printf '%T@ %p\n' | sort -nr | tail -n +6 | cut -d' ' -f2- | xargs rm -rf