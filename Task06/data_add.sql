-- Добавление 5 новых пользователей (1 - ты, 4 - соседа)
INSERT INTO users (name, email, gender, register_date, occupation) VALUES 
('Смирнов Александр', 'smirnovaleksandr28621@gmail.com', 'male', date('now'), 'student'),
('Иванов Иван', 'ivanov_ii@example.com', 'male', date('now'), 'student'),
('Петрова Анна', 'petrova_aa@example.com', 'female', date('now'), 'student'),
('Сидоров Петр', 'sidorov_pp@example.com', 'male', date('now'), 'student'),
('Козлова Мария', 'kozlova_mm@example.com', 'female', date('now'), 'student');

-- Добавление 3 новых фильмов разных жанров
INSERT INTO movies (title, year) VALUES 
('Мой Новый Фильм 1', 2024),
('Мой Новый Фильм 2', 2023),
('Мой Новый Фильм 3', 2022);

-- Привязка жанров к новым фильмам (Action, Comedy, Drama)
INSERT INTO movie_genres (movie_id, genre_id) 
SELECT m.id, g.id FROM movies m, genres g WHERE m.title = 'Мой Новый Фильм 1' AND g.name = 'Action';

INSERT INTO movie_genres (movie_id, genre_id) 
SELECT m.id, g.id FROM movies m, genres g WHERE m.title = 'Мой Новый Фильм 2' AND g.name = 'Comedy';

INSERT INTO movie_genres (movie_id, genre_id) 
SELECT m.id, g.id FROM movies m, genres g WHERE m.title = 'Мой Новый Фильм 3' AND g.name = 'Drama';

-- Добавление 3 твоих отзывов
INSERT INTO ratings (user_id, movie_id, rating, timestamp) 
SELECT u.id, m.id, 5.0, strftime('%s', 'now') 
FROM users u, movies m WHERE u.email = 'smirnovaleksandr28621@gmail.com' AND m.title = 'Мой Новый Фильм 1';

INSERT INTO ratings (user_id, movie_id, rating, timestamp) 
SELECT u.id, m.id, 4.5, strftime('%s', 'now') 
FROM users u, movies m WHERE u.email = 'smirnovaleksandr28621@gmail.com' AND m.title = 'Мой Новый Фильм 2';

INSERT INTO ratings (user_id, movie_id, rating, timestamp) 
SELECT u.id, m.id, 3.0, strftime('%s', 'now') 
FROM users u, movies m WHERE u.email = 'smirnovaleksandr28621@gmail.com' AND m.title = 'Мой Новый Фильм 3';