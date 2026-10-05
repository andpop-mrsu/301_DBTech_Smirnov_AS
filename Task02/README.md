# Лабораторная работа №2

## Задание
Организовать ETL-процесс: из исходных текстовых файлов сгенерировать SQL-скрипт для создания таблиц и загрузки данных в SQLite.

## Требования к окружению
- Python 3.x
- SQLite 3.x

Проверка:
- `python --version`
- `sqlite3 --version`

## Структура
- `make_db_init.py` — утилита, генерирующая SQL-скрипт
- `db_init.bat` — шелл-скрипт для запуска генерации и загрузки
- `db_init.sql` — сгенерированный SQL-скрипт
- `movies.csv`, `ratings.csv`, `tags.csv`, `users.txt` — исходные данные
- `genres.txt`, `occupation.txt` — справочники

## Запуск
1. Перейти в каталог `Task02`
2. Выполнить `bash db_init.bat`
3. Создастся файл `movies_rating.db` с таблицами `movies`, `ratings`, `tags`, `users`.
