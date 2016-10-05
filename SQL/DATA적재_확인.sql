use km_db;
delete from LEASE_DATA;
alter table LEASE_DATA auto_increment=1;

show variables;

update LEASE_DATA
set A_13 = concat(left(A_13,2), "*")
where A_13 != "";

LOAD DATA LOCAL INFILE 'C:/merge_data__.csv' INTO TABLE km_db.LEASE_DATA CHARACTER SET UTF8 FIELDS TERMINATED BY ',';