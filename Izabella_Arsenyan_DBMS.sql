DROP TABLE IF EXISTS University_Score;
DROP TABLE IF EXISTS University;
DROP TABLE IF EXISTS Country;
DROP TABLE IF EXISTS Ranks;

CREATE TABLE University_Score(
	world_rank INT,                          --world rank for university.
	national_rank INT,                       --rank of university within its country
	score FLOAT,                             --total score, used for determining world rank
	ScoreID SERIAL PRIMARY KEY
);

CREATE TABLE University(
	institution VARCHAR,                     --name of university
	quality_of_education INT,                --rank for quality of education
	quality_of_faculty INT,                  --rank for quality of faculty
	UniversityID SERIAL PRIMARY KEY
);


CREATE TABLE Country(
	country VARCHAR,                         --country of each university
	year_ INT,                               --year of ranking (2012 to 2015)
	CountryID SERIAL PRIMARY KEY
 );
  
CREATE TABLE Ranks(
	alumni_employment INT,                   --rank for alumni employment
	publications INT,                        --rank for publications
    influence INT,                           --rank for influence
    citations INT,                           --number of students at the university
    patents INT,                             --rank for patents
	RankID SERIAL PRIMARY KEY     
);

COPY University_Score FROM 'C:\Users\ExpressPrint\Downloads\cwurData.csv' WITH CSV HEADER;

COPY University FROM 'C:\Users\ExpressPrint\Downloads\cwurData1.csv' WITH CSV HEADER;

COPY Country FROM 'C:\Users\ExpressPrint\Downloads\cwurData2.csv' WITH CSV HEADER;

COPY Ranks FROM 'C:\Users\ExpressPrint\Downloads\cwurData4.csv' WITH CSV HEADER;

--------------------------------------------------------------------------------------
--1-- 
SELECT *
FROM University, Country
WHERE country = 'USA' AND quality_of_education = max(quality_of_education)

--2--
SELECT institution, max(score) as max_score
from University,University_Score
group by institution

--3--
SELECT institution,quality_of_education,quality_of_faculty
from University
group by institution,quality_of_education,quality_of_faculty
order by quality_of_education desc;

--4--
SELECT institution,country
FROM University
INNER JOIN Country ON University.UniversityID=Country.CountryID
group by institution,country;

--5--
SELECT u.institution as university, r.citations as number_of_students, s.score as score
FROM Ranks r JOIN University u ON u.UniversityID=r.RankID
JOIN University_Score s ON  u.UniversityID=s.ScoreID
WHERE national_rank > (SELECT AVG(national_rank) FROM University_Score )
order by score desc

--6--
SELECT institution AS university,CONCAT(quality_of_education,' ',quality_of_faculty) AS quality, 
CONCAT(alumni_employment, ' ', publications,' ',influence,' ',patents) AS ranks,
CONCAT(national_rank,' ',score) AS total_score
FROM University, University_Score,Ranks
WHERE quality_of_education = max(quality_of_education) AND quality_of_faculty = max(quality_of_faculty) AND score = max(score)
GROUP BY institution
ORDER BY score DESC LIMIT 10;

--7--
SELECT institution as university
FROM University u
 LEFT JOIN (SELECT r.alumni_employment, r.publications,r.patents 
 FROM Ranks r
 INNER JOIN (SELECT  score > AVG(score) as high_score 
            FROM University_score us
            GROUP BY score) us ON (us.ScoreID = u.UniversityID)) u ON (u.UniversityID = r.RanksID)
            
--8--           
CREATE VIEW Universities_with_high_score AS
    SELECT institution AS university,country, score,year_
    FROM University, University_score
    WHERE score between 80 AND 100;

CREATE VIEW Universities_with_low_score AS
    SELECT institution AS university,country, score,year_
    FROM University, University_score
    WHERE score < 50;

--9--            
SELECT institution AS university,year_,score AS total_Score
OVER (PARTITION BY institution ORDER BY score desc)
FROM University , University_Score ;



