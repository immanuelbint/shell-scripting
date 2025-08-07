#!/bin/bash

# Declare known keytabs in an associative array
declare -A KEYTABS
KEYTABS["hdfs"]="/etc/security/keytabs/hdfs.headless.keytab"
KEYTABS["yarn"]="/etc/security/keytabs/yarn.service.keytab"
KEYTABS["hbase"]="/etc/security/keytabs/hbase.service.keytab"
KEYTABS["hive"]="/etc/security/keytabs/hive.service.keytab"
KEYTABS["storm"]="/etc/security/keytabs/storm.headless.keytab"
KEYTABS["kafka"]="/etc/security/keytabs/kafka.service.keytab"
KEYTABS["solr"]="/etc/security/keytabs/solr.service.keytab"
KEYTABS["spark"]="/etc/security/keytabs/spark.service.keytab"

# Get service name input
read -r -p "Enter service name you'd like to kinit => " response
response=$(echo "$response" | tr '[:upper:]' '[:lower:]')

# Check if service exists
if [[ -n "${KEYTABS[$response]}" ]]; then
    keytab_path="${KEYTABS[$response]}"
else
    echo "Service not found. Would you like to specify a custom keytab?"
    read -r -p "(y/n) => " userinput
    if [[ "$userinput" =~ ^[Yy]$ ]]; then
        read -r -p "Enter full path to keytab => " keytab_path
    else
        exit 0
    fi
fi

# Validate keytab and perform kinit
if [[ -f "$keytab_path" ]]; then
    principal=$(klist -kt "$keytab_path" | grep @ | awk '{print $NF}' | head -n 1)
    if [[ -n "$principal" ]]; then
        kinit -kt "$keytab_path" "$principal"
        echo "INFO: Successfully authenticated with keytab: $keytab_path"
    else
        echo "Error: No principal found in keytab."
    fi
else
    echo "Error: Keytab file not found at $keytab_path"
fi
