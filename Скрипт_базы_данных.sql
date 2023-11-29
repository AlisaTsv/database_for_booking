DROP DATABASE IF EXISTS booking_db;
CREATE DATABASE booking_db; 
USE booking_db;

DROP TABLE IF EXISTS users;
CREATE TABLE users (
	id INT UNSIGNED AUTO_INCREMENT NOT NULL PRIMARY KEY COMMENT "Идентификатор строки", 
	email VARCHAR(100) UNIQUE NOT NULL COMMENT "Почта",
	phone VARCHAR(100) UNIQUE NOT NULL COMMENT "Телефон",
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Таблица пользователей";

DROP TABLE IF EXISTS profiles;
CREATE TABLE profiles (
	id INT UNSIGNED AUTO_INCREMENT NOT NULL PRIMARY KEY COMMENT "Идентификатор строки",
	user_id INT UNSIGNED NOT NULL COMMENT "Ссылка на пользователя - владельца профиля",
	profile_type ENUM ('GUEST', 'HOTEL') NOT NULL COMMENT "Тип профиля",
	profile_status ENUM('ACTIVE', 'INACTIVE', 'BLOCKED') NOT NULL COMMENT "Текущий статус профиля",
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Таблица профилей";

ALTER TABLE profiles ADD CONSTRAINT fk_profiles_user_id FOREIGN KEY (user_id) REFERENCES users(id); 

DROP TABLE IF EXISTS guests;
CREATE TABLE guests (
	id INT UNSIGNED AUTO_INCREMENT NOT NULL PRIMARY KEY COMMENT "Идентификатор строки",
	profile_id INT UNSIGNED UNIQUE NOT NULL COMMENT "Ссылка на запись в таблице профилей", 
	first_name VARCHAR(100) NOT NULL COMMENT "Имя путешественника",
	last_name VARCHAR(100) NOT NULL COMMENT "Фамилия путешественника",
	birth_date DATE NOT NULL COMMENT "Дата рождения",
	gender ENUM('NOT SPECIFIED', 'MALE', 'FEMALE', 'OTHER') NOT NULL COMMENT "Гендер", 
	country VARCHAR(100) NOT NULL COMMENT "Страна проживания", 
	discount_status ENUM('STANDARD', 'EXPERIENCED TOURIST', 'PROFESSIONAL TRAVELLER') NOT NULL COMMENT "Статус путешественника, дающий дополнительные скидки за лояльность",
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Таблица профилей путешественников";

ALTER TABLE guests ADD CONSTRAINT fk_guests_profile_id FOREIGN KEY (profile_id) REFERENCES profiles(id); 

DROP TABLE IF EXISTS hotels;
CREATE TABLE hotels (
	id INT UNSIGNED AUTO_INCREMENT NOT NULL PRIMARY KEY COMMENT "Идентификатор строки",
	profile_id INT UNSIGNED UNIQUE NOT NULL COMMENT "Ссылка на запись в таблице профилей",
	address_id INT UNSIGNED UNIQUE NOT NULL COMMENT "Ссылка на запись в таблице адресов",
	hotel_name VARCHAR(100) NOT NULL COMMENT "Название отеля",
	foundation_date DATE COMMENT "Дата основания отеля",
	stars_status ENUM ('NO STARS OR UNKNOWN', 'ONE STAR', 'TWO STARS', 'THREE STARS', 'FOUR STARS', 'FIVE STARS') NOT NULL COMMENT "Информация о количестве звезд",
	rating_id INT UNSIGNED UNIQUE NOT NULL COMMENT "Ссылка на таблицу пользовательских оценок",
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Таблица профилей отелей";

ALTER TABLE hotels ADD CONSTRAINT fk_hotels_profile_id FOREIGN KEY (profile_id) REFERENCES profiles(id); 

DROP TABLE IF EXISTS address_book;
CREATE TABLE address_book (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки",
	country VARCHAR(100) NOT NULL COMMENT "Страна", 
	city VARCHAR(100) NOT NULL COMMENT "Город",
	phone VARCHAR(100) NOT NULL COMMENT "Телефон",
	str_or_distr VARCHAR(100) NOT NULL COMMENT "Улица или район",
	building_number VARCHAR(50) NOT NULL COMMENT "Номер дома", 
	apartment_number VARCHAR(50) COMMENT "Номер квартиры", 
	post_code VARCHAR(100) NOT NULL COMMENT "Почтовый индекс",
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания записи",
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления записи"
) COMMENT "Таблица адресов отелей";

ALTER TABLE hotels ADD CONSTRAINT fk_hotels_address_id FOREIGN KEY (address_id) REFERENCES address_book(id); 

DROP TABLE IF EXISTS ratings;
CREATE TABLE ratings (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки", 
	rating DECIMAL (4, 2) COMMENT "Рейтинг отеля на основе отзывов"
) COMMENT "Таблица рейтингов отелей на основе отзывов";

ALTER TABLE hotels ADD CONSTRAINT fk_hotels_rating_id FOREIGN KEY (rating_id) REFERENCES ratings(id);

DROP TABLE IF EXISTS rooms;
CREATE TABLE rooms (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки",
	hotel_id INT UNSIGNED NOT NULL COMMENT "Ссылка на профайл отеля",
	accom_type_id INT UNSIGNED NOT NULL COMMENT "Ссылка на таблицу типов размещения", 
	room_type_id INT UNSIGNED NOT NULL COMMENT "Ссылка на таблицу типов номеров",
	price_id INT UNSIGNED UNIQUE NOT NULL COMMENT "Ссылка на запись в таблице цен", 
	to_arrive TIME NOT NULL COMMENT "Время дня, когда в номер можно заехать", 
	to_leave TIME NOT NULL COMMENT "Время дня, когда номер нужно покинуть", 
	usage_status ENUM('ACTIVE', 'INACTIVE') COMMENT "Текущий статус",
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания записи",
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления записи"
) COMMENT "Таблица номеров";

ALTER TABLE rooms ADD CONSTRAINT fk_rooms_hotel_id FOREIGN KEY (hotel_id) REFERENCES hotels(id);

DROP TABLE IF EXISTS accom_types;
CREATE TABLE accom_types (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки",
	accom_type VARCHAR(500) NOT NULL COMMENT "Тип размещения"
) COMMENT "Таблица типов размещения";

ALTER TABLE rooms ADD CONSTRAINT fk_rooms_accom_type_id FOREIGN KEY (accom_type_id) REFERENCES accom_types(id);

DROP TABLE IF EXISTS room_types;
CREATE TABLE room_types (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки",
	room_type VARCHAR(500) NOT NULL COMMENT "Тип номера"
) COMMENT "Таблица типов номера";

ALTER TABLE rooms ADD CONSTRAINT fk_rooms_room_type_id FOREIGN KEY (room_type_id) REFERENCES room_types(id);

DROP TABLE IF EXISTS meal_types;
CREATE TABLE meal_types (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки",
	meal_type VARCHAR(500) NOT NULL COMMENT "Тип питания"
) COMMENT "Таблица типов питания";

DROP TABLE IF EXISTS prices;
CREATE TABLE prices (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки",
	base_price DECIMAL(10, 2) NOT NULL COMMENT "Базовая цена",  
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Таблица цен"; 

ALTER TABLE rooms ADD CONSTRAINT fk_rooms_price_id FOREIGN KEY (price_id) REFERENCES prices(id);
 
DROP TABLE IF EXISTS messages;
CREATE TABLE messages (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки", 
	from_profile_id INT UNSIGNED NOT NULL COMMENT "Ссылка на отправителя сообщения",
	to_profile_id INT UNSIGNED NOT NULL COMMENT "Ссылка на получателя сообщения",
	message_body TEXT NOT NULL COMMENT "Текст сообщения",
	is_delivered BOOLEAN NOT NULL COMMENT "Признак доставки",
	was_edited BOOLEAN NOT NULL COMMENT "Признак правки сообщения",
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Таблица сообщений пользователей";

ALTER TABLE messages ADD CONSTRAINT fk_messages_from_profile_id FOREIGN KEY (from_profile_id) REFERENCES profiles(id);
ALTER TABLE messages ADD CONSTRAINT fk_messages_to_profile_id FOREIGN KEY (to_profile_id) REFERENCES profiles(id);

DROP TABLE IF EXISTS bookings;
CREATE TABLE bookings (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки", 
	guest_id INT UNSIGNED NOT NULL COMMENT "Ссылка на путешественника",
	hotel_id INT UNSIGNED NOT NULL COMMENT "Ссылка на отель",
	room_id INT UNSIGNED NOT NULL COMMENT "Ссылка на номер отеля",
	meal_type_id INT UNSIGNED NOT NULL COMMENT "Ccылка на тип питания", 
	arrival_date DATETIME NOT NULL COMMENT "Дата заезда", 
	departure_date DATETIME NOT NULL COMMENT "Дата отъезда",  
	is_confirmed BOOLEAN NOT NULL COMMENT "Признак подтверждения бронирования",
	was_cancelled BOOLEAN NOT NULL COMMENT "Признак отмены бронирования",
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания записи",
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления записи"
) COMMENT "Таблица бронирований";

ALTER TABLE bookings ADD CONSTRAINT fk_bookings_guest_id FOREIGN KEY (guest_id) REFERENCES guests(id);
ALTER TABLE bookings ADD CONSTRAINT fk_bookings_hotel_id FOREIGN KEY (hotel_id) REFERENCES hotels(id);
ALTER TABLE bookings ADD CONSTRAINT fk_bookings_room_id FOREIGN KEY (room_id) REFERENCES rooms(id);
ALTER TABLE bookings ADD CONSTRAINT fk_bookings_meal_type_id FOREIGN KEY (meal_type_id) REFERENCES meal_types(id);

DROP TABLE IF EXISTS payments;
CREATE TABLE payments (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки", 
	booking_id INT UNSIGNED NOT NULL COMMENT "Ссылка на бронирование",
	payment_amount DECIMAL(10, 2) NOT NULL COMMENT "Cумма платежа", 
	is_paid BOOLEAN NOT NULL COMMENT "Признак осуществления оплаты",
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время  строки",
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Таблица платежей";

ALTER TABLE payments ADD CONSTRAINT fk_payments_booking_id FOREIGN KEY (booking_id) REFERENCES bookings(id);

DROP TABLE IF EXISTS feedbacks;
CREATE TABLE feedbacks (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки", 
	booking_id INT UNSIGNED NOT NULL COMMENT "Ссылка на бронирование",
	feedback_body TEXT NOT NULL COMMENT "Текст отзыва",
	score ENUM ("0", "1", "2", "3", "4", "5") NOT NULL COMMENT "Оценка", 
	was_edited BOOLEAN NOT NULL COMMENT "Признак правки отзыва",
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки",
	updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT "Время обновления строки"
) COMMENT "Таблица отзывов";

ALTER TABLE feedbacks ADD CONSTRAINT fk_feedbacks_booking_id FOREIGN KEY (booking_id) REFERENCES bookings(id);

DROP TABLE IF EXISTS media;
CREATE TABLE media (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки",
	profile_id INT UNSIGNED NOT NULL COMMENT "Ссылка на запись в таблице профилей",
	media_type_id INT UNSIGNED NOT NULL COMMENT "Ссылка на таблицу типов медиафайлов",
	link VARCHAR(1000) NOT NULL COMMENT "Ссылка на медиафайл",
	created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT "Время создания строки"
	) COMMENT "Медиафайлы";

ALTER TABLE media ADD CONSTRAINT fk_media_profile_id FOREIGN KEY (profile_id) REFERENCES profiles(id);

DROP TABLE IF EXISTS media_types;
CREATE TABLE media_types (
	id INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY COMMENT "Идентификатор строки",
	media_type VARCHAR(100) NOT NULL COMMENT "Тип медиафайла"
) COMMENT "Типы медиафайлов";

ALTER TABLE media ADD CONSTRAINT fk_media_media_type_id FOREIGN KEY (media_type_id) REFERENCES media_types(id);

CREATE INDEX ix_guests_country ON guests(country); 
CREATE INDEX ix_address_book_country ON address_book(country); 
CREATE INDEX ix_address_book_city ON address_book(city);
