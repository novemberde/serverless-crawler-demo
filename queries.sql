WITH variables AS (SELECT * FROM naverkeyword)
SELECT keyword, sum(val) as sum FROM (
  (SELECT rank0 as keyword, 6 as val FROM variables)
  UNION 
  (SELECT rank1 as keyword, 5 as val FROM variables)
  UNION 
  (SELECT rank2 as keyword, 4 as val FROM variables)
  UNION 
  (SELECT rank3 as keyword, 3 as val FROM variables)
  UNION 
  (SELECT rank4 as keyword, 2 as val FROM variables)
  UNION 
  (SELECT rank5 as keyword, 1 as val FROM variables)
) as t GROUP BY t.keyword ORDER BY sum(val) DESC LIMIT 10;

-- 
SELECT date_parse(createdAt, '%Y-%m-%dT%H:%i:%s.%fZ') FROM naverkeyword LIMIT 10;

-- 
WITH a AS (SELECT * FROM naverkeyword WHERE createdAt>'2018-10-01')
SELECT keyword, sum(val) as totalValue FROM (
  (SELECT rank0 as keyword, 15 as val FROM a)
  UNION 
  (SELECT rank1 as keyword, 12 as val FROM a)
  UNION 
  (SELECT rank2 as keyword, 7 as val FROM a)
  UNION 
  (SELECT rank3 as keyword, 5 as val FROM a)
  UNION 
  (SELECT rank4 as keyword, 3 as val FROM a)
) as t GROUP BY t.keyword ORDER BY sum(val)DESC LIMIT 50;

-- 
WITH a AS (
  SELECT * FROM naverkeyword 
  WHERE to_unixtime(date_parse(createdAt, '%Y-%m-%dT%H:%i:%s.%fZ'))>to_unixtime(date_parse('2018-10-01T00:00:00.000Z', '%Y-%m-%dT%H:%i:%s.%fZ'))
)
SELECT keyword, sum(val) as totalValue FROM (
  (SELECT rank0 as keyword, 15 as val FROM a)
  UNION 
  (SELECT rank1 as keyword, 12 as val FROM a)
  UNION 
  (SELECT rank2 as keyword, 7 as val FROM a)
  UNION 
  (SELECT rank3 as keyword, 5 as val FROM a)
  UNION 
  (SELECT rank4 as keyword, 3 as val FROM a)
) as t GROUP BY t.keyword ORDER BY sum(val)DESC LIMIT 50;

-- 
SELECT 
  createdAt,
  date_parse(createdAt, '%Y-%m-%dT%H:%i:%s.%fZ') as c,
  to_unixtime(date_parse(createdAt, '%Y-%m-%dT%H:%i:%s.%fZ')) as d,
  to_unixtime(date_parse('2018-10-01T00:00:00.000Z', '%Y-%m-%dT%H:%i:%s.%fZ')) as e
FROM naverkeyword as n 
LIMIT 10;

-- 

SELECT 
  createdAt,
  date_parse(createdAt, '%Y-%m-%dT%H:%i:%s.%fZ') as c,
  to_unixtime(date_parse(createdAt, '%Y-%m-%dT%H:%i:%s.%fZ'))/10 as d,
  date_parse('2018-10-01T00:00:00.001Z', '%Y-%m-%dT%H:%i:%s.%fZ') as g,
  to_unixtime(date_parse('2018-10-01T00:00:00.001Z', '%Y-%m-%dT%H:%i:%s.%fZ'))/100 as e,
  ((to_unixtime(date_parse(createdAt, '%Y-%m-%dT%H:%i:%s.%fZ'))/100)-(to_unixtime(date_parse('2018-10-01T00:00:00.001Z', '%Y-%m-%dT%H:%i:%s.%fZ'))/100))>0 as f,
  (to_unixtime(date_parse(createdAt, '%Y-%m-%dT%H:%i:%s.%fZ'))/100)-(to_unixtime(date_parse('2018-10-01T00:00:00.001Z', '%Y-%m-%dT%H:%i:%s.%fZ'))/100) as h
