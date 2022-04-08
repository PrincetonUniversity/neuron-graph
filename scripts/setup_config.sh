#!/bin/sh

if [ $# -ne 3 ]
then
    echo "Usage: $0 <DATABASE-NAME> <DATABASE-USER> <DATABASE-PASWORD>"
    exit 1
fi

NEMANODE_DATABASE="$1"
NEMANODE_TEST_DATABASE="$1_tests"
NEMANODE_USER="$2"
NEMANODE_PASSWORD="$(echo $3 | sed -e "s/\\\\/\\\\\\\/g" -e "s/'/\\\'/g")"

# Create config file.
cat >config.ini <<EOL
[http_server]
port = 3000
auth_user = 
auth_password = 

[mysql]
database = $NEMANODE_DATABASE
test_database = $NEMANODE_TEST_DATABASE
user = $NEMANODE_USER
password = $NEMANODE_PASSWORD

[google_analytics]
google_analytics_id = 
EOL

# Create output for MySQL.
cat <<EOSQL

DROP DATABASE IF EXISTS $NEMANODE_DATABASE;
CREATE DATABASE $NEMANODE_DATABASE;
USE $NEMANODE_DATABASE;
GRANT ALL PRIVILEGES ON *.* TO '$NEMANODE_USER'@'localhost' IDENTIFIED BY '$NEMANODE_PASSWORD';

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS datasets;
CREATE TABLE datasets (
  id VARCHAR(20) NOT NULL,
  collection VARCHAR(20) NOT NULL,
  name VARCHAR(50) NOT NULL,
  description TEXT NOT NULL,
  time SMALLINT NOT NULL,
  visual_time SMALLINT NOT NULL,
  datatypes VARCHAR(8) NOT NULL,
  CONSTRAINT pk_datasets PRIMARY KEY (id),
  INDEX idx_datasets_id (id),
  INDEX idx_datasets_collection (collection)
);

DROP TABLE IF EXISTS neurons;
CREATE TABLE neurons (
  name VARCHAR(30) NOT NULL,
  class VARCHAR(30) NOT NULL,
  neurotransmitter VARCHAR(10) NOT NULL,
  type VARCHAR(10) NOT NULL,
  embryonic BOOLEAN NOT NULL,
  inhead BOOLEAN NOT NULL,
  intail BOOLEAN NOT NULL,
  CONSTRAINT pk_neurons PRIMARY KEY (name)
);

DROP TABLE IF EXISTS trajectories;
CREATE TABLE trajectories (
  id INT NOT NULL,
  dataset_id VARCHAR(20) NOT NULL,
  neuron_name VARCHAR(30) NOT NULL,
  trajectory_json MEDIUMTEXT NOT NULL,
  PRIMARY KEY (id),
  FOREIGN KEY (dataset_id) REFERENCES datasets(id),
  FOREIGN KEY (neuron_name) REFERENCES neurons(name)
);

DROP TABLE IF EXISTS connections;
CREATE TABLE connections (
  id INT UNSIGNED NOT NULL,
  dataset_id VARCHAR(20) NOT NULL,
  pre VARCHAR(30) NOT NULL,
  post VARCHAR(30) NOT NULL,
  type VARCHAR(20) NOT NULL,
  synapses SMALLINT NOT NULL,
  CONSTRAINT pk_connections PRIMARY KEY (dataset_id, pre, post, type),
  CONSTRAINT idx_connections_dataset_id FOREIGN KEY (dataset_id) REFERENCES datasets(id),
  INDEX idx_connections_id (id),
  INDEX idx_connections_dataset_id (dataset_id),
  INDEX idx_connections_pre (pre),
  INDEX idx_connections_post (post),
  INDEX idx_connections_type (type),
  INDEX idx_connections_synapses (synapses)
);

DROP TABLE IF EXISTS synapses;
CREATE TABLE synapses (
  id INT UNSIGNED NOT NULL AUTO_INCREMENT,
  connection_id INT UNSIGNED NOT NULL,
  connector_id INT UNSIGNED NOT NULL,
  weight INT UNSIGNED NOT NULL,
  pre_tid INT UNSIGNED NOT NULL,
  post_tid INT UNSIGNED NOT NULL,
  CONSTRAINT pk_synapses PRIMARY KEY (id),
  CONSTRAINT idx_synapses_connection_id FOREIGN KEY (connection_id) REFERENCES connections(id),
  INDEX idx_synapses_connection_id (connection_id),
  INDEX idx_synapses_connector_id (connector_id),
  INDEX idx_synapses_weight (weight),
  INDEX idx_synapses_pre_tid (pre_tid),
  INDEX idx_synapses_post_tid (post_tid)
);

DROP TABLE IF EXISTS annotations;
CREATE TABLE annotations (
  pre VARCHAR(30) NOT NULL,
  post VARCHAR(30) NOT NULL,
  type VARCHAR(20) NOT NULL,
  collection VARCHAR(20) NOT NULL,
  annotation VARCHAR(30) NOT NULL,
  CONSTRAINT pk_annotations PRIMARY KEY (pre, post, type, collection, annotation),
  INDEX idx_annotations_pre (pre),
  INDEX idx_annotations_post (post),
  INDEX idx_annotations_type (type),
  INDEX idx_annotations_collection (collection),
  INDEX idx_annotations_annotation (annotation)
);


DROP DATABASE IF EXISTS $NEMANODE_TEST_DATABASE;
CREATE DATABASE $NEMANODE_TEST_DATABASE;
USE $NEMANODE_TEST_DATABASE;
GRANT ALL PRIVILEGES ON *.* TO '$NEMANODE_USER'@'localhost' IDENTIFIED BY '$NEMANODE_PASSWORD';

CREATE TABLE datasets LIKE $NEMANODE_DATABASE.datasets;
CREATE TABLE neurons LIKE $NEMANODE_DATABASE.neurons;
CREATE TABLE trajectories LIKE $NEMANODE_DATABASE.trajectories;
CREATE TABLE connections LIKE $NEMANODE_DATABASE.connections;
CREATE TABLE synapses LIKE $NEMANODE_DATABASE.synapses;
CREATE TABLE annotations LIKE $NEMANODE_DATABASE.annotations;

SET FOREIGN_KEY_CHECKS = 1;
EOSQL
