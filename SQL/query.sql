Affordable and Clean energy
Query 1

-- QUERY_1: TOP CINQUE PAESI PER PRODUZIONE DI ENERGIA RINNOVABILE NEL 2000 E CONFRONTO CON 2019.
--Con questa CTE creo una tabella temporanea contenenti i paesi che nel 2000 erano leader nella produzione di energie rinnovabili.
with 
best_e_ren_2000 as (
select 
	entity,
	geographical_area,
	"year",
	e_renewables,
	e_fossil,
	renewable_final_consumption,
-- Con row_number assegno ad ogni riga un numero progressivo  e con order by desc vado
--ad ordinare dal valore più grande al più piccolo creando una classifica per l'anno 2000.
	row_number () over ( order by e_renewables desc) as  ranking_2000
from sql.global_data
where "year" = 2000 and e_renewables is not null 
),
--Con questa CTE creo una tabella temporanea contenenti i paesi che nel 2019 erano leader nella produzione di energie rinnovabili.
best_e_ren_2019 as (
select 
	entity,
	geographical_area,
	"year",
	e_renewables,
	e_fossil,
	renewable_final_consumption,
-- Con row_number assegno ad ogni riga un numero progressivo  e con order by desc vado
--ad ordinare dal valore più grande al più piccolo creando una classifica per l'anno 2019.
	row_number () over ( order by e_renewables desc) as  ranking_2019
from sql.global_data
where "year" = 2019 and e_renewables is not null 
)
-- selezionare le colonne  riguardanti la situazione energetica da entrambe le CTE per metterle a confronto.
select 
	b19.entity,
	b00.e_renewables as e_renewables_2000,
	b19.e_renewables as e_renewables_2019,
	b00.e_fossil as e_fossil_2000,
	b19.e_fossil as e_fossil_2019,
	b00.renewable_final_consumption as renewable_final_consumption_2000,
	b19.renewable_final_consumption as renewable_final_consumption_2019,
	b00.ranking_2000,
	b19.ranking_2019
from best_e_ren_2019 as b19
-- join tra le due CTE per mettere a confronto i paesi che compaiono in entrambi gli anni considerati.
inner join best_e_ren_2000 as b00
		on b19.entity = b00.entity
where b19.ranking_2019 <= 5
–ordino per anno e poi per pos.in classifica così da mostrare i paesi in ordine di performance decrescente nelle energie rinnovabili.
order by b19."year", b19.ranking_2019;


Query 2
--QUERY_2:RANKING DELLE AREE GEOGRAFICHE PER PRODUZIONE DI ENERGIA RINNOVABILE (2020)
--CTE media Electricity from renewables per area geografica.
with media_geographical_area as (
    select
       	geographical_area,
	count(entity) as country_for_area,
--Calcolo la media di e_renewable e inserisco round per avere solo due decimali nell'output
       	 round(avg(e_renewables)::numeric, 2) as avg_area
    from sql.global_data
    where "year" = 2020
--Raggruppando per geographical_area trovo la media per ogni macro area.
    group by geographical_area
),
-- CTE media mondiale di e_renewable per poterle confrontare.
world_avg_er as (
    select
--Inserisco round per poter avere solo due decimali nell'output e calcolo la media mondiale. 
        round(avg(e_renewables)::numeric, 2) as avg_world
    from sql.global_data
    where "year" = 2020
),
--CTE che seleziona le prime cinque aree con avg_area più alta (migliori).
best as (       
select
--Assegno un numero progressivo, ordinato per avg_area decrescente.
row_number () over (order by avg_area desc) as position_ranking,
*,
--Differenza tra la media della macroarea e la media mondiale 
avg_area - avg_world as avg_diff,
-- Vado ad etichettare il risultato,"best" per chi ha la media uguale o al di sopra di quella –mondiale e
--"worst" per le macro aree al di sotto della media.
Case
when avg_area >= avg_world then 'best'
when avg_area < avg_world then 'worst'
end as classification
from media_geographical_area
--Uso una cross join che mi produce una riga contenente la media mondiale ripetuta per ogni area.
cross join world_avg_er
--Ordino i risultati in maniera decrescente così da ordinare dal migliore al peggiore.
order by avg_area desc 
--Limito il risultato ai primi cinque record e trovo le cinque area con la media per area più alta.
limit 5),

