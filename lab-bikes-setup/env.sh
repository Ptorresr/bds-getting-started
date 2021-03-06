#!/bin/bash
# Setup environment for data used for workshop

# Object Store:  ocid for the compartment.
export COMPARTMENT_OCID=""

# Object Store:  Bucket where data will be copied
export BUCKET_NAME="livelabs"

# HDFS:  root directory in HDFS for the data
export HDFS_ROOT="/data"

# HDFS:  local target directory where files will be downloaded
export TARGET_DIR="$HOME/Downloads"