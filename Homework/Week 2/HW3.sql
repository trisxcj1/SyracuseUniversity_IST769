use demo;
go

/* Question 1 */
-- dropping tables
alter table dbo.players set (system_versioning=off);
go

drop table if exists dbo.shots;
go

drop table if exists dbo.players;
go

-- creating tables
create table players(
	player_id int identity,
	player_name varchar(30) not null,
	shots_attempted int not null,
	shots_made int not null,
	constraint PK_players primary key (player_id)
);

create table shots(
	shot_id int identity,
	player_id int not null,
	clock_time datetime not null default GetDate(),
	shot_made bit,
	constraint FK1_shots foreign key (player_id) references players(player_id)
)

-- inserting into tables
insert into dbo.players(player_name, shots_attempted, shots_made)
values
	('Mary', 0, 0),
	('Sue', 0, 0);
go
select * from dbo.players;
go

/* Question 2 */
-- dropping the stored procedure to update shots 
drop procedure if exists dbo.p_write_shot;
go

-- creating the stored procedure to update shots
create procedure p_write_shot(
	@player_id int,
	@clock_time datetime,
	@shot_made bit
) as
begin try
	begin transaction
		insert into dbo.shots(player_id, clock_time, shot_made)
		values
			(@player_id, @clock_time, @shot_made)
		if @@ROWCOUNT <> 1 throw 500001, 'expected 1 row to be effected', 0

		update dbo.players set
			shots_attempted = shots_attempted + 1,
			shots_made = shots_made + cast(@shot_made as int)
		where player_id = @player_id
		if @@ROWCOUNT <> 1 throw 500001, 'expected 1 row to be effected', 0

		print 'Committing'
		commit
end try
begin catch
	select 
		ERROR_NUMBER() as error,
		ERROR_MESSAGE() as message
	print 'Rolling back'
	rollback 
end catch;
go

exec dbo.p_write_shot @player_id=1, @clock_time='07/22/2021 11:26', @shot_made=0;
go
exec dbo.p_write_shot @player_id=2, @clock_time='07/22/2021 11:28', @shot_made=0;
go
exec dbo.p_write_shot @player_id=1, @clock_time='07/22/2021 11:29', @shot_made=1;
go
select * from dbo.players
select * from dbo.shots

/* Question 3 */
-- altering the table such that it is a system versioning table
alter table dbo.players
add
	valid_from datetime2 (2) generated always as row start hidden constraint df_valid_from default dateadd(second, -1, sysutcdatetime()),
	valid_to datetime2 (2) generated always as row end hidden constraint df_valid_to default '9999.12.31 23:59:59.99',
	period for system_time (valid_from, valid_to);
go

alter table dbo.players set (system_versioning=on (history_table = dbo.players_history));
go
select * from dbo.players
select * from dbo.players_history

/* Question 4 */
-- adding more shots
exec dbo.p_write_shot @player_id=1, @clock_time='07/22/2021 12:15', @shot_made=1;
go
exec dbo.p_write_shot @player_id=1, @clock_time='07/22/2021 12:15', @shot_made=1;
go
exec dbo.p_write_shot @player_id=2, @clock_time='07/22/2021 12:15', @shot_made=0;
go
exec dbo.p_write_shot @player_id=1, @clock_time='07/22/2021 12:15', @shot_made=1;
go
exec dbo.p_write_shot @player_id=1, @clock_time='07/22/2021 12:15', @shot_made=1;
go
exec dbo.p_write_shot @player_id=2, @clock_time='07/22/2021 12:16', @shot_made=0;
go
exec dbo.p_write_shot @player_id=2, @clock_time='07/22/2021 12:16', @shot_made=1;
go
exec dbo.p_write_shot @player_id=1, @clock_time='07/22/2021 12:16', @shot_made=0;
go
exec dbo.p_write_shot @player_id=2, @clock_time='07/22/2021 12:16', @shot_made=1;
go
exec dbo.p_write_shot @player_id=1, @clock_time='07/22/2021 12:16', @shot_made=0;
go
exec dbo.p_write_shot @player_id=2, @clock_time='07/22/2021 12:16', @shot_made=0;
go
exec dbo.p_write_shot @player_id=2, @clock_time='07/22/2021 12:17', @shot_made=1;
go
exec dbo.p_write_shot @player_id=2, @clock_time='07/22/2021 12:18', @shot_made=1;
go
exec dbo.p_write_shot @player_id=1, @clock_time='07/22/2021 12:18', @shot_made=0;
go
exec dbo.p_write_shot @player_id=1, @clock_time='07/22/2021 12:20', @shot_made=1;
go

select * from dbo.players
select * from dbo.shots
select * from dbo.players_history

/* Question 5 */
-- current player statistics
select * from dbo.players
-- player statistics at exactly 2.5mins into the 5mins window
select * from dbo.players for system_time as of '2021-07-22 16:17:30'
-- player statistics within the last min of the 5mins window
select * from dbo.players for system_time between '2021-07-22 16:19:00' and '2021-07-22 16:20:00' 
