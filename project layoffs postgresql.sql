-- buat table
create table layoffs (
id int generated always as identity primary key,
company varchar(150),
location varchar(250),
industry varchar(150),
total_laid_off int,
percentage_laid_off float,
date varchar(150),
stage varchar(150),
country varchar(150),
funds_raised_millions int
)

-- ubah tipe kolom
--1. total laid off
select count(total_laid_off)
from layoffs
where total_laid_off !~ '^\d+$';

update layoffs
set total_laid_off = NULL
where total_laid_off = 'NULL';

select total_laid_off
from layoffs
where total_laid_off is null;

alter table layoffs
alter column total_laid_off type integer
USING total_laid_off::integer;

--2. percentage_laid_off
select count(percentage_laid_off)
from layoffs
where percentage_laid_off = 'NULL';

update layoffs
set percentage_laid_off = NULL
where percentage_laid_off = 'NULL';

alter table layoffs
alter column percentage_laid_off
type decimal(5, 2)
using percentage_laid_off::decimal(5, 2);

--3. date
alter table layoffs
rename column "date" to date_laid_off;

select date_laid_off, id
from layoffs
where date_laid_off = 'NULL';

select date_laid_off
from layoffs;

update layoffs
set date_laid_off = '2/15/2023'
where id = 2357;

alter table layoffs
alter column date_laid_off 
type date
using to_date(date_laid_off, 'MM/DD/YY');

-- 4. funds_raised_millions
select count(funds_raised_millions)
from layoffs
where funds_raised_millions = 'NULL';

select *
from layoffs;

update layoffs
set funds_raised_millions = NULL
where funds_raised_millions = 'NULL';

alter table layoffs
alter column funds_raised_millions
type decimal(9, 2)
using funds_raised_millions::decimal(9, 2);

-------------------------------------------
---data profiling--------------------------
--1. overview
select * from layoffs
limit 5;

select * from information_schema.columns
where table_name = 'layoffs';

--2. data Null
select company
from layoffs
where company = 'NULL';

select industry, id
from layoffs
where industry = 'NULL';

select stage, id
from layoffs
where stage = 'NULL';

select country, id
from layoffs
where country = 'NULL';

--3. cek data kategorikal
select industry, count(industry) as jumlah
from layoffs
group by industry
order by jumlah DESC;

select location, count(location) as jumlah
from layoffs
group by location
order by jumlah DESC;

select stage, count(stage) as jumlah
from layoffs
group by stage
order by jumlah DESC;

select country, count(country) as jumlah
from layoffs
group by country
order by jumlah DESC;

--4. cek persebaran tipe data numerik
select
count(total_laid_off) as jumlah_PHK,
sum(total_laid_off) as total_terdampak_PHK,
avg(total_laid_off) as rata_rata_PHK,
max(total_laid_off) as phk_tertinggi,
min(total_laid_off) as phk_terendah,
STDDEV(total_laid_off) as standar_deviasi,
percentile_cont(0.25) within group (order by total_laid_off) as q1,
percentile_cont(0.50) within group (order by total_laid_off) as q2_median,
percentile_cont(0.75) within group (order by total_laid_off) as q3
from layoffs;

select
count(funds_raised_millions) as jumlah_investasi,
sum(funds_raised_millions) as total_investasi,
avg(funds_raised_millions) as rata_rata_investasi,
max(funds_raised_millions) as investasi_tertinggi,
min(funds_raised_millions) as investasi_terendah,
STDDEV(funds_raised_millions) as standar_deviasi,
percentile_cont(0.25) within group (order by funds_raised_millions) as q1,
percentile_cont(0.50) within group (order by funds_raised_millions) as q2_median,
percentile_cont(0.75) within group (order by funds_raised_millions) as q3
from layoffs;

-------------------------------------------
-- memulai data cleaning ------------------
-- 1. industry
update layoffs
set industry = NULL
where id = 331;

select id, company, industry
from layoffs
where industry is NULL
order by id;

/* dari sini, ada 4 perusahaan dengan industry null, saya mengasumsikan bahwa
"Juul" = Consumer
"Carvana" = Transportation
"Airbnb" = Travel
"Bally's Interactive" = Other
*/

update layoffs
set industry =
case
when id = 9 then 'Travel'
when id = 331 then 'Other'
when id = 737 then 'Consumer'
when id = 1596 then 'Transportation'
else industry
end
where id in (9, 331, 737, 1596);

select id, company, industry
from layoffs
where industry in ('Crypto Currency', 'CryptoCurrency');

update layoffs
set industry = case
when id = 1259 then 'Crypto'
when id = 1273 then 'Crypto'
when id = 902 then 'Crypto'
else industry
end
where id in (1273, 902, 1259);

--
select *
from information_schema.columns
where table_name = 'layoffs';

--2. stage
update layoffs
set stage = NULL
where stage = 'NULL';

------------------------------------
-- bagian analisis -----------------
---1. basic
select country, sum(total_laid_off) as jumlah_phk
from layoffs
group by country
having sum(total_laid_off) is not null
order by jumlah_phk desc;

