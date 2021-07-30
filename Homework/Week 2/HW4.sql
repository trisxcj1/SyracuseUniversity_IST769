use demo;
go

select * from demo.dbo.timesheets;
go

/* Question 1 */
-- initial query
select
	employee_id,
	employee_firstname,
	employee_lastname,
	sum(timesheet_hourlyrate * timesheet_hours)
from timesheets
group by employee_id, employee_firstname, employee_lastname;
go

-- Creating a non-clustered index
drop index if exists dbo.timesheets_q1_nonclustered_index;
go

create index timesheets_q1_nonclustered_index
	on demo.dbo.timesheets (employee_id)
	include (employee_firstname, employee_lastname);
go

-- query after cluster
select
	employee_id,
	employee_firstname,
	employee_lastname,
	sum(timesheet_hourlyrate * timesheet_hours)
from timesheets
group by employee_id, employee_firstname, employee_lastname;
go

/* Question 2 */
select employee_id, employee_firstname, employee_lastname
from timesheets
where employee_id = 1;
go

/* Question 3 */
-- pre columnstore
select
	employee_department,
	sum(timesheet_hours)
from timesheets 
group by employee_department;
go

select employee_jobtitle, avg(timesheet_hourlyrate)
from timesheets
group by employee_jobtitle;
go

-- creating columnstore
create clustered columnstore index timesheets_IX2
	on demo.dbo.timesheets
	with (drop_existing = on);
go

-- post columnstore
select
	employee_department,
	sum(timesheet_hours)
from timesheets 
group by employee_department;
go

select employee_jobtitle, avg(timesheet_hourlyrate)
from timesheets
group by employee_jobtitle;
go

/* Question 4 */
drop view if exists dbo.v_employees;
go

create view dbo.v_employees
with schemabinding
as
	select
		employee_id,
		employee_firstname,
		employee_lastname,
		employee_jobtitle,
		employee_department,
		count_big(*) as timesheet_count
	from [dbo].timesheets
	group by employee_id, employee_firstname, employee_lastname, employee_jobtitle, employee_department;
go

create unique clustered index v_employees_clustered_index
	on v_employees (employee_id, employee_firstname, employee_lastname, employee_jobtitle, employee_department);
go

select * from v_employees;
go

/* Question 5 */
select 
	employee_id,
	employee_firstname,
	employee_lastname,
	count(employee_id) as count_of_timesheets,
	sum(timesheet_hours) as total_hours_worked,
	avg(timesheet_hourlyrate) as average_timesheet_hourly_rate
from dbo.timesheets
group by employee_id, employee_firstname, employee_lastname
for json auto;
go