--CTE che seleziona le prime cinque aree con avg_area più basso (peggiori)
worst as(
select 
--assegno un numero progressivo ordinato per avg_area ascendente 
row_number () over (order by avg_area asc) as position_ranking,
*,
--Differenza tra la media della macroarea e la media mondiale 
round((avg_area - avg_world)::numeric, 2) as avg_diff,
-- Vado ad etichettare il risultato,"best" per chi ha la media uguale o al di sopra di quella –mondiale e
--"worst" per le macro aree al di sotto della media.
Case
when avg_area >=  avg_world then 'best'
when avg_area < avg_world then 'worst'
end as classification
from media_geographical_area
--Uso una cross join che mi produce una riga contenente la media mondiale ripetuta per ogni area.
cross join world_avg_er
--Ordino i risultati in maniera ascendente così da ordinare dal peggiore al migliore.
order by avg_area asc 
--Limito il risultato ai primi cinque record e trovo le cinque area con la media per area più bassa.
limit 5)
--Seleziono tutte le colonne della cte best.
select *
from best
--Unisco i risultati delle due cte best e worst.
union all
--Seleziono tutte le colonne della cte worst.
select *
from worst;


Climate action
Query 3
--QUERY_3: VARIAZIONE DELLE EMISSIONI DI CO2 E FONTI ENERGETICHE (2000-2019).
--CTE per selezionare i dati della situazione del 2000.
with situazione_2000 as(
select 
	entity,
	geographical_area,
	"year",
	co2_emissions,
	e_fossil,
	e_nuclear,
	e_renewables
from sql.global_data
where "year" = 2000 and co2_emissions is not null
--ordina in ordine decrescente di emissioni di co2 
order by co2_emissions desc
--seleziono solo i primi cinque risultati.
limit 5
),
--CTE per selezionare i dati della situazione del 2019.
situazione_2019 as(
select
	entity,
	"year",
	co2_emissions,
	e_fossil,
	e_nuclear,
	e_renewables
from sql.global_data
where "year" = 2019 and co2_emissions is not null
)
--Query principale che mette a confronto i dati del 2000 con quelli del 2019.
select 
	s_00.entity,
	s_00.geographical_area,
	s_00.co2_emissions as co2_emissions_2000,
	s_19.co2_emissions as co2_emissions_2019,
	s_00.e_fossil as e_fossil_2000,
	s_19.e_fossil as e_fossil_2019,
	s_00.e_nuclear as e_nuclear_2000,
            s_19.e_nuclear as e_nuclear_2019,
	s_00.e_renewables as e_renewables_2000,
	s_19.e_renewables as e_renewables_2019,
--Calcolo la variazione delle emissioni di co2 (2019-2000)
    s_19.co2_emissions - s_00.co2_emissions as co2_variation
from situazione_2000 as s_00
--Left join per associare i dati del 2019 ai primi paesi del 2000.
left join situazione_2019 as s_19
	on s_00.entity = s_19.entity 
--Ordino il risultato per variazione delle emissioni di co2 dal maggiore incremento al minore.
order by  co2_variation desc;

Query 4

--QUERY_4: RIDURRE LE EMISSIONI: I PAESI CHE HANNO FATTO LA DIFFERENZA (2000-2019).
--CTE emissioni anno 2000
with emissions_2000 as (
select
	entity,
	geographical_area,
	"year",
--Rinomino per indicare il valore iniziale di emissioni(2000)
	co2_emissions as co2_2000
from sql.global_data
where "year" = 2000  and co2_emissions is not null
),
--CTE emissioni anno 2019.
emissions_2019 as(
select
	entity,
	geographical_area,
	"year",
--Rinomino per indicare il valore finale di emissioni(2019)
	co2_emissions as co2_2019
from sql.global_data
where "year" = 2019  and co2_emissions is not null 
)
--Query principale: seleziono le colonne di mio interesse da entrambe le cte.
select
	e_2000.entity,
	e_2000.geographical_area,
	e_2000.co2_2000,
	e_2019.co2_2019,
--Calcolo la variazione percentuale delle emissioni tra il 2000 e il 2019.
	round ((e_2019.co2_2019 - e_2000.co2_2000 ) / e_2000.co2_2000 * 100, 2)  as "%_var",
--Calcolo la differenza assoluta delle emissioni 2019 e 2000.
	 e_2019.co2_2019 - e_2000.co2_2000 as absolute_var
from emissions_2000 as e_2000
--Con la left join metto a confronto le emissioni del 2000 e del 2019 per ciascun paese.
left join emissions_2019 as e_2019 
	on e_2000.entity = e_2019.entity
--Ordino per difference asc: i paesi che hanno ridotto maggiormente le emissioni appariranno per primi.
order by absolute_var asc 
--Limito il risultato ai primi dieci record.
limit 10;


