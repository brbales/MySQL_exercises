USE sakila;
SELECT * FROM actor;
-- 1a. Display the first and last names of all actors from the table actor.
SELECT first_name, last_name FROM actor;

-- 1b. Display the first and last name of each actor in a single column in upper
--     case letters. Name the column Actor Name.
SELECT
    CONCAT(UPPER(first_name), ' ', UPPER(last_name)) AS Actor_Name
FROM actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of
--     whom you know only the first name, "Joe." What is one query would you use
--     to obtain this information?
SELECT 
    actor_id, first_name, last_name
FROM 
    actor
WHERE
    first_name = 'joe';

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT
    last_name
FROM
    actor
WHERE
    last_name LIKE '%gen%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order
--     the rows by last name and first name, in that order:
SELECT
    last_name, first_name
FROM
    actor
WHERE
    last_name LIKE '%li%';

-- 2d. Using IN, display the country_id and country columns of the following
--     countries: Afghanistan, Bangladesh, and China:
SELECT country_id, country
FROM country
WHERE country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a. Add a middle_name column to the table actor. Position it between first_name
--     and last_name. Hint: you will need to specify the data type.
ALTER TABLE actor ADD COLUMN middle_name VARCHAR(50) AFTER first_name;

-- 3b. You realize that some of these actors have tremendously long last names. Change
--     the data type of the middle_name column to blobs.
ALTER TABLE actor MODIFY COLUMN middle_name BLOB;

-- 3c. Now delete the middle_name column.
ALTER TABLE actor DROP COLUMN middle_name;

-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*) AS `Actors Same Name`
FROM actor 
GROUP BY last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but
--     only for names that are shared by at least two actors
SELECT last_name, COUNT(*) AS `Actors Same Name`
FROM actor
GROUP BY last_name HAVING count(*) > 1
ORDER BY `Actors Same Name` DESC;


-- 4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table
--     as GROUCHO WILLIAMS, the name of Harpo's second cousin's husband's yoga
--     teacher. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' AND last_name = 'Williams';

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that
--     GROUCHO was the correct name after all! In a single query, if the first name
--     of the actor is currently HARPO, change it to GROUCHO. Otherwise, change the
--     first name to MUCHO GROUCHO, as that is exactly what the actor will be with the
--     grievous error. BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO
--     GROUCHO, HOWEVER! (Hint: update the record using a unique identifier.)
-- USE CASE FUNCTION
UPDATE actor
SET first_name = CASE
    WHEN (first_name = 'HARPO') THEN 'GROUCHO'
    WHEN (first_name = 'GROUCHO') THEN 'MUCHO GROUCHO'
    ELSE first_name
    END;
    
-- 5a. You cannot locate the schema of the address table. Which query would you use
--     to re-create it?
DESCRIBE address;

DROP TABLE IF EXISTS address;

CREATE TABLE address (
    address_id INTEGER(5) AUTO_INCREMENT NOT NULL,
    address VARCHAR(50) NOT NULL,
    address2 VARCHAR(50),
    district VARCHAR(20) NOT NULL,
    city_id INTEGER(5) NOT NULL,
    postal_code VARCHAR(10) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    location GEOMETRY NOT NULL,
    last_updata TIMESTAMP NOT NULL,
    PRIMARY KEY (address_id)
    );
    
-- 6a. Use JOIN to display the first and last names, as well as the address, of each
--     staff member. Use the tables staff and address:
SELECT s.first_name, s.last_name, ad.address
FROM
    staff s
    INNER JOIN
    address ad
    ON (s.address_id = ad.address_id);
    
-- 6b. Use JOIN to display the total amount rung up by each staff member in August
--     of 2005. Use tables staff and payment.
SELECT first_name, last_name, SUM(amount) AS 'Total Rung'
FROM
    staff s
    INNER JOIN
    payment p
    ON (s.staff_id = p.staff_id)
WHERE payment_date BETWEEN '2005-08-01 00:00:00' AND '2005-09-01 00:00:00' 
GROUP BY first_name;

SELECT * FROM payment;

-- 6c. List each film and the number of actors who are listed for that film. Use tables
--     film_actor and film. Use inner join.
SELECT title, COUNT(DISTINCT actor_id) AS 'Actor Count'
FROM
    film f
    INNER JOIN
    film_actor fa
    ON (f.film_id = fa.film_id)
