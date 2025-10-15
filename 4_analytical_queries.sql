USE BicycleRental;
GO

PRINT '=============================================';
PRINT 'АНАЛИТИЧЕСКИЕ ЗАПРОСЫ ПО ВЕЛОПРОКАТУ';
PRINT '=============================================';
GO

/* ---------------------------------------------------------
   1️⃣ Топ-5 рентабельных велосипедов (3 таблицы)
   Анализ: ROI по каждому велосипеду
--------------------------------------------------------- */
PRINT '1️⃣ Топ-5 рентабельных велосипедов';
SELECT TOP 5 
    b.Id,
    b.Brand AS Bicycle,
    SUM(b.RentPrice * r.Time) AS TotalRevenue,
    SUM(ISNULL(s.Price, 0)) AS TotalServiceCost,
    SUM(b.RentPrice * r.Time) - SUM(ISNULL(s.Price, 0)) AS NetProfit,
    CASE WHEN SUM(b.RentPrice * r.Time) > 0 
         THEN CAST((SUM(b.RentPrice * r.Time) - SUM(ISNULL(s.Price, 0))) * 100.0 / SUM(b.RentPrice * r.Time) AS DECIMAL(10,1)) + '%'
         ELSE 'N/A' 
    END AS ProfitMargin
FROM Bicycle b
LEFT JOIN RentBook r ON b.Id = r.BicycleId AND r.Paid = 1
LEFT JOIN ServiceBook s ON b.Id = s.BicycleId
GROUP BY b.Id, b.Brand
ORDER BY NetProfit DESC;
GO

/* ---------------------------------------------------------
   2️⃣ Топ-5 клиентов по оплатам (2 таблицы)
   Анализ: клиентская ценность (LTV)
--------------------------------------------------------- */
PRINT '2️⃣ Топ-5 клиентов по оплатам';
SELECT TOP 5
    c.Id,
    c.Name,
    c.Country,
    COUNT(r.Id) AS RentCount,
    SUM(b.RentPrice * r.Time) AS TotalSpent,
    AVG(b.RentPrice * r.Time) AS AvgRentPrice,
    SUM(b.RentPrice * r.Time) / NULLIF(COUNT(r.Id), 0) AS AvgSpentPerRent
FROM RentBook r
JOIN Client c ON r.ClientId = c.Id
JOIN Bicycle b ON r.BicycleId = b.Id
WHERE r.Paid = 1
GROUP BY c.Id, c.Name, c.Country
ORDER BY TotalSpent DESC;
GO

/* ---------------------------------------------------------
   3️⃣ Эффективность сотрудников (3 таблицы)
   Анализ: продуктивность и вклад в прибыль
--------------------------------------------------------- */
PRINT '3️⃣ Эффективность сотрудников';
SELECT 
    s.Id,
    s.Name,
    COUNT(DISTINCT r.Id) AS RentsHandled,
    COUNT(DISTINCT sb.Id) AS ServicesPerformed,
    ISNULL(SUM(b.RentPrice * r.Time), 0) AS RevenueFromRents,
    ISNULL(SUM(sb.Price), 0) AS ServiceRevenue,
    ISNULL(SUM(b.RentPrice * r.Time), 0) + ISNULL(SUM(sb.Price), 0) AS TotalContribution
FROM Staff s
LEFT JOIN RentBook r ON s.Id = r.StaffId AND r.Paid = 1
LEFT JOIN Bicycle b ON r.BicycleId = b.Id
LEFT JOIN ServiceBook sb ON s.Id = sb.StaffId
GROUP BY s.Id, s.Name
ORDER BY TotalContribution DESC;
GO

/* ---------------------------------------------------------
   4️⃣ Частота замен деталей (2 таблицы)
   Анализ: надежность и стоимость содержания компонентов
--------------------------------------------------------- */
PRINT '4️⃣ Частота замен деталей';
SELECT 
    d.Id,
    d.Brand + ' ' + d.Name AS DetailName,
    d.Type,
    COUNT(sb.Id) AS ReplacementCount,
    SUM(ISNULL(sb.Price, 0)) AS TotalMaintenanceCost,
    AVG(ISNULL(sb.Price, 0)) AS AvgReplacementCost,
    COUNT(DISTINCT sb.BicycleId) AS UniqueBicyclesServiced
FROM Detail d
LEFT JOIN ServiceBook sb ON d.Id = sb.DetailId
GROUP BY d.Id, d.Brand, d.Name, d.Type
HAVING COUNT(sb.Id) > 0
ORDER BY ReplacementCount DESC, TotalMaintenanceCost DESC;
GO

/* ---------------------------------------------------------
   5️⃣ Прибыль на час аренды (3 таблицы)
   Анализ: операционная эффективность моделей
--------------------------------------------------------- */
PRINT '5️⃣ Прибыль на час аренды';
SELECT 
    b.Id,
    b.Brand AS Bicycle,
    b.RentPrice AS HourlyRate,
    COUNT(r.Id) AS TotalRentals,
    SUM(b.RentPrice * r.Time) AS TotalRevenue,
    SUM(r.Time) AS TotalRentalHours,
    SUM(ISNULL(s.Price, 0)) AS TotalServiceCost,
    (SUM(b.RentPrice * r.Time) - SUM(ISNULL(s.Price, 0))) / NULLIF(SUM(r.Time), 0) AS ProfitPerHour,
    CAST((SUM(b.RentPrice * r.Time) - SUM(ISNULL(s.Price, 0))) * 100.0 / NULLIF(SUM(b.RentPrice * r.Time), 0) AS DECIMAL(10,1)) + '%' AS ProfitMargin
FROM Bicycle b
LEFT JOIN RentBook r ON b.Id = r.BicycleId AND r.Paid = 1
LEFT JOIN ServiceBook s ON b.Id = s.BicycleId
GROUP BY b.Id, b.Brand, b.RentPrice
HAVING SUM(r.Time) > 0
ORDER BY ProfitPerHour DESC;
GO

PRINT '✅ Все аналитические запросы успешно выполнены';
PRINT '---------------------------------------------';
PRINT '📊 ОТЧЕТЫ:';
PRINT '   1. Рентабельность велосипедов (ROI)';
PRINT '   2. Клиентская ценность (LTV)';
PRINT '   3. Эффективность персонала';
PRINT '   4. Анализ надежности компонентов';
PRINT '   5. Операционная эффективность';
PRINT '---------------------------------------------';
GO