Reduced inequalities
Query 5
--QUERY_5: ANALISI COMPARATIVA DEGLI ESTREMI DI MORTALITA' INFANTILE E DELLE VARIABILI SOCIO-ECONOMICHE CORRELATE (2023).
--CTE i primi cinque paesi con la mortalità infantile più alta.
with highest_mortality as(
select
--Creo una classifica con ordinamento decrescente
	row_number() over (order by infant_mortality DESC) AS rank_, 
	country,
	geographical_area,
	round(infant_mortality::numeric,2) as i_mortality,
--Calcolo la media di mortalità infantile mondiale
	round((avg(infant_mortality) over ())::numeric, 2) as avg_i_mortality_world,
	gdp,
--Calcolo la media mondiale del pil.
	round((avg(gdp) over ())::numeric, 0) as avg_gdp_world,
	physicians_thousand as physicians,
--Calcolo la media mondiale di medici ogni mille abitanti.
	round((avg(physicians_thousand) over ())::numeric,2) as avg_physicians_world,
	tertiary_education,
-- Calcolo la media mondiale di istruzione terziaria.
	round((avg(tertiary_education) over ())::numeric,2) as avg_t_education_world
	from sql.world_data
where infant_mortality is not null
--Ordino dal valore più alto al più basso per mortalità infantile.
order by infant_mortality desc
limit 5),
--CTE i primi cinque paesi con la mortalità più bassa.
lowest_mortality as (	
select
--Creo una classifica ordinamento crescente
	row_number() over (order by infant_mortality asc) AS rank_,
	country,
	geographical_area,
	round(infant_mortality, 2) as i_mortality,
--Calcolo la media mondiale di mortalità infantile..
	round((avg(infant_mortality) over ())::numeric, 2) as avg_i_mortality_world,
	gdp,
- Calcolo la media mondiale del pil.
	round((avg(gdp) over ())::numeric,0) as avg_gdp_world,
	physicians_thousand as physicians,
--Calcolo la media mondiale di medici ogni mille abitanti.
	round((avg(physicians_thousand) over ())::numeric, 2) as avg_physicians_world,
	tertiary_education,
-- Calcolo la media mondiale di istruzione terziaria.
	round((avg(tertiary_education) over ())::numeric, 2) as avg_t_education_world
from sql.world_data
where infant_mortality is not null
--Ordino dal valore più basso al più alto per mortalità infantile.
order by infant_mortality asc
limit 5)
--Restituisce i cinque paesi peggiori.
select * from highest_mortality
--Unione dei due insiemi.
union all
--Restituisce i cinque paesi migliori.
select * from lowest_mortality;


		

Decent work and economic growth

Query 6

--QUERY_6: ANALISI COMPARATIVA GLOBALE DI DISOCCUPAZIONE, POVERTA' LAVORATIVA E INDICATORI ECONOMICI (2023).

--CTE sql.world_data
with unemployment as (
select 
	country,
	geographical_area,
	labor_force_participation,
	unemployment_rate,
--trovo la media della del tasso di disoccupazione mondiale al 2023 e lo riporto per ogni 
--record della mia colonna
	avg(unemployment_rate) over() as avg_world_unemployment,
	gdp
from sql.world_data
where labor_force_participation is not null and unemployment_rate is not null
),

--CTE sql.working_poor 
poor as(
select 
	ref_area,
	working_poverty_rate,
--trovo la media del tasso di povertà lavorativa e lo riporto per
--ogni record della mia colonna così da poter confrontare il tasso specifico del paese
--con la media mondiale
	avg(working_poverty_rate) over () as avg_w_poverty
from sql.working_poor
)
--select principale seleziono le colonne di mio interesse da entrambe le cte.
select
	u.country,
	u.geographical_area,
	u.labor_force_participation,
	u.unemployment_rate,
	round(u.avg_world_unemployment, 2) as avg_world_unemployment,
	u.gdp,
	round(p.working_poverty_rate, 2) as working_poverty_rate,
	round(p.avg_w_poverty, 2) as avg_w_poverty
from unemployment as u
--eseguo una left join per poter mettere le due tabelle a confronto.
left join poor as p 
	on  lower (u.country) = lower (p.ref_area)
where p.working_poverty_rate is not null and p.avg_w_poverty is not null 
-- ordino per tasso di disoccupazione ascendente così da poter trovare la lista dei
-- primi 5 paesi con il tasso di disoccupazione più basso a livello mondiale
order by u.unemployment_rate asc
limit 5




	
	





