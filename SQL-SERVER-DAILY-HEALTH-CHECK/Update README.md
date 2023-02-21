SQL-SERVER-DAILY-HEALTH-CHECK
Are you a Senior Sql Server DBA or novice looking for a Daily Sql Server Health Check? As a Senior dba for over 15 years I have compile a few scripts I use on a daily basis to check the health of my Sql Servers.

Perform a Daily Sql Server Health Check on your Sql Server 2012 version and above. The scripts will create the following tables and items.

SCRIPT 1: Step1_Daily_Sql_Health_Check_Create

Verify your Sql Server services and agents are running
Check which Databases are online and offline
Check Always-on High Availability AG Health
Verify the current day Database Backups
Check Sql Server Jobs
Check the current Sql Server Login Count
Check the current Sql server databases Read & Write
Check the Sql Server Luns free space
SCRIPT 2: Step2_Daily_Sql_Health_Check_Insert

Insert the current day health check records into the health check tables. You can run this job manually or add the script to a Sql jobs.
The script also deletes records that are older than 14 days. You can change the number of days to delete.
SCRIPT 3: Step3_Daily_Sql_Health_Check_Job (Optional)

Create a Sql Server job that execute script 2.
SCRIPT 4: Step4_QUERY_DAILY_HEALTH_CHECK_TABLES 1. Run select statements to view the daily Sql server health check records.
