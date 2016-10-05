<<<<<<< HEAD
﻿create user 'Kmaster'@'124.254.170.215'  identified by 'kookmin1234'; 

drop user 'km_01'@'124.254.170.215'; 
drop user 'km_02'@'124.254.170.215'; 
drop user 'km_03'@'124.254.170.215'; 

drop user 'km_01'@'%';
drop user 'km_02'@'%';
drop user 'km_03'@'%';

drop user 'KMaster'@'%';

create user 'KMaster'@'%' identified by 'kookmin1234';
flush privileges;

use mysql; 
select * from user;
--# 사용자 생성
create user km_01; -- 재혁이형
create user km_01@'124.254.170.215' identified by 'km_011234';
create user 'km_01'@'%' identified by 'km_031234';
GRANT ALL ON *.* TO km_01@'%';
-- create user 'km_01'@'%' identified by 'km_031234';
flush privileges; 

create user km_02; -- 민욱이형
create user km_02@'124.254.170.215' identified by 'km_021234';
create user 'km_02'@'%' identified by 'km_031234';
GRANT ALL ON *.* TO km_02@`%`;
flush privileges; 

create user km_03; -- 미진이
create user km_03@'124.254.170.215' identified by 'km_031234';
create user 'km_03'@'%' identified by 'km_031234';
=======
use mysql;
grant all on km_db.* to 'KMaster'@'%' identified by 'kookmin1234';
flush privileges ;

--use km_db;
--# ����� ����
create user km_01; -- ��������
create user km_01@124.254.170.215 identified by 'km_011234';
--create user 'km_01'@'%' identified by 'km_031234';
GRANT ALL ON `%`.* TO km_01@`%`;
grant all privileges on km_db.* to km_01@124.254.170.215 identified by 'km_011234';
grant all privileges on km_db.* to 'km_01'@124.254.170.215 identified by 'km_011234' with grant option;

grant all privileges on *.* to 'KMaster'@'%' identified by 'kookmin1234' with grant option;
GRANT ALL PRIVILEGES ON *.* to km_01@host identified by 'km_011234';

create user km_02; -- �ο�����
create user km_02@124.254.170.215 identified by 'km_021234';
--create user 'km_02'@'%' identified by 'km_031234';
GRANT ALL ON `%`.* TO km_02@`%`;
grant all privileges on km_db.* to km_02@124.254.170.215 identified by 'km_021234';
grant all privileges on km_db.* to 'km_02'@124.254.170.215 identified by 'km_021234' with grant option;

create user km_03; -- ������
create user km_03@124.254.170.215 identified by 'km_031234';


--# 데이터베이스 생성
create database km_db default character set utf8; -- character set 지정(안하면 한글 깨짐)

--# 부여된 권한 확인
show grants for km_01@'124.254.170.215';
show grants for km_02@'124.254.170.215';
show grants for km_03@'124.254.170.215';

FLUSH PRIVILEGES;
create user 'km_01'@'211.55.61.235' identified by 'km_011234'; 
create user 'km_02'@'211.55.61.235' identified by 'km_021234'; 
create user 'km_03'@'211.55.61.235' identified by 'km_031234'; 