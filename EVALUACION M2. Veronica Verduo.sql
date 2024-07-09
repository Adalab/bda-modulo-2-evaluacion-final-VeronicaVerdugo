CREATE SCHEMA Evaluacion_Final_Modulo2

USE Sakila

-- 1. Selecciona todos los nombres de las películas sin que aparezcan duplicados.
SELECT DISTINCT title
FROM film;

-- 2. Muestra los nombres de todas las películas que tengan una clasificación de "PG-13".
SELECT title
FROM film
WHERE rating = "PG-13";

-- 3. Encuentra el título y la descripción de todas las películas que contengan la palabra "amazing" en su descripción.
-- 3.1 Quiero saber si la columna "description" es igual en la tabla film y film text. (spoiler:SI)
SELECT description
FROM film NATURAL JOIN film_text;

-- 3.2 Elijo sacarlo de film_text porque es una tabla más pequeña y específica.
SELECT title
FROM film_text
WHERE description LIKE("%amazing%");

-- 4. Encuentra el título de todas las películas que tengan una duración mayor a 120 minutos.
SELECT title
FROM film
WHERE length > 120;

-- 5. Recupera los nombres de todos los actores.
SELECT first_name AS NombreActores
FROM actor;

-- 6. Encuentra el nombre y apellido de los actores que tengan "Gibson" en su apellido.
SELECT first_name AS nombre, last_name AS apellido
FROM actor
WHERE last_name = "Gibson";

-- 7. Encuentra los nombres de los actores que tengan un actor_id entre 10 y 20
SELECT first_name AS nombre_actor
FROM actor
WHERE actor_id BETWEEN 10 AND 20;

-- 8. Encuentra el título de las películas en la tabla film que no sean ni "R" ni "PG-13" en cuanto a su clasificación.
SELECT title
FROM film
WHERE rating <> "R" "PG-13";

-- 9. Encuentra la cantidad total de películas en cada clasificación de la tabla film y muestra la clasificación junto con el recuento.
-- 9.1 Primero saco las distintas clasificaciones que hay para hacer la tabla
SELECT DISTINCT rating
FROM film;
-- 9.2 Después hago una consulta ordenada según lo solicitado
SELECT rating AS clasificación, COUNT(rating) AS total_peliculas
FROM film
GROUP BY rating; 

-- 10. Encuentra la cantidad total de películas alquiladas por cada cliente y muestra el ID del cliente, su nombre y apellido junto con la cantidad de películas alquiladas.
-- 10.1Primero saco de la tabla rental (alquileres) Los clientes y la cantidad de películas que an alquilado usando COUNT.
SELECT customer_id, COUNT(rental_id)
FROM rental
GROUP BY customer_id; 

-- 10.2 Después establezco una unión entre las tablas customer y rental para realizar la consulta completa, añadiendo alias a cada elemento:
SELECT c.customer_id AS ID_Cliente, c.first_name AS Nombre, c.last_name AS Apellido, COUNT(r.rental_id) AS Total_peliculas_alquiladas
FROM customer AS c
	INNER JOIN rental AS r 
	USING (customer_id)
GROUP BY ID_cliente;

-- 11. Encuentra la cantidad total de películas alquiladas por categoría y muestra el nombre de la categoría junto con el recuento de alquileres.
/* La magia del orden que diría Marie.Kondo Primero selecciono las columnas que quiero que aparezcan, 
¡Oh no! Son de tablas diferentes ¡NO PASA NADA! 
La más importante: category (que es genero para no liarnos) y luego un recuento del total de peliculas alquiladas agrupadas por... genero (ya dijimos que era la más importante)
para llegar al recuento debo pasar por film, de aí a inventario y de inventario... TACHÁN llegamos a alquiler (recordemos que las queriamos con un COUNT, que va en el select.
¿He sudado aciendo este? Un poquito si, pero qué bien a quedado al final
*/
SELECT cat.name AS Genero, COUNT(r.rental_id) AS Total_peliculas_alquiladas
FROM category cat
	INNER JOIN film_category fc USING (category_id)
	INNER JOIN film f USING (film_id)
	INNER JOIN inventory i USING (film_id)
	INNER JOIN rental r USING (inventory_id)
GROUP BY Genero;

