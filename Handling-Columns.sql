--select * from ClinicalData

--Data Profiling

drop table if exists #1

--select * from ClinicalData

select * from INFORMATION_SCHEMA.columns where TABLE_NAME like 'ClinicalData'

select column_name,ordinal_position, data_type, character_maximum_length into #1
from INFORMATION_SCHEMA.columns where TABLE_NAME like 'ClinicalData'

select * from #1

alter table #1 add maximum nvarchar(max)
alter table #1 add minimum nvarchar(max)
alter table #1 add nulls int
alter table #1 add distinct_count int
alter table #1 add mean float
alter table #1 add median float
alter table #1 add mode nvarchar(max)
alter table #1 add SD float
alter table #1 add Zero_Values int


------------------------------------------------------


declare @i int = 1
declare @j int

set @j = (select max(ordinal_position) from #1)

declare @columnname nvarchar(max)
declare @datatype nvarchar(max)

declare @sql nvarchar(max)

declare @l int
declare @m int, @n int

while @i<=@j
begin

select @columnname = column_name ,@datatype = DATA_TYPE from #1 where ORDINAL_POSITION = @i

    -- Handle numeric columns

    IF @dataType IN ('int', 'float', 'real', 'decimal', 'numeric', 'money', 'smallint', 'tinyint')

	begin

		set @sql = 'update #1 set maximum = (select max(' + @columnname + ') from ClinicalData) where ordinal_position = ' + cast(@i as varchar(max))
		exec sp_executesql @sql

		set @sql = 'update #1 set minimum = (select min(' + @columnname + ')from ClinicalData) where ordinal_position = '+ cast(@i as varchar(max))
		exec sp_executesql @sql

		set @sql = 'update #1 set mean = (select avg(cast(' + @columnname + ' as bigint)) from ClinicalData) where ordinal_position = '+ cast(@i as varchar(max))
		exec sp_executesql @sql

		set @sql = 'update #1 set SD = (select STDEV(' + @columnname + ')from ClinicalData) where ordinal_position = '+ cast(@i as varchar(max))
		exec sp_executesql @sql

		set @sql = 'update #1 set ZERO_VALUES = (select COUNT(*) from ClinicalData WHERE ' + @columnname  + ' = 0) 
		where ordinal_position = '+ cast(@i as varchar(max))
		exec sp_executesql @sql

		set @sql = 'update #1 set nulls = (select COUNT(*) from ClinicalData WHERE ' + @columnname  + ' is null) 
		where ordinal_position = '+ cast(@i as varchar(max))
		exec sp_executesql @sql

		set @sql = 'update #1 set distinct_count = ( select count(distinct ' + @columnname + ') from ClinicalData) where ordinal_position = '
		+ cast(@i as varchar(max))
		exec sp_executesql @sql

		set @sql = 'update #1 set mode = (select string_agg( ' + @columnname + ' , '','') from
		(select ' + @columnname + ' ,dense_rank() over(order by [count All] desc) [DR] from
		(select ' + @columnname + ' ,count(*) [Count All] from ClinicalData
		group by ' + @columnname + ') x) y where DR = 1) where ordinal_position = ' + cast(@i as varchar(max))
		exec sp_executesql @sql

		set @sql = '

		--select * from ClinicalData

		select ' + @columnname + ',row_number() over(order by ' + @columnname + ') [rn] into #2 from ClinicalData

		--select * from #2

		--Even Records
		--8
		--8/2 = 4
		--4+1 = 5

		--Odd Records

		declare @l int
		declare @m int, @n int, @x float

		set @l = (select max(rn) from #2)
		set @m = @l%2 --remainder
		set @n = @l/2 --Integral Quotient

		if @m = 0 --Even Number of records
		begin
		set @x = (select avg(' + @columnname + ') from #2 where rn in (@n,@n+1))
		end

		if @m <> 0 --Odd Number of Records
		begin
		set @x = (select ' + @columnname + ' from #2 where rn = @n+1)
		end

		update #1 set median = @x where ordinal_position = ' + cast(@i as varchar(max))
		exec sp_executesql @sql

	end


	-- Handle date columns

    IF @dataType IN ('date', 'datetime', 'datetime2', 'smalldatetime', 'time')

	begin

		set @sql = 'update #1 set maximum = (select max(' + @columnname + ') from ClinicalData) where ordinal_position = ' + cast(@i as varchar(max))
		exec sp_executesql @sql

		set @sql = 'update #1 set minimum = (select min(' + @columnname + ')from ClinicalData) where ordinal_position = '+ cast(@i as varchar(max))
		exec sp_executesql @sql

		set @sql = 'update #1 set ZERO_VALUES = (select COUNT(*) from ClinicalData WHERE ' + @columnname  + ' = ''1900-01-01'') 
		where ordinal_position = '+ cast(@i as varchar(max))
		exec sp_executesql @sql

		set @sql = 'update #1 set nulls = (select COUNT(*) from ClinicalData WHERE ' + @columnname  + ' is null) 
		where ordinal_position = '+ cast(@i as varchar(max))
		exec sp_executesql @sql

		set @sql = 'update #1 set distinct_count = ( select count(distinct ' + @columnname + ') from ClinicalData) where ordinal_position = '
		+ cast(@i as varchar(max))
		exec sp_executesql @sql

		set @sql = 'update #1 set mode = (select string_agg( ' + @columnname + ' , '','') from
		(select ' + @columnname + ' ,dense_rank() over(order by [count All] desc) [DR] from
		(select ' + @columnname + ' ,count(*) [Count All] from ClinicalData
		group by ' + @columnname + ') x) y where DR = 1) where ordinal_position = ' + cast(@i as varchar(max))
		exec sp_executesql @sql

	end

	-- Handle non-numeric columns for max and min

    IF @dataType IN ('varchar', 'nvarchar', 'text', 'char', 'nchar')

	begin

		set @sql = 'update #1 set maximum = (select max(' + @columnname + ') from ClinicalData) where ordinal_position = ' + cast(@i as varchar(max))
		exec sp_executesql @sql

		set @sql = 'update #1 set minimum = (select min(' + @columnname + ')from ClinicalData) where ordinal_position = '+ cast(@i as varchar(max))
		exec sp_executesql @sql

		set @sql = 'update #1 set ZERO_VALUES = (select COUNT(*) from ClinicalData WHERE ' + @columnname  + ' = ''0'') 
		where ordinal_position = '+ cast(@i as varchar(max))
		exec sp_executesql @sql

		set @sql = 'update #1 set nulls = (select COUNT(*) from ClinicalData WHERE ' + @columnname  + ' is null) 
		where ordinal_position = '+ cast(@i as varchar(max))
		exec sp_executesql @sql

		set @sql = 'update #1 set distinct_count = ( select count(distinct ' + @columnname + ') from ClinicalData) where ordinal_position = '
		+ cast(@i as varchar(max))
		exec sp_executesql @sql

		set @sql = 'update #1 set mode = (select string_agg( ' + @columnname + ' , '','') from
		(select ' + @columnname + ' ,dense_rank() over(order by [count All] desc) [DR] from
		(select ' + @columnname + ' ,count(*) [Count All] from ClinicalData
		group by ' + @columnname + ') x) y where DR = 1) where ordinal_position = ' + cast(@i as varchar(max))
		exec sp_executesql @sql

	end


	-- Handle non-numeric columns for max and min

    IF @dataType IN ('bit')

	begin

		set @sql = 'update #1 set ZERO_VALUES = (select COUNT(*) from ClinicalData WHERE ' + @columnname  + ' = ''0'') 
		where ordinal_position = '+ cast(@i as varchar(max))
		exec sp_executesql @sql

		set @sql = 'update #1 set nulls = (select COUNT(*) from ClinicalData WHERE ' + @columnname  + ' is null) 
		where ordinal_position = '+ cast(@i as varchar(max))
		exec sp_executesql @sql

		set @sql = 'update #1 set distinct_count = ( select count(distinct ' + @columnname + ') from ClinicalData) where ordinal_position = '
		+ cast(@i as varchar(max))
		exec sp_executesql @sql

		set @sql = 'update #1 set mode = (select string_agg( ' + @columnname + ' , '','') from
		(select ' + @columnname + ' ,dense_rank() over(order by [count All] desc) [DR] from
		(select ' + @columnname + ' ,count(*) [Count All] from ClinicalData
		group by ' + @columnname + ') x) y where DR = 1) where ordinal_position = ' + cast(@i as varchar(max))
		exec sp_executesql @sql

	end


set @i = @i+1
end







