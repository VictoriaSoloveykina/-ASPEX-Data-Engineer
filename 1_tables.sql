-- ==============================================================
-- Создание таблиц как в задании
-- ==============================================================

CREATE DATABASE BicycleRental;
GO

USE BicycleRental;
GO

-- Таблица Bicycle (велосипеды)
CREATE TABLE [Bicycle]
(
   [Id] int IDENTITY(1,1) not null,
   [Brand] varchar(50)  not null,
   [RentPrice] int not null, -- цена аренды
   primary key(Id)
)

-- Таблица Client (клиенты)
CREATE TABLE [Client]
(
   [Id] int IDENTITY(1,1) not null,
   [Name] varchar(10) not null,
   [Passport] varchar(50) not null,
   [Phone number] varchar(50) not null,
   [Country] varchar(50) not null,
   primary key(Id)
)

-- Таблица Staff (сотрудники)
CREATE TABLE [Staff]
(
   [Id] int IDENTITY(1,1) not null,
   [Name] varchar(10) not null, -- имя сотрудника
   [Passport] varchar(50) not null,
   [Date] date not null, -- дата начала работы
   primary key(Id)
)

-- Таблица Detail (запчасти велосипеда)
CREATE TABLE [Detail]
(
   [Id] int IDENTITY(1,1) not null,
   [Brand] varchar(50)  not null,
   [Type] varchar(50) not null, -- тип детали (цепь, звезда, etc.)
   [Name] varchar(50) not null, -- название детали
   [Price] int not null,
   primary key(Id) 
)

-- Таблица DetailForBicycle (список деталей подходящих к велосипедам)
CREATE TABLE [DetailForBicycle]
(
   [BicycleId] int not null,
   [DetailId] int not null,
   FOREIGN KEY ([BicycleId]) REFERENCES [Bicycle] ([Id]),
   FOREIGN KEY ([DetailId]) REFERENCES [Detail] ([Id])
)

-- Таблица ServiceBook (сервисное обслуживание велосипедов)
CREATE TABLE [ServiceBook]
(
   [BicycleId] int not null,
   [DetailId] int not null,
   [Date] date not null,
   [Price] int not null, -- цена работы
   [StaffId] int not null,
   FOREIGN KEY ([BicycleId]) REFERENCES [Bicycle] ([Id]),
   FOREIGN KEY ([StaffId]) REFERENCES [Staff] ([Id]),
   FOREIGN KEY ([DetailId]) REFERENCES [Detail] ([Id])
)

-- Таблица RentBook (аренда велосипеда клиентом)
CREATE TABLE [RentBook]
(
   [Id] int IDENTITY(1,1) not null,
   [Date] date not null, -- дата аренды
   [Time] int not null, -- время аренды в часах
   [Paid] bit not null, -- 1 оплатил; 0 не оплатил 
   [BicycleId] int not null,
   [ClientId] int not null,
   [StaffId] int not null,
   FOREIGN KEY ([BicycleId]) REFERENCES [Bicycle] ([Id]),
   FOREIGN KEY ([StaffId]) REFERENCES [Staff] ([Id]),
   FOREIGN KEY ([ClientId]) REFERENCES [Client] ([Id])
)

PRINT '✅ Все таблицы созданы точно по условию задания';
GO