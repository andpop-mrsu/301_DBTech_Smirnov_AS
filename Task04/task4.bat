#!/bin/bash
chcp 65001

sqlite3 movies_rating.db < db_init.sql

echo "1. Найти все пары пользователей, оценивших один и тот же фильм. Устранить дубликаты, проверить отсутствие пар с самим собой. Для каждой пары должны быть указаны имена пользователей и название фильма, который они ценили. В списке оставить первые 100 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT u1.name AS user1, u2.name AS user2, m.title FROM ratings r1 JOIN ratings r2 ON r1.movie_id = r2.movie_id AND r1.user_id < r2.user_id JOIN users u1 ON r1.user_id = u1.id JOIN users u2 ON r2.user_id = u2.id JOIN movies m ON r1.movie_id = m.id LIMIT 100;"
echo " "

echo "2. Найти 10 самых старых оценок от разных пользователей, вывести названия фильмов, имена пользователей, оценку, дату отзыва в формате ГГГГ-ММ-ДД."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT m.title, u.name, r.rating, strftime('%Y-%m-%d', r.timestamp, 'unixepoch') AS date FROM ratings r JOIN movies m ON r.movie_id = m.id JOIN users u ON r.user_id = u.id ORDER BY r.timestamp ASC LIMIT 10;"
echo " "

echo "3. Вывести в одном списке все фильмы с максимальным средним рейтингом и все фильмы с минимальным средним рейтингом. Общий список отсортировать по году выпуска и названию фильма. В зависимости от рейтинга в колонке 'Рекомендуем' для фильмов должно быть написано 'Да' или 'Нет'."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH AvgRatings AS (SELECT movie_id, AVG(rating) as avg_r FROM ratings GROUP BY movie_id), Stats AS (SELECT MAX(avg_r) as max_r, MIN(avg_r) as min_r FROM AvgRatings) SELECT m.title, m.year, ar.avg_r, CASE WHEN ar.avg_r = s.max_r THEN 'Да' ELSE 'Нет' END AS 'Рекомендуем' FROM movies m JOIN AvgRatings ar ON m.id = ar.movie_id CROSS JOIN Stats s WHERE ar.avg_r = s.max_r OR ar.avg_r = s.min_r ORDER BY m.year, m.title;"
echo " "

echo "4. Вычислить количество оценок и среднюю оценку, которую дали фильмам пользователи-мужчины в период с 2011 по 2014 год."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT COUNT(r.rating) AS total_ratings, AVG(r.rating) AS avg_rating FROM ratings r JOIN users u ON r.user_id = u.id WHERE u.gender = 'male' AND strftime('%Y', r.timestamp, 'unixepoch') BETWEEN '2011' AND '2014';"
echo " "

echo "5. Составить список фильмов с указанием средней оценки и количества пользователей, которые их оценили. Полученный список отсортировать по году выпуска и названиям фильмов. В списке оставить первые 20 записей."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT m.title, m.year, AVG(r.rating) AS avg_rating, COUNT(DISTINCT r.user_id) AS users_count FROM movies m JOIN ratings r ON m.id = r.movie_id GROUP BY m.id, m.title, m.year ORDER BY m.year, m.title LIMIT 20;"
echo " "

echo "6. Определить самый распространенный жанр фильма и количество фильмов в этом жанре. Отдельную таблицу для жанров не использовать, жанры нужно извлекать из таблицы movies."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE split_genres(id, genre, rest) AS (SELECT id, '', genres || '|' FROM movies UNION ALL SELECT id, substr(rest, 1, instr(rest, '|') - 1), substr(rest, instr(rest, '|') + 1) FROM split_genres WHERE rest != '') SELECT genre, COUNT(*) as count FROM split_genres WHERE genre != '' GROUP BY genre ORDER BY count DESC LIMIT 1;"
echo " "

echo "7. Вывести список из 10 последних зарегистрированных пользователей в формате 'Фамилия Имя|Дата регистрации' (сначала фамилия, потом имя)."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT substr(name, instr(name, ' ') + 1) || ' ' || substr(name, 1, instr(name, ' ') - 1) || '|' || register_date AS user_info FROM users ORDER BY register_date DESC LIMIT 10;"
echo " "

echo "8. С помощью рекурсивного CTE определить, на какие дни недели приходился ваш день рождения в каждом году."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE years(y) AS (SELECT 2006 UNION ALL SELECT y + 1 FROM years WHERE y < 2025) SELECT y AS year, CASE strftime('%w', y || '-11-29') WHEN '0' THEN 'Воскресенье' WHEN '1' THEN 'Понедельник' WHEN '2' THEN 'Вторник' WHEN '3' THEN 'Среда' WHEN '4' THEN 'Четверг' WHEN '5' THEN 'Пятница' WHEN '6' THEN 'Суббота' END AS day_of_week FROM years;"
echo " "
