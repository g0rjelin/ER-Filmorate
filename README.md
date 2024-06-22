![ER Filmorate](Filmorate.png)
[ER-��������� Filmorate � DBDiagram](https://dbdiagram.io/d/Filmorate-66768c5c5a764b3c72216930)

# �����������
1. ��� ��������� ����� ������ ������� id, ������� ����� *<��������>*[*_���.����*]_id.
2. ��� ��������� ������ ������������ ���������������� ���� serial � bigserial
3. ������� ������� �� film � ��������� ���������� �� ������ 1 � 1, �.�. ������ ����� ����������� ����� ���������, � ������� � ���� ������� ����� ���� ������� � ������� �� ������ ������� (�����, �������������� � �.�.)   
4. ��������� ���� last_update - ��������� ���������� ��������� ������
5. ����� ������ �� ������ �� �� ����������� � �������� �����������, �.�. ���� ���� ������ � ���, ��� ������������1 �������� ������ ������������2, �� ���������� �� �������� ����� ����� ���������� �� ������� (��. ������ 4).

# ������� ��������
1. ��������� ���������� � 10 ��������� ����������� �������
```sql
SELECT id,
       name,
       description,
       duration,
       rating.name AS rating_name,
       last_update
FROM film
LEFT JOIN rating ON film.rating_id = rating.id
ORDER BY last_update DESC
    LIMIT 10
```

2. ����������� ��������������� 10 �������� ���������� �������
```sql
SELECT film.id,
       film.name,
       film.description,
       film.duration,
       rating.name AS rating_name,
       fl.cnt,
       film.last_update
FROM film
INNER JOIN
     (SELECT f.id,
             COUNT(fu.user_id) AS cnt
      FROM film f
      LEFT JOIN film_userlikes fu ON fu.film_id = f.id
      GROUP BY f.id
      ORDER BY COUNT(fu.user_id) DESC
          LIMIT 10) fl ON fl.id = film.id
LEFT JOIN rating ON film.rating_id = rating.id
```

3. ����� ������� �� ����� (`DISTINCT` �����, �.�. � ������ ������� ��������� ������, � ����� ����� ������������ ���������� ������)
```sql
SELECT DISTINCT f.id,
                f.name,
                f.description,
                f.duration,
                rating.name AS rating_name,
                f.last_update
FROM film f
LEFT JOIN film_genre fg ON f.id = fg.film_id
LEFT JOIN genre g ON fg.genre_id = g.genre_id
LEFT JOIN rating ON f.rating_id = rating.id
WHERE g.name IN ('�������',
                 '������')
```

4. ����������� ������ ������������ (������������ ��������� `${userId}`). ������������ ������ `is_confirmed` ��� ��������� ���������� ������.
```sql
SELECT
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
WHERE uf.user_id = ${userId}
```

5. ����������� ����� ������ ������������ (������������ ��������� `${userId}`, `${friendId}`)
```sql
--��� ������
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
     first_friends AS --������ ������� ������������
         (SELECT fuf.user_friend_id
          FROM all_user_friends fuf
          WHERE fuf.user_id = ${userId} ) 
        ,
     second_friends AS --������ ������� ������������
         (SELECT fuf.user_friend_id
          FROM all_user_friends suf
          WHERE suf.user_id = ${friendId} )
SELECT u.id,
       u.email,
       u.login,
       u.name,
       u.birthday
FROM first_friends ff
INNER JOIN second_friends sf ON sf.user_friend_id = ff.user_friend_id --����������� ������ ������
INNER JOIN users u ON sf.user_friend_id = u.id
```