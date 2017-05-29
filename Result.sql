-- Использование Alter Scripts Создайте 2 sql-скрипта, которые выполняют обновление базы по версиям: 
-- • 1.0 -> 1.1 • 1.1 -> 1.3 При выполнении задания добиться того, чтобы скрипты можно было накатывать многократно 
-- (например, для случая ошибочного повторного обновления) без ошибок.

-- First
IF NOT EXISTS (SELECT * FROM sys.objects 
	WHERE object_id = OBJECT_ID(N'[dbo].[Card]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[Card]
(
	[Id] INT NOT NULL PRIMARY KEY, 
    [CardNumber] INT NOT NULL, 
    [ExpireDate] DATE NOT NULL, 
    [CardHolder] NVARCHAR(50) NOT NULL, 
    [CustomerId] NCHAR(5) NOT NULL, 
    CONSTRAINT [FK_Card_ToCustomers] FOREIGN KEY ([CustomerID]) REFERENCES [Customers]([CustomerID])
)
END

GO

-- Second
IF EXISTS (SELECT * FROM sys.objects 
	WHERE object_id = OBJECT_ID(N'[dbo].[Region]') AND type in (N'U'))
BEGIN
	IF EXISTS (SELECT * FROM sysobjects WHERE name = 'FK_Territories_Region')
	BEGIN
	  ALTER TABLE [FK_Territories_Regions]
	  DROP CONSTRAINT FK_Territories_Region
	END

	IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'Regions')
	BEGIN
	CREATE TABLE Regions (
    [RegionID]          INT        NOT NULL,
    [RegionDescription] NCHAR (50) NOT NULL,
    CONSTRAINT [PK_Regions] PRIMARY KEY NONCLUSTERED ([RegionID] ASC))
	END

	IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'FK_Territories_Regions')
	BEGIN
	ALTER TABLE [dbo].[Territories] WITH NOCHECK
    ADD CONSTRAINT [FK_Territories_Regions] FOREIGN KEY ([RegionID]) REFERENCES [dbo].[Regions] ([RegionID]);
	END

	BEGIN
	ALTER TABLE [dbo].[Territories] WITH CHECK CHECK CONSTRAINT [FK_Territories_Regions];
	END

	IF EXISTS (SELECT * FROM sysobjects WHERE name = 'Region')
	BEGIN
	EXECUTE sp_rename'Region', 'Regions'
	END

END


IF NOT EXISTS (SELECT * FROM sysobjects WHERE name = 'FoundationDate')
BEGIN
ALTER TABLE [dbo].[Customers]
	ADD FoundationDate DATE NULL        
END

GO

-- Выбрать в таблице Orders заказы, которые были доставлены после 6 мая 1998 года (колонка ShippedDate) 
-- включительно и которые доставлены с ShipVia >= 2. Запрос должен возвращать только колонки OrderID, ShippedDate и ShipVia. 
DECLARE @date date = '1998-05-06';  
DECLARE @datetime datetime = @date;

SELECT [OrderID],[ShippedDate], [ShipVia] FROM [Northwind].[dbo].[Orders]
WHERE [ShippedDate] >= @datetime AND [ShipVia] >= 2

-- Написать запрос, который выводит только недоставленные заказы из таблицы Orders. В результатах запроса возвращать для колонки 
-- ShippedDate вместо значений NULL строку ‘Not Shipped’ (использовать системную функцию CASЕ). Запрос должен возвращать только 
-- колонки OrderID и ShippedDate.
SELECT [OrderID], CASE WHEN [ShippedDate] IS NULL  THEN 'Not Shipped' END AS ShipDate
FROM [Northwind].[dbo].[Orders]
WHERE [ShippedDate] IS NULL  

-- Выбрать в таблице Orders заказы, которые были доставлены после 6 мая 1998 года (ShippedDate) не включая эту дату или которые 
-- еще не доставлены. В запросе должны возвращаться только колонки OrderID (переименовать в Order Number) и ShippedDate (переименовать в Shipped Date). 
-- В результатах запроса возвращать для колонки ShippedDate вместо значений NULL строку ‘Not Shipped’, для остальных значений возвращать дату в формате по умолчанию. 
DECLARE @date date = '1998-05-06';  
DECLARE @datetime datetime = @date;

SELECT [OrderID] AS [Order Number], COALESCE(CAST([ShippedDate] AS VARCHAR), 'Not Shipped') AS [Shipped Date]
FROM [Northwind].[dbo].[Orders]
WHERE [ShippedDate] IS NULL OR [ShippedDate] > @datetime

-- Выбрать из таблицы Customers всех заказчиков, проживающих в USA и Canada. Запрос сделать с только помощью оператора IN. Возвращать колонки 
-- с именем пользователя и названием страны в результатах запроса. Упорядочить результаты запроса по имени заказчиков и по месту проживания. 
SELECT ContactName, Country 
FROM [Northwind].[dbo].[Customers]
WHERE Country IN ('USA', 'Canada')
ORDER BY ContactName, Country

-- Выбрать из таблицы Customers всех заказчиков, не проживающих в USA и Canada. Запрос сделать с помощью оператора IN. Возвращать колонки с именем 
-- пользователя и названием страны в результатах запроса. Упорядочить результаты запроса по имени заказчиков. 
SELECT ContactName, Country 
FROM [Northwind].[dbo].[Customers]
WHERE Country NOT IN ('USA', 'Canada')
ORDER BY ContactName

-- Выбрать из таблицы Customers все страны, в которых проживают заказчики. Страна должна быть упомянута только один раз и список отсортирован по убыванию. 
-- Не использовать предложение GROUP BY. Возвращать только одну колонку в результатах запроса. 
SELECT DISTINCT Country 
FROM [Northwind].[dbo].[Customers]
ORDER BY Country DESC

-- Выбрать все заказы (OrderID) из таблицы Order Details (заказы не должны повторяться), где встречаются продукты с количеством от 3 до 10 включительно – 
-- это колонка Quantity в таблице Order Details. Использовать оператор BETWEEN. Запрос должен возвращать только колонку OrderID. 
SELECT DISTINCT OrderId
FROM [Northwind].[dbo].[Order Details]
WHERE Quantity BETWEEN 3 AND 10

-- Выбрать всех заказчиков из таблицы Customers, у которых название страны начинается на буквы из диапазона b и g. Использовать оператор BETWEEN. 
-- Проверить, что в результаты запроса попадает Germany. Запрос должен возвращать только колонки CustomerID и Country и отсортирован по Country. 
SELECT CustomerId, Country
FROM [Northwind].[dbo].[Customers]
WHERE Country BETWEEN 'B' AND 'H'
ORDER BY Country

-- Выбрать всех заказчиков из таблицы Customers, у которых название страны начинается на буквы из диапазона b и g, не используя оператор BETWEEN.
SELECT CustomerId
FROM [Northwind].[dbo].[Customers]
WHERE Country > 'B' AND Country < 'H'
ORDER BY Country

-- В таблице Products найти все продукты (колонка ProductName), где встречается подстрока 'chocolade'. Известно, что в подстроке 'chocolade' 
-- может быть изменена одна буква 'c' в середине - найти все продукты, которые удовлетворяют этому условию.
SELECT ProductName  
FROM [Northwind].[dbo].[Products]
WHERE ProductName LIKE 'cho_olade'