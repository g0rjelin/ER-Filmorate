DROP TABLE IF EXISTS user_friends;
DROP TABLE IF EXISTS film_userlikes;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS film_genre;
DROP TABLE IF EXISTS film;
DROP TABLE IF EXISTS genre;
DROP TABLE IF EXISTS rating;

CREATE TABLE rating(id serial NOT NULL,
                    name varchar NOT NULL,
                    CONSTRAINT rating_pkey PRIMARY KEY (id));

CREATE TABLE genre(id serial NOT NULL,
                   name varchar NOT NULL,
                   CONSTRAINT genre_pkey PRIMARY KEY (id));



CREATE TABLE film(id serial NOT NULL,
                  name varchar NOT NULL,
                  description varchar NOT NULL,
                  release_date date NOT NULL,
                  duration int4 NOT NULL,
                  rating_id int4 NOT NULL,
                  CONSTRAINT film_pkey PRIMARY KEY (id), 
                  CONSTRAINT film_rating_id_fkey FOREIGN KEY (rating_id) REFERENCES rating(id));

CREATE TABLE film_genre(id serial NOT NULL,
                        film_id int4 NOT NULL,
                        genre_id int4 NOT NULL,
                        CONSTRAINT film_genre_pkey PRIMARY KEY (id), 
                        CONSTRAINT film_genre_film_id_fkey FOREIGN KEY (film_id) REFERENCES film(id),
                        CONSTRAINT film_genre_genre_id_fkey FOREIGN KEY (genre_id) REFERENCES genre(id));

CREATE TABLE users(id bigserial NOT NULL,
                   email varchar NOT NULL,
                   login varchar NOT NULL,
                   name varchar NOT NULL,
                   birthday date NOT NULL,
                   CONSTRAINT users_pkey PRIMARY KEY (id));

CREATE TABLE film_userlikes(id bigserial NOT NULL,
                            film_id int4 NOT NULL,
                            user_id int8 NOT NULL,
                            CONSTRAINT film_userlikes_pkey PRIMARY KEY (id), 
                            CONSTRAINT film_userlikes_film_id_fkey FOREIGN KEY (film_id) REFERENCES film(id),
                            CONSTRAINT film_userlikes_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id));

CREATE TABLE user_friends(id bigserial NOT NULL,
                          user_id int8 NOT NULL,
                          user_friend_id int8 NOT NULL,
                          is_confirmed bool NOT NULL,
                          CONSTRAINT user_friends_pkey PRIMARY KEY (id), 
                          CONSTRAINT user_friends_user_id_fkey FOREIGN KEY (user_id) REFERENCES users(id),
                          CONSTRAINT user_friends_user_friend_id_fkey FOREIGN KEY (user_friend_id) REFERENCES users(id));


insert into rating(name)
values ('G'),('PG'),('PG-13'),('R'),('NC-17');
insert into rating(id,name)
values(0, 'Unrated');

insert into genre(name)
values ('комедия'),('драма'),('мультфильм'),('триллер'),('документальный'),('боевик');

insert into film (name
,description
,release_date
,duration
,rating_id) values 
('Film1', 'Film1 desc', '2000-01-01'::DATE, 180, (select id from rating where name = 'G') ),
('Film2', 'Film2 desc', '2001-01-01'::DATE, 200, (select id from rating where name = 'PG') ),
('Film3', 'Film3 desc', '2002-01-01'::DATE, 150, (select id from rating where name = 'PG-13') ),
('Film4', 'Film4 desc', '2003-01-01'::DATE, 120, (select id from rating where name = 'R') ),
('Film5', 'Film5 desc', '2004-01-01'::DATE, 120, (select id from rating where name = 'NC-17') );

insert into film_genre(film_id, genre_id) values 
( ( select id from film where name = 'Film1'), (select id from genre where name = 'комедия' ) ),
( ( select id from film where name = 'Film1'), (select id from genre where name = 'боевик' ) ),
( ( select id from film where name = 'Film2'), (select id from genre where name = 'мультфильм' ) ),
( ( select id from film where name = 'Film3'), (select id from genre where name = 'триллер' ) ),
( ( select id from film where name = 'Film4'), (select id from genre where name = 'документальный' ) ),
( ( select id from film where name = 'Film5'), (select id from genre where name = 'драма' ) ),
( ( select id from film where name = 'Film5'), (select id from genre where name = 'триллер' ) ),
( ( select id from film where name = 'Film5'), (select id from genre where name = 'боевик' ) );

insert into users(email, login, name, birthday) values
( 'user1@mail.com', 'user1', 'user1', '1980-01-01'::DATE),
( 'user2@mail.com', 'user2', 'user2', '1990-01-01'::DATE),
( 'user3@mail.com', 'user3', 'user3', '1995-01-01'::DATE),
( 'user4@mail.com', 'user4', 'user4', '2000-01-01'::DATE),
( 'user5@mail.com', 'user5', 'user5', '2010-01-01'::DATE),
( 'user6@mail.com', 'user6', 'user6', '2015-01-01'::DATE),
( 'user7@mail.com', 'user7', 'user7', '2020-01-01'::DATE);

