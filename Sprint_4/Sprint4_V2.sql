

### Nivell 1
#Descàrrega els arxius CSV, estudia'ls i dissenya una base de dades amb un esquema d'estrella que contingui, 
#almenys 4 taules de les quals puguis realitzar les següents consultes:


# En primer lloc creem la base de dades:

CREATE DATABASE transactionsS4;

# A continuació creem les taules:

CREATE TABLE companies 
(company_id VARCHAR (15) PRIMARY KEY,
company_name VARCHAR(150),
phone VARCHAR (25),
email VARCHAR (150),
country VARCHAR (150),
website VARCHAR (150)
);

CREATE TABLE credit_cards
(id VARCHAR (20) PRIMARY KEY,
user_id VARCHAR (100),
iban VARCHAR (100) ,
pan VARCHAR (100) ,
pin VARCHAR (100) ,
cvv VARCHAR (100) ,
track1 VARCHAR (100) ,
track2 VARCHAR (100) ,
expiring_date VARCHAR(50)
);


CREATE TABLE products
(id VARCHAR(50) PRIMARY KEY,
product_name VARCHAR (255),
price VARCHAR (20),
colour VARCHAR (50),
weight DECIMAL(8,2),
warehouse_id VARCHAR(50)
);


CREATE TABLE transactions
(id VARCHAR (50) PRIMARY KEY,
card_id VARCHAR(20),
business_id	 VARCHAR(20),
timestamp DATETIME,
amount DECIMAL (10,2),
declined TINYINT(1),
product_ids VARCHAR(50),
user_id VARCHAR(20),
lat FLOAT ,
longitude FLOAT);


CREATE TABLE users
(id VARCHAR(20) PRIMARY KEY,
name VARCHAR (200),
surname VARCHAR(200),
phone VARCHAR(25),
email VARCHAR(150),
birth_date VARCHAR(50),
country VARCHAR (150),
city VARCHAR (150),
postal_code VARCHAR (50),
address VARCHAR (150)
);

#Ara importem les dades de les taules
# he tingut problemes per importar les dades des de csv, he hagut de canviar el secure file per (secure-file-priv = "") per poder importar dades de qualsevol carpeta.

SHOW VARIABLES LIKE 'secure_file_priv';

LOAD DATA
INFILE 'C:/Users/ereth/Desktop/archivosCSV/ITAcademy/sprint4_V2/companies.csv'
INTO TABLE companies
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;


LOAD DATA
INFILE 'C:/Users/ereth/Desktop/archivosCSV/ITAcademy/sprint4_V2/credit_cards.csv'
INTO TABLE credit_cards
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

LOAD DATA
INFILE 'C:/Users/ereth/Desktop/archivosCSV/ITAcademy/sprint4_V2/products.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
IGNORE 1 ROWS;

# En el cas de la taula transactions l'arxiu està separat per '; ' per tant canviem una mica la query:
LOAD DATA
INFILE 'C:/Users/ereth/Desktop/archivosCSV/ITAcademy/sprint4_V2/transactions.csv'
INTO TABLE transactions
FIELDS TERMINATED BY ';'
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

# En el cas de la taula users, tenim tres arxius diferents separats per country els importarem tots a la mateixa taula per que no cal que estiguin separats

LOAD DATA
INFILE 'C:/Users/ereth/Desktop/archivosCSV/ITAcademy/sprint4_V2/users_ca.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA
INFILE 'C:/Users/ereth/Desktop/archivosCSV/ITAcademy/sprint4_V2/users_uk.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


LOAD DATA
INFILE 'C:/Users/ereth/Desktop/archivosCSV/ITAcademy/sprint4_V2/users_usa.csv'
INTO TABLE users
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

#Ara establirem les relacions mitjançant les foreing keys:

ALTER TABLE transactions
ADD CONSTRAINT fk_companies
FOREIGN KEY (business_id) 
REFERENCES companies(company_id),
ADD CONSTRAINT fk_credit_cards
FOREIGN KEY (card_id) 
REFERENCES credit_cards(id),
ADD CONSTRAINT fk_users
FOREIGN KEY (user_id)
REFERENCES users (id);

#No podem fer relació amb la taula products, perque hi ha més d'un id a products_ids, ho solucionarem més endavant en un exercici.

