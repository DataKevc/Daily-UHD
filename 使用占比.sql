/*
(1)每日/週/月：訂單轉換率：用戶登入並有訂餐
`1-1` 可先以用戶使用記錄表的sql的手機，先做DISTINCT計算出 每日/週/月 登入總人數
`1-2` 再計算出訂單中，有訂單的手機號　每日/週/月　總人數
將 `1-2` 總人數　除以` 1-1` 　總人數 即可得到每日/週/月　訂單轉換率

(2) 每日/週/月：新用戶佔比
`2-1` 可先以用戶使用記錄表的sql的手機，先做DISTINCT計算出 每日/週/月 登入總人數
`2-2` 以OP註冊註記的sql，可計算出　每日/週/月　的新用戶總數
將 `2-2` 總人數　除以` 2-1` 　總人數 即可得到每日/週/月　新用戶佔比
*/
SET @return_day := 0; -- 0=當日，1=回溯1日

SET @today := DATE_FORMAT(CURDATE(),"%Y%m%d");
SET @today := DATE_FORMAT(DATE_SUB(@today,INTERVAL @return_day DAY),"%Y%m%d");
SET @yesterday        := DATE_FORMAT(DATE_SUB(@today,INTERVAL 1 DAY),"%Y%m%d");
SET @week_fisrt_date  := DATE_FORMAT(DATE_SUB(@today,INTERVAL WEEKDAY(@today) + 1 DAY),"%Y%m%d"); 
SET @month_fisrt_date := DATE_FORMAT(@today ,'%Y%m01');

-- D_用戶使用記錄表.sql	
SELECT @D_all_user := count(1)
FROM (
select DISTINCT phone
from `tb_user_position`
inner join  `tb_user`
on `tb_user`.`id` = `tb_user_position`.`user_id`
where 
FROM_UNIXTIME( `tb_user_position`.`create_time`, "%Y%m%d" ) BETWEEN @yesterday AND @yesterday
) a;
-- W_用戶使用記錄表.sql	
SELECT @W_all_user := count(1)
FROM (
select DISTINCT phone
from `tb_user_position`
inner join  `tb_user`
on `tb_user`.`id` = `tb_user_position`.`user_id`
where 
FROM_UNIXTIME( `tb_user_position`.`create_time`, "%Y%m%d" ) BETWEEN @week_fisrt_date AND @yesterday
) a;
-- M_用戶使用記錄表.sql	
SELECT @M_all_user := count(1)
FROM (
select DISTINCT phone
from `tb_user_position`
inner join  `tb_user`
on `tb_user`.`id` = `tb_user_position`.`user_id`
where 
FROM_UNIXTIME( `tb_user_position`.`create_time`, "%Y%m%d" ) BETWEEN @month_fisrt_date AND @yesterday
) a ;

-- D_下單使用記錄表.sql
SELECT @D_order_user := count(1)
FROM (
SELECT DISTINCT u.phone 
  FROM tb_order o ,tb_user u
 WHERE o.user_id = u.id
   AND o.order_status = 2
   AND FROM_UNIXTIME(o.create_time , "%Y%m%d" ) BETWEEN @yesterday AND @yesterday
) a;
-- W_下單使用記錄表.sql
SELECT @W_order_user := count(1)
FROM (
SELECT DISTINCT u.phone 
  FROM tb_order o ,tb_user u
 WHERE o.user_id = u.id
   AND o.order_status = 2
   AND FROM_UNIXTIME(o.create_time , "%Y%m%d" ) BETWEEN @week_fisrt_date AND @yesterday
) a;
-- M_下單使用記錄表.sql
SELECT @M_order_user := count(1)
FROM (
SELECT DISTINCT u.phone 
  FROM tb_order o ,tb_user u
 WHERE o.user_id = u.id
   AND o.order_status = 2
   AND FROM_UNIXTIME(o.create_time , "%Y%m%d" ) BETWEEN @month_fisrt_date AND @yesterday
) a;

-- D_新用用記錄表.sql	
SELECT @D_new_user := count(1)
FROM (
select DISTINCT phone
from `tb_user_position`
inner join  `tb_user`
on `tb_user`.`id` = `tb_user_position`.`user_id`
where 
FROM_UNIXTIME( `tb_user`.`update_time`, "%Y%m%d" ) BETWEEN @yesterday AND @yesterday
) a;
-- W_用戶使用記錄表.sql	
SELECT @W_new_user := count(1)
FROM (
select DISTINCT phone
from `tb_user_position`
inner join  `tb_user`
on `tb_user`.`id` = `tb_user_position`.`user_id`
where 
FROM_UNIXTIME( `tb_user`.`update_time`, "%Y%m%d" ) BETWEEN @week_fisrt_date AND @yesterday
) a;
-- M_用戶使用記錄表.sql	
SELECT @M_new_user := count(1)
FROM (
select DISTINCT phone
from `tb_user_position`
inner join  `tb_user`
on `tb_user`.`id` = `tb_user_position`.`user_id`
where 
FROM_UNIXTIME( `tb_user`.`update_time`, "%Y%m%d" ) BETWEEN @month_fisrt_date AND @yesterday
) a ;
/*
SELECT @D_all_user,   @W_all_user,   @M_all_user,
       @D_order_user, @W_order_user, @M_order_user,
       @D_new_user,   @W_new_user,   @M_new_user;
*/   
SELECT (@D_order_user/@D_all_user)*100 AS '訂單轉換率_日', (@W_order_user/@W_all_user)*100 AS '訂單轉換率_週', (@M_order_user/@M_all_user)*100 AS '訂單轉換率_月',
       (@D_new_user/@D_all_user)*100 AS '新用戶佔比_日',   (@W_new_user/@W_all_user)*100 AS '新用戶佔比_週'  , (@M_new_user/@M_all_user)*100 AS '新用戶佔比_月';