FROM naverkeyword as n
WHERE ((to_unixtime(date_parse(createdAt, '%Y-%m-%dT%H:%i:%s.%fZ'))/100)-(to_unixtime(date_parse('2018-10-01T00:00:00.001Z', '%Y-%m-%dT%H:%i:%s.%fZ'))/100))>0
LIMIT 100;

-- 

SELECT 
  createdAt,
  date_parse(createdAt, '%Y-%m-%dT%H:%i:%s.%fZ') as c,
  to_unixtime(date_parse(createdAt, '%Y-%m-%dT%H:%i:%s.%fZ'))/10 as d,
  date_parse('2018-10-01T00:00:00.001Z', '%Y-%m-%dT%H:%i:%s.%fZ') as g,
  to_unixtime(date_parse('2018-10-01T00:00:00.001Z', '%Y-%m-%dT%H:%i:%s.%fZ'))/100 as e,
  ((to_unixtime(date_parse(createdAt, '%Y-%m-%dT%H:%i:%s.%fZ'))/100)-(to_unixtime(date_parse('2018-09-12T00:00:00.001Z', '%Y-%m-%dT%H:%i:%s.%fZ'))/100))>0 as f,
  (to_unixtime(date_parse(createdAt, '%Y-%m-%dT%H:%i:%s.%fZ'))/100)-(to_unixtime(date_parse('2018-09-12T00:00:00.001Z', '%Y-%m-%dT%H:%i:%s.%fZ'))/100) as h
FROM naverkeyword as n
WHERE (
  to_unixtime(date_parse(createdAt, '%Y-%m-%dT%H:%i:%s.%fZ'))-
  to_unixtime(date_parse('2018-09-12T00:00:00.001Z', '%Y-%m-%dT%H:%i:%s.%fZ'))
)>0
LIMIT 100;

-- 
SELECT 
  createdAt,
  date_parse(createdAt, '%Y-%m-%dT%H:%i:%s.%fZ') as c,
  to_unixtime(date_parse(createdAt, '%Y-%m-%dT%H:%i:%s.%fZ'))/10 as d,
  date_parse('2018-10-01T00:00:00.001Z', '%Y-%m-%dT%H:%i:%s.%fZ') as g,
  to_unixtime(date_parse('2018-10-01T00:00:00.001Z', '%Y-%m-%dT%H:%i:%s.%fZ'))/100 as e,
  ((to_unixtime(date_parse(createdAt, '%Y-%m-%dT%H:%i:%s.%fZ'))/100)-(to_unixtime(date_parse('2018-09-12T00:00:00.001Z', '%Y-%m-%dT%H:%i:%s.%fZ'))/100))>0 as f,
  (to_unixtime(date_parse(createdAt, '%Y-%m-%dT%H:%i:%s.%fZ'))/100)-(to_unixtime(date_parse('2018-09-12T00:00:00.001Z', '%Y-%m-%dT%H:%i:%s.%fZ'))/100) as h
FROM naverkeyword as n
WHERE (
  to_unixtime(date_parse(createdAt, '%Y-%m-%dT%H:%i:%s.%fZ'))-
  to_unixtime(date_parse('2018-09-12T00:00:00.001Z', '%Y-%m-%dT%H:%i:%s.%fZ'))
)>0
LIMIT 100;

-- 

SELECT 
  createdAt
FROM naverkeyword as n
WHERE (
  date_parse(createdAt, '%Y-%m-%dT%H:%i:%s.%fZ')-
  date_parse('2018-09-12T00:00:00.001Z', '%Y-%m-%dT%H:%i:%s.%fZ')
)>0
LIMIT 100;

-- 

SELECT 
  createdAt,
  current_date,
  date_diff('day', date_parse(createdAt, '%Y-%m-%dT%H:%i:%s.%fZ'), current_date)
FROM naverkeyword as n  
LIMIT 100;

-- 