-- 12. Encuentra el promedio de duración de las películas para cada clasificación de la tabla film y muestra la clasificación junto con el promedio de duración.
/* Ya no ay quien me pare, un AVG no me asusta, con eso sacamos el promedio de duración y ya se que tengo que ir del genero a la tabla film para ver la duracion (length)*/

SELECT cat.name AS Genero, AVG(f.length) AS Promedio_duración
FROM category cat
	INNER JOIN film_category fc USING (category_id)
	INNER JOIN film f USING (film_id)
GROUP BY Genero;

-- 13. Encuentra el nombre y apellido de los actores que aparecen en la película con title "Indian Love".

SELECT ac.first_name AS Nombre, ac.last_name AS Apellido
FROM actor AS ac
	INNER JOIN film_actor USING (actor_id)
	INNER JOIN film USING (film_id)
WHERE title = "Indian Love";

-- 14. Muestra el título de todas las películas que contengan la palabra "dog" o "cat" en su descripción.
SELECT title, description
FROM film_text
WHERE description LIKE ("%dog%") OR description LIKE ("%cat%");

-- 15. Hay algún actor o actriz que no apareca en ninguna película en la tabla film_actor.
-- Para esta consulta debo contrastar la tabla de actores y la de film_actor y ver si hay actores identificados que no aparecen en la tabla film_actor (serían campos vacios/NULL)
SELECT a.actor_id, a.first_name, a.last_name
FROM actor AS a
LEFT JOIN film_actor AS fa USING(actor_id)
WHERE fa.actor_id IS NULL;
/*Hago un left join ya que mantengo todos los datos de actors y comparo los que necesito de film_actor (los que están vacíos) 
CONCLUSIIÓN: No hay actores que no aparecen en la tabla film_actor*/

SELECT fa.actor_id
FROM film_actor fa
RIGHT JOIN actor a USING (actor_id)
WHERE a.actor_id IS NULL

-- 16. Encuentra el título de todas las películas que fueron lanzadas entre el año 2005 y 2010

SELECT title AS peliculas_lanzadas_2005_2010
FROM film
WHERE release_year BETWEEN 2005 AND 2020
GROUP BY title;


-- 17. Encuentra el título de todas las películas que son de la misma categoría que "Family"
-- 17.1 Busco la Id_category de "Family". Es la numero ocho

SELECT *
FROM category;
-- 17.2 Hago la consulta

SELECT f.title AS titulos_familiares
FROM film AS f
INNER JOIN film_category AS fc USING (film_id)
WHERE category_id = 8;

-- 18. Muestra el nombre y apellido de los actores que aparecen en más de 10 películas.

SELECT ac.first_name AS nombre , ac.last_name AS apellido
FROM actor AS ac
JOIN film_actor USING (actor_id)
JOIN film USING (film_id)
GROUP BY nombre, apellido
HAVING  COUNT(film_id) > 10; 

-- Tengo curiosidad por saber el número total de actores que aparecen en más de 10 películas: 200 :)

SELECT COUNT(*)
FROM (
    SELECT ac.actor_id
    FROM actor AS ac
    JOIN film_actor USING (actor_id)
    GROUP BY ac.actor_id
    HAVING COUNT(film_id) > 10
) AS total_actores;


-- 19. Encuentra el título de todas las películas que son "R" y tienen una duración mayor a 2 horas en la tabla film.

SELECT title
FROM film
WHERE rating = "R" AND length > 120;

-- 20. Encuentra las categorías de películas que tienen un promedio de duración superior a 120 minutos y muestra el nombre de la categoría junto con el promedio de duración
SELECT c.name AS genero, AVG(film.length) AS Promedio_superior_120min
FROM film 
JOIN film_category USING (film_id)
JOIN category AS c USING (category_id)
GROUP BY c.name
HAVING AVG(film.length) > 120; 

-- 21 Encuentra los actores que han actuado en al menos 5 películas y muestra el nombre del actor junto con la cantidad de películas en las que han actuado.

SELECT actor.first_name AS nombre, actor.last_name AS apellido, COUNT(fa.film_id) AS NºPeliculas 
FROM actor 
JOIN film_actor AS fa USING (actor_id)
GROUP BY nombre, apellido
HAVING COUNT(fa.film_id) >= 5;

-- 22. Encuentra el título de todas las películas que fueron alquiladas por más de 5 días. Utiliza una subconsulta para encontrar los rental_ids con una duración superior a 5 días y luego selecciona las películas correspondientes.
-- 22.1 Utiliza una subconsulta para encontrar los rental_ids con una duración superior a 5 días
/* Nos dieron la pista: DATEDIFF, impotante notar que ay que poner primero la fecha de devolución para que se reste bien la feca de alquiler*/

