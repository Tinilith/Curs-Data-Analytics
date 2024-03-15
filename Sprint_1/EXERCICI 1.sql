# NIVELL 1
# EXERCICI 2: Realitza la següent consulta: Has d'obtenir el nom, email i país de cada companyia, ordena les dades en funció del nom de les companyies.

SELECT DISTINCT company_name , email, country
FROM company
ORDER BY company_name;

# Exercici 3: Des de la secció de màrqueting et sol·liciten que els passis un llistat dels països que estan fent compres.

# Si volem les transaccions:
SELECT DISTINCT country
FROM company
INNER JOIN transaction
ON company.id = transaction.company_id
;
# Si volem compres:
SELECT DISTINCT country
FROM company
INNER JOIN transaction
ON company.id = transaction.company_id
WHERE declined =0
;

#Exercici 4: Des de màrqueting també volen saber des de quants països es realitzen les compres.

#amb iINNER JOIN
SELECT COUNT(DISTINCT country) AS num_paisos
FROM company
INNER JOIN transaction
ON company.id=transaction.company_id
WHERE declined = 0;

#Amb subconsulta
SELECT COUNT(DISTINCT country) AS num_paisos
FROM (
	SELECT country
    FROM company
	INNER JOIN transaction
	ON company.id = transaction.company_id
    WHERE declined= 0 ) AS paisos
    
;

#Exercici 5: El teu cap identifica un error amb la companyia que té ID 'b-2354'. Per tant, et sol·licita que li indiquis el país i nom de companyia d'aquest aneu.

SELECT company_name , country
FROM company
where id = "b-2354";

#Exercici 6: A més, el teu cap et sol·licita que identifiquis la companyia amb major mitjana de vendes.

SELECT company_name, AVG(amount) AS mitjana
FROM company
LEFT JOIN transaction
ON company.id =transaction.company_id
GROUP BY company_name
ORDER BY mitjana desc
LIMIT 1;

## NIVELL 2

#Exercici 1: El teu cap està redactant un informe de tancament de l'any i et sol·licita que li enviïs informació rellevant per al document. 
#Per a això et sol·licita verificar si en la base de dades existeixen companyies amb identificadors (ID) duplicats.

# Si volem saber si hi ha podem fer una consulta ràpida seleccionant tota la taula de company i després fer una altra amb un distinct als id, 
#això ens donaria una idea si n’hi ha.
#Però si volem saber quins són:

;
 SELECT id, COUNT(id) AS duplicats
 FROM company
 GROUP BY id
 HAVING duplicats >1;
 
  
#Exercici 2: Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. 
#Mostra la data de cada transacció juntament amb el total de les vendes.

SELECT DATE(timestamp), SUM(amount) AS total_vendes
FROM transaction
WHERE declined = 0
GROUP BY DATE(timestamp)
ORDER BY total_vendes desc
LIMIT 5;

# Exercici 3: Identifica els cinc dies que es va generar la menor quantitat d'ingressos a l'empresa per vendes. Mostra la data de cada transacció juntament amb el total de les vendes.

SELECT DATE(timestamp), SUM(amount) AS total_vendes
FROM transaction
WHERE declined = 0
GROUP BY DATE(timestamp)
ORDER BY total_vendes
LIMIT 5;

#Exercici 4: Quina és la mitjana de vendes per país? Presenta els resultats ordenats per la mitjana de major a menor

SELECT country, AVG(amount) AS total_vendes
FROM transaction left join company
ON transaction.company_id = company.id
WHERE declined =0
GROUP BY country
ORDER BY total_vendes desc;


## Nivell 3

# Exercici 1: Presenta el nom, telèfon i país de les companyies, juntament amb la quantitat total de vendes, d'aquelles empreses que van realitzar 
#transaccions amb una venda compresa entre 100 i 200 euros. Ordena els resultats de major a menor quantitat.

SELECT company_name, phone, country, SUM(amount) AS Total_vendes
FROM transaction LEFT JOIN company
ON transaction.company_id = company.id
WHERE declined=0 AND amount >=100 AND amount <= 200
GROUP BY company_name, phone, country
ORDER BY Total_vendes desc
 ;

# Exercici 2: Indica el nom de les companyies que van fer compres el 16 de març del 2022, 28 de febrer del 2022 i 13 de febrer del 2022.

SELECT DISTINCT company_name
FROM transaction LEFT JOIN company
ON transaction.company_id = company.id
WHERE DATE(timestamp) IN ('2022-03-16', '2022-02-28', '2022-02-13') 
;