select industry, sum(total_laid_off) as jumlah_phk
from layoffs
group by industry
having sum(total_laid_off) is not null
order by jumlah_phk desc;

select
stage,
sum(total_laid_off) as jumlah_phk
from layoffs
group by stage
order by jumlah_phk desc;

select
id, stage, company
from layoffs
where stage is null;

---2. intermediate
select sum(total_laid_off), extract(YEAR from date_laid_off) as tahun
from layoffs
group by extract(YEAR from date_laid_off)
having extract(YEAR from date_laid_off) in (2023, 2022, 2021, 2020)
;

select distinct(extract(YEAR from date_laid_off))
from layoffs;

select 
sum(total_laid_off),
extract(month from date_laid_off) as bulan,
extract(year from date_laid_off) as tahun
from layoffs
group by extract(month from date_laid_off), extract(year from date_laid_off)
order by tahun desc, bulan desc;

-- ini sama saja cuma bawah pakai cte
select 
avg(total_laid_off), avg(funds_raised_millions),
case
when funds_raised_millions between 0 and 300 then 'small'
when funds_raised_millions between 301 and 800 then 'medium'
when funds_raised_millions > 800 then 'big'
else 'unknown'
end as category
from layoffs
where total_laid_off is not null
group by category;

with kategori as (select 
total_laid_off, funds_raised_millions,
case
when funds_raised_millions between 0 and 300 then 'small'
when funds_raised_millions between 301 and 800 then 'medium'
when funds_raised_millions > 800 then 'big'
else 'unknown'
end as category
from layoffs)
select avg(total_laid_off), avg(funds_raised_millions), category
from kategori
where total_laid_off is not null
group by category
order by category desc;
----- end

-- 3. advanced
-- 3.1 Perusahaan yang PHK-nya Di Atas Rata-rata Dataset
WITH rata AS (
SELECT
company,
total_laid_off,
AVG(total_laid_off) OVER () AS rerata
FROM layoffs
)
SELECT
company,
total_laid_off
FROM rata
WHERE total_laid_off > rerata;

select 
company,
total_laid_off
from layoffs
where total_laid_off > (select avg(total_laid_off) from layoffs);

-- 3.2 Negara yang Kontribusinya di Atas Rata-rata
with kontribusi as (
select 
country,
sum(total_laid_off) as totalan
from layoffs
group by country)
select *
from kontribusi
where totalan > (select avg(total_laid_off) from layoffs);

-- 3.3 Kategori Dana Pendanaan dan Dampaknya terhadap PHK
with dampak as (
select
stage,
sum(total_laid_off),
case
when sum(total_laid_off) between 0 and 4000 then 'rendah'
when sum(total_laid_off) between 4001 and 10000 then 'medium'
when sum(total_laid_off) > 10000 then 'tinggi'
else 'unknown'
end
from layoffs
group by stage)
select * from dampak;


select
stage,
sum(total_laid_off),
case
when sum(total_laid_off) between 0 and 4000 then 'rendah'
when sum(total_laid_off) between 4001 and 10000 then 'medium'
when sum(total_laid_off) > 10000 then 'tinggi'
else 'unknown'
end as kategori
from layoffs
group by stage;

--3.3 Ranking Perusahaan Berdasarkan Jumlah PHK
select 
company,
industry,
total_laid_off,
rank() over(partition by industry order by total_laid_off desc) as urutan
from layoffs
where total_laid_off is not null;

-- 3.4 Running Total PHK per Bulan
select
    date_trunc('month', date_laid_off)::date as bulan_tahun,
    sum(total_laid_off) as phk_bulanan,
    sum(sum(total_laid_off)) over(order by date_trunc('month', date_laid_off)) as running_total
from layoffs
where total_laid_off is not null and date_laid_off is not null
group by date_trunc('month', date_laid_off)
order by bulan_tahun;

--3.5 Persentase Kontribusi Tiap Negara terhadap Total PHK
select
country,
sum(total_laid_off) as jumlah_phk,
round(sum(total_laid_off)* 100 / sum(sum(total_laid_off)) over(), 2)
from layoffs
group by country
having sum(total_laid_off) is not null ;

-- 3.6 Membandingkan PHK Perusahaan dengan Rata-rata Industrinya
with tabel_sementara as (
select
company,
total_laid_off,
industry,
avg(total_laid_off) over(partition by industry) as rata_rata
from layoffs
where total_laid_off is not null)
select *,
case
when total_laid_off < rata_rata then 'normal'
when total_laid_off > rata_rata then 'too big'
else 'unknown'
end
from tabel_sementara;
)

-- 3.7 Selisih PHK Perusahaan terhadap Rata-rata Negara
with tabel_s as (
select
company,
total_laid_off,
country,
avg(total_laid_off) over(partition by country) as rata_rata
from layoffs
where total_laid_off is not null
)
select *,
total_laid_off - rata_rata as selisih
from tabel_s;

select * from layoffs;