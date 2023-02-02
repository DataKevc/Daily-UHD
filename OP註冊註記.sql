SET @today := DATE_FORMAT(CURDATE(),"%Y%m%d");
SET @yesterday := DATE_FORMAT(DATE_SUB(CURDATE(),INTERVAL 1 DAY),"%Y%m%d");

SET @return_day := 0; -- 0=當日，1=回溯1日
SET @today := DATE_FORMAT(DATE_SUB(@today,INTERVAL @return_day DAY),"%Y%m%d");
SET @yesterday := DATE_FORMAT(DATE_SUB(@yesterday,INTERVAL @return_day DAY),"%Y%m%d");
-- SELECT @today,@yesterday;

-- D_OP註冊註記
SELECT
	DATE_FORMAT( FROM_UNIXTIME( tb_user.create_time ), '%Y-%m-%d' ) AS "date",
	tb_user.id,
	tb_user.gid_bar_code,
	DATE_FORMAT( FROM_UNIXTIME( tb_user.update_time ), '%Y-%m-%d' ) AS "update_date",
IF
	( tb_user.create_time < 1625544000, "舊會員首次登入", "全新會員註冊" ) AS "新/舊",
	FROM_UNIXTIME(o.pay_finish_time) AS "首購時間"
FROM
	tb_user left join (select user_id, pay_finish_time from tb_order where pay_finish_time<>0 group by user_id order by pay_finish_time)o
	on tb_user.id=o.user_id 
WHERE
	tb_user.gid_bar_code != "" AND FROM_UNIXTIME( tb_user.create_time, "%Y%m%d" ) < @today;
	