GROUP BY title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT title, (
	SELECT COUNT(*) FROM inventory WHERE film.film_id = inventory.film_id
) AS 'Num Copies'
FROM film
WHERE title = 'Hunchback Impossible';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid
--     by each customer. List the customers alphabetically by last name:
SELECT first_name, last_name, sum(amount) as 'Total Paid'
FROM
    customer c
    INNER JOIN
    payment p
    ON (c.customer_id = p.customer_id)
GROUP BY last_name
ORDER BY last_name ASC;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As
--     an unintended consequence, films starting with the letters K and Q have also
--     soared in popularity. Use subqueries to display the titles of movies starting
--     with the letters K and Q whose language is English.
SELECT title
FROM film
WHERE language_id IN (
    SELECT language_id
    FROM language
    WHERE name = 'English'
    )
AND title LIKE 'Q%' OR title LIKE 'K%';
--  7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, Last_name
FROM actor
WHERE actor_id IN (
    SELECT actor_id
    FROM film_actor
    WHERE film_id IN (
        SELECT film_id
        FROM film
        WHERE title = 'Alone Trip'
        )
	);

-- 7c. You want to run an email marketing campaign in Canada, for which you will need
--     the names and email addresses of all Canadian customers. Use joins to retrieve
--     this information.
SELECT first_name, last_name, email
FROM customer
WHERE address_id IN (
    SELECT address_id
    FROM address
    WHERE city_id IN (
        SELECT city_id
        FROM city
        WHERE country_id IN (
            SELECT country_id
            FROM country
            WHERE country = 'Canada'
            )
		)
	);

-- 7d. Sales have been lagging among young families, and you wish to target all family
--     movies for a promotion. Identify all movies categorized as famiy films.
SELECT title
FROM film
WHERE film_id IN (
    SELECT film_id
    FROM film_category
    WHERE category_id IN (
        SELECT category_id
        FROM category
        WHERE name = 'Family'
        )
	);
-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title, COUNT(DISTINCT i.inventory_id) AS `Times Rented`
FROM
    film f
    INNER JOIN
	inventory i
    ON (f.film_id = i.film_id)
	INNER JOIN
	rental r
	ON (i.inventory_id = r.inventory_id)
GROUP BY title
ORDER BY `Times Rented` DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT store_id, SUM(amount) AS `Total Revenue`
FROM staff s, payment p
WHERE s.staff_id = p.staff_id
GROUP BY store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, ct.city, c.country
FROM
    store s
    INNER JOIN
    address a
    ON (s.address_id = a.address_id)
    INNER JOIN
    city ct
    ON (a.city_id = ct.city_id)
    INNER JOIN
    country c
    ON (ct.country_id = c.country_id)
GROUP BY s.store_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may
--     need to use the following tables: category, film_category, inventory, payment,
--     and rental.)
SELECT name, SUM(amount) AS `Revenue`
FROM
    category cat
    INNER JOIN
    film_category fc
    ON (cat.category_id = fc.category_id)
    INNER JOIN
    inventory i
    ON (fc.film_id = i.film_id)
    INNER JOIN
    rental r
    ON (i.inventory_id = r.inventory_id)
    INNER JOIN
    payment p
    ON (r.rental_id = p.rental_id)
GROUP BY name
ORDER BY `Revenue` DESC
LIMIT 5;
    
-- 8a. In your new role as an executive, you would like to have an easy way of viewing
--     the Top five genres by gross revenue. Use the solution from the problem above to
--     create a view. If you haven't solved 7h, you can substitute another query
--     create a view.
DROP VIEW IF EXISTS genre_revenue_top_5;

CREATE VIEW genre_revenue_top_5 AS
SELECT name, SUM(amount) AS `Revenue`
FROM
    category cat
    INNER JOIN
    film_category fc
    ON (cat.category_id = fc.category_id)
    INNER JOIN
    inventory i
    ON (fc.film_id = i.film_id)
    INNER JOIN
    rental r
    ON (i.inventory_id = r.inventory_id)
    INNER JOIN
    payment p
    ON (r.rental_id = p.rental_id)
GROUP BY name
ORDER BY `Revenue` DESC
LIMIT 5;

-- 8b. How would you display the view that you created in 8a?
SELECT * FROM genre_revenue_top_5;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to
--     delete it.
DROP VIEW genre_revenue_top_5;