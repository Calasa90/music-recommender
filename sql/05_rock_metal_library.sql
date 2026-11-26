USE music_recommender;

-- 05. ROCK & METAL LIBRARY
-- Self-contained selection of 104 Spotify tracks.
-- Original source playlist positions are preserved.

DROP TEMPORARY TABLE IF EXISTS tmp_rock_classics;
CREATE TEMPORARY TABLE tmp_rock_classics (
    position INT NOT NULL PRIMARY KEY,
    track_id VARCHAR(64) NOT NULL UNIQUE
);

INSERT INTO tmp_rock_classics (position, track_id) VALUES
    (3, '4OROzZUy6gOWN4UGQVaZMF'),
    (4, '2MuWTIM3b0YEAskbeeFE1i'),
    (8, '3nlGByvetDcS1uomAoiBmy'),
    (9, '54yLLvpezvPO1lA3GspiZj'),
    (11, '4Zc7TCHzuNwL0AFBlyLdyr'),
    (12, '5IX4TbIR5mMHGE4wiWwKW0'),
    (13, '5qFxuUIAwJlzO60vqOiL7y'),
    (14, '1hlveB9M6ijHZRbzZ2teyh'),
    (15, '6b6uLZsoGhObYexIxnRbIb'),
    (16, '0L7zm6afBEtrNKo6C6Gj08'),
    (17, '51TG9W3y9qyO8BY5RXKgnZ'),
    (18, '0IXpUl1fn2QZcBavfuq0H4'),
    (19, '1brpdmqkx3kSxyqzqXfW7J'),
    (20, '6KTv0Z8BmVqM7DPxbGzpVC'),
    (21, '3J9NEWkd9Cx1MwSSvDySkL'),
    (24, '28WmNsclKsrVmdv3tDmoYU'),
    (25, '2RaA6kIcvomt77qlIgGhCT'),
    (26, '2dbOYFfS7r7NAzquRvji9A'),
    (32, '2SrVGpjv0mqCR6j9EZPSm2'),
    (33, '3wFGRek61NIF330UwJCI52'),
    (34, '5XcZRgJv3zMhTqCyESjQrF'),
    (35, '05RgAMGypEvqhNs5hPCbMS'),
    (42, '70Z9t1qhytWtG4cCmmi7mU'),
    (45, '4fiOTntQKr24p07FvQDHZE'),
    (46, '5ohfpKB5tt275f4Y4lQ9F7'),
    (47, '4cJhBmeJ7KiBeuy7oxRnZ3'),
    (49, '5LyRtsQLhcXmy50VXhQXXS'),
    (54, '3KhF2YiNpJvGpfiCW45R6D'),
    (55, '2SgbR6ttzoNlCRGQOKjrop'),
    (64, '1aZLIbKEdsyqxyD6iNcrbA'),
    (67, '1erRDf98WX0VllciGPYO1H'),
    (73, '469rBLYJUZHMJLtq2Wch3h'),
    (76, '3U9gogDStAfWxSm91PJuxb'),
    (77, '0bVtevEgtDIeRjCJbK3Lmv'),
    (78, '57bgtoPSgt236HzfBOd8kj'),
    (79, '3YBZIN3rekqsKxbJc9FZko'),
    (81, '4f3RDq9nYPBeR1yMSgnmBm'),
    (86, '6p8eFfPw3nQkf37aT3AkmK'),
    (88, '204523f9MSgEfc0oDJycNS'),
    (89, '2CgXyaryyuxl35iMlvanD8'),
    (95, '5MMnwYs0hIxkENRsbkWJ2G'),
    (96, '2zYzyRzz6pRmhPzyfMEC8s'),
    (97, '3uMmllZo1AfoEnVT4ENCD3'),
    (99, '0hCB0YR03f6AmQaHbwWDe8'),
    (100, '1iW2ktyrQHNKZwFTvgP0Ta'),
    (119, '6fybp4N6eW3bsFAvARxyVe'),
    (123, '18URo35acNKRTHfEdjTcGn'),
    (125, '0dlTGl67UFWcKupzkxZYOn'),
    (126, '2vNw57KPaYDzkyPxXYUORX'),
    (132, '7yDrKl1J4VWNbR4aLU3qJ7'),
    (135, '3vhKrSxe3fRuS5Ogis76VO'),
    (139, '1aDNYyeU62BuQsBAY18i48'),
    (143, '1E0yt5XSdjE9NOu897RilW'),
    (144, '7fcfNW0XxTWlwVlftzfDOR'),
    (147, '5Z8EDau8uNcP1E8JvmfkZe'),
    (155, '2E7W1X4maFFcjHrVrFA7Vs'),
    (168, '08mG3Y1vljYA6bvDt4Wqkj'),
    (169, '78lgmZwycJ3nzsdgmPPGNx'),
    (173, '6WE7jSshLCuVKoCmobVKVf'),
    (174, '573Z2Dty5epeNgKsgoDOlr'),
    (175, '2c1ccPqUnFYD8W7LY65bKG'),
    (185, '31dqpLUModJWNbxrXu6TWd'),
    (217, '0X1sqQ652p1sceKM2nJlIJ'),
    (221, '4ZpXHlV2vQVfPXUvbDSZ92'),
    (222, '769cLRTw2y6KRdkFWFkxtu'),
    (223, '6rkeaQRCWZxwkjhyqgxjXi'),
    (224, '5Tdx85q8KQIcIZJ9XoHblt'),
    (228, '2tAeN2TKlQLOoSPXtARzBV'),
    (239, '4qjscZh4jfhkpcQG4ZQfi2'),
    (244, '1j06ieEC2BOCM0fTmYhn2l'),
    (247, '0rmGAIH9LNJewFw7nKzZnc'),
    (248, '37ZJ0p5Jm13JPevGcx4SkF'),
    (266, '0oerlffJSzhRVvtDfLcp3N'),
    (269, '7snQQk1zcKl8gZ92AnueZW'),
    (271, '0rFWuqFgHAfuzE8uSB9TWR'),
    (289, '7LRMbd3LEoV5wZJvXT1Lwb'),
    (290, '69QHm3pustz01CJRwdo20z'),
    (291, '2d4e45fmUnguxh6yqC7gNT'),
    (294, '3MrRksHupTVEQ7YbA0FsZK'),
    (309, '3QZ7uX97s82HFYSmQUAN1D'),
    (312, '2dEgwtRjYl6TJkIwjRwn6z'),
    (352, '0QwZfbw26QeUoIy82Z2jYp'),
    (354, '6i4Qi1mJxXjqNIL9HfJhRs'),
    (357, '4JiEyzf0Md7KEFFGWDDdCr'),
    (358, '2N2yrmodOnVF10mKvItC9P'),
    (359, '3YRCqOhFifThpSRFJ1VWFM'),
    (366, '4vJr55lngvhSM8WIh9CjQc'),
    (376, '2o4u19nlQWOGg5mLanT7Pg'),
    (384, '6hpPAOftKbe1YghyTtJuCq'),
    (396, '0C80GCp0mMuBzLf3EAXqxv'),
    (398, '17lu4tymfnhmcIDlzBbtAb'),
    (401, '753KutoAy00apPsplMRetG'),
    (407, '5S126DaCBZ8z6yh7B1Lszr'),
    (409, '0Yfpc5zHc9pElVCQ1bPlF4'),
    (416, '3ovjw5HZZv43SxTwApooCM'),
    (417, '1bKQ48M9onID2kbSpRy8kK'),
    (431, '4WwWjFCyvUY2fcx8OULByB'),
    (434, '3vV3cr2TpPqFk07zxYUbla'),
    (435, '01Q4wU19hamqnhNjtuvTyI'),
    (443, '2KPcujYDaukvtfRR0Zmu0O'),
    (449, '29wJiSQcze8HEmxkUQykyp'),
    (459, '2PFIZFcGry0po3ZfRZkzKc'),
    (486, '3Rtv6zRNKpeSygXoaF9kCm'),
    (549, '2KKLuHN6zDxVnWtFKO8vo4');

