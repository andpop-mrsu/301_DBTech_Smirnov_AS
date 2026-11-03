#!/bin/bash
chcp 65001

sqlite3 movies_rating.db < db_init.sql

echo "1. Для каждого фильма выведите его название, год выпуска и средний рейтинг. Дополнительно добавьте столбец rank_by_avg_rating, в котором укажите ранг фильма среди всех фильмов по убыванию среднего рейтинга (фильмы с одинаковым средним рейтингом должны получить одинаковый ранг). Используйте оконную функцию RANK() или DENSE_RANK(). В результирующем наборе данных оставить 10 фильмов с наибольшим рангом."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH MovieAvg AS (SELECT m.id, m.title, m.year, AVG(r.rating) as avg_r FROM movies m JOIN ratings r ON m.id = r.movie_id GROUP BY m.id, m.title, m.year) SELECT title, year, avg_r, RANK() OVER (ORDER BY avg_r DESC) as rank_by_avg_rating FROM MovieAvg ORDER BY rank_by_avg_rating LIMIT 10;"
echo " "

echo "2. С помощью рекурсивного CTE выделить все жанры фильмов, имеющиеся в таблице movies. Для каждого жанра рассчитать средний рейтинг avg_rating фильмов в этом жанре. Выведите genre, avg_rating и ранг жанра по убыванию среднего рейтинга, используя оконную функцию RANK()."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE split_genres(id, genre, rest) AS (SELECT id, '', genres || '|' FROM movies UNION ALL SELECT id, substr(rest, 1, instr(rest, '|') - 1), substr(rest, instr(rest, '|') + 1) FROM split_genres WHERE rest != ''), GenreAvg AS (SELECT sg.genre, AVG(r.rating) as avg_r FROM split_genres sg JOIN ratings r ON sg.id = r.movie_id WHERE sg.genre != '' GROUP BY sg.genre) SELECT genre, avg_r, RANK() OVER (ORDER BY avg_r DESC) as rank FROM GenreAvg;"
echo " "

echo "3. Посчитайте количество фильмов в каждом жанре. Выведите два столбца: genre и movie_count, отсортировав результат по убыванию количества фильмов."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE split_genres(id, genre, rest) AS (SELECT id, '', genres || '|' FROM movies UNION ALL SELECT id, substr(rest, 1, instr(rest, '|') - 1), substr(rest, instr(rest, '|') + 1) FROM split_genres WHERE rest != '') SELECT genre, COUNT(id) as movie_count FROM split_genres WHERE genre != '' GROUP BY genre ORDER BY movie_count DESC;"
echo " "

echo "4. Найдите жанры, в которых чаще всего оставляют теги (комментарии). Для этого подсчитайте общее количество записей в таблице tags для фильмов каждого жанра. Выведите genre, tag_count и долю этого жанра в общем числе тегов (tag_share), выраженную в процентах."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH RECURSIVE split_genres(id, genre, rest) AS (SELECT id, '', genres || '|' FROM movies UNION ALL SELECT id, substr(rest, 1, instr(rest, '|') - 1), substr(rest, instr(rest, '|') + 1) FROM split_genres WHERE rest != ''), GenreTags AS (SELECT sg.genre, COUNT(t.movie_id) as tag_count FROM split_genres sg JOIN tags t ON sg.id = t.movie_id WHERE sg.genre != '' GROUP BY sg.genre), TotalTags AS (SELECT COUNT(*) as total FROM tags) SELECT genre, tag_count, ROUND((tag_count * 100.0 / total), 2) as tag_share FROM GenreTags, TotalTags ORDER BY tag_count DESC;"
echo " "

echo "5. Для каждого пользователя рассчитайте: общее количество выставленных оценок, средний выставленный рейтинг, дату первой и последней оценки (по полю timestamp в таблице ratings). Выведите user_id, rating_count, avg_rating, first_rating_date, last_rating_date. Отсортируйте результат по убыванию количества оценок и выведите только 10 первых строк."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "SELECT user_id, COUNT(*) as rating_count, AVG(rating) as avg_rating, strftime('%Y-%m-%d', MIN(timestamp), 'unixepoch') as first_rating_date, strftime('%Y-%m-%d', MAX(timestamp), 'unixepoch') as last_rating_date FROM ratings GROUP BY user_id ORDER BY rating_count DESC LIMIT 10;"
echo " "

echo "6. Сегментируйте пользователей по типу поведения:"
echo "Комментаторы — пользователи, у которых количество тегов (tags) больше количества оценок (ratings);"
echo "Оценщики — наоборот, оценок больше, чем тегов;"
echo "Активные — и оценок, и тегов >= 10;"
echo "Пассивные — и оценок, и тегов < 5."
echo "Выведите user_id, общее число оценок, общее число тегов и категорию поведения. Используйте CASE."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH UserRatings AS (SELECT user_id, COUNT(*) as rating_count FROM ratings GROUP BY user_id), UserTags AS (SELECT user_id, COUNT(*) as tag_count FROM tags GROUP BY user_id), Combined AS (SELECT u.id as user_id, COALESCE(ur.rating_count, 0) as rating_count, COALESCE(ut.tag_count, 0) as tag_count FROM users u LEFT JOIN UserRatings ur ON u.id = ur.user_id LEFT JOIN UserTags ut ON u.id = ut.user_id) SELECT user_id, rating_count, tag_count, CASE WHEN tag_count > rating_count THEN 'Комментаторы' WHEN rating_count > tag_count THEN 'Оценщики' WHEN rating_count >= 10 AND tag_count >= 10 THEN 'Активные' WHEN rating_count < 5 AND tag_count < 5 THEN 'Пассивные' ELSE 'Смешанные' END as category FROM Combined;"
echo " "

echo "7. Для каждого пользователя выведите его имя и последний фильм, который он оценил (по времени из ratings.timestamp). Если пользователь не оценивал ни одного фильма, он всё равно должен быть в результате (с NULL в полях фильма). Результат: user_id, name, last_rated_movie_title, last_rating_timestamp."
echo --------------------------------------------------
sqlite3 movies_rating.db -box -echo "WITH LastRating AS (SELECT user_id, movie_id, timestamp, ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY timestamp DESC) as rn FROM ratings) SELECT u.id as user_id, u.name, m.title as last_rated_movie_title, lr.timestamp as last_rating_timestamp FROM users u LEFT JOIN LastRating lr ON u.id = lr.user_id AND lr.rn = 1 LEFT JOIN movies m ON lr.movie_id = m.id;"
echo " "
