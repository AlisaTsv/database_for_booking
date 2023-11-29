USE booking_db;

-- Часть 1. Наиболее популярные запросы
-- Все пользователи, которые писали отелю или бронировали номер у отеля, сгруппированные по странам
-- Выбираем страну, смотрим, какие там отели самые востребованные: по числу бронирований и сообщений
-- Выбираем страну, смотрим, какие отели предоставляют там номера для молодоженов
-- Находим страны, в которых средняя цена за номер самая низкая 
-- Отели в определенной стране, топ по рейтингу и звездам

-- 1.1
-- Все пользователи, которые писали отелю или бронировали номер у отеля, сгруппированные по странам
-- Выберем номер отеля = 72

SELECT country, COUNT(country) FROM guests 
WHERE id IN
	(SELECT guest_id FROM bookings WHERE hotel_id = 72)
OR profile_id IN
	(SELECT from_profile_id FROM messages 
	WHERE to_profile_id = 
		(SELECT profile_id FROM hotels WHERE id = 72))
GROUP BY country
ORDER BY country DESC;

-- 1.2
-- Выбираем страну, смотрим, какие там отели самые востребованные: по числу бронирований и сообщений
-- Выберем Турцию, там всего 2 отеля

SELECT hotel_name, COUNT(hotel_name) FROM 
(
	(SELECT hotel_name FROM hotels h
	JOIN messages m 
	ON h.profile_id = m.to_profile_id
	WHERE to_profile_id IN 
		(SELECT profile_id from hotels
		WHERE address_id IN 
			(SELECT id FROM address_book
			WHERE country = "Turkey")))
UNION ALL
	(SELECT hotel_name FROM hotels h
	JOIN bookings b
	ON h.id = b.hotel_id 
	WHERE hotel_id IN
		(SELECT id from hotels
		WHERE address_id IN 
			(SELECT id FROM address_book
			WHERE country = "Turkey")))
) AS hotels_mentioned
GROUP BY hotel_name
ORDER BY hotel_name DESC;

-- 1.3
-- Выбираем страну, смотрим, какие отели предоставляют там номера для молодоженов

-- Cначала посмотрим, в каких странах номера для молодоженов есть
SELECT country
FROM address_book 
WHERE id
	IN 
	(SELECT address_id 
    FROM hotels 
    WHERE id 
		IN 
		(SELECT hotel_id 
        FROM rooms 
		WHERE room_type_id 
        IN
		(SELECT id 
        FROM room_types 
		WHERE room_type 
        LIKE 'honeymoon%')));

-- Снова выберем Турцию

SELECT * 
FROM hotels 
WHERE id 
	IN
	(SELECT hotel_id 
    FROM rooms 
	WHERE room_type_id 
		IN 
			(SELECT id 
			FROM room_types 
			WHERE room_type 
			LIKE 'honeymoon%')
	AND hotel_id 
		IN 
			(SELECT id 
            FROM hotels 
			WHERE address_id 
				IN 
					(SELECT id 
                    FROM address_book
					WHERE country = 'Turkey')
			)
	);
    
 -- 1.4   
 -- Находим страны, в которых средняя цена за номер самая низкая 
 
 SELECT country, AVG (base_price) 
 AS average_price FROM rooms r
 INNER JOIN hotels h 
 ON r.hotel_id = h.id
 INNER JOIN prices p 
 ON r.price_id = p.id
 INNER JOIN address_book a 
 ON h.address_id = a.id
 GROUP BY country
 ORDER BY average_price; 
 
 -- 1.5
 -- Отели в определенной стране, топ по рейтингу и звездам
 -- Выбираем Кипр
 
 SELECT hotel_name, stars_status, rating 
 FROM hotels h
 INNER JOIN ratings r 
 ON h.rating_id = r.id
 INNER JOIN address_book a 
 ON h.address_id = a.id
 WHERE a.country = 'Cyprus'
 ORDER BY rating DESC;
 
 SELECT hotel_name, stars_status, rating 
 FROM hotels h
 INNER JOIN ratings r 
 ON h.rating_id = r.id
 INNER JOIN address_book a 
 ON h.address_id = a.id
 WHERE a.country = 'Cyprus'
 ORDER BY stars_status DESC;

-- Часть 2. Представления
-- Определенная страна: все отели (включая адреса)
-- Сеть отелей: номера (вся информация), цены 

-- 2.1 
-- Представление: информация об отелях в определенной стране, включая основную информацию, адресc и рейтинг. 
-- Выберем Испанию
 
DROP VIEW IF EXISTS Spain_hotels;
CREATE VIEW Spain_hotels
	AS 
		SELECT hotel_name, foundation_date, stars_status, rating, country, city, phone, str_or_distr, 
		building_number, apartment_number, post_code
		FROM hotels h
		INNER JOIN address_book a ON h.address_id = a.id
		INNER JOIN ratings r ON h.rating_id = r.id
		WHERE country = "Spain";
	
SELECT * FROM Spain_hotels;
    
-- 2.2 
-- Представление: информация о номерах в сети отелей. 

DROP VIEW IF EXISTS Mann_hotels;
CREATE VIEW Mann_hotels
	AS
		SELECT accom_type, room_type, hotel_name, 
		foundation_date, stars_status, rating, 
		country, city, phone, str_or_distr, 
		building_number, apartment_number, post_code
		FROM rooms rm
		INNER JOIN hotels h ON rm.hotel_id = h.id
		INNER JOIN address_book a ON h.address_id = a.id
		INNER JOIN ratings r ON h.rating_id = r.id
		INNER JOIN accom_types act ON rm.accom_type_id = act.id
		INNER JOIN room_types rmt ON rm.room_type_id = rmt.id
		WHERE hotel_name LIKE "Mann%";

