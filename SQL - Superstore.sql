-- 1. Menampilkan data Superstore
select *
from superstore;
-- Deskripsi data Superstore
desc superstore;
-- Mencari tahu apakah ada data NULL
select * 
from superstore
where OrderDate is null
	or OrderID is null
    or CustomerID is null
    or ProductID
    or Market is null 
    or OrderPriority is null
    or ShipMode is null;

-- 1.1 Menampilkan banyaknya customer yang melakukan transaksi setiap tahunnya
select year(OrderDate) Year, count(distinct CustomerID) TotalCustomer
from superstore
group by Year;
-- Menampilkan daftar Customer ID yang melakukan setidaknya satu kali transaksi setiap tahunnya
with t1 as (
	select CustomerID, count(distinct month(OrderDate)) as Month
    from superstore
    where year(OrderDate) = 2011
    group by CustomerID, year(OrderDate)
	having count(distinct month(OrderDate)) >= 1
), t2 as (
	select CustomerID,count(distinct month(OrderDate)) as Month
    from superstore
    where year(OrderDate) = 2012
    group by CustomerID, year(OrderDate)
	having count(distinct month(OrderDate)) >= 1
), t3 as (
	select CustomerID, count(distinct month(OrderDate)) as Month
    from superstore
    where year(OrderDate) = 2013
    group by CustomerID, year(OrderDate)
	having count(distinct month(OrderDate)) >= 1
), t4 as (
	select CustomerID, count(distinct month(OrderDate)) as Month
    from superstore
    where year(OrderDate) = 2014
    group by CustomerID, year(OrderDate)
	having count(distinct month(OrderDate)) >= 1
) select t1.CustomerID LoyalCustomerID
from ((t1 inner join t2 on t1.CustomerID = t2.CustomerID)
		  inner join t3 on t1.CustomerID = t3.CustomerID)
		  inner join t4 on t1.CustomerID = t4.CustomerID;
-- Menampilkan banyaknya Customer ID yang melakukan setidaknya satu kali transaksi setiap tahunnya
with t1 as (
	select CustomerID, count(distinct month(OrderDate)) as Month
    from superstore
    where year(OrderDate) = 2011
    group by CustomerID, year(OrderDate)
	having count(distinct month(OrderDate)) >= 1
), t2 as (
	select CustomerID,count(distinct month(OrderDate)) as Month
    from superstore
    where year(OrderDate) = 2012
    group by CustomerID, year(OrderDate)
	having count(distinct month(OrderDate)) >= 1
), t3 as (
	select CustomerID, count(distinct month(OrderDate)) as Month
    from superstore
    where year(OrderDate) = 2013
    group by CustomerID, year(OrderDate)
	having count(distinct month(OrderDate)) >= 1
), t4 as (
	select CustomerID, count(distinct month(OrderDate)) as Month
    from superstore
    where year(OrderDate) = 2014
    group by CustomerID, year(OrderDate)
	having count(distinct month(OrderDate)) >= 1
) select count(*) TotalLoyalCustomer
from ((t1 inner join t2 on t1.CustomerID = t2.CustomerID)
		  inner join t3 on t1.CustomerID = t3.CustomerID)
		  inner join t4 on t1.CustomerID = t4.CustomerID;

-- 1.3 Menampilkan banyaknya customer yang berbelanja di masing-masing jenis pasar
select Market, count(distinct CustomerID) TotalCustomer
from superstore
group by Market;

-- 1.4 Menampilkan banyaknya customer sesuai dengan kombinasi prioritas pesanan dan jenis pengiriman 
select OrderPriority, ShipMode, count(distinct CustomerID) TotalCustomer
from superstore
group by OrderPriority, ShipMode
order by OrderPriority, ShipMode asc;

-- -----------------------------------------------------------------------------------------------
-- 2. Menampilkan data Customer
select *
from customer;
-- Deskripsi data Customer
desc customer;
-- Mencari tahu apakah ada NULL
select * 
from customer
where Segment is null
    or Country is null
    or Region is null;

-- -----------------------------------------------------------------------------------------------
-- 3. Menampilkan data Product
-- Menampilkan data Product
select *
from product;
-- Deskripsi data Customer
desc product;
-- Mencari tahu apakah ada NULL
select * 
from product
where Category is null
    or SubCategory is null
    or Quantity is null
    or Sales is null
    or Profit is null;

-- -----------------------------------------------------------------------------------------------
-- 4. Menggabungkan data
create table sps as
select s.OrderDate, s.OrderID, s.CustomerID, s.ProductID, s.Market, s.OrderPriority, s.ShipMode, 
	c.Segment, c.Country, c.Region, 
    p.Category, p.SubCategory, p.Quantity, p.Sales, p.Profit
