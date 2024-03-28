###SPRINT 2

###NIVELL 1
## Exercici 1.1
#Mostra totes les transaccions realitzades per empreses d'Alemanya.

SELECT *
FROM transaction 
WHERE company_id IN (SELECT  id 
	FROM company 
	WHERE country ='Germany');
    

##Exercici 1.2
#Màrqueting està preparant alguns informes de tancaments de gestió, et demanen que els passis un llistat de les empreses que han realitzat transaccions 
#per una suma superior a la mitjana de totes les transaccions.

SELECT DISTINCT company_name 
FROM transaction LEFT JOIN company
ON transaction.company_id =company.id
WHERE amount > (SELECT AVG(amount)
FROM transaction)
ORDER BY company_name;

SELECT company_name
FROM company
WHERE id IN (SELECT DISTINCT company_id
	FROM transaction
    WHERE amount > (SELECT avg(amount)
    FROM transaction))
ORDER BY company_name;
    
##Exercici 1.3
#El departament de comptabilitat va perdre la informació de les transaccions realitzades per una empresa, però no recorden el seu nom, només recorden que el seu nom iniciava amb 
#la lletra c. Com els pots ajudar? Comenta-ho acompanyant-ho de la informació de les transaccions.

SELECT * 
FROM transaction
WHERE company_id IN (
	SELECT  id
    FROM company
    WHERE company_name like 'C%');

SELECT company.company_name, transaction.id, transaction.credit_card_id, transaction.company_id, transaction.user_id,
	transaction.lat, transaction.longitude, transaction.timestamp, transaction.amount, transaction.declined
FROM transaction LEFT join company
ON transaction.company_id =company.id
WHERE company_name LIKE 'C%';

##Exercici 1.4
#Van eliminar del sistema les empreses que no tenen transaccions registrades, lliura el llistat d'aquestes empreses.

SELECT company_name 
FROM company
WHERE id NOT IN (SELECT company_id
	FROM transaction);
    
###Nivell 2
##Exercici 2.1
#En la teva empresa, es planteja un nou projecte per a llançar algunes campanyes publicitàries per a fer competència a la companyia Non Institute. 
#Per a això, et demanen la llista de totes les transaccions realitzades per empreses que estan situades en el mateix país que aquesta companyia.
SELECT  *
FROM transaction LEFT JOIN company
ON transaction.company_id=company.id 
WHERE country = (SELECT country 
FROM company
WHERE company_name = 'Non Institute');


SELECT *
FROM transaction
WHERE company_id IN ( 
	SELECT id
    FROM company 
    WHERE country = (
		SELECT country
		FROM company
        WHERE company_name = 'Non Institute'));
        
##Exercici 2.2
#El departament de comptabilitat necessita que trobis l'empresa que ha realitzat la transacció de major suma en la base de dades.

SELECT company_name
FROM company
WHERE id IN (SELECT company_id
		FROM transaction
        WHERE amount = (SELECT max(amount)
			FROM transaction));
            
###Nivell 3
##Exercici 3.1
#S'estan establint els objectius de l'empresa per al següent trimestre, per la qual cosa necessiten una base sòlida per a avaluar el rendiment i mesurar 
#l'èxit en els diferents mercats. Per a això, necessiten el llistat dels països la mitjana de transaccions dels quals sigui superior a la mitjana general.

SELECT country
FROM (
	SELECT country, AVG(amount) AS mitjana
    FROM transaction 
    JOIN company 
    ON transaction.company_id = company.id
    GROUP BY country) as mitjana_paisos
WHERE mitjana > (
	SELECT AVG(amount) as mitjana_total
    FROM transaction);
    
##Exercici 3.2
#Necessitem optimitzar l'assignació dels recursos i dependrà de la capacitat operativa que es requereixi, per la qual cosa et demanen la 
#informació sobre la quantitat de transaccions que realitzen les empreses, però el departament de recursos humans és exigent i vol un 
#llistat de les empreses on especifiquis si tenen més de 4 transaccions o menys.

SELECT company_name, 
	CASE
    WHEN transactions_empresa > 4 THEN 'Més de 4 transaccions'
    ELSE 'Menys de 4 transaccions'
    END AS num_transactions
FROM ( SELECT company_name, COUNT(*) as transactions_empresa
	FROM transaction LEFT JOIN company
	ON transaction.company_id = company.id
    GROUP BY company_name) as te
    ORDER BY num_transactions;


