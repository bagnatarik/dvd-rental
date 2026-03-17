/*
    Author: Tarik BAGNA
    Version: 1.0
*/

-- 1. Calculer les 5 meilleurs clients de l'entreprise

WITH cte_nombre_total_location_par_client AS (
	SELECT customer_id AS id_client, COUNT(*) AS nombre_total_de_location
	FROM rental
	GROUP BY customer_id
)
SELECT n.id_client, c.first_name AS prenom,c.last_name AS nom, n.nombre_total_de_location, DENSE_RANK() OVER(ORDER BY n.nombre_total_de_location DESC)
FROM cte_nombre_total_location_par_client AS n INNER JOIN Customer AS c
ON n.id_client = c.customer_id
LIMIT 10;

-- 2. Calculer l'écart entre le client ayant le plus de locations et le client ayant le moins de locations
WITH cte_nombre_total_location_par_client AS (
	SELECT customer_id AS id_client, COUNT(*) AS nombre_total_de_location
	FROM rental
	GROUP BY customer_id
)
SELECT MAX(nombre_total_de_location) - MIN(nombre_total_de_location) 
FROM cte_nombre_total_location_par_client;

-- 2.1 Duree de location
SELECT ROUND(EXTRACT(EPOCH FROM (return_date - rental_date))/86400, 2) AS duree_location
FROM rental;

-- 3. Calculer la durée moyenne de location par film
SELECT i.film_id, f.title, ROUND(AVG(EXTRACT(EPOCH FROM (r.return_date - r.rental_date))/86400), 2) AS moyenne_duree_location
FROM rental AS r INNER JOIN inventory AS i
ON r.inventory_id = i.inventory_id
INNER JOIN film AS f
ON i.film_id = f.film_id
GROUP BY i.film_id, f.title
ORDER BY moyenne_duree_location
LIMIT 5;

-- 4. Chiffre d'affaires par mois et celui du mois précédent
SELECT 
	TO_CHAR(payment_date, 'YYYY-MM') as mois, 
	SUM(amount) as chiffre_affaires,
	LAG(SUM(amount)) OVER(ORDER BY TO_CHAR(payment_date, 'YYYY-MM') ASC) as chiffre_affaires_mois_precedent
FROM payment
GROUP BY TO_CHAR(payment_date, 'YYYY-MM');

-- 5. Essayer de comprendre pourquoi la chute drastique du mois de mai 2007
SELECT TO_CHAR(payment_date, 'YYYY-MM-DD'), amount, SUM(amount) OVER()
FROM payment
WHERE EXTRACT(MONTH FROM payment_date) = 5
AND EXTRACT(YEAR FROM payment_date) = 2007;

-- 6. Top 10 des films les plus rentables
SELECT f.film_id, f.title, SUM(p.amount) as total_amount
FROM payment AS p INNER JOIN rental AS r
ON p.rental_id = r.rental_id
INNER JOIN inventory i
ON r.inventory_id = i.inventory_id
INNER JOIN film f
ON i.film_id = f.film_id
GROUP BY f.film_id, f.title
ORDER BY total_amount DESC
LIMIT 10;

-- 7. Le staff qui génère le plus de revenus
SELECT s.staff_id, s.first_name, s.last_name, 
       SUM(p.amount) AS revenu_genere
FROM payment AS p 
INNER JOIN staff AS s ON p.staff_id = s.staff_id
GROUP BY s.staff_id, s.first_name, s.last_name
ORDER BY revenu_genere DESC
LIMIT 5;