insert into film_userlikes(film_id, user_id) 
select f.id, u.id from film f
join users u on u.login in ('user1','user2','user3') 
where f.name = 'Film1'
union all
select f.id, u.id from film f
join users u on u.login in ('user4') 
where f.name = 'Film2'
union all
select f.id, u.id from film f
join users u on u.login in ('user1','user2','user3','user4') 
where f.name = 'Film3'
union all
select f.id, u.id from film f
join users u on u.login in ('user1','user2','user6') 
where f.name = 'Film4';

insert into user_friends(user_id, user_friend_id, is_confirmed) values 
((select id from users where login = 'user1'), (select id from users where login = 'user2'), true),
((select id from users where login = 'user1'), (select id from users where login = 'user3'), true),
((select id from users where login = 'user1'), (select id from users where login = 'user4'), true),
((select id from users where login = 'user2'), (select id from users where login = 'user5'), true),
((select id from users where login = 'user4'), (select id from users where login = 'user2'), true),
((select id from users where login = 'user5'), (select id from users where login = 'user1'), true),
((select id from users where login = 'user7'), (select id from users where login = 'user1'), false),
((select id from users where login = 'user2'), (select id from users where login = 'user7'), false)
;

--Определение идентификаторов 3 наиболее популярных фильмов
SELECT film.id,
       film.name,
       film.description,
       film.release_date, 
       film.duration,
       rating.name AS rating_name,
       fl.cnt
FROM film
INNER JOIN
     (SELECT f.id,
             COUNT(fu.user_id) AS cnt
      FROM film f
      LEFT JOIN film_userlikes fu ON fu.film_id = f.id
      GROUP BY f.id
          LIMIT 3) fl ON fl.id = film.id
LEFT JOIN rating ON film.rating_id = rating.id
ORDER BY fl.cnt desc, film.id;

--Поиск фильмов по жанру (`DISTINCT` нужен, т.к. в поиске указано несколько жанров, а фильм может принадлежать нескольким жанрам)
SELECT DISTINCT f.id,
                f.name,
                f.description,
                f.duration,
                rating.name AS rating_name
FROM film f
LEFT JOIN film_genre fg ON f.id = fg.film_id
LEFT JOIN genre g ON fg.genre_id = g.id
LEFT JOIN rating ON f.rating_id = rating.id
WHERE g.name IN ('комедия',
                 'боевик');
                 
--Определение друзей пользователя (используются параметры `${userId}`). Используется фильтр `is_confirmed` для выделения одобренных заявок.
select u.id,u.email,u.login,u.name,u.birthday
FROM users u
INNER JOIN
     (SELECT user_id,
             user_friend_id
      FROM user_friends
      WHERE is_confirmed
      UNION ALL 
      SELECT user_friend_id,
             user_id
      FROM user_friends
      WHERE is_confirmed ) all_user_friends ON all_user_friends.user_friend_id = u.id
WHERE all_user_friends.user_id = ${userId};


--все друзья
WITH all_user_friends AS
         (SELECT user_id,
                 user_friend_id
          FROM user_friends
          WHERE is_confirmed
          UNION ALL 
          SELECT user_friend_id,
                 user_id
          FROM user_friends
          WHERE is_confirmed ) 
        ,
     first_friends AS --друзья первого пользователя
         (SELECT fuf.user_friend_id
          FROM all_user_friends fuf
          WHERE fuf.user_id = ${userId} ) 
        ,
     second_friends AS --друзья второго пользователя
         (SELECT suf.user_friend_id
          FROM all_user_friends suf
          WHERE suf.user_id = ${friendId} )
SELECT u.id,
       u.email,
       u.login,
       u.name,
       u.birthday
FROM first_friends ff
INNER JOIN second_friends sf ON sf.user_friend_id = ff.user_friend_id --пересечение списка друзей
INNER JOIN users u ON sf.user_friend_id = u.id;

with all_user_friends as (
SELECT user_id,
                 user_friend_id
          FROM user_friends
          WHERE is_confirmed
          UNION ALL 
          SELECT user_friend_id,
                 user_id
          FROM user_friends
          WHERE is_confirmed ) 
        SELECT fuf.user_friend_id
          FROM all_user_friends fuf
          WHERE fuf.user_id = ${userId};  

--Второй вариант с хранением информации о друзьях в виде двух записей на каждую связь (если есть запись, что user1 друг user2, то должна быть запись, что user2 друг user1)
/*insert into user_friends(user_id, user_friend_id, is_confirmed) 
select user_friend_id, user_id, is_confirmed
from user_friends 
where is_confirmed;


--Определение друзей во втором варианте
SELECT user_friend_id
FROM user_friends AS f
WHERE is_confirmed AND f.user_id = ${userId};

--Определение общих друзей во втором варианте
SELECT u.id,
       u.email,
       u.name,
       u.login,
       u.birthday
FROM users u
JOIN
  (SELECT f.user_friend_id AS common_friend
   FROM user_friends f
   JOIN user_friends f2 ON f.user_friend_id = f2.user_friend_id
   WHERE f.user_id = ${userId}
     AND f2.user_id = ${friendId}) AS common_friends ON u.id = common_friends.common_friend;
*/