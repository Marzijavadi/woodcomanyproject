--گزارشی تهیه کنید که مقدار تولید هر محصول را در بازه های زمانی مشخص و از بیشترین میزان تولید نشان دهد
alter procedure sp_producAmount 
@fdate nchar(10) , @ldate nchar(10) 
as
select dp.[productID],dp.[dateID],dp.[amountPRO],dp.[proPrice],p.name
from dailyProduct as dp 
inner join production as p
on dp.[productID]=p.[productID]
where dp.[dateID] between @fdate and  @ldate
order by dp.[amountPRO] desc 
go

--مقدار فروش هر محصول در بازه های زمانی مشخص از بیشترین میزان تا کمترین میزان فروش
alter procedure sp_productSale
@fdate nchar(10) , @ldate nchar(10)
as
select s.productID , s.dateID , s.fee , s.number ,  [dbo].[production].name
from [dbo].[sales] as s 
inner join [dbo].[production] 
on s.productID = [dbo].[production].productID
where s.dateID between @fdate and @ldate
order by s.number desc 
go 

-- مقدار مصرفی مواد اولیه از بیشترین تا کمترین
alter procedure sp_consumematerial
@fdate nchar(10) , @ldate nchar(10) 
as 
select dp.dateID , dp.[report id] , proi.materialID , 
sum(proi.number) as materialused, mi.name
from [dbo].[dailyProduct] as dp 
inner join productINFO as proi
on dp.productID = proi.productID
inner join [dbo].[materialInfo] as mi
on mi.id= proi.materialID 
where dp.dateID between @fdate and @ldate 
group by proi.materialID , dp.dateID , dp.[report id] , mi.name
order by sum(proi.number) desc 
go

--مقدار خرید محصول از داخل یا خارج کشور و بیشترین تا کمترین میزان خرید از شرکت

alter procedure sp_orderamount
@fdate nchar(10) , @ldate nchar(10) 
as 
select mc.[company id] , mc.name , mc.country ,mc.city ,o.dateID ,
o.number , o.material_id , mi.name
from [dbo].[materialCOMPANY] as mc
inner join [dbo].[orderInfo] as o
on mc.[company id]=o.[companyId]
inner join [dbo].[materialInfo] as mi 
on mi.id = o.material_id
where o.dateID between @fdate and @ldate
order by o.[number] desc 
go

-- سود حاصل از فروش هر محصول 
create view vw_profit
as 
select dp.salePrice - dp.proPrice as profit  , 
dp.productID , s.dateID , p.name
from  [dbo].[dailyProduct] as dp
inner join [dbo].[sales] as s
on s.productID= dp.productID
inner join production as p
on p.productID = s.productID
go

--مقدار مانده از هر کدام از مواد اولیه

 select dp.dateID,proi.materialID , sum(proi.number) as materialused , 
sum(ord.number) as orderdmaterial , sum(ord.number)-sum(proi.number) as rest
from dailyProduct as dp 
inner join productINFO as proi
on dp.productID=proi.productID
inner join orderInfo as ord
on proi.materialID=ord.material_id
group by proi.materialID , dp.dateID , ord.dateID
go

--تاریخ خرید مواد اولیه و مقایسه قیمت آنها
select o.material_id ,  o.dateID , mi.name,
MIN(o.fee) as cheaper , MAX(o.fee) as expensiver 
from orderInfo as o
inner join materialInfo as mi 
on o.material_id= mi.id 
group by o.dateID , o.material_id , mi.name
go
 --ایجاد view بین daily product وproduct info
 create view vw_dailymaterial 
 as
 select SUM(proi.number) as meterialUsed, proi.materialID ,dp.dateID,dp.[report id]
 from dailyProduct as dp inner join 
 productINFO as proi on dp.productID=proi.productID
group by proi.materialID , dp.dateID , dp.[report id]
go
 backup database [wood company]
 to disk='F:\task 2\woodcompany.bak'
