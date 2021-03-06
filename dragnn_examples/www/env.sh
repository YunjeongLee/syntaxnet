#!/bin/bash
set -o errexit

# code from http://stackoverflow.com/a/1116890
function readlink()
{
    TARGET_FILE=$2
    cd `dirname $TARGET_FILE`
    TARGET_FILE=`basename $TARGET_FILE`

    # Iterate down a (possible) chain of symlinks
    while [ -L "$TARGET_FILE" ]
    do
        TARGET_FILE=`readlink $TARGET_FILE`
        cd `dirname $TARGET_FILE`
        TARGET_FILE=`basename $TARGET_FILE`
    done

    # Compute the canonicalized name by finding the physical path
    # for the directory we're in and appending the target file.
    PHYS_DIR=`pwd -P`
    RESULT=$PHYS_DIR/$TARGET_FILE
    echo $RESULT
}
export -f readlink

export LC_ALL=ko_KR.UTF-8
export LANG=ko_KR.UTF-8

# directory
## current dir of this script
CDIR=$(readlink -f $(dirname $(readlink -f ${BASH_SOURCE[0]})))
PDIR=$(readlink -f $(dirname $(readlink -f ${BASH_SOURCE[0]}))/..)

# server 
daemon_name='dragnn_dm'
port_devel=8897
port_service=8897
enable_konlpy='False'

# resources
if [ "${enable_konlpy}" == "True" ]; then
    DATA_DIR=${PDIR}/data_sejong
else
    DATA_DIR=${PDIR}/data
fi
DRAGNN_SPEC_FILE=${DATA_DIR}/parser_spec.textproto
CHECKPOINT_FILE=${DATA_DIR}/checkpoint.model

# tf master
TF_MASTER=''
#TF_MASTER=grpc://localhost:45806

# command setting
python='/usr/bin/python'

# functions

function make_calmness()
{
	exec 3>&2 # save 2 to 3
	exec 2> /dev/null
}

function revert_calmness()
{
	exec 2>&3 # restore 2 from previous saved 3(originally 2)
}

function close_fd()
{
	exec 3>&-
}

function jumpto
{
	label=$1
	cmd=$(sed -n "/$label:/{:a;n;p;ba};" $0 | grep -v ':$')
	eval "$cmd"
	exit
}
