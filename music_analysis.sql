-- Q1: WHO IS THE SENIOR MOST EMPLOYEE BASED ON THEIR JOB TITLE ?

SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1;

-- Q2:  WHICH COUNTRIES HAVE THE MOST INVOICES 

SELECT COUNT(*) as c, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY c DESC;

-- Q3: WHAT ARE TOP 3 VALUES OF TOTAL INVOICE

SELECT total FROM invoice
ORDER BY total DESC
LIMIT 3;

-- Q4: WHICH CITY HAS THE BEST CUSTOMERS ? WE WOULD LIKE TO THROW A PROMOTIONAL MUSIC
-- FESTIVEL IN THE CITY WE MADE THE MOST MONEY. 
-- WRITE A QUERY THAT RETURNS ONE CITY THAT HAS THE HIGHEST SUM OF INVOICES TOTAL RETURN
-- BOTH THE CITY NAME AND SUM OF ALL INVOICE TOTAL

SELECT SUM(total) AS invoice_total, billing_city
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total DESC
LIMIT 1;

-- Q5: WHO IS THE BEST CUSTOMER ? THE CUSTOMER WHO HAS SPENT THE MOST MONEY WILL BE
-- DECLARED THE BEST CUSTOMER.
-- WRITE A QUERY THAT RETURNS THE PERSON WHO HAS SPENT THE MOST MONEY..

SELECT cs.customer_id, cs.first_name, cs.last_name, SUM(i.total) AS total FROM customer AS cs
JOIN invoice AS i ON cs.customer_id = i.customer_id
GROUP BY cs.customer_id
ORDER BY total DESC
LIMIT 1;

-- Moderate Level Question 

-- Q1: Write query to return the email, first name, last name & Genre of all Rock music listeners. 
-- Return your list ordered Alphabetically by email starting with A.
SELECT * FROM customer;

SELECT DISTINCT email, first_name, last_name FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock' 
)
ORDER BY email;

-- Second Method 
SELECT DISTINCT c.email, c.first_name, c.last_name FROM customer AS c
JOIN invoice AS i ON c.customer_id = i.customer_id
JOIN invoice_line AS il ON i.invoice_id = il.invoice_id
JOIN track AS tr ON il.track_id = tr.track_id
JOIN genre AS ge ON tr.genre_id = ge.genre_id
WHERE ge.name LIKE 'Rock'
ORDER BY email;

-- Q2: Let's invite the artists who have written the most rock music in our Dataset. Write a Query
-- that returns the artist name and total track count of the top 10 rock bands..

SELECT artist.artist_id, artist.name, COUNT(artist.artist_id) AS number_of_songs FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;

-- Q3: Return all the track names that have a song length longer than the average song length. Return the name and milliseconds
-- for each track order by the song length with the longest song listed first.

SELECT name, milliseconds FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) as avg_milliseconds FROM track
)
ORDER BY milliseconds DESC;

-- Advanced Level Questions

-- Q1: Find how much amount spent by each customer on Artist ? Write a query to return customer names, artist name, and 
-- Total spent.

WITH best_selling_artist AS(
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name,
	SUM( invoice_line.unit_price * invoice_line.quantity) AS total_sales From invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)

SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name,
SUM(il.unit_price * il.quantity) AS total_spent FROM invoice i

JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5;

-- Q2: We want to find out the most popular music genre for each country. We determine the highest amount of purchases.
-- Write a query that returns each country along with the top Genre.
WITH best_selling_artist AS (
	SELECT artist.artist_id AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price*invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY 1
	ORDER BY 3 DESC
	LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

-- Q3: Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount.
WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1
