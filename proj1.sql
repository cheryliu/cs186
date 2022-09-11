DROP VIEW IF EXISTS q0, q1i, q1ii, q1iii, q1iv, q2i, q2ii, q2iii, q3i, q3ii, q3iii, q4i, q4ii, q4iii, q4iv, q4v;

-- Question 0
CREATE VIEW q0(era) 
AS
  -- SELECT 1 -- replace this line
  SELECT MAX(era)
  FROM pitching
;

-- Question 1i
CREATE VIEW q1i(namefirst, namelast, birthyear)
AS
  -- SELECT 1, 1, 1 -- replace this line
  SELECT p.namefirst, p.namelast, p.birthyear
  FROM people AS p
  WHERE p.weight > 300
;

-- Question 1ii
CREATE VIEW q1ii(namefirst, namelast, birthyear)
AS
  -- SELECT 1, 1, 1 -- replace this line
  SELECT p.namefirst, p.namelast, p.birthyear
  FROM people AS p
  WHERE p.namefirst ~ '.* .*'
  ORDER BY p.namefirst
;

-- Question 1iii
CREATE VIEW q1iii(birthyear, avgheight, count)
AS
  -- SELECT 1, 1, 1 -- replace this line
  SELECT birthyear, AVG(height) as avgheight, COUNT(*) as count
  FROM people
  GROUP BY birthyear
  ORDER BY birthyear ASC
;

-- Question 1iv
CREATE VIEW q1iv(birthyear, avgheight, count)
AS
  -- SELECT 1, 1, 1 -- replace this line
  SELECT birthyear, AVG(height) as avgheight, COUNT(*) as count
  FROM people
  GROUP BY birthyear
  HAVING AVG(height) > 70
  ORDER BY birthyear ASC
;

-- Question 2i
CREATE VIEW q2i(namefirst, namelast, playerid, yearid)
AS
  -- SELECT 1, 1, 1, 1 -- replace this line
  SELECT p.namefirst, p.namelast, h.playerid, h.yearid
  FROM halloffame AS h INNER JOIN people AS p ON h.playerid = p.playerid
  WHERE h.inducted = 'Y'
  ORDER BY h.yearid DESC
;

-- Question 2ii
CREATE VIEW q2ii(namefirst, namelast, playerid, schoolid, yearid)
AS
  -- SELECT 1, 1, 1, 1, 1 -- replace this line
  SELECT p.namefirst, p.namelast, h.playerid, s.schoolid, h.yearid
  FROM halloffame AS h 
       INNER JOIN people AS p ON h.playerid = p.playerid
       INNER JOIN collegeplaying AS c ON c.playerid = p.playerid
       INNER JOIN schools AS s ON s.schoolid = c.schoolid
  WHERE h.inducted = 'Y' AND s.schoolstate = 'CA'
  ORDER BY h.yearid DESC, s.schoolid, h.playerid ASC
;

-- Question 2iii
CREATE VIEW q2iii(playerid, namefirst, namelast, schoolid)
AS
  -- SELECT 1, 1, 1, 1 -- replace this line
  SELECT h.playerid, p.namefirst, p.namelast, s.schoolid
  FROM halloffame AS h 
       INNER JOIN people AS p ON h.playerid = p.playerid
       LEFT OUTER JOIN collegeplaying AS c ON c.playerid = p.playerid
       LEFT OUTER JOIN schools AS s ON s.schoolid = c.schoolid
  WHERE h.inducted = 'Y'
  ORDER BY h.playerid DESC, h.playerid, s.schoolid ASC
;

-- Question 3i
CREATE VIEW q3i(playerid, namefirst, namelast, yearid, slg)
AS
  -- SELECT 1, 1, 1, 1, 1 -- replace this line
  SELECT p.playerid, p.namefirst, p.namelast, b.yearid,
         (b.h - b.h2b - b.h3b - b.hr + 2 * b.h2b + 3 * b.h3b + 4 * b.hr) 
                / (cast(b.ab as real)) AS slg
  FROM people AS p INNER JOIN batting as b ON p.playerid = b.playerid
  WHERE b.ab > 50
  ORDER BY slg DESC, b.yearid, p.playerid ASC
  LIMIT 10
;