SELECT * FROM Mann_hotels;

-- Часть 3. Процедуры и триггеры
-- Процедура: выбрать информацию об отелях определенной страны, название которой вводит пользователь
-- Триггер: сохраняет информацию об отеле перед удалением записи из таблицы отелей

-- 3.1. Процедура: выдается основная информация об отелях определенной страны, 
-- включая название отеля, город, район, дату основания и рейтинг, 
-- страна задается пользователем

DELIMITER $$ 
DROP PROCEDURE IF EXISTS select_country_hotels $$
CREATE PROCEDURE select_country_hotels(chosen_country VARCHAR (100))
BEGIN
	SELECT hotel_name, city, str_or_distr, 
		foundation_date, stars_status, 
		rating 
	FROM hotels h
	INNER JOIN ratings r 
	ON h.rating_id = r.id
	INNER JOIN address_book a 
	ON h.address_id = a.id
    WHERE a.country = chosen_country
	ORDER BY rating DESC;
END$$
DELIMITER ;

CALL select_country_hotels ('Cyprus'); 

-- 3.2 
-- Создадим триггер, записывающий данные об удаленных записях из таблицы отелей в таблицу hotels_history
-- Создадим дополнительную таблицу hotels_history, документирующую изменения в таблице отелей

DROP TABLE IF EXISTS hotels_history;
CREATE TABLE hotels_history (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки",
    hotel_id INT UNSIGNED NOT NULL COMMENT "ID отеля в таблице отелей",
    hotel_name VARCHAR(100) NOT NULL COMMENT "Название отеля",
    address_id INT UNSIGNED NOT NULL COMMENT "ID отеля в таблице адресов",
    foundation_date DATE COMMENT "Дата основания отеля",
	stars_status ENUM ('NO STARS OR UNKNOWN', 'ONE STAR', 'TWO STARS', 'THREE STARS', 'FOUR STARS', 'FIVE STARS') NOT NULL COMMENT "Информация о количестве звезд",
	rating_id INT UNSIGNED UNIQUE NOT NULL COMMENT "ID отеля в таблице пользовательских оценок",
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",
    operation VARCHAR (50) NOT NULL COMMENT "Операция со строкой"
    ) COMMENT "История обновления таблицы отелей";

DROP TRIGGER IF EXISTS before_hotels_delete;

DELIMITER $$
CREATE TRIGGER before_hotels_delete
BEFORE DELETE
ON hotels FOR EACH ROW
BEGIN
    INSERT INTO hotels_history(hotel_id, hotel_name, address_id, foundation_date, stars_status, rating_id, operation)
    VALUES (OLD.id, OLD.hotel_name, OLD.address_id, OLD.foundation_date, OLD.stars_status, OLD.rating_id, 'deleted');
END$$    
DELIMITER ;

-- Тестируем триггер. Создадим 2 дополнительные записи в таблице отелей и необходимые для этого профили, адреса, рейтинги

INSERT INTO `profiles` (`id`, `user_id`, `profile_type`, `profile_status`, `created_at`, `updated_at`) VALUES (270, 157, 'HOTEL', 'ACTIVE', '2014-12-04 16:20:43', '2023-10-16 08:24:58');
INSERT INTO `profiles` (`id`, `user_id`, `profile_type`, `profile_status`, `created_at`, `updated_at`) VALUES (271, 158, 'HOTEL', 'BLOCKED', '2020-08-09 23:38:26', '2023-10-20 16:01:55');

INSERT INTO `address_book` (`id`, `country`, `city`, `phone`, `str_or_distr`, `building_number`, `apartment_number`, `post_code`, `created_at`, `updated_at`) VALUES (270, 'Australia', 'Hyattburgh', '1-623-503-6748x422', 'Stoltenberg Valleys', '7', '', '31704', '2019-10-07 04:20:24', '2017-11-04 05:57:17');
INSERT INTO `address_book` (`id`, `country`, `city`, `phone`, `str_or_distr`, `building_number`, `apartment_number`, `post_code`, `created_at`, `updated_at`) VALUES (271, 'Uzbekistan', 'Parisshire', '+76(7)6644225780', 'Little Mountain', '9', '4', '96016', '2017-02-15 00:17:40', '2021-09-21 13:10:58');

INSERT INTO `ratings` (`id`, `rating`) VALUES (102, '3');
INSERT INTO `ratings` (`id`, `rating`) VALUES (105, '5');

INSERT INTO `hotels` (`id`, `profile_id`, `address_id`, `hotel_name`, `foundation_date`, `stars_status`, `rating_id`) VALUES (102, 270, 270, 'Fritsch Inc', '1977-09-22', 'NO STARS OR UNKNOWN', 102);
INSERT INTO `hotels` (`id`, `profile_id`, `address_id`, `hotel_name`, `foundation_date`, `stars_status`, `rating_id`) VALUES (105, 271, 271, 'Ferry and Sons', '1995-07-01', 'TWO STARS', 105);

-- Удаляем записи из таблицы отелей
DELETE FROM hotels where id = 102; 
DELETE FROM hotels where id = 105; 

-- Проверяем таблицу hotels_history
SELECT * FROM hotels_history;