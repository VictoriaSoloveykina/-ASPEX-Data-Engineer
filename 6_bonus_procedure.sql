-- ==============================================================
-- ХРАНИМАЯ ПРОЦЕДУРА ДЛЯ РАСЧЕТА ПРЕМИЙ
-- Формула: X = (P1*X1 + P2*X2)*X0
-- P1 = стоимость аренды (RentPrice * Time)
-- X1 = 30% от аренды
-- P2 = стоимость ремонта (Price из ServiceBook)
-- X2 = 80% от ремонта
-- X0 = процент от стажа (5%, 10%, 15%)
-- ==============================================================

CREATE OR ALTER PROCEDURE [usp_LoadEmployeeBonusMart]
    @TargetYear INT = NULL,
    @TargetMonth INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Определение целевого периода
    IF @TargetYear IS NULL SET @TargetYear = YEAR(GETDATE());
    IF @TargetMonth IS NULL SET @TargetMonth = MONTH(GETDATE());

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Очистка данных за указанный период
        DELETE FROM [EmployeeBonusMart]
        WHERE [Year] = @TargetYear AND [Month] = @TargetMonth;

        -- Расчет премий по формуле: (P1*X1 + P2*X2) * X0
        ;WITH StaffExperience AS (
            SELECT 
                s.Id AS StaffId,
                s.Name AS StaffName,
                DATEDIFF(YEAR, s.[Date], GETDATE()) AS ExperienceYears,
                CASE 
                    WHEN DATEDIFF(YEAR, s.[Date], GETDATE()) < 1 THEN 0.05      -- До 1 года: 5%
                    WHEN DATEDIFF(YEAR, s.[Date], GETDATE()) <= 2 THEN 0.10     -- 1-2 года: 10%
                    ELSE 0.15                                                   -- Более 2 лет: 15%
                END AS ExperienceCoefficient
            FROM [Staff] s
        ),
        RentalData AS (
            -- P1: Стоимость аренды (RentPrice * Time)
            SELECT 
                r.StaffId,
                SUM(b.RentPrice * r.Time) AS TotalRentalRevenue
            FROM [RentBook] r
            JOIN [Bicycle] b ON r.BicycleId = b.Id
            WHERE YEAR(r.[Date]) = @TargetYear 
              AND MONTH(r.[Date]) = @TargetMonth
              AND r.Paid = 1
            GROUP BY r.StaffId
        ),
        ServiceData AS (
            -- P2: Стоимость ремонта
            SELECT 
                sb.StaffId,
                SUM(sb.Price) AS TotalServiceRevenue
            FROM [ServiceBook] sb
            WHERE YEAR(sb.[Date]) = @TargetYear 
              AND MONTH(sb.[Date]) = @TargetMonth
            GROUP BY sb.StaffId
        ),
        BonusCalculation AS (
            SELECT
                se.StaffId,
                se.StaffName,
                se.ExperienceYears,
                se.ExperienceCoefficient * 100 AS ExperienceBonusPercent,
                ISNULL(rd.TotalRentalRevenue, 0) AS RentalRevenue,
                ISNULL(sd.TotalServiceRevenue, 0) AS ServiceRevenue,
                -- Расчет по формуле: (P1*X1 + P2*X2) * X0
                (ISNULL(rd.TotalRentalRevenue, 0) * 0.3) AS RentalBonus,          -- P1 * X1
                (ISNULL(sd.TotalServiceRevenue, 0) * 0.8) AS ServiceBonus,        -- P2 * X2
                ((ISNULL(rd.TotalRentalRevenue, 0) * 0.3) + (ISNULL(sd.TotalServiceRevenue, 0) * 0.8)) * se.ExperienceCoefficient AS TotalBonus
            FROM StaffExperience se
            LEFT JOIN RentalData rd ON se.StaffId = rd.StaffId
            LEFT JOIN ServiceData sd ON se.StaffId = sd.StaffId
            WHERE ISNULL(rd.TotalRentalRevenue, 0) > 0 OR ISNULL(sd.TotalServiceRevenue, 0) > 0
        )
        INSERT INTO [EmployeeBonusMart] (
            [Year], [Month], [StaffId], [StaffName],
            [ExperienceYears], [ExperienceBonusPercent],
            [RentalRevenue], [ServiceRevenue],
            [RentalBonus], [ServiceBonus], [TotalBonus]
        )
        SELECT
            @TargetYear,
            @TargetMonth,
            StaffId,
            StaffName,
            ExperienceYears,
            ExperienceBonusPercent,
            RentalRevenue,
            ServiceRevenue,
            RentalBonus,
            ServiceBonus,
            TotalBonus
        FROM BonusCalculation;

        COMMIT TRANSACTION;

        -- Вывод статистики
        SELECT 
            @TargetYear AS [Year],
            @TargetMonth AS [Month],
            COUNT(*) AS [RecordsLoaded],
            FORMAT(SUM([TotalBonus]), 'N2') AS [TotalBonusAmount],
            FORMAT(AVG([TotalBonus]), 'N2') AS [AverageBonus]
        FROM [EmployeeBonusMart]
        WHERE [Year] = @TargetYear AND [Month] = @TargetMonth;

        PRINT '✅ Витрина EmployeeBonusMart успешно обновлена за ' 
              + CAST(@TargetYear AS VARCHAR(4)) + '-' + CAST(@TargetMonth AS VARCHAR(2));

    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        DECLARE 
            @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE(),
            @ErrorSeverity INT = ERROR_SEVERITY(),
            @ErrorState INT = ERROR_STATE();

        PRINT '❌ Ошибка при загрузке витрины: ' + @ErrorMessage;
        RAISERROR (@ErrorMessage, @ErrorSeverity, @ErrorState);
    END CATCH;
END;
GO

-- ============================================================================
-- АВТОМАТИЗАЦИЯ ЗАГРУЗКИ ВИТРИНЫ
-- ============================================================================
/*
Процесс ежедневной загрузки витрины данных можно автоматизировать следующими способами:

1️⃣ SQL SERVER AGENT (рекомендуемый метод)
   - Создать Job, который ежедневно вызывает процедуру:
       EXEC dbo.usp_LoadEmployeeBonusMart;
   - Настроить расписание (например, каждый день в 02:00)
   - Добавить уведомления об ошибках

2️⃣ WINDOWS TASK SCHEDULER
   - Использовать команду sqlcmd в .bat файле
   - Запускать задачу по расписанию
   - Пример:
       sqlcmd -S . -d BicycleRental -Q "EXEC dbo.usp_LoadEmployeeBonusMart"

3️⃣ SSIS / AZURE DATA FACTORY
   - Для корпоративных решений: создание ETL-пайплайна
   - Возможности: логирование, алерты, интеграция с другими системами

4️⃣ POWERSHELL SCRIPT
   - Скрипт с вызовом Invoke-Sqlcmd
   - Гибкая обработка ошибок и уведомления по email
*/

PRINT '✅ Процедура расчета премий создана';
PRINT '📊 Формула: (Аренда × 30% + Ремонт × 80%) × Стаж%';