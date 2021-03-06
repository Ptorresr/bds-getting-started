# Backup Your Hadoop Cluster to Oracle Object Storage

## Before You Begin

### Objectives
The goal for this tutorial is to back up your Cloudera Apache Hadoop cluster to Oracle Object Storage.  After backing up your cluster, you can restore it to a your Big Data Service cluster.

To backup your Hadoop cluster, you will:
* Log into Oracle Cloud Infrastructure and create a bucket in Oracle Object Storage
* Create a Secret Key, which you will use to connect to Oracle Object Storage from your Hadoop Cluster
* Log into Cloudera Manager on your source cluster
* User Cloudera Backup and Disaster Recovery to backup both HDFS data and Hive Metadata

### Requirements

To complete this lab, you need to have the following:

* Login credentials and a tenancy name for the Oracle Cloud Infrastructure Console
* Oracle Big Data Service Hadoop cluster deployed 
* Privileges to create a bucket in Oracle Object Storage
* Admin credentials for Cloudera Manager on your source cluster
* Key services on the source cluster (Zookeeper, Hive, HDFS, etc.) are running and healthy

If you don't have a Big Data Service cluster created, then you can follow the steps in [Create a Big Data Service Cluster](../?create-cluster) to create one.

## Create a bucket in Oracle Object Storage

* From your browser, [login to Oracle Cloud Infrastructure](https://console.us-ashburn-1.oraclecloud.com/a/tenancy)
    * Enter your **Tenancy** and then click **Continue**.
    * Enter your OCI user name and password


* Select **Object Storage**

* Create a bucket called `BDCS-MIGRATION`.  Use an UPPERCASE name; this is required for the Hadoop S3 connector to work.

## Create a Customer Secret Key

* Select **Identity >> Users >> User Details >> Customer Secret Keys**
* Click **Generate Secret Key**
* Name the secret key `migration-key`
* Save the secret key to a safe place.  It will not be shown again..
    * Access Key: `myaccesskey`
    * Secret Key: `mysecretkey`

## Update the s3a Endpoint
Update the s3a endpoint to point to Oracle Object Storage.  See the [OCI documentation](https://docs.cloud.oracle.com/en-us/iaas/Content/Object/Tasks/understandingnamespaces.htm) to determine your Object Storage Namespace
* Go to the Cloudera Manager home.  
* Select **S3 Connector >> Configuration**
* Update the **Default S3 Endpoint** property with the following
    https://`myobj-store-namespace`.compat.objectstorage.`yourregion`.oraclecloud.com

    For example:
    `https://oraclebigdatadb.compat.objectstorage.us-phoenix-1.oraclecloud.com`
* The cluster must be updated once more.  Click **mycluster >> Deploy Client Configuration**.  Once complete, click **Close**
* Restart the cluster by clicking **mycluster >> Restart**

## Create an External Account in Cloudera Manager
Use the Access Key and Secret Key to create an external account in Cloudera Manager
* Go to **Administration >> External Accounts**
* Click **Add Access Key Credentials** and specify your Access and Secret Key
  * **Name:**  `oracle-credential`
  * **AWS Access Key ID:** `myaccesskey`
  * **AWS Secret Key:** `mysecretkey`
* Do not check **Enable S3Guard** 

## Create a Hive Replication Schedule
Prior to running the replication, ensure that snapshots are enabled for the /user/hive/warehouse directory.  This will ensure that any changes made to files during the replication process will not cause replication failures.

For more details, see [Using Snapshots with Replication](https://docs.cloudera.com/documentation/enterprise/5-15-x/topics/cm_bdr_snap_repl.html) in the Cloudera Administration documentation..

* Enable Snapshots for the **/user/hive/warehouse** directory.  In Cloudera Manager:
  * Select the **HDFS** service
  * Click the **File Browser**
  * Navigate to **/user/hive/warehouse** directory
  * Click **Enable Snapshots**

* Create a Hive Replication Schedule.  In Cloudera Manager, select **Backup >> Replication Schedules** and the select **Create Schedule**.  Fill out the details for the Hive replication schedule.  For example:

  * **Name:**  `hive-rep1`
  * **Source:** `hive`
  * **Destination:** `oracle-credential`
  * **Cloud Root Path:**  `s3a://BDCS-BACKUP/`   (**Note: name of bucket must be upper case**)
  * **Replication Option:**  `Metadata and Data`
  * **Schedule:** `Immediate`
  * **Run As Username:** `Default`
  
  Click **Save Schedule** and run the backup.  You can monitor the replication in Replication Schedules.

## Create an HDFS Replication Schedule
Similar to Hive replication, ensure that the directories that will be replicated are Snapshot enabled.  In this example, `/data/` directory will be backed up to object store.
* Enable Snapshots for the **/data** directory.  In Cloudera Manager:
  * Select the **HDFS** service
  * Click the **File Browser**
  * Navigate to **/data** directory
  * Click **Enable Snapshots**

* Create an HDFS Replication Schedule.  In Cloudera Manager, select **Backup >> Replication Schedules** and the select **Create Schedule**.  Fill out the details for the HDFS replication schedule.  For example:

  * **Name:**  `hdfs-rep1`
  * **Source:** `hdfs`
  * **Destination:** `oracle-credential`
  * **Destination Path:**  `s3a://BDCS-BACKUP/`
  * **Replication Option:**  `Metadata and Data`
  * **Schedule:** `Immediate`
  * **Run As Username:** `Default`
  
  Click **Save Schedule** and run the backup.

## Review Source Cluster Configuration
Make note of any custom configuration settings on your source cluster.  You may have to make similar updates to your BDS cluster.  This includes things like application jar files, updated paths, etc.  Log into Cloudera Manager and then download the cluster deployment using the following URL:
    
https://`your-cm-host`:7183/api/v18/cm/deployment

This will dump the configuration in JSON format - listing any overrides made on the cluster.  For example, search for `hive.aux.jars.path` to view the list of application jars required to run your hive queries.  These files will need to be copied to your BDS cluster and an equivalent update to `hive.aux.jars.path` should be made.
  

## Summary
Your Hadoop data and metadata are now backed up to Oracle Object Storage.  You can perform incremental backups of this data by scheduling the backup jobs.  Your next step will be to restore this data to your Big Data Service Hadoop cluster.

**This completes the tutorial!**
