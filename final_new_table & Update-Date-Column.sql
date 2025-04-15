

select * into new_table
from ClinicalData

select top 5 * from new_table

select max(year(admissiondate)) from new_table
select min(year(admissiondate)) from new_table


update new_table 
set admissiondate = 
    case 
        when year(admissiondate) > 2030 
        then 
            DATEADD(
                day,
                (abs(checksum(newid()))) % (datediff(day, '2024-01-01', '2030-12-31') + 1),
                '2024-01-01'
            )
        else admissiondate
    end