-- 1. Create library (idempotent).
INSERT INTO libraries (library_name, description)
SELECT 'Rock & Metal Library', 'Classic rock, hard rock and heavy metal songs.'
WHERE NOT EXISTS (SELECT 1 FROM libraries WHERE library_name = 'Rock & Metal Library');

-- 2. Create playlist (idempotent).
INSERT INTO playlists (playlist_name, description, status)
SELECT 'Rock & Metal Classics', 'Selection of 104 classic rock, hard rock and metal tracks.', 'active'
WHERE NOT EXISTS (SELECT 1 FROM playlists WHERE playlist_name = 'Rock & Metal Classics');

-- 3. Link existing songs to the library.
INSERT INTO belongs_to (song_id, library_id)
SELECT s.song_id, l.library_id
FROM tmp_rock_classics AS t
JOIN songs AS s ON s.track_id = t.track_id
JOIN libraries AS l ON l.library_name = 'Rock & Metal Library'
WHERE NOT EXISTS (
    SELECT 1 FROM belongs_to AS b
    WHERE b.song_id = s.song_id AND b.library_id = l.library_id
);

-- 4. Link existing songs to the playlist at their original positions.
INSERT INTO contains (playlist_id, song_id, position)
SELECT p.playlist_id, s.song_id, t.position
FROM tmp_rock_classics AS t
JOIN songs AS s ON s.track_id = t.track_id
JOIN playlists AS p ON p.playlist_name = 'Rock & Metal Classics'
WHERE NOT EXISTS (
    SELECT 1 FROM contains AS c
    WHERE c.playlist_id = p.playlist_id AND c.song_id = s.song_id
);

-- 5. Validate selection, matches, library and playlist.
SELECT COUNT(*) AS selected_tracks,
       COUNT(DISTINCT position) AS unique_positions,
       MIN(position) AS first_position, MAX(position) AS last_position
FROM tmp_rock_classics;

SELECT COUNT(DISTINCT s.song_id) AS matched_tracks
FROM tmp_rock_classics AS t
JOIN songs AS s ON s.track_id = t.track_id;

SELECT l.library_name, COUNT(DISTINCT b.song_id) AS library_songs
FROM libraries AS l
LEFT JOIN belongs_to AS b ON b.library_id = l.library_id
WHERE l.library_name = 'Rock & Metal Library'
GROUP BY l.library_id, l.library_name;

SELECT p.playlist_name, COUNT(DISTINCT c.song_id) AS playlist_songs,
       COUNT(DISTINCT c.position) AS unique_positions,
       MIN(c.position) AS first_position, MAX(c.position) AS last_position
FROM playlists AS p
LEFT JOIN contains AS c ON c.playlist_id = p.playlist_id
WHERE p.playlist_name = 'Rock & Metal Classics'
GROUP BY p.playlist_id, p.playlist_name;

SELECT COUNT(*) AS missing_library_links
FROM contains AS c
JOIN playlists AS p ON p.playlist_id = c.playlist_id
JOIN libraries AS l ON l.library_name = 'Rock & Metal Library'
LEFT JOIN belongs_to AS b ON b.song_id = c.song_id AND b.library_id = l.library_id
WHERE p.playlist_name = 'Rock & Metal Classics' AND b.song_id IS NULL;

DROP TEMPORARY TABLE IF EXISTS tmp_rock_classics;
