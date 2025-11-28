#!/bin/bash
# mydbinstance.sh– prototype for future `mydbin` CLI
# EXPERIMENTAL / WIP – internal script, interface may change
# Author: Piotr Fratczak <piotr4f@gmail.com>
#
# License: MIT License
#
# Copyright (c) 2024 Piotr Frątczak
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


CONFIG_FILE=~/.mydbinstancerc
INSTANCE_DIR=~/.mydbinstancerc.d
MYSQL_VERSIONS=("mysql-5.5.62-linux-glibc2.12-x86_64" "mysql-5.6.51-linux-glibc2.12-x86_64" "mysql-5.7.44-linux-glibc2.12-x86_64" "mysql-8.0.40-linux-glibc2.28-x86_64" "mysql-8.4.3-linux-glibc2.28-x86_64")

# Utility function: Print error and exit
error_exit() {
    echo "[ERROR] $1" >&2
    exit 1
}

# Ensure configuration exists
ensure_config_exists() {
    [[ ! -f $CONFIG_FILE ]] && error_exit "Configuration file not found. Run with --initialize_config first."
}

# Check if an instance is running
is_running() {
    local pid_file=$1
    [[ -f $pid_file ]] && kill -0 $(cat $pid_file) 2>/dev/null
}

# Extract pid-file from the configuration
get_pid_file() {
    grep -E '^pid-file' "$MYCNF" | awk -F= '{print $2}' | tr -d ' '
}

# Initialize config file
initialize_config() {
    if [[ -f $CONFIG_FILE ]]; then
        echo "Config file already exists at $CONFIG_FILE"
        return
    fi

    echo "Initializing configuration..."
    read -p "Enter root path [~/testdir]: " MYROOTPATH
    MYROOTPATH=${MYROOTPATH:-~/testdir}

    read -p "Enter MySQL binary path [/opt/mysqlbin]: " MYBINPATH
    MYBINPATH=${MYBINPATH:-/opt/mysqlbin}

    [[ ! -d $MYROOTPATH ]] && mkdir -p "$MYROOTPATH" || echo "Directory $MYROOTPATH exists."
    [[ ! -d $MYBINPATH ]] && error_exit "Binary path $MYBINPATH does not exist."

    echo "MYROOTPATH=$MYROOTPATH" > $CONFIG_FILE
    echo "MYBINPATH=$MYBINPATH" >> $CONFIG_FILE

    mkdir -p $INSTANCE_DIR
    echo "Configuration saved to $CONFIG_FILE"
}


