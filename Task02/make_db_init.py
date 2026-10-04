import os
import re
import csv

WORK_DIR = os.path.dirname(os.path.abspath(__file__))
OUTPUT_SQL = os.path.join(WORK_DIR, "db_init.sql")


def quote(val):
    if val is None:
        return "NULL"
    return "'" + str(val).replace("'", "''") + "'"


def split_title_year(raw_title):
    m = re.search(r"\((\d{4})\)\s*$", raw_title)
    if not m:
        return raw_title.strip(), None
    return raw_title[:m.start()].strip(), int(m.group(1))


def rows_from_csv(fname):
    with open(os.path.join(WORK_DIR, fname), encoding="utf-8", newline="") as fh:
        for row in csv.DictReader(fh):
            yield row


def rows_from_users():
    with open(os.path.join(WORK_DIR, "users.txt"), encoding="utf-8") as fh:
        for raw in fh:
            parts = raw.rstrip("\n").split("|")
            if len(parts) == 6:
                yield parts


def build_sql():
    with open(OUTPUT_SQL, "w", encoding="utf-8", newline="\n") as out:
        out.write("-- Сгенерировано автоматически\n")
        out.write("PRAGMA foreign_keys = OFF;\n\n")

        for tbl in ("movies", "ratings", "tags", "users"):
            out.write(f"DROP TABLE IF EXISTS {tbl};\n")

        out.write("\n")
        out.write("CREATE TABLE movies (\n")
        out.write("    id INTEGER PRIMARY KEY,\n")
        out.write("    title TEXT,\n")
        out.write("    year INTEGER,\n")
        out.write("    genres TEXT\n")
        out.write(");\n\n")

        out.write("CREATE TABLE ratings (\n")
        out.write("    id INTEGER PRIMARY KEY,\n")
        out.write("    user_id INTEGER,\n")
        out.write("    movie_id INTEGER,\n")
        out.write("    rating REAL,\n")
        out.write("    timestamp INTEGER\n")
        out.write(");\n\n")

        out.write("CREATE TABLE tags (\n")
        out.write("    id INTEGER PRIMARY KEY,\n")
        out.write("    user_id INTEGER,\n")
        out.write("    movie_id INTEGER,\n")
        out.write("    tag TEXT,\n")
        out.write("    timestamp INTEGER\n")
        out.write(");\n\n")

        out.write("CREATE TABLE users (\n")
        out.write("    id INTEGER PRIMARY KEY,\n")
        out.write("    name TEXT,\n")
        out.write("    email TEXT,\n")
        out.write("    gender TEXT,\n")
        out.write("    register_date TEXT,\n")
        out.write("    occupation TEXT\n")
        out.write(");\n\n")

        out.write("BEGIN TRANSACTION;\n")

        for r in rows_from_csv("movies.csv"):
            t, y = split_title_year(r["title"])
            y_sql = "NULL" if y is None else str(y)
            out.write(
                f"INSERT INTO movies VALUES "
                f"({int(r['movieId'])}, {quote(t)}, {y_sql}, {quote(r['genres'])});\n"
            )

        for i, r in enumerate(rows_from_csv("ratings.csv"), 1):
            out.write(
                f"INSERT INTO ratings VALUES "
                f"({i}, {int(r['userId'])}, {int(r['movieId'])}, "
                f"{float(r['rating'])}, {int(r['timestamp'])});\n"
            )

        for i, r in enumerate(rows_from_csv("tags.csv"), 1):
            out.write(
                f"INSERT INTO tags VALUES "
                f"({i}, {int(r['userId'])}, {int(r['movieId'])}, "
                f"{quote(r['tag'])}, {int(r['timestamp'])});\n"
            )

        for u in rows_from_users():
            uid, name, email, gender, rdate, occ = u
            out.write(
                f"INSERT INTO users VALUES "
                f"({int(uid)}, {quote(name)}, {quote(email)}, "
                f"{quote(gender)}, {quote(rdate)}, {quote(occ)});\n"
            )

        out.write("COMMIT;\n")

    print("SQL-скрипт создан:", OUTPUT_SQL)


if __name__ == "__main__":
    build_sql()
