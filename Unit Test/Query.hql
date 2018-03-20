create schema ${hiveconf:DB_NAME};
show schemas;
use ${hiveconf:DB_NAME};
CREATE TABLE ${hiveconf:DB_NAME}.${hiveconf:TABLE_NAME} (crash_id int,crash_date	string,crash_time string,severity string,crash_type string,cyclists int,cyclist_casualties int,reported_location string,latitude double,longitude double,location_1 string) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';
show tables;
LOAD DATA LOCAL INPATH './Cyclist_Crashes.csv' OVERWRITE INTO TABLE ${hiveconf:DB_NAME}.${hiveconf:TABLE_NAME};
select * from ${hiveconf:DB_NAME}.${hiveconf:TABLE_NAME};
CREATE VIEW VIEW_Crash as SELECT crash_id,severity from ${hiveconf:DB_NAME}.${hiveconf:TABLE_NAME};
