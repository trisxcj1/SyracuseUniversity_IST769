use fudgemart_v3;
go

/* Question 1*/
select
	product_id,
	product_name,
	product_department,
	right(product_name, charindex(' ', reverse(product_name), 0)) as product_category
from dbo.fudgemart_products;
go

/* Question 2 */
drop function if exists dbo.f_total_vendor_sales;
go

create function f_total_vendor_sales(
	@vendor_id int
)
returns decimal(10, 2) as
begin
	declare @returnvalue as decimal(10, 2)

	select @returnvalue = sum(product_wholesale_price)
	from dbo.fudgemart_products
	where product_vendor_id = @vendor_id
	group by product_vendor_id

	return @returnvalue
end;
go

select
	distinct product_vendor_id,
	dbo.f_total_vendor_sales(product_vendor_id) as total_vendor_sales
from dbo.fudgemart_products;
go

select * from dbo.fudgemart_products

select dbo.f_total_vendor_sales(1) as total_vendor_sales

/* Question 3 */
drop procedure if exists dbo.p_write_vendor;
go

create procedure p_write_vendor(
	@vendor_name varchar(100),
	@phone_number varchar(30),
	@website varchar(50) = NULL
)
as
begin
	if exists(
		select vendor_name from dbo.fudgemart_vendors
		where vendor_name = @vendor_name		
	)
		begin
			update dbo.fudgemart_vendors
			set
				vendor_phone = @phone_number,
				vendor_website = @website
			where vendor_name = @vendor_name
		end
	else
		begin
		insert into dbo.fudgemart_vendors
		values (@vendor_name, @phone_number, @website)
		end
end;
go

select * from fudgemart_vendors;
go

exec dbo.p_write_vendor 'Soney', '555-2940'
select * from fudgemart_vendors where vendor_name = 'Soney';
go

exec dbo.p_write_vendor 'Tristn J', '444-4567', 'mywebsite.my'
select * from fudgemart_vendors where vendor_name = 'Tristn J';
go

exec dbo.p_write_vendor 'Tristn J', '123-4567', 'mywebsite.my'
select * from fudgemart_vendors where vendor_name = 'Tristn J';
go

/* Question 4 */
drop view if exists dbo.v_fudgemart_products;
go

create view dbo.v_fudgemart_products as	
	select
		product_id,
		product_name,
		product_department,
		right(product_name, charindex(' ', reverse(product_name), 0)) as product_category
	from dbo.fudgemart_products;
go

select * from dbo.v_fudgemart_products;
go

/* Question 5 */
drop function if exists dbo.f_employee_timesheets;
go

create function f_employee_timesheets(
	@employee_id as int
)
returns table as 
return
	select
		employee_id,
		concat(employee_firstname, ' ', employee_lastname) as employeename,
		employee_department,
		employee_hiredate,
		employee_hourlywage
	from dbo.fudgemart_employees
	where employee_id = @employee_id;
go

select * from dbo.f_employee_timesheets(1)
