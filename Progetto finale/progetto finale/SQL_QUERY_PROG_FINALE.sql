-- Prima query per verificare che i risultati siano stati caricati correttamente
select * 
from progetto.scienza
limit 10;

-- Controllo del numero totale di righe  presenti nel dataset
select count(*) as total_row
from progetto.scienza;

-- Controllo se nel dataset sono presenti valori null
select 
    count(*), 
    count(read_date),
	count (user_uuid),
	count (category),
    count(journalist_id), 
    count(language),
    count(length),
    count(country),
    count(subscription_date),
    count(platform), 
    count(article_id),
    count(stars) 
FROM progetto.scienza;

-- Controllo valori anomali nei punteggi
select *
from progetto.scienza
where stars < 1 or stars > 5;


-- Controllo valori non validi nella colonna length
select *
from progetto.scienza
where length not in ('short', 'medium', 'long');

-- Controllo coerenza temporale
select *
from progetto.scienza
where read_date < subscription_date;

-- Controllo paesi
select distinct country
from progetto.scienza
order by country;

-- Controllo duplicati esatti
select
    read_date,
    user_uuid,
    article_id,
    count(*) as occurrences
from progetto.scienza
group by read_date, user_uuid, article_id
having count(*) > 1;

-- Controllo piattaforme
select distinct platform
from progetto.scienza
order by platform;