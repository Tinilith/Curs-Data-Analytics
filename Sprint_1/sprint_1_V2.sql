#Exercici 1
#A partir dels documents adjunts (estructura_dades i dades_introduir), importa les dues taules. Mostra les característiques principals de l'esquema creat i explica les diferents taules i 
#variables que existeixen. Assegura't d'incloure un diagrama que il·lustri la relació entre les diferents taules i variables.

-- Creamos la base de datos
    CREATE DATABASE IF NOT EXISTS transactions;
    USE transactions;

    -- Creamos la tabla company
    CREATE TABLE IF NOT EXISTS company (
        id VARCHAR(15) PRIMARY KEY,
        company_name VARCHAR(255),
        phone VARCHAR(15),
        email VARCHAR(100),
        country VARCHAR(100),
        website VARCHAR(255)
    );


    -- Creamos la tabla transaction
    CREATE TABLE IF NOT EXISTS transaction (
        id VARCHAR(255) PRIMARY KEY,
        credit_card_id VARCHAR(15) REFERENCES credit_card(id),
        company_id VARCHAR(20), 
        user_id INT REFERENCES user(id),
        lat FLOAT,
        longitude FLOAT,
        timestamp TIMESTAMP,
        amount DECIMAL(10, 2),
        declined BOOLEAN,
        FOREIGN KEY (company_id) REFERENCES company(id) 
    );
#a continuació introduïm les dades des del l'arxiu sql que ens ha proporcionat l'exercici.


##Exercici 2
#Realitza la següent consulta: Has d'obtenir el nom, email i país de cada companyia, ordena les dades en funció del nom de les companyies.

SELECT company_name, email, country
FROM company
ORDER BY company_name;

##Exercici 3
#Des de la secció de màrqueting et sol·liciten que els passis un llistat dels països que estan fent compres.
#si volem saber quins paisos fan transaccions
SELECT DISTINCT country
FROM company INNER JOIN transaction
ON company.id=transaction.company_id;

#si volem saber només les aprovades:
SELECT DISTINCT country
FROM company INNER JOIN transaction
ON company.id=transaction.company_id
WHERE declined =0;

##- Exercici 4
#Des de màrqueting també volen saber des de quants països es fan les compres.

SELECT count(distinct country) as num_paisos
FROM company
INNER JOIN transaction 
ON company.id=transaction.company_id
WHERE declined =0;

#-----------------per utilitzar l'alies correctament!!!
SELECT num_paisos
FROM (
    SELECT COUNT(DISTINCT country) as num_paisos
    FROM company
    INNER JOIN transaction ON company.id = transaction.company_id
    WHERE declined = 0
) AS paisos;

##Exercici 5
#El teu cap identifica un error amb la companyia que té ID 'b-2354'. Per tant, et sol·licita que li indiquis el país i nom de companyia d'aquest ID.

SELECT country, company_name
FROM company 
WHERE id ='b-2354';

##Exercici 6
#A més, el teu cap et sol·licita que identifiquis la companyia amb major mitjana de vendes.

SELECT company_name, avg(amount) as mitjana
FROM company join transaction
on company.id= transaction.company_id
group by company_name
order by mitjana desc
limit 1;

##NIVELL 2:

#Exercici 2.1
#El teu cap està redactant un informe de tancament de l'any i et sol·licita que li enviïs informació rellevant per al document. 
#Per a això et sol·licita verificar si en la base de dades existeixen companyies amb identificadors (ID) duplicats.

SELECT id, count(id) as duplicats
FROM company
GROUP BY id
HAVING duplicats >1;

##Exercici 2.2
##Identifica els cinc dies que es va generar la quantitat més gran d'ingressos a l'empresa per vendes. Mostra la data de cada transacció juntament amb el total de les vendes.

SELECT DATE(timestamp) as data, SUM(amount) as total_vendes #DATE ens ajuda a elimirnar l'hora, per poder fer la suma de tot el dia
FROM transaction
WHERE declined = 0
GROUP by data
ORDER by total_vendes desc
LIMIT 5;

##Exercici 2.3
#Identifica els cinc dies que es va generar la menor quantitat d'ingressos a l'empresa per vendes. Mostra la data de cada transacció juntament amb el total de les vendes.

SELECT DATE(timestamp) as data, SUM(amount) as total_vendes #DATE ens ajuda a elimirnar l'hora, per poder fer la suma de tot el dia
FROM transaction
WHERE declined = 0
GROUP by data
ORDER by total_vendes 
LIMIT 5;

##Exercici 4
#Quina és la mitjana de vendes per país? Presenta els resultats ordenats per la mitjana de major a menor

SELECT country, AVG(amount) as mitjana
FROM transaction left join company
on transaction.company_id= company.id
where declined=0
GROUP BY country
ORDER BY mitjana desc;

##NIVELL 3

#Exercici 3.1
#Presenta el nom, telèfon i país de les companyies, juntament amb la quantitat total de vendes, d'aquelles empreses que van realitzar transaccions amb una venda compresa entre 100 i 200 euros. Ordena els resultats de major a menor quantitat.

SELECT company_name, phone, country, amount
FROM transaction LEFT JOIN company
ON transaction.company_id= company.id
WHERE declined=0 AND amount>=100 AND amount <=200
ORDER BY amount desc;

##Exercici 3.2
#Indica el nom de les companyies que van fer compres el 16 de març del 2022, 28 de febrer del 2022 i 13 de febrer del 2022.
SELECT company_name
FROM transaction LEFT JOIN company 
ON transaction.company_id = company.id
WHERE DATE(timestamp) IN ('2022-03-16', '2022-02-28','2022-02-13');




