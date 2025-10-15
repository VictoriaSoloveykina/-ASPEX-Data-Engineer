-- ==============================================================
-- ТЕСТОВЫЕ ДАННЫЕ для исходной структуры таблиц
-- ==============================================================

USE BicycleRental;
GO

-- Очистка таблиц (обратный порядок из-за foreign keys)
DELETE FROM [RentBook];
DELETE FROM [ServiceBook];
DELETE FROM [DetailForBicycle];
DELETE FROM [Detail];
DELETE FROM [Bicycle];
DELETE FROM [Client];
DELETE FROM [Staff];
GO

-- Сброс идентификаторов
DBCC CHECKIDENT ('[RentBook]', RESEED, 0);
DBCC CHECKIDENT ('[Bicycle]', RESEED, 0);
DBCC CHECKIDENT ('[Client]', RESEED, 0);
DBCC CHECKIDENT ('[Staff]', RESEED, 0);
DBCC CHECKIDENT ('[Detail]', RESEED, 0);
GO

-- 1. Велосипеды (только исходные поля)
INSERT INTO [Bicycle] ([Brand], [RentPrice])
VALUES 
('Trek', 15),
('Giant', 18),
('Cube', 20),
('Specialized', 17),
('Scott', 19);
PRINT '✅ Добавлено 5 велосипедов';

-- 2. Клиенты (только исходные поля)
INSERT INTO [Client] ([Name], [Passport], [Phone number], [Country])
VALUES
('John Doe', 'P1234567', '+201001112233', 'USA'),
('Anna Smith', 'P2233445', '+201009998877', 'UK'),
('Omar Khaled', 'EG5544332', '+201113334455', 'Egypt'),
('Maria Lopez', 'SP9988776', '+201118889900', 'Spain'),
('Mike Brown', 'P6677889', '+201119996655', 'Canada');
PRINT '✅ Добавлено 5 клиентов';

-- 3. Сотрудники (только исходные поля)
INSERT INTO [Staff] ([Name], [Passport], [Date])
VALUES
('Ahmed', 'E112233', '2022-03-01'),
('Fatma', 'E223344', '2021-08-15'),
('Youssef', 'E334455', '2023-01-10'),
('Sara', 'E445566', '2020-06-20'),
('Ola', 'E556677', '2024-02-01');
PRINT '✅ Добавлено 5 сотрудников';

-- 4. Детали (только исходные поля)
INSERT INTO [Detail] ([Brand], [Type], [Name], [Price])
VALUES
('Shimano', 'Chain', 'CN-HG601', 35),
('SRAM', 'Cassette', 'PG-1130', 60),
('Maxxis', 'Tire', 'Rekon 29x2.25', 50),
('Bontrager', 'Brake', 'Hydraulic Disc', 75),
('KMC', 'Chain', 'X11.93', 30);
PRINT '✅ Добавлено 5 деталей';

-- 5. Совместимость деталей и велосипедов
INSERT INTO [DetailForBicycle] ([BicycleId], [DetailId])
VALUES 
(1, 1), (1, 3), 
(2, 2), (2, 3), 
(3, 4), 
(4, 1), 
(5, 5);
PRINT '✅ Добавлены связи деталей и велосипедов';

-- 6. Сервисное обслуживание
INSERT INTO [ServiceBook] ([BicycleId], [DetailId], [Date], [Price], [StaffId])
VALUES
(1, 1, '2024-06-10', 25, 1),
(2, 2, '2024-07-20', 40, 2),
(3, 4, '2024-10-05', 20, 3),
(1, 3, '2024-08-15', 30, 2),
(4, 1, '2024-09-01', 15, 1);
PRINT '✅ Добавлено 5 записей обслуживания';

-- 7. Аренда велосипедов (только исходные поля)
INSERT INTO [RentBook] ([Date], [Time], [Paid], [BicycleId], [ClientId], [StaffId])
VALUES
('2024-06-01', 3, 1, 1, 1, 1),
('2024-07-15', 5, 1, 2, 2, 2),
('2024-08-22', 2, 1, 3, 3, 3),
('2024-09-28', 4, 0, 4, 4, 4),
('2024-10-10', 6, 1, 5, 5, 5),
('2024-10-15', 3, 1, 1, 2, 1),
('2024-10-20', 2, 1, 3, 1, 3);
PRINT '✅ Добавлено 7 записей аренды';

-- ==============================================================
-- ПРОВЕРКА ДАННЫХ
-- ==============================================================

PRINT ' ';
PRINT '📊 СТАТИСТИКА ДАННЫХ:';
PRINT '-------------------';

DECLARE @BicycleCount INT = (SELECT COUNT(*) FROM [Bicycle]);
DECLARE @ClientCount INT = (SELECT COUNT(*) FROM [Client]);
DECLARE @StaffCount INT = (SELECT COUNT(*) FROM [Staff]);
DECLARE @DetailCount INT = (SELECT COUNT(*) FROM [Detail]);
DECLARE @RentCount INT = (SELECT COUNT(*) FROM [RentBook]);
DECLARE @ServiceCount INT = (SELECT COUNT(*) FROM [ServiceBook]);

PRINT 'Велосипеды: ' + CAST(@BicycleCount AS VARCHAR);
PRINT 'Клиенты: ' + CAST(@ClientCount AS VARCHAR);
PRINT 'Сотрудники: ' + CAST(@StaffCount AS VARCHAR);
PRINT 'Детали: ' + CAST(@DetailCount AS VARCHAR);
PRINT 'Аренды: ' + CAST(@RentCount AS VARCHAR);
PRINT 'Обслуживание: ' + CAST(@ServiceCount AS VARCHAR);

PRINT ' ';
PRINT '✅ ВСЕ ТЕСТОВЫЕ ДАННЫЕ УСПЕШНО ДОБАВЛЕНЫ';
PRINT '=========================================';