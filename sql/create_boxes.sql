.echo off
.mode csv
.output data/boxes.csv

SELECT * 
FROM v_record_cases;

.output
.mode column
.echo on
