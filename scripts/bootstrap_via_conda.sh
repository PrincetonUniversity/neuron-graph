#!/bin/bash

# if you already have a neuron-graph env, rename it here
NGENV="neuron-graph"

# two main packages version limits.
# should be greater than GT value and
# less than LT value

NODEJS_GT=11
NODEJS_LT=16

MYSQL_GT=4
MYSQL_LT=8

main() {

if [[ ! $CONDA_EXE ]]; then
  cat << MINIC

conda command not found. Download and run miniconda from:

https://repo.anaconda.com/miniconda

MINIC
  exit 1
fi

CDIR="$(dirname $(dirname $CONDA_EXE))"
if [[ -f ${CDIR}/etc/profile.d/conda.sh ]]; then
  . ${CDIR}/etc/profile.d/conda.sh
else
  export PATH="$(dirname $CONDA_EXE):${PATH}"
fi

if have_env ${NGENV}; then
  echo "conda env $NGENV exists, skipping \"conda create\"..."
else
  envloc="$( dirname $( dirname ${CONDA_EXE} ) )/envs/${NGENV}"
  [[ -d $envloc ]] && echo "old or incomplete $NGENV dir, remove via rm -rf $eloc if this is the case, and rerun." && exit 1
  conda create -yn "${NGENV}" "nodejs>${NODEJS_GT},<${NODEJS_LT}" "mysql>${MYSQL_GT},<${MYSQL_LT}"
fi

echo "Activating conda env $NGENV ... "
conda activate "${NGENV}"

# jan 2022 experience with conda's mysql package
#
#   - is version 5.7.x in default channel
#   - is not set up to work when you run:
#        mysql.server start
#
# info about conda's version of the  mysql.server script
#
# "basedir" is configured to be the conda env base dir ($CONDA_PREFIX)
#
# Problem 1: dir where error logs, pid files, etc  are saved
#            does not exist. By default is "datadir"
#            datadir is set to "basedir/data" by default.
#           
# Solution: create datadir in default location ${CONDA_PREFIX}/data
datadir="${CONDA_PREFIX}/data"
if [[ ! -d $datadir ]]; then
  echo "Creating MySQL server datadir $datadir"
  mkdir "$datadir"
fi

# now if you run mysql.server it has a place to save error logs!
#
# Examining the datadir/$(hostname).err log:
#
# Problem 2:  cannot find errmsg.sys in the basedir.
#             That's because it is in basedir/share/<language>
# 
# It is time to create a "my.cnf" file
#    stackoverflow: <https://stackoverflow.com/a/41757888>
CONFIG_FILE="${CONDA_PREFIX}/my.cnf"
if [[ ! -f ${CONFIG_FILE} ]]; then
  echo "Creating MySQL my.cnf file in $NGENV env..."
  cat << MYCNF > ${CONFIG_FILE}
[mysqld]
lc_messages_dir=${CONDA_PREFIX}/share/mysql
lc_messages = en_US
MYCNF
fi
# initialize mysql. Cannot run mysql_secure_installation since that requires
# that mysqld is running!
# Must specify --log-error otherwise it defaults to the datadir, which
# initialize insists must be empty in order to initialize the databases there!
# Here we initialize without a root password-- dev machine. Can always add one later
# via substituting it in for root-password below at mysql prompt
#  ALTER USER 'root'@'localhost' IDENTIFIED BY 'root-password';
# NOTE that we do not need to be root or use sudo to login as mysql root, just
# specify it via mysql -u root (append "-p root-password" if added one per above)
# 
# set -e starts here, will quit script if child returns non-zero
echo "Initializing and starting MySQL from conda env ..."
set -e
mysqld_safe --initialize-insecure --log-error="${CONDA_PREFIX}/install.err"
mysql.server start

# install nodejs requirements
if [[ -f package.json ]]; then
  echo "Installing nodejs dependencies via npm into $NGENV environment..."
  npm install
  printf "\nInitializing nemanode database ...\n\n"
  scripts/setup_config.sh nemanode nemanode_user password | mysql -u root
  printf "Running \"npm run populate-database\" ...\n\n"
  npm run populate-database
  [[ Darwin == $(uname) ]] && open "http://localhost:3000" || echo "open localhost:3000 in browser"
  printf "Launching neuron-graph via \"npm start\"...\n\n"
  npm start
else
  cat << TOPLEVEL
  
  TO DO:
   - cd to the neuron-graph source toplevel dir containing package.json
   - if you have not done it yet, run these commands to complete
     the installation and setup:
         npm install
         mysql.server start  (if it has been stopped)
         scripts/setup_config.sh nemanode nemanode_user password | mysql -u root
         npm run populate-database
  - and finally, run it (from top-level dir):
         npm start
         go to localhost:3000 in web browser
TOPLEVEL
 
fi
set +e
# quit-on-error off

# now instruct user how to activate env and run mysql.server
cat << HOWTO

Summary of steps (post successful install, that is):

0 activate conda env

conda activate neuron-graph

1 start mysql server

mysql.server start

2 cd to neuron-graph repo toplevel dir

cd /path/to/neuron-graph

3 launch it

npm start

4 shutting down:

   - ctrl-c back to the prompt

   - mysql.server stop if desired
   
   - conda deactivate (note: can no longer access
                             mysql and npm commands
                             when deactivated)

A Wiping out the neuron-graph dir and re-cloning from github requires re-running:

cd /path/to/neuron-graph
npm install

B Wiping out the conda env (by "conda env remove -n ${NGENV}" or by deleting files,)
   means rerunning this script.

C Wiping out database files, requires initializing and re-populating it.

i) wiping out
mysql.server stop
rm -rf ${CONDA_PREFIX}/data && mkdir ${CONDA_PREFIX}/data

ii) re-init, re-pop
mysqld_safe --initialize-insecure --log-error="${CONDA_PREFIX}/install.err"
mysql.server start
cd /path/to/neuron-graph
scripts/setup_config.sh nemanode nemanode_user password | mysql -u root
npm run populate-database

iii) run neuron-graph, and open web browser to http://localhost:3000
npm start

HOWTO

}

# create a neuron-graph env with nodejs and mysql if does not already exist
have_env() {
  ENAME="$1"
  false
  conda env list | awk '{print $1}' | while read x; do
    [[ $x == $ENAME ]] && true && break
  done
}

main $@