WITH a AS (SELECT * FROM naverkeyword WHERE date_diff('day', date_parse(createdAt, '%Y-%m-%dT%H:%i:%s.%fZ'), current_date)>5)
SELECT keyword, sum(val) as totalValue FROM (
  SELECT rank0 as keyword, 15 as val FROM a
    UNION ALL
  SELECT rank1 as keyword, 12 as val FROM a
    UNION ALL
  SELECT rank2 as keyword, 7 as val FROM a
    UNION ALL
  SELECT rank3 as keyword, 5 as val FROM a
    UNION ALL
  SELECT rank4 as keyword, 3 as val FROM a
) as t GROUP BY t.keyword ORDER BY sum(val)DESC LIMIT 50;

-- 
CREATE OR REPLACE VIEW "daumkeywordwithin5days" AS
WITH a AS (SELECT * FROM daumkeyword WHERE date_diff('day', date_parse(createdAt, '%Y-%m-%dT%H:%i:%s.%fZ'), current_date)>5)
SELECT keyword, sum(val) as totalValue FROM (
  SELECT rank0 as keyword, 15 as val FROM a
    UNION ALL
  SELECT rank1 as keyword, 12 as val FROM a
    UNION ALL
  SELECT rank2 as keyword, 7 as val FROM a
    UNION ALL
  SELECT rank3 as keyword, 5 as val FROM a
    UNION ALL
  SELECT rank4 as keyword, 3 as val FROM a
) as t GROUP BY t.keyword ORDER BY sum(val)DESC LIMIT 50;

-- 
WITH a AS (SELECT * FROM naverkeyword WHERE date_diff('day', date_parse(createdAt, '%Y-%m-%dT%H:%i:%s.%fZ'), current_date)>30)
SELECT keyword, sum(val) as totalValue FROM (
  SELECT rank0 as keyword, 15 as val FROM a
    UNION ALL
  SELECT rank1 as keyword, 12 as val FROM a
    UNION ALL
  SELECT rank2 as keyword, 7 as val FROM a
    UNION ALL
  SELECT rank3 as keyword, 5 as val FROM a
    UNION ALL
  SELECT rank4 as keyword, 3 as val FROM a
) as t GROUP BY t.keyword ORDER BY sum(val)DESC LIMIT 50;

-- 
WITH a AS (SELECT * FROM keywords WHERE portal='naver' AND date_diff('day', date_parse(createdAt, '%Y-%m-%dT%H:%i:%s.%fZ'), current_date)<5)
SELECT keyword, sum(val) as totalValue FROM (
  SELECT rank0 as keyword, 15 as val FROM a
    UNION ALL
  SELECT rank1 as keyword, 12 as val FROM a
    UNION ALL
  SELECT rank2 as keyword, 7 as val FROM a
    UNION ALL
  SELECT rank3 as keyword, 5 as val FROM a
    UNION ALL
  SELECT rank4 as keyword, 3 as val FROM a
) as t GROUP BY t.keyword ORDER BY sum(val)DESC LIMIT 50;

-- 
date_diff('day', date_parse(createdAt, '%Y-%m-%dT%H:%i:%s.%fZ'), current_date)<5

WITH a AS (SELECT * FROM keywords)
SELECT * FROM (
  SELECT rank0 as keyword, 15 as val, createdAt, portal FROM a
    UNION ALL
  SELECT rank1 as keyword, 13 as val, createdAt, portal FROM a
    UNION ALL
  SELECT rank2 as keyword, 11 as val, createdAt, portal FROM a
    UNION ALL
  SELECT rank3 as keyword, 9 as val, createdAt, portal FROM a
    UNION ALL
  SELECT rank4 as keyword, 8 as val, createdAt, portal FROM a
    UNION ALL
  SELECT rank5 as keyword, 6 as val, createdAt, portal FROM a
    UNION ALL
  SELECT rank6 as keyword, 5 as val, createdAt, portal FROM a
    UNION ALL
  SELECT rank7 as keyword, 3 as val, createdAt, portal FROM a
    UNION ALL
  SELECT rank8 as keyword, 2 as val, createdAt, portal FROM a
    UNION ALL
  SELECT rank9 as keyword, 1 as val, createdAt, portal FROM a
)