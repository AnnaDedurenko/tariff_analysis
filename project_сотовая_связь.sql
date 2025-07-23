--Анализировать поведение клиентов федерального оператора сотовой связи «Мегасеть» и оценить эффективность действующих тарифных планов. 
--На основе данных определить, насколько текущие тарифы соответствуют потребностям клиентов и как часто пользователи выходят за пределы включённых услуг.
--Компания предлагает два тарифа: Smart и Ultra. Задача — понять, как клиенты пользуются услугами, сколько тратят, сколько переплачивают при выходе за лимиты, 
--и на основе этого предоставить бизнесу информацию для улучшения тарифной линейки.
--Проект был реализован с использованием SQL: все расчёты и агрегации выполнены в виде SQL-запросов.

--1. Найти строки с пропусками (NULL) в любых полях, кроме user_id
SELECT*
FROM telecom.users
WHERE age IS NULL
    OR churn_date IS NULL
    OR city IS NULL
    OR first_name IS NULL
    OR last_name IS NULL
    OR reg_date IS NULL
    OR tariff IS NULL
    
-- 2. Посчитать долю активных клиентов (churn_date IS NULL)
SELECT 
    CAST(COUNT(CASE WHEN churn_date IS NULL THEN 1 END) AS REAL) / COUNT(*) AS active_clients_share 
FROM telecom.users

-- 3. Проверить, что каждый активный клиент использовал только один тарифный план
-- Вывести клиентов, у которых больше одного тарифа
SELECT 
    user_id, -- ID клиента
    COUNT(DISTINCT tariff) AS tariff_count -- Количество уникальных тарифных планов
FROM telecom.users
WHERE churn_date IS NULL -- Фильтр для активных клиентов
GROUP BY user_id
HAVING COUNT(DISTINCT tariff) > 1; -- Оставляем только клиентов с более чем одним тарифным планом

-- 4. Найти строки с пропусками (NULL) в таблице calls (duration или call_date)
SELECT *
FROM telecom.calls
WHERE call_date IS NULL
    OR duration IS null

-- 5. Проверить аномалии в длительности разговоров
--Найти минимальную и максимальную длительность звонков
SELECT MIN(duration) AS min_duration,
        MAX(duration) AS max_duration
FROM telecom.calls

-- 6. Рассчитать долю звонков с длительностью 0 минут от всех звонков
SELECT 
    CAST(COUNT(CASE WHEN duration = 0 THEN 1 END) AS REAL) / COUNT(*)  AS dol_call
FROM telecom.calls

-- 7. Посчитать суммарную длительность звонков за день для каждого клиента
--Определить случаи, когда общая длительность превышает 24 часа
--Вывести топ-10 клиентов с максимальной суммарной длительностью (в часах)
SELECT user_id, 
        call_date,
        SUM(duration) / 60 AS total_day_duration
FROM telecom.calls
GROUP BY user_id, call_date
ORDER BY total_day_duration DESC