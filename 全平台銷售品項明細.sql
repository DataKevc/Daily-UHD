SET time_zone = '+8:00';
SET @today := DATE_FORMAT(CURDATE(),"%Y%m%d");
SET @yesterday := DATE_FORMAT(DATE_SUB(CURDATE(),INTERVAL 1 DAY),"%Y%m%d");

SET @return_day := 0; -- 0=當日，1=回溯1日
SET @today := DATE_FORMAT(DATE_SUB(@today,INTERVAL @return_day DAY),"%Y%m%d");
SET @yesterday := DATE_FORMAT(DATE_SUB(@yesterday,INTERVAL @return_day DAY),"%Y%m%d");

SELECT
	DATE_FORMAT( FROM_UNIXTIME( t.create_time ), '%Y-%m-%d %H:%i:%s' ) AS "date",
	t.id AS "orderID",
	t.order_number AS "訂單編號",
	s.id AS "storeID",
	s.`name` AS "店家名稱",
	st.id AS "店家分類編號",
	st.name AS "店家分類名稱",
	ft.`name` AS "餐點分類",
	f.`name` AS "餐點名稱",
	tb_set.`name` AS "套餐名稱",
	tb_set.`desc` AS "套餐說明",
	f.unit_price AS "單價",
	oi.total_price AS "總價",
	oi.quantity AS "數量",
CASE	
		WHEN t.order_status = 2 THEN
		'完成' 
		WHEN t.order_status = 3 THEN
		'拒絕' ELSE '其他' 
	END AS "訂單狀態",
CASE
		
		WHEN t.dining_type = 0 THEN
		'外帶' 
		WHEN t.dining_type = 1 THEN
		'外送' 
		WHEN t.dining_type = 2 THEN
		'內用' ELSE '商城' 
	END AS "用餐方式",
	CASE
		
		WHEN pay_type = 2 THEN
		'現金支付' 
		WHEN pay_type = 4 THEN
		'ApplePay' 
		WHEN pay_type = 5 THEN
		'LINE Pay' 
		WHEN pay_type = 6 THEN
		'台新支付' ELSE '其他'
	END AS "支付方式"
FROM
tb_order t 
JOIN tb_store s ON s.id = t.store_id
LEFT JOIN tb_store_store_type sst ON s.id = sst.store_id
LEFT JOIN tb_store_type st ON sst.store_type_id = st.id
JOIN tb_order_item oi ON oi.order_id = t.id
LEFT JOIN tb_food f ON f.id = oi.food_id
LEFT JOIN tb_set ON tb_set.id = oi.set_id
LEFT JOIN tb_food_type ft ON ft.id = f.food_type_id	
WHERE
s.`status` = 1
AND 
	FROM_UNIXTIME( t.pay_finish_time, "%Y%m%d" ) BETWEEN @yesterday AND @today
GROUP BY f.name, t.id
ORDER BY date