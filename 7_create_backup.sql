-- ==============================================================
-- ПРОСТОЙ БЭКАП БАЗЫ ДАННЫХ
-- ==============================================================

USE master;
GO

PRINT 'Создание бэкапа базы BicycleRental...';

BEGIN TRY
    -- Простой бэкап в текущую папку
    BACKUP DATABASE [BicycleRental] 
    TO DISK = 'BicycleRental_Backup.bak'
    WITH FORMAT;
    
    PRINT '✅ Бэкап успешно создан: BicycleRental_Backup.bak';
    PRINT '📁 Файл находится в папке с скриптами';
    
END TRY
BEGIN CATCH
    PRINT '❌ Ошибка: ' + ERROR_MESSAGE();
    PRINT '';
    PRINT 'Инструкция по созданию бэкапа через SSMS:';
    PRINT '1. Правой кнопкой по базе BicycleRental';
    PRINT '2. Tasks → Back Up...';
    PRINT '3. Нажмите OK';
    PRINT '4. Найдите файл .bak и прикрепите к ответу';
END CATCH;
GO