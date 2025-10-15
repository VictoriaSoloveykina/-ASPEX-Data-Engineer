-- ==============================================================
-- УЛУЧШЕНИЯ СХЕМЫ ДАННЫХ - Bicycle Rental System
-- Обоснование изменений в комментариях
-- ==============================================================

USE BicycleRental;
GO

-- 1. УВЕЛИЧЕНИЕ ДЛИНЫ ИМЕН (Client, Staff)
-- Проблема: VARCHAR(10) слишком мало для имен
-- Решение: NVARCHAR(50) для поддержки международных имен
ALTER TABLE [Client] ALTER COLUMN [Name] NVARCHAR(50) NOT NULL;
ALTER TABLE [Staff] ALTER COLUMN [Name] NVARCHAR(50) NOT NULL;
GO
PRINT '✅ Увеличена длина полей Name для поддержки полных имен';

-- 2. ИСПРАВЛЕНИЕ ИМЕНИ ПОЛЯ (Client)
-- Проблема: Пробелы в именах полей требуют постоянного экранирования
-- Решение: Замена [Phone number] на [PhoneNumber]
ALTER TABLE [Client] ADD [PhoneNumber] VARCHAR(50) NULL;
UPDATE [Client] SET [PhoneNumber] = [Phone number];
ALTER TABLE [Client] DROP COLUMN [Phone number];
ALTER TABLE [Client] ALTER COLUMN [PhoneNumber] VARCHAR(50) NOT NULL;
GO
PRINT '✅ Исправлено имя поля Phone number → PhoneNumber';

-- 3. УНИКАЛЬНОСТЬ ПАСПОРТОВ (Client, Staff)
-- Проблема: Возможность дублирования клиентов/сотрудников
-- Решение: Уникальные ограничения на паспортные данные
ALTER TABLE [Client] ADD CONSTRAINT UQ_Client_Passport UNIQUE ([Passport]);
ALTER TABLE [Staff] ADD CONSTRAINT UQ_Staff_Passport UNIQUE ([Passport]);
GO
PRINT '✅ Добавлена уникальность паспортных данных';

-- 4. ПЕРВИЧНЫЙ КЛЮЧ ДЛЯ СВЯЗЕЙ (DetailForBicycle)
-- Проблема: Возможность дублирования связей велосипед-деталь
-- Решение: Составной первичный ключ
ALTER TABLE [DetailForBicycle] 
ADD CONSTRAINT PK_DetailForBicycle PRIMARY KEY ([BicycleId], [DetailId]);
GO
PRINT '✅ Добавлен первичный ключ для таблицы связей';

-- 5. ПЕРВИЧНЫЙ КЛЮЧ ДЛЯ СЕРВИСА (ServiceBook)
-- Проблема: Нет уникального идентификатора записей обслуживания
-- Решение: Добавление ID и первичного ключа
ALTER TABLE [ServiceBook] ADD [Id] INT IDENTITY(1,1) NOT NULL;
ALTER TABLE [ServiceBook] ADD CONSTRAINT PK_ServiceBook PRIMARY KEY ([Id]);
GO
PRINT '✅ Добавлен первичный ключ для журнала обслуживания';

-- 6. ВАЛИДАЦИЯ ДАННЫХ (RentBook)
-- Проблема: Возможность некорректной продолжительности аренды
-- Решение: Проверка положительного времени аренды
ALTER TABLE [RentBook] 
ADD CONSTRAINT CHK_RentBook_Time CHECK ([Time] > 0);
GO
PRINT '✅ Добавлена проверка положительного времени аренды';

-- 7. ВАЛИДАЦИЯ ЦЕН (Detail)
-- Проблема: Возможность отрицательных цен на детали
-- Решение: Проверка положительной цены
ALTER TABLE [Detail] 
ADD CONSTRAINT CHK_Detail_Price CHECK ([Price] > 0);
GO
PRINT '✅ Добавлена проверка положительных цен на детали';

-- 8. БАЗОВЫЕ ИНДЕКСЫ ДЛЯ ПРОИЗВОДИТЕЛЬНОСТИ
-- Проблема: Медленные JOIN-запросы
-- Решение: Индексы на часто используемых внешних ключах
CREATE INDEX IX_RentBook_BicycleId ON [RentBook]([BicycleId]);
CREATE INDEX IX_RentBook_ClientId ON [RentBook]([ClientId]);
CREATE INDEX IX_RentBook_StaffId ON [RentBook]([StaffId]);
CREATE INDEX IX_ServiceBook_BicycleId ON [ServiceBook]([BicycleId]);
GO
PRINT '✅ Добавлены индексы для оптимизации запросов';

PRINT '=========================================';
PRINT '✅ ВСЕ УЛУЧШЕНИЯ УСПЕШНО ПРИМЕНЕНЫ';
PRINT '=========================================';