SELECT i.film_id
    FROM inventory AS i JOIN rental AS r USING (inventory_id)
    WHERE DATEDIFF(r.return_date, r.rental_date) > 5;
-- 22.2 Teniendo la subconsulta paso a realizar la consulta. para sacar los títiulos tenemos que unir la tabla rental con inventory y de inventory extraer film_id y con ello ir a film para sacar los títulos.
SELECT f.title
FROM film AS f
WHERE f.film_id IN (
    SELECT i.film_id
    FROM inventory AS i JOIN rental AS r USING (inventory_id)
    WHERE DATEDIFF(r.return_date, r.rental_date) > 5
);

--  23. Encuentra el nombre y apellido de los actores que no han actuado en ninguna película de la categoría "Horror". Utiliza una subconsulta para encontrar los actores que han actuado en películas de la categoría "Horror" y luego exclúyelos de la lista de actores.
-- 23.1 Subconsulta: Vamos a ver la ID-actores actores no le han temido al genero "horror" - categgory_id: 8.

SELECT fa.actor_id
FROM film_actor AS fa
JOIN film AS f USING (film_id)
JOIN film_category AS fc USING (film_id)
WHERE fc.category_id = 8;

-- 23.2 Ahora tenemos que mostrar nombre y apellido de los actores que NO han actuado en "Horror" (a ver esos miedicas)
/* hago mi primera consulta(nombre y apellidos) y después le pido los que NO ESTÉN en la subconsulta que ice antes*/

SELECT a.first_name AS nombre, a.last_name AS apellido
FROM actor AS a
WHERE a.actor_id NOT IN (
    SELECT fa.actor_id
    FROM film_actor AS fa
    JOIN film AS f USING (film_id)
    JOIN film_category AS fc USING (film_id)
    WHERE fc.category_id = 8
);

-- 24. BONUS: Encuentra el título de las películas que son comedias y tienen una duración mayor a 180 minutos en la tabla film.
/* Selecciono el titulo de la tabla film. Uno con la tabla film_categgoryId y pongo las dos condiciones: 
que sea comedia: (category_id=5) AND length <180.  El RESULTADO son 3 titulos.*/
SELECT f. title
FROM film AS f
JOIN film_category AS fc USING (film_id)
JOIN category AS c USING (category_id)
WHERE fc.category_id = 5
AND f.length >180
;

-- 25. BONUS: Encuentra todos los actores que han actuado juntos en al menos una película. 
-- La consulta debe mostrar el nombre y apellido de los actores y el número de películas en las que han actuado juntos.
/* Me estaba volviendo loca y he preguntado a chatgpt porque mis opciones eran crear una nueva tabla para duplicar la tabla actores y que así me salieran las dos columnas y unirlas por film_id
Y que se contaran. O también asignar un número a cada pareja haciendo una nueva tabla... Pero he descubierto que si llamamos a la misma tabla de distinta forma...
¡Se pueden usar duplicadas! Es un SELF JOIN, claro, se junta "consigo misma" OH MY GOD. Merece ser tenido en cuenta. ¿Qué he aprendido? Que existen mucísimas vías para lograr el objetivo pero que poder llamar 
"a las cosas por su nombre" adquiere una dimensión desconocida y súper útil en SQL. Lo de que "lo que no se nombra no existe" hay que entenderlo también en su contrario:
"lo que se nombra... EXISTE"*/

SELECT a1.first_name AS Actor1, a1.last_name AS Apellido1, 
       a2.first_name AS Actor2, a2.last_name AS Apellido2, 
       COUNT(*) AS Cantidad_pelis_juntis
FROM film_actor AS fa1
JOIN film_actor AS fa2 ON fa1.film_id = fa2.film_id AND fa1.actor_id < fa2.actor_id -- La condición fa1.actor_id < fa2.actor_id evita duplicados y asegura que cada par se cuente solo una vez.
JOIN actor a1 ON fa1.actor_id = a1.actor_id
JOIN actor a2 ON fa2.actor_id = a2.actor_id
GROUP BY Actor1, Apellido1, Actor2, Apellido2 
HAVING COUNT(*) > 0
ORDER BY Cantidad_pelis_juntis DESC;