-- Question 3ii
CREATE VIEW q3ii(playerid, namefirst, namelast, lslg)
AS
  -- SELECT 1, 1, 1, 1 -- replace this line
  SELECT p.playerid, p.namefirst, p.namelast,
         SUM(b.h - b.h2b - b.h3b - b.hr + 2 * b.h2b + 3 * b.h3b + 4 * b.hr)
             / cast(SUM(b.ab) as real) as lslg
  FROM people as p INNER JOIN batting as b on b.playerid = p.playerid
  WHERE b.ab > 0
  GROUP BY p.playerid
  HAVING(SUM(b.ab) > 50)
  ORDER BY lslg DESC, playerid ASC
  LIMIT 10
;

-- Question 3iii
CREATE VIEW q3iii(namefirst, namelast, lslg)
AS
  -- SELECT 1, 1, 1 -- replace this line
  WITH temp AS (
      SELECT p.playerid, 
             SUM(b.h - b.h2b - b.h3b - b.hr + 2 * b.h2b + 3 * b.h3b + 4 * b.hr)
                / cast(SUM(b.ab) as real) as lslg
      FROM people as p 
      INNER JOIN batting as b on b.playerid = p.playerid
      WHERE b.ab > 0
      GROUP BY p.playerid
      HAVING(SUM(b.ab) > 50))
  SELECT p.namefirst, p.namelast, t.lslg
  FROM people AS p INNER JOIN temp AS t ON p.playerid = t.playerid
  WHERE t.lslg > (SELECT lslg FROM temp WHERE playerid = 'mayswi01')
  ORDER BY p.namefirst ASC
;

-- Question 4i
CREATE VIEW q4i(yearid, min, max, avg, stddev)
AS
  -- SELECT 1, 1, 1, 1, 1 -- replace this line
  SELECT yearid, MIN(salary), MAX(salary), AVG(salary), stddev(salary)
  FROM salaries
  GROUP BY yearid
  ORDER BY yearid ASC
;

-- Question 4ii
CREATE VIEW q4ii(binid, low, high, count)
AS
  -- SELECT 1, 1, 1, 1 -- replace this line
  WITH ranges AS (SELECT MIN(salary), MAX(salary)
             FROM salaries WHERE yearid = '2016'), 
        bins AS (SELECT i AS binid, 
                    (i + 1) * (r.max - r.min) / 10.0 + r.min AS high,
                    i * (r.max - r.min) / 10.0 + r.min AS low
           FROM generate_series(0, 9) AS i, ranges AS r)
  SELECT b.binid, b.low, b.high, COUNT(*) 
  FROM bins as b
  INNER JOIN salaries AS s 
    ON s.salary >= b.low 
      AND (s.salary < b.high OR b.binid = 9 AND s.salary <= b.high)
      AND s.yearid = '2016'
  GROUP BY b.binid, b.low, b.high
  ORDER BY b.binid ASC
;

-- Question 4iii
CREATE VIEW q4iii(yearid, mindiff, maxdiff, avgdiff)
AS
  -- SELECT 1, 1, 1, 1 -- replace this line
  WITH temp AS (SELECT yearid, MIN(salary), MAX(salary), AVG(salary)
            FROM salaries 
            GROUP BY yearid)
  SELECT t_2.yearid,
         t_2.min - t.min AS mindiff,
         t_2.max - t.max AS maxdiff,
         t_2.avg - t.avg AS avgdiff
  FROM temp AS t INNER JOIN temp AS t_2 ON t_2.yearid = t.yearid + 1
  ORDER BY t_2.yearid ASC
;

-- Question 4iv
CREATE VIEW q4iv(playerid, namefirst, namelast, salary, yearid)
AS
  -- SELECT 1, 1, 1, 1, 1 -- replace this line
  WITH temp AS(SELECT yearid, MAX(salary) FROM salaries
        WHERE yearid IN (2000,2001)
        GROUP BY yearid)
  SELECT p.playerid, p.namefirst, p.namelast, s.salary, s.yearid
  FROM people AS p 
  NATURAL JOIN salaries AS s
  INNER JOIN temp AS t ON s.salary = t.max AND t.yearid = s.yearid
;
-- Question 4v
CREATE VIEW q4v(team, diffAvg) AS
  -- SELECT 1, 1 -- replace this line
  SELECT a.teamid as team, MAX(s.salary) - MIN(s.salary) as diffavg
  FROM allstarfull AS a 
  INNER JOIN salaries AS s
  ON s.playerid = a.playerid and s.yearid = a.yearid
  WHERE a.yearid = 2016
  GROUP BY team
  ORDER BY team
;

