SET @today := DATE_FORMAT(CURDATE(),"%Y%m%d");
SET @yesterday := DATE_FORMAT(DATE_SUB(CURDATE(),INTERVAL 1 DAY),"%Y%m%d");

SET @return_day := 0; -- 0=當日，1=回溯1日
SET @today := DATE_FORMAT(DATE_SUB(@today,INTERVAL @return_day DAY),"%Y%m%d");
SET @yesterday := DATE_FORMAT(DATE_SUB(@yesterday,INTERVAL @return_day DAY),"%Y%m%d");
-- SELECT @today,@yesterday;

-- D_店家導出_全
SELECT
 s.id,
 replace(s.`name`,'\t','') AS '餐廳名稱',
 DATE_FORMAT( FROM_UNIXTIME( s.create_time ), '%Y-%m' ) AS "Year-Month",
IF
 ( s.`status` = 1, '啟用', '禁用' ) AS `狀態`,
IF
 ( s.is_tester = 1, '是', '否' ) AS `內部測試餐廳`,
 s.disable_reason AS '未啟用原因',
 (select group_concat(name) from tb_store_type st left join tb_store_store_type sst on st.id = sst.store_type_id where sst.store_id = s.id and type = 1 group by sst.store_id, sst.type) as '主分類',
 (select group_concat(name) from tb_store_type st left join tb_store_store_type sst on st.id = sst.store_type_id where sst.store_id = s.id and type = 0 group by sst.store_id, sst.type) as '副分類',
 c.name AS '所在城市',
 a.area AS '所在地區',
 replace(replace(s.address,'\r\n',''),'\t','') AS '詳細地址',
 s.rest_day AS "公休日(0:Sun 1:Mon 2:Tue...)",
 replace(s.phone,'\n','') AS phone,
 s.corporation_fee AS "外帶%",
 s.fodomo_deliver_fee AS "外送%",
 s.eatin_corportaion_fee AS "內用%",
 s.email,
 unified_code AS '統一編號',
 order_cheque AS '發票抬頭',
 product_id AS '食品登錄字號',
IF
 ( s.has_delivery= 1, '是', '否' ) AS `是否開啟外送`,
IF
 ( s.has_take= 1, '是', '否' ) AS `是否開啟自取`,
 concat(sd.fodomo_delivery_time_first_start,' ~ ',sd.fodomo_delivery_time_first_end) AS '第一個外送時間段',
 concat(sd.fodomo_delivery_time_second_start,' ~ ',sd.fodomo_delivery_time_second_end) AS '第二個外送時間段',
 concat(sd.fodomo_delivery_week_time_first_start,' ~ ',sd.fodomo_delivery_week_time_first_end) AS '週末第一個外送時間段',
 concat(sd.fodomo_delivery_week_time_second_start,' ~ ',sd.fodomo_delivery_week_time_second_end) AS '週末第二個外送時間段',
 IF(s.store_delivery_enabled= 1, '是', '否' ) AS '店家自送',
 s.store_delivery_distance AS '自送範圍',
 IF(s.store_delivery_by_store= 1, '是', '否' ) AS '店家App是否可設置 店家自送選單',
 payee_name as '收款人戶名',
 payee_account as '收款人帳號(14碼)'
FROM
 tb_store AS s
  JOIN tb_store_area AS a ON s.store_area_id = a.id
  JOIN tb_store_city AS c ON a.city_id = c.id 
  LEFT JOIN tb_store_delivery sd ON sd.store_id = s.id
WHERE 
 s.apply_status = 1 ORDER BY id;