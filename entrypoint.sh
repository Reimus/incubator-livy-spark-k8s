#!/bin/bash

# can override following env vars:
# CONFIG_SPARK_DIR
# CONFIG_LIVY_DIR
# CONFIG_HADOOP_DIR

if [ -z "$CONFIG_SPARK_DIR" ]; then
CONFIG_SPARK_DIR=/opt/configfiles
fi
if [ -z "$CONFIG_LIVY_DIR" ]; then
CONFIG_LIVY_DIR=/opt/configfiles
fi
if [ -z "$CONFIG_HADOOP_DIR" ]; then
CONFIG_HADOOP_DIR=/opt/configfiles
fi


LIVYFILE_TUPLES="${CONFIG_LIVY_DIR}/livy.conf ${LIVY_HOME}/conf/livy.conf
${CONFIG_LIVY_DIR}/livy-client.conf ${LIVY_HOME}/conf/livy-client.conf
${CONFIG_LIVY_DIR}/spark-blacklist.conf ${LIVY_HOME}/conf/spark-blacklist.conf
${CONFIG_LIVY_DIR}/livy-env.sh ${LIVY_HOME}/conf/livy-env.sh"

SPARKFILE_TUPLES="${CONFIG_SPARK_DIR}/spark-defaults.conf ${SPARK_HOME}/conf/spark-defaults.conf
${CONFIG_SPARK_DIR}/spark-env.sh ${SPARK_HOME}/conf/spark-env.sh"

HADOOPFILE_TUPLES="${CONFIG_HADOOP_DIR}/core-site.xml ${SPARK_HOME}/conf/core-site.xml
${CONFIG_HADOOP_DIR}/hdfs-site.xml ${SPARK_HOME}/conf/hdfs-site.xml
${CONFIG_HADOOP_DIR}/hive-site.xml ${SPARK_HOME}/conf/hive-site.xml
${CONFIG_HADOOP_DIR}/hbase-site.xml ${SPARK_HOME}/conf/hbase-site.xml"

copy_file_tuples() {
echo "$1" | while read src dst; do
    if [ -e "$src" ]; then
        cat "$src" >> "$dst"
    fi
done
}

unset CONFIG_SPARK_DIR
unset CONFIG_LIVY_DIR
unset CONFIG_HADOOP_DIR

copy_file_tuples "$LIVYFILE_TUPLES"
copy_file_tuples "$SPARKFILE_TUPLES"
copy_file_tuples "$HADOOPFILE_TUPLES"

#
# Fill in configuration data from environment variables
#
env_to_conf() {
    prefix=$1
    file=$2
    sep=$3

    for prop in $(env | grep "^${prefix}_"); do
        env=$(echo "$prop" | sed 's/=.*//')
        val=$(echo "$prop" | sed "s/${env}=//" )
        key=$(echo "$env" | sed -e "s/^${prefix}_//" -e 's/__/-/g' -e 's/_/./g')
        echo "$key" $sep "$val" >> "$file"
    done
}

env_to_conf LIVY_CONF "${LIVY_HOME}/conf/livy.conf" '='
env_to_conf LIVY_CLIENT_CONF "${LIVY_HOME}/conf/livy-client.conf" '='
env_to_conf SPARK_CONF "${SPARK_HOME}/conf/spark-defaults.conf"

#
# Hadoop Config
#



#
# Start Livy Server
#
exec "${LIVY_HOME}/bin/livy-server"
