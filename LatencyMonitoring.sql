--Change @profile_name and @Recipients in at the end

set nocount on
declare @body nvarchar(max)=''
declare @subject nvarchar(max)=''
declare @importance varchar(10)
declare @html nvarchar(max)=''
declare @Recipients nvarchar(100)=''
declare @msend_latency bit=0

if OBJECT_ID('dba.dbo.Latency') is not null drop table dba.dbo.Latency

SELECT

Latency_fetched_at = convert(varchar, getdate(), 22)
,ar.replica_server_name
,adc.database_name
,drs.is_primary_replica
,drs.synchronization_state_desc
,drs.secondary_lag_seconds
,ar.availability_mode_desc
,drs.synchronization_health_desc
,drs.last_commit_time


into dba.dbo.Latency

from sys.dm_hadr_database_replica_states as drs

inner join sys.availability_databases_cluster as adc
on (drs.group_id=adc.group_id)
and (drs.group_database_id=adc.group_database_id)

inner join sys.availability_groups as ag
on (ag.group_id=drs.group_id)

inner join sys.availability_replicas as ar
on (drs.group_id=ar.group_id)
and (drs.replica_id=ar.replica_id)

--Query taken from this link and then some columns added/removed  
-- https://sqlperformance.com/2015/08/monitoring/availability-group-replica-sync


--Filtered as needed

where

(

	(availability_mode_desc='SYNCHRONOUS_COMMIT' AND drs.secondary_lag_seconds>0)
	OR (availability_mode_desc='ASYNCHRONOUS_COMMIT' AND drs.secondary_lag_seconds >120)
	OR(drs.synchronization_state_desc='NOT SYNCHRONIZING')

)


Order by

ag.name,
ar.replica_server_name,
adc.database_name;

----------------------------
----------------------------



if (OBJECT_ID('dba.dbo.ExistingL') is not null ) 

	begin		
		
			insert into dba.dbo.ExistingL select * from dba.dbo.Latency	
			where (replica_server_name+database_name) 
			not in (select replica_server_name+database_name from dba.dbo.ExistingL)
			if @@rowcount > 0 set @msend_latency=1	
			
			
			delete from dba.dbo.ExistingL	
			where (replica_server_name+database_name) 
			not in (select replica_server_name+database_name from dba.dbo.Latency)
			if @@rowcount > 0 set @msend_latency=1
		

	end

else 
	begin
	select * into dba.dbo.ExistingL from dba.dbo.Latency
	set @msend_latency=1
	end




if (@msend_latency=1)

begin
	
	if exists(select * from dba.dbo.ExistingL) 
		begin
			set @subject='Latency ! on server '+@@servername
			set @importance='High'
			set @msend_latency=0
			--print 'Latency'
		end
	
	else
		begin
			set @subject='Latency cleared on server '+@@servername
			set @importance='Normal'
			set @msend_latency=0
			--print 'Cleared'
		end



----------

exec dba.dbo.SqlTableToHtml 'dba.dbo.Latency', 
@html output, '', 'style="border-top:1px #CCCCCC solid;padding:10px"', 'style="padding:7px"'
--Proc copied from https://gist.github.com/PatrickDinh/93a03e706b143f016235

exec msdb.dbo.sp_send_dbmail
@profile_name='YourServerMailProfile',
@recipients='Yourmail@somemailserver.com',
@subject=@subject,
@importance=@importance,
@body=@html,
@body_format = 'HTML'


end
	
---------------------------------------------------------
---------------------------------------------------------





--select * from dba.dbo.Latency 
--select * from dba.dbo.ExistingL
--print @msend_latency


		/*
		drop table dba.dbo.Latency
		drop table dba.dbo.ExistingL
		*/

