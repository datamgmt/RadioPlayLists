.echo off
.mode csv
.output data/boxes.csv

SELECT * 
FROM v_record_cases;

.output

.output data/box_counts.csv

select  collection_folder, 
        count(*) record_count 
from    collection 
group by collection_folder;

.output

.mode column
.echo on