from superstore s
left join customer c on (s.CustomerID = c.CustomerID)
left join product p on (s.ProductID = p.ProductID);
-- Mengecek jumlah baris data SPS
select count(*) from sps;
-- Memanggil data hasil penggabungan
select *
from sps;
-- Mengecek apakah ada NULL pada data
select * 
from sps
where OrderDate is null
	or OrderID is null
    or CustomerID is null
    or ProductID is null
    or Market is null 
    or OrderPriority is null
    or ShipMode is null
    or Category is null
    or SubCategory is null
    or Quantity is null
    or Sales is null
    or Profit is null
    or Segment is null
    or Country is null
    or Region is null;

-- 4.1 Berapa total penjualan, profit, barang terjual, dan margin profit?
select sum(Sales) TotalSales,
	cast(sum(Profit) as decimal) TotalProfit, 
    sum(Quantity) TotalQuantity, 
    concat(cast(sum(Profit)/sum(Sales)*100 as decimal), '%') MarginProfit
from sps;

-- 4.2 Berapa total penjualan berdasarkan jenis pasar (Market)?
select Market, sum(Sales) TotalSales
from sps
group by Market
order by TotalSales desc;

-- 4.3 Berapa total penjualan berdasarkan Region?
select Region, sum(Sales) TotalSales
from sps
group by Region
order by sum(Sales) desc;

-- 4.4 Ada berapa banyak negara yang termasuk ke dalam region dengan total penjualan terbanyak?
-- Telah diketahui bahwa region dengan total penjualan terbanyak adala Central, sehingga pertanyaan 4.5 dapat dijawab dengan:
select count(distinct Country) TotalCountry
from sps
where Region = 'Central';

-- 4.5 Negara apa yang memberikan total penjualan terbesar dari setiap region?
-- Perlu dicari tahu terlebih dahulu ada berapa banyak region
select count(distinct Region) TotalRegion
from sps;
-- Setelah itu, pertanyaan 4.5 dapat dijawab dengan:
select row_number() over(partition by Region) as RowNum, Region, Country, TotalSales
from (
	select Region, Country, max(summ) TotalSales
	from (
		select Region, Country, sum(Sales) summ
		from sps
		group by Region, Country
	) as ts1
    group by Region, Country
    order by Region, TotalSales desc
) as ts2
order by RowNum asc limit 13;

-- 4.6 Bagaimana kontribusi kelompok konsumen terhadap hasil penjualan? Sajikan dalam bentuk persentase dengan dua angka di belakang koma.
select Segment, sum(Sales) TotalSales, concat(cast((sum(Sales)/(select sum(Sales) from sps)*100) as decimal (16,2)), '%') Percentage
from sps
group by Segment
order by TotalSales;

-- 4.7 Apakah terjadi kenaikan terhadap total banyaknya produk yang terjual di tahun 2013 ke tahun 2014?
with prod13 as (
	select Category, sum(Quantity) TotalQuantity13
    from sps
    where year(OrderDate) = 2013
    group by Category
), prod14 as (
	select Category, sum(Quantity) TotalQuantity14
    from sps
    where year(OrderDate) = 2014
    group by Category
) select prod13.Category,
	prod13.TotalQuantity13,
    prod14.TotalQuantity14, 
    concat(cast(((prod14.TotalQuantity14-prod13.TotalQuantity13)/prod13.TotalQuantity13*100) as decimal), '%') Increment
from prod13
left join prod14 on prod13.Category = prod14.Category
order by Increment desc;

/* cara lain apabila diketahui kategori produk pada salah satu atau kedua tabel tidak lengkap
with prod13 as (
	select Category, sum(Quantity) TotalQuantity13
    from sps
    where year(OrderDate) = 2013
    group by Category
), prod14 as (
	select Category, sum(Quantity) TotalQuantity14
    from sps
    where year(OrderDate) = 2014
    group by Category
), cat as(
select distinct Category
from sps
) select cat.Category,
	prod13.TotalQuantity13,
    prod14.TotalQuantity14, 
    prod14.TotalQuantity14-prod13.TotalQuantity13 Difference
from cat
left join prod13 on cat.Category = prod13.Category
left join prod14 on cat.Category = prod14.Category;
*/

-- 4.8 Negara apa yang mengalami paling banyak kerugian profit di region Southeast Asia?
select Country, count(prof) Count
from (
	select Country, sum(Profit) prof
    from sps
    group by year(OrderDate), month(OrderDate), Region, Country
    having
    prof < 0 and 
    Region = 'Southeast Asia'
) as tabs
group by Country
order by Count desc limit 1;