SET @today := DATE_FORMAT(CURDATE(),"%Y%m%d");
SET @yesterday := DATE_FORMAT(DATE_SUB(CURDATE(),INTERVAL 1 DAY),"%Y%m%d");

SET @return_day := 0; -- 0=當日，1=回溯1日
SET @today := DATE_FORMAT(DATE_SUB(@today,INTERVAL @return_day DAY),"%Y%m%d");
SET @yesterday := DATE_FORMAT(DATE_SUB(@yesterday,INTERVAL @return_day DAY),"%Y%m%d");
-- SELECT @today,@yesterday;

-- D_用戶使用記錄表.sql	
select 
    `tb_user`.id, 
    REPLACE(REPLACE(trim(`tb_user`.nickname),char(10),''),char(13),'') AS nickname, 
    REPLACE(REPLACE(trim(`tb_user`.first_name),char(10),''),char(13),'') AS first_name, 
    REPLACE(REPLACE(trim(`tb_user`.last_name),char(10),''),char(13),'') AS last_name,
    REPLACE(REPLACE(trim(`tb_user`.phone),char(10),''),char(13),'') AS phone, 
    REPLACE(REPLACE(trim(`tb_user`.email),char(10),''),char(13),'') AS email, 
    `tb_user_position`.`user_agent`, 
    REPLACE(REPLACE(trim(`tb_user_position`.`position`),char(10),''),char(13),'') AS position, 
    `tb_user_position`.`version_code`,
    FROM_UNIXTIME(`tb_user_position`.create_time, "%Y-%m-%d %H:%i:%s") as "last used date",
    FROM_UNIXTIME(`tb_user`.create_time, "%Y-%m-%d %H:%i:%s") as "register date"
from `tb_user_position`
inner join  `tb_user`
on `tb_user`.`id` = `tb_user_position`.`user_id`
where 
FROM_UNIXTIME( `tb_user_position`.`create_time`, "%Y%m%d" ) BETWEEN @yesterday AND @yesterday;