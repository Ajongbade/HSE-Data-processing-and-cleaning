--Delete unwanted columns

select * from hse_data

ALTER TABLE hse_data drop column con_end, "Construction End Use", "Building Stories", build_stor, "Project Cost", proj_cost, proj_type,hazsub, fat_cause, fall_ht, "Project Type"
select * from hse_data



--check for  duplicate rows using cte

WITH cte AS (SELECT *, ROW_NUMBER() OVER ( PARTITION BY "Event Date", "Abstract Text", "Event Description" 
ORDER BY "Event Date", "Abstract Text", "Event Description") row_num FROM hse_data)

select * from cte 
where row_num > 1



--delete duplicate rows
WITH cte AS (SELECT *, ROW_NUMBER() OVER ( PARTITION BY "Event Date", "Abstract Text", "Event Description" 
ORDER BY "Event Date", "Abstract Text", "Event Description") row_num FROM hse_data)

delete from cte 
where row_num > 1


--Check for continuing  rows

select  count(summary_nr) from hse_data
select count (distinct summary_nr) from hse_data

--delete continuing rows

WITH new_cte AS (SELECT summary_nr, ROW_NUMBER() OVER ( PARTITION BY summary_nr 
ORDER BY summary_nr) row_num FROM hse_data)

delete from new_cte 
where row_num > 1

--check dataypes
select * from INFORMATION_SCHEMA.columns

-- Convert date Event date to DD/MM/YY

alter table hse_data
add Event_Date varchar(255);

update hse_data
set "Event Date"= convert (varchar(10), Event_Date, 105) 

alter table hse_data
drop column Event_date


-- Get time of incident 

-- clean field containing time of incident

select * from hse_data


-- * truncate data using string function
select
substring ("Abstract Text",1, charindex('.', "Abstract Text")+1) 
 from hse_data 

 update  hse_data 

 set "Abstract Text" = substring ("Abstract Text",1, charindex('.', "Abstract Text")+1)
 from hse_data  

 select * from hse_data


 --- create loop function to further clean field containing time data 


CREATE FUNCTION HseFunction

 (@str VARCHAR(8000), @ValidCharacters VARCHAR(8000))
RETURNS VARCHAR(8000) 

AS
BEGIN


  WHILE PATINDEX('%[^' + @ValidCharacters + ']%',@str) > 0
   SET @str=REPLACE(@str, SUBSTRING(@str ,PATINDEX('%[^' + @ValidCharacters +
']%',@str), 1) ,'')
  RETURN @str
END


-- initiate function 

select dbo.HseFunction ("Abstract Text", '012 3456789a:pm') from hse_data



-- update field by removing irrelevant characters 
update hse_data 
set "Abstract Text" = dbo.HseFunction ("Abstract Text", '012 3456789a:pm')

select * from hse_data


-- set null value for fields without time data

update hse_data 

set "Abstract Text" = NULL where "Abstract Text" not like '[a.m-p.m-am-pm]%' 

-- truncate data to select only time value 

select right ("Abstract Text",8) from hse_data

-- update table

update hse_data 

set "Abstract Text" = right ("Abstract Text",8) from hse_data

select * from hse_data

-- further cleaning 

select * from hse_data where "Abstract Text"  not like '%[am-pm]' 

update hse_data 

set "Abstract Text" = NULL where "Abstract Text" not like '%[am-pm]' 



--trim field 

update hse_data 

set "Abstract Text" = ltrim("Abstract Text")  



-- convert abstract_text datatype to time

update hse_data 

set  "Abstract Text" = try_convert(time, "Abstract Text", 105) 

select * from hse_data



--combine date and time data

--create new column

alter table hse_data 
add "Accident time" nvarchar (255)

--update table with time and date field

update hse_data

set  "Accident time" = ("Event Date" + "Abstract text")

-- clean data

update hse_data 

set "Accident time" = left ("Accident time",19) 


--convert data type to datetime
update hse_data 

set   "Accident time" = try_convert(datetime, "Accident time", 105) from hse_data

select * from hse_data


ALTER TABLE hse_data drop column "Abstract Text", "Event Date"






