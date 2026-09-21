use streamhub_ab_test;
select count(*) as total_rows from streamhub_data;

-- CTR and average watch-time by device and group --
select
device,
`group`,
round(avg(click_through_rate), 4) as avg_ctr,
round(avg(total_watch_minutes), 2) as avg_watch_minutes,
count(*) as num_users
from streamhub_data
group by device, `group`
order by device, `group`;

-- Overall topline summary --
SELECT
    `group`,
    ROUND(AVG(click_through_rate), 4) AS avg_ctr,
    ROUND(AVG(total_watch_minutes), 2) AS avg_watch_minutes,
    ROUND(AVG(CASE WHEN churned_30d = 'TRUE' THEN 1 ELSE 0 END), 4) AS churn_rate,
    COUNT(*) AS num_users
FROM streamhub_data
GROUP BY `group`;

-- Churn rate by subscription tier --
SELECT
    subscription_tier,
    `group`,
    ROUND(AVG(CASE WHEN churned_30d = 'TRUE' THEN 1 ELSE 0 END), 4) AS churn_rate,
    COUNT(*) AS num_users
FROM streamhub_data
GROUP BY subscription_tier, `group`
ORDER BY subscription_tier, `group`;

-- Using a CTE + Window Function --
WITH device_summary AS (
    SELECT
        device,
        `group`,
        ROUND(AVG(click_through_rate), 4) AS avg_ctr
    FROM streamhub_data
    GROUP BY device, `group`
)
SELECT
    device,
    `group`,
    avg_ctr,
    RANK() OVER (PARTITION BY `group` ORDER BY avg_ctr DESC) AS ctr_rank_within_group
FROM device_summary
ORDER BY `group`, ctr_rank_within_group;