# En el cas de credit_cards tenim les dates en format dd/mm/yy. Canviem a format DATE i posteriorment canviem les dades:


	
UPDATE users
SET birth_date = STR_TO_DATE(birth_date, '%b %d, %Y');

#amb %b %d, %y indiquem el format en que estan les dades, %b es refereix a que el mes està de forma abreujada
#per fer això últim he hagut de desactivar el safe updates de preferències, ja que si no, no puc fer aquest update de totes les línies
    
#Ara si podem posar el tipus de dada:
ALTER TABLE users
MODIFY COLUMN birth_date DATE ;



#El mateix passa amb la taula credit_cards, les dades estan com mes/dia/any i per posar tipus de dada a DATE hem de pasahor a any/mes/dia:
UPDATE credit_cards
SET expiring_date = STR_TO_DATE(expiring_date, '%m/%d/%y');

ALTER TABLE credit_cards
MODIFY COLUMN expiring_date DATE;

# A la taulaproducts la columna'price' te el simbol de dolar l'eliminarem per despres pooderlo categoritzar com decimal i poder fer calculs correctament

UPDATE products
SET price = REPLACE(price, '$', '') # eliminem el signe del dollar
WHERE price LIKE '%$%' ;

ALTER TABLE products
CHANGE COLUMN price price_usd DECIMAL(10,2); #tornem a definir el tipus de dada a "DECIMAL", he aprofitat de canviar el nom a price_usd per recordar que està en dollars.


## Exercici 1.1
#Realitza una subconsulta que mostri tots els usuaris amb més de 30 transaccions utilitzant almenys 2 taules.


SELECT users.name, users.surname
FROM users
WHERE users.id IN (SELECT transactions.user_id
	FROM transactions
    GROUP BY user_id
    HAVING count(*)  >30);
    
    
    
##Exercici 1.2
#Mostra la mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, utilitza almenys 2 taules.

SELECT iban, AVG(amount) 
FROM transactions
LEFT JOIN credit_cards
ON transactions.card_id = credit_cards.id
LEFT JOIN companies
ON transactions.business_id = companies.company_id
WHERE company_name LIKE ('Donec Ltd')
GROUP BY iban;

##Nivell 2
#Crea una nova taula que reflecteixi l'estat de les targetes de crèdit basat en si les últimes tres transaccions van ser declinades i genera la següent consulta:


CREATE TABLE Estado_Tarjetas AS
SELECT
    card_id,
    CASE
        WHEN COUNT(*) < 3 THEN 'Activa'
        WHEN SUM(declined) = 3 THEN 'Inactiva'
        ELSE 'Activa'
    END AS Estado
FROM (
    SELECT
        card_id,
        declined,
        ROW_NUMBER() OVER(PARTITION BY card_id ORDER BY timestamp DESC) AS Rank_Transaccion
    FROM transactions
) AS Transacciones_Ordenadas
WHERE Rank_Transaccion <= 3
GROUP BY card_id;






#Exercici 2.1
#Quantes targetes estan actives?

SELECT COUNT(*) AS Tarjetas_activas
FROM Estado_tarjetas 
WHERE Estado = 'Activa';


###Nivell 3
#Crea una taula amb la qual puguem unir les dades del nou arxiu products.csv amb la base de dades creada, tenint en compte que des de transaction tens product_ids. Genera la següent consulta:





CREATE TABLE transaction_products (
    transaction_id VARCHAR(40),
    product_id VARCHAR(50),
    PRIMARY KEY (transaction_id, product_id),
    FOREIGN KEY (transaction_id) REFERENCES transactions(id),
    FOREIGN KEY (product_id) REFERENCES products(id));

#Ara importarem les dades de id de transacció i id del producte a aquesta taula, per fer-ho hem de dividir les dades de "products_ids)

INSERT INTO transaction_products (transaction_id, product_id)
SELECT transactions.id, products.id
FROM transactions
JOIN products ON FIND_IN_SET(products.id, REPLACE(transactions.product_ids, ', ', ','));


##Exercici 1
#Necessitem conèixer el nombre de vegades que s'ha venut cada producte.

SELECT products.id, products.product_name, Count(transaction_id) as num_ventes
FROM transactions LEFT JOIN transaction_products
ON transaction_products.transaction_id = transactions.id
LEFT JOIN products 
ON transaction_products.product_id=products.id
WHERE transactions.declined = 0
GROUP BY products.id, product_name
ORDER BY num_ventes desc
;




