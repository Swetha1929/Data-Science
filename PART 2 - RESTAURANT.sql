CREATE DATABASE RESTAURANT;

USE RESTAURANT;

CREATE TABLE GEOPLACES2
(
PLACE_ID INT,
LATITUDE REAL,
LONGITUDE REAL,
the_geom_meter text,
Name Varchar(30),
Address Text,
City Varchar(30),
State Varchar(30),
Country Varchar(30),
Fax Varchar(30),
Zip INT,
Alcohol Varchar(30),
Smoking_area Varchar(30),
Dress_code Varchar(30),
Accessibility Varchar(30),
Price Varchar(30),
URL Varchar(30),
Rambience Varchar(30),
franchise Varchar(30),
Area Varchar(30),
Other_Services Varchar(30));

ALTER TABLE GEOPLACES2 MODIFY PLACE_ID INT PRIMARY KEY;

CREATE TABLE Chefmozaccepts
(
PLACE_ID INT,
PAYMENT VARCHAR(30));

ALTER TABLE Chefmozaccepts ADD CONSTRAINT FK_PLACE_ID FOREIGN KEY (PLACE_ID) REFERENCES GEOPLACES2 (PLACE_ID);

SET FOREIGN_KEY_CHECKS=0;

CREATE TABLE Chefmozcuisine
(
Place_ID INT,
Rcuisine VARCHAR(30));

ALTER TABLE Chefmozcuisine  ADD CONSTRAINT F_PLACE_ID FOREIGN KEY (PLACE_ID) REFERENCES GEOPLACES2 (PLACE_ID);


CREATE TABLE Userprofile
(
User_ID Varchar(30),
Latitude real,
Longitude real,
Smoker Varchar(30),
Drive_Level Varchar(30),
dress_preference Varchar(30),
ambience Varchar(30),
transport Varchar(30),
marital_status Varchar(30),
hijos Varchar(30),
birth_year INT,
interest Varchar(30),
personality Varchar(30),
religion Varchar(30),
activity Varchar(30),
color Varchar(30),
Weight INT,
Budget Varchar(30),
Height INT );

ALTER TABLE Userprofile MODIFY USER_ID VARCHAR(30) PRIMARY KEY;

CREATE TABLE chefmozhours4
(
Place_ID INT,
Hours Time,
Days TEXT); 

ALTER TABLE ChefmozHOURS4  ADD CONSTRAINT FH_PLACE_ID FOREIGN KEY (PLACE_ID) REFERENCES GEOPLACES2 (PLACE_ID);


CREATE TABLE Chefmozparking
(
Place_ID INT,
Parking_lot Varchar(30));

ALTER TABLE ChefmozPARKING  ADD CONSTRAINT FP_PLACE_ID FOREIGN KEY (PLACE_ID) REFERENCES GEOPLACES2 (PLACE_ID);


CREATE TABLE rating_final
(
User_ID VARCHAR(30),
Place_ID INT,
Rating INT,
Food_Rating INT,
Service_Rating INT); 

ALTER TABLE rating_final  ADD CONSTRAINT FR_PLACE_ID FOREIGN KEY (PLACE_ID) REFERENCES GEOPLACES2 (PLACE_ID);
ALTER TABLE rating_final  ADD CONSTRAINT RF_PLACE_ID FOREIGN KEY (USER_ID) REFERENCES USER_PROFILE (USER_ID);


CREATE TABLE Usercuisine
(
User_ID VARCHAR(30),
Rcuisine VARCHAR(30));

ALTER TABLE  Usercuisine ADD CONSTRAINT UC_PLACE_ID FOREIGN KEY (USER_ID) REFERENCES USER_PROFILE (USER_ID);


CREATE TABLE Userpayment
(
User_ID VARCHAR(30),
Upayment VARCHAR(30));

ALTER TABLE  USERPAYMENT ADD CONSTRAINT UP_PLACE_ID FOREIGN KEY (USER_ID) REFERENCES USER_PROFILE (USER_ID);


#Question 1: - We need to find out the total visits to all restaurants under all alcohol categories available.

SELECT SUM(visits) AS total_visits
FROM (
    SELECT COUNT(*) AS visits
    FROM geoplaces2
    GROUP BY Alcohol
) AS alcohol_visits;

#Question 2: -Let's find out the average rating according to alcohol and price so that we can understand the rating in respective price categories as well.

SELECT Alcohol, Price, AVG(Rating) AS avg_rating
FROM geoplaces2
JOIN rating_final ON geoplaces2.Place_id = rating_final.Place_id
GROUP BY Alcohol, Price;

#Question 3:  Let’s write a query to quantify that what are the parking availability as well in different alcohol categories along with the total number of restaurants.

SELECT Alcohol, Parking_lot, COUNT(*) AS total_restaurants
FROM geoplaces2
JOIN Chefmozparking ON geoplaces2.Place_id = Chefmozparking.Place_id
GROUP BY Alcohol, Parking_lot;

#Question 4: -Also take out the percentage of different cuisine in each alcohol type.

SELECT Alcohol, Rcuisine, COUNT(*) AS cuisine_count, 
COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY Alcohol) * 100 AS percentage
FROM geoplaces2
JOIN Chefmozcuisine ON geoplaces2.Place_id = Chefmozcuisine.Place_id
GROUP BY Alcohol, Rcuisine;

#Questions 5: - let’s take out the average rating of each state.

SELECT State, AVG(Rating) AS avg_rating
FROM geoplaces2
JOIN rating_final ON geoplaces2.Place_id = rating_final.Place_id
GROUP BY State;

#Questions 6: -' Tamaulipas' Is the lowest average rated state. Quantify the reason why it is the lowest rated by providing the summary on the basis of State, alcohol, and Cuisine.

SELECT State, Alcohol, Rcuisine, AVG(Rating) AS avg_rating
FROM geoplaces2
JOIN rating_final ON geoplaces2.Place_id = rating_final.Place_id
JOIN Chefmozcuisine ON geoplaces2.Place_id = Chefmozcuisine.Place_id
WHERE State = 'Tamaulipas'
GROUP BY State, Alcohol, Rcuisine
ORDER BY avg_rating;

#Question 7:  - Find the average weight, food rating, and service rating of the customers who have visited KFC and tried Mexican or Italian types of cuisine, and also their budget level is low.

SELECT AVG(Userprofile.Weight) AS avg_weight, 
       AVG(rating_final.Food_Rating) AS avg_food_rating, 
       AVG(rating_final.Service_Rating) AS avg_service_rating
FROM rating_final
JOIN Userprofile ON rating_final.User_ID = Userprofile.User_ID
JOIN geoplaces2 ON rating_final.Place_id = geoplaces2.Place_id
JOIN Usercuisine ON rating_final.User_ID = Usercuisine.User_ID
WHERE geoplaces2.Name = 'KFC'
AND (Usercuisine.Rcuisine = 'Mexican' OR Usercuisine.Rcuisine = 'Italian')
AND Userprofile.Budget = 'low';

COMMIT;