# List instances
list_instances() {
    ensure_config_exists
    [[ ! -d $INSTANCE_DIR || -z "$(ls -A $INSTANCE_DIR 2>/dev/null)" ]] && { echo "No instances found."; return; }

    echo "Available instances:"
    for rc_file in "$INSTANCE_DIR"/*rc; do
        instance_name=$(basename "${rc_file::-2}" .rc)
        source "$rc_file"

        pid_file=$(get_pid_file)
        log_file="$MYROOTPATH/$instance_name/${instance_name}-err.log"
        if is_running "$pid_file"; then
            status="running"
        elif [[ ! -f "$log_file" ]]; then
            status="never run"
        else
            status="stopped"
        fi

        echo "- $instance_name: $status"
    done
}

# Create a new instance
create_instance() {
    ensure_config_exists
    source $CONFIG_FILE || error_exit "Failed to load configuration."


    if [[ -f "$INSTANCE_DIR/${MYINSTANCEUNIQUENAME}rc" ]]; then
        error_exit "Instance $MYINSTANCEUNIQUENAME already exists."
    fi

    echo "Select MySQL version:"
    select version in "${MYSQL_VERSIONS[@]}"; do
        MYBINVERPATH=$MYBINPATH/$version
        [[ -d $MYBINVERPATH ]] && break || echo "Invalid choice, try again."
    done

    MYCNF=$MYROOTPATH/$MYINSTANCEUNIQUENAME/${MYINSTANCEUNIQUENAME}.cnf
    mkdir -p "$MYROOTPATH/$MYINSTANCEUNIQUENAME/data" "$MYROOTPATH/$MYINSTANCEUNIQUENAME/binlogs" "$MYROOTPATH/$MYINSTANCEUNIQUENAME/tmp"

    cat > $MYCNF <<EOF
[mysqld]
server-id = 1
user = $USER
socket = $MYROOTPATH/$MYINSTANCEUNIQUENAME/${MYINSTANCEUNIQUENAME}.sock
datadir = $MYROOTPATH/$MYINSTANCEUNIQUENAME/data
basedir = $MYBINVERPATH
pid-file = $MYROOTPATH/$MYINSTANCEUNIQUENAME/${MYINSTANCEUNIQUENAME}.pid
slow-query-log-file = $MYROOTPATH/$MYINSTANCEUNIQUENAME/${MYINSTANCEUNIQUENAME}-slow.log
log_error = $MYROOTPATH/$MYINSTANCEUNIQUENAME/${MYINSTANCEUNIQUENAME}-err.log
log-bin = $MYROOTPATH/$MYINSTANCEUNIQUENAME/binlogs/${MYINSTANCEUNIQUENAME}-bin
tmpdir = $MYROOTPATH/$MYINSTANCEUNIQUENAME/tmp
default-storage-engine = InnoDB
lower_case_table_names = 1
innodb_flush_method = O_DIRECT
skip-name-resolve
skip-networking
[mysqld-5.5]
innodb_file_per_table
[mysqld-5.6]
explicit_defaults_for_timestamp = 1
[mysqld-5.7]
innodb_tmpdir = $MYROOTPATH/$MYINSTANCEUNIQUENAME/tmp
[mysqld-8.0]
innodb_tmpdir = $MYROOTPATH/$MYINSTANCEUNIQUENAME/tmp
[mysqld-8.4]
innodb_tmpdir = $MYROOTPATH/$MYINSTANCEUNIQUENAME/tmp

EOF

    cat >> $MYCNF <<EOF
[client]
user = root
socket = $MYROOTPATH/$MYINSTANCEUNIQUENAME/${MYINSTANCEUNIQUENAME}.sock
EOF

    echo "MYINSTANCEUNIQUENAME=$MYINSTANCEUNIQUENAME" > "$INSTANCE_DIR/${MYINSTANCEUNIQUENAME}rc"
    echo "MYBINVERPATH=$MYBINVERPATH" >> "$INSTANCE_DIR/${MYINSTANCEUNIQUENAME}rc"
    echo "MYCNF=$MYCNF" >> "$INSTANCE_DIR/${MYINSTANCEUNIQUENAME}rc"

    echo "Instance $MYINSTANCEUNIQUENAME created with configuration saved to $MYCNF."
    echo "To connect: $MYBINVERPATH/bin/mysql --defaults-file=$MYCNF"
}

# Destroy an instance
destroy_instance() {
    ensure_config_exists
    source $CONFIG_FILE || error_exit "Failed to load configuration."

    local rc_file="$INSTANCE_DIR/${MYINSTANCEUNIQUENAME}rc"
    [[ ! -f $rc_file ]] && error_exit "Instance $MYINSTANCEUNIQUENAME does not exist."

    source $rc_file
    pid_file=$(get_pid_file)
    if is_running "$pid_file"; then
        echo "Stopping running instance $MYINSTANCEUNIQUENAME..."
        $MYBINVERPATH/bin/mysqladmin --defaults-file=$MYCNF shutdown || error_exit "Failed to stop instance $MYINSTANCEUNIQUENAME."
        sleep 5
        if is_running "$pid_file"; then
            error_exit "Instance $MYINSTANCEUNIQUENAME is still running."
        fi
    fi

    echo "Destroying instance $MYINSTANCEUNIQUENAME..."
    rm -rf "$MYROOTPATH/$MYINSTANCEUNIQUENAME"
    rm -f "$rc_file"
    echo "Instance $MYINSTANCEUNIQUENAME destroyed."
}

# Initialize instance
initialize_instance() {
    ensure_config_exists
    source $CONFIG_FILE || error_exit "Failed to load configuration."

    local rc_file="$INSTANCE_DIR/${MYINSTANCEUNIQUENAME}rc"
    [[ ! -f $rc_file ]] && error_exit "Instance $MYINSTANCEUNIQUENAME does not exist."

    source $rc_file
    if [[ ! -d "$MYROOTPATH/$MYINSTANCEUNIQUENAME/data" ]]; then
        error_exit "Instance data directory does not exist."
    fi
    if [[ -n "$(ls -A "$MYROOTPATH/$MYINSTANCEUNIQUENAME/data" 2>/dev/null)" ]]; then
        error_exit "Instance data directory is not empty."
    fi

    echo "Initializing data for instance $MYINSTANCEUNIQUENAME..."
    $MYBINVERPATH/bin/mysqld --defaults-file=$MYCNF --initialize-insecure || error_exit "Failed to initialize data."
    echo "Data initialization complete."
}

# Initialize instance 5.6
initialize_instance_56() {
    ensure_config_exists
    source $CONFIG_FILE || error_exit "Failed to load configuration."

    local rc_file="$INSTANCE_DIR/${MYINSTANCEUNIQUENAME}rc"
    [[ ! -f $rc_file ]] && error_exit "Instance $MYINSTANCEUNIQUENAME does not exist."

    source $rc_file

    echo "Initializing MySQL 5.6 instance $MYINSTANCEUNIQUENAME..."
    $MYBINVERPATH/scripts/mysql_install_db \
        --defaults-file=$MYCNF \
        --basedir=$MYBINVERPATH \
        --keep-my-cnf || error_exit "Failed to initialize MySQL 5.6 instance."

    echo "Initialization complete for MySQL 5.6 instance."
}

# Initialize instance 5.5
initialize_instance_55() {
    ensure_config_exists
    source $CONFIG_FILE || error_exit "Failed to load configuration."

    local rc_file="$INSTANCE_DIR/${MYINSTANCEUNIQUENAME}rc"
    [[ ! -f $rc_file ]] && error_exit "Instance $MYINSTANCEUNIQUENAME does not exist."

    source $rc_file

    echo "Initializing MySQL 5.5 instance $MYINSTANCEUNIQUENAME..."
    $MYBINVERPATH/scripts/mysql_install_db \
        --defaults-file=$MYCNF \
        --basedir=$MYBINVERPATH || error_exit "Failed to initialize MySQL 5.6 instance."

    echo "Initialization complete for MySQL 5.5 instance."
}

# Start an instance
start_instance() {
    ensure_config_exists
    source $CONFIG_FILE || error_exit "Failed to load configuration."

    local rc_file="$INSTANCE_DIR/${MYINSTANCEUNIQUENAME}rc"
    [[ ! -f $rc_file ]] && error_exit "Instance $MYINSTANCEUNIQUENAME does not exist."

    source $rc_file
    pid_file=$(get_pid_file)

    if is_running "$pid_file"; then
        echo "Instance $MYINSTANCEUNIQUENAME is already running."
        echo "Connect using: $MYBINVERPATH/bin/mysql --defaults-file=$MYCNF -uroot"
        return
    fi

    echo "Starting instance $MYINSTANCEUNIQUENAME..."
    $MYBINVERPATH/bin/mysqld --defaults-file=$MYCNF &
    sleep 5
    if ! is_running "$pid_file"; then
        error_exit "Failed to start instance $MYINSTANCEUNIQUENAME."
    fi
    echo "Instance $MYINSTANCEUNIQUENAME started."
    echo "Connect using: $MYBINVERPATH/bin/mysql --defaults-file=$MYCNF -uroot"
}

# Stop an instance
stop_instance() {
    ensure_config_exists
    source $CONFIG_FILE || error_exit "Failed to load configuration."

    local rc_file="$INSTANCE_DIR/${MYINSTANCEUNIQUENAME}rc"
    [[ ! -f $rc_file ]] && error_exit "Instance $MYINSTANCEUNIQUENAME does not exist."

    source $rc_file
    pid_file=$(get_pid_file)
    if ! is_running "$pid_file"; then
        echo "Instance $MYINSTANCEUNIQUENAME is not running."
        return
    fi

    echo "Stopping instance $MYINSTANCEUNIQUENAME..."
    $MYBINVERPATH/bin/mysqladmin --defaults-file=$MYCNF shutdown || error_exit "Failed to stop instance $MYINSTANCEUNIQUENAME."
    sleep 5
    if is_running "$pid_file"; then
        error_exit "Instance $MYINSTANCEUNIQUENAME is still running."
    fi
    echo "Instance $MYINSTANCEUNIQUENAME stopped."
}

# Main logic
MYINSTANCEUNIQUENAME=""
while [[ $# -gt 0 ]]; do
    MYINSTANCEUNIQUENAME=$2
if [[ -z "$MYINSTANCEUNIQUENAME" && "$1" != "--list" && "$1" != "--initialize_config" ]]; then
    error_exit "Instance name cannot be empty. Specify unique database instance name as the argument after the command (e.g., --create <instance_name>)."
fi

case $1 in
    --name)
        shift
        ;;
        --name)
            MYINSTANCEUNIQUENAME=$2
            shift 2
            ;;
        *)
            break
            ;;
    esac
done

case $1 in
    --initialize_config)
        initialize_config
        ;;
    --list)
        ensure_config_exists
        list_instances
        ;;
    --create)
        ensure_config_exists
        create_instance
        ;;
    --destroy)
        ensure_config_exists
        destroy_instance
        ;;
    --initialize)
        ensure_config_exists
        initialize_instance
        ;;
    --initialize_56)
        ensure_config_exists
        initialize_instance_56
        ;;
    --initialize_55)
        ensure_config_exists
        initialize_instance_55
        ;;
    --start)
        ensure_config_exists
        start_instance
        ;;
    --stop)
        ensure_config_exists
        stop_instance
        ;;
    *)
        echo "Usage: $0 --initialize_config | --list | --create | --destroy | --initialize | --initialize_56 | --initialize_55 |  --start | --stop"
        ;;
esac
