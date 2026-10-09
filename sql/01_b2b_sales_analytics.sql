/* 
B2B SALES ANALYTICS — MYSQL
Source: Maven Analytics CRM Sales Opportunities (synthetic data)
Purpose: staging, data-quality checks, and four business analyses.

Important project decisions:
- Preserve raw staging data; normalize GTXPro to GTX Pro only in analytical joins.
- Win rate = Won / (Won + Lost); exclude open opportunities.
- sales_price is suggested retail price, not cost or profit.
- Agent categories: Poor < 60%; Average 60%-65% inclusive; Good > 65%.
*/


-- Select our project database
CREATE DATABASE IF NOT EXISTS b2b_sales_analytics
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE b2b_sales_analytics;

-- Record the MySQL version
SELECT VERSION() AS mysql_version;

-- 1. Accounts
CREATE TABLE IF NOT EXISTS stg_accounts (
    account          VARCHAR(255),
    sector           VARCHAR(100),
    year_established VARCHAR(20),
    revenue          VARCHAR(50),
    employees        VARCHAR(50),
    office_location  VARCHAR(255),
    subsidiary_of    VARCHAR(255)
);

-- 2. Products
CREATE TABLE IF NOT EXISTS stg_products (
    product     VARCHAR(255),
    series      VARCHAR(100),
    sales_price VARCHAR(50)
);

-- 3. Sales teams
CREATE TABLE IF NOT EXISTS stg_sales_teams (
    sales_agent     VARCHAR(255),
    manager         VARCHAR(255),
    regional_office VARCHAR(100)
);

-- 4. Sales pipeline
CREATE TABLE IF NOT EXISTS stg_sales_pipeline (
    opportunity_id VARCHAR(50),
    sales_agent    VARCHAR(255),
    product        VARCHAR(255),
    account        VARCHAR(255),
    deal_stage     VARCHAR(100),
    engage_date    VARCHAR(30),
    close_date     VARCHAR(30),
    close_value    VARCHAR(50)
);

-- 5. Data dictionary
CREATE TABLE IF NOT EXISTS stg_data_dictionary (
    `Table`       VARCHAR(100),
    Field         VARCHAR(100),
    Description   TEXT
);

-- Verify the staging tables
SHOW TABLES;

SELECT 'accounts' AS source_table, COUNT(*) AS row_count
FROM stg_accounts
UNION ALL
SELECT 'products', COUNT(*) FROM stg_products
UNION ALL
SELECT 'sales_teams', COUNT(*) FROM stg_sales_teams
UNION ALL
SELECT 'sales_pipeline', COUNT(*) FROM stg_sales_pipeline
UNION ALL
SELECT 'data_dictionary', COUNT(*) FROM stg_data_dictionary;


-- 1. Check total rows and distinct opportunity IDs
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT opportunity_id) AS distinct_opportunity_ids,
    COUNT(*) - COUNT(DISTINCT opportunity_id) AS duplicate_id_count
FROM stg_sales_pipeline;

-- 2. Check missing or blank required fields
SELECT
    SUM(CASE
        WHEN opportunity_id IS NULL OR TRIM(opportunity_id) = ''
        THEN 1 ELSE 0
    END) AS missing_opportunity_id,

    SUM(CASE
        WHEN sales_agent IS NULL OR TRIM(sales_agent) = ''
        THEN 1 ELSE 0
    END) AS missing_sales_agent,

    SUM(CASE
        WHEN product IS NULL OR TRIM(product) = ''
        THEN 1 ELSE 0
    END) AS missing_product,

    SUM(CASE
        WHEN account IS NULL OR TRIM(account) = ''
        THEN 1 ELSE 0
    END) AS missing_account,

    SUM(CASE
        WHEN deal_stage IS NULL OR TRIM(deal_stage) = ''
        THEN 1 ELSE 0
    END) AS missing_deal_stage
FROM stg_sales_pipeline;

-- 3. Inspect the number of records at each deal stage
SELECT
    deal_stage,
    COUNT(*) AS opportunity_count
FROM stg_sales_pipeline
GROUP BY deal_stage
ORDER BY opportunity_count DESC;



-- Check close-value and close-date patterns by deal stage
SELECT
    deal_stage,
    COUNT(*) AS total_rows,

    SUM(CASE
        WHEN close_value IS NULL OR TRIM(close_value) = ''
        THEN 1 ELSE 0
    END) AS missing_close_value,

    SUM(CASE
        WHEN TRIM(close_value) REGEXP '^[0-9]+(\\.[0-9]+)?$'
             AND CAST(TRIM(close_value) AS DECIMAL(15,2)) = 0
        THEN 1 ELSE 0
    END) AS zero_close_value,

    SUM(CASE
        WHEN TRIM(close_value) REGEXP '^[0-9]+(\\.[0-9]+)?$'
             AND CAST(TRIM(close_value) AS DECIMAL(15,2)) > 0
        THEN 1 ELSE 0
    END) AS positive_close_value,

    SUM(CASE
        WHEN close_date IS NULL OR TRIM(close_date) = ''
        THEN 1 ELSE 0
    END) AS missing_close_date

FROM stg_sales_pipeline
GROUP BY deal_stage
ORDER BY deal_stage;



-- Check for pipeline records with unmatched references

SELECT
    'Product' AS reference_type,
    COUNT(*) AS unmatched_rows
FROM stg_sales_pipeline p
LEFT JOIN stg_products pr
    ON TRIM(p.product) = TRIM(pr.product)
WHERE p.product IS NOT NULL
  AND TRIM(p.product) <> ''
  AND pr.product IS NULL

UNION ALL

SELECT
    'Account' AS reference_type,
    COUNT(*) AS unmatched_rows
FROM stg_sales_pipeline p
LEFT JOIN stg_accounts a
    ON TRIM(p.account) = TRIM(a.account)
WHERE p.account IS NOT NULL
  AND TRIM(p.account) <> ''
  AND a.account IS NULL

UNION ALL

SELECT
    'Sales Agent' AS reference_type,
    COUNT(*) AS unmatched_rows
FROM stg_sales_pipeline p
LEFT JOIN stg_sales_teams st
    ON TRIM(p.sales_agent) = TRIM(st.sales_agent)
WHERE p.sales_agent IS NOT NULL
  AND TRIM(p.sales_agent) <> ''
  AND st.sales_agent IS NULL;
  
  
SELECT
    TRIM(p.product) AS pipeline_product,
    COUNT(*) AS opportunity_count
FROM stg_sales_pipeline p
LEFT JOIN stg_products pr
    ON TRIM(p.product) = TRIM(pr.product)
WHERE p.product IS NOT NULL
  AND TRIM(p.product) <> ''
  AND pr.product IS NULL
GROUP BY TRIM(p.product)
ORDER BY opportunity_count DESC;

SELECT product
FROM stg_products;


SELECT
    'Accounts' AS table_name,
    COUNT(*) AS duplicate_key_groups
FROM (
    SELECT account
    FROM stg_accounts
    GROUP BY account
    HAVING COUNT(*) > 1
) AS duplicates

UNION ALL

SELECT
    'Products',
    COUNT(*)
FROM (
    SELECT product
    FROM stg_products
    GROUP BY product
    HAVING COUNT(*) > 1
) AS duplicates

UNION ALL

SELECT
    'Sales Teams',
    COUNT(*)
FROM (
    SELECT sales_agent
    FROM stg_sales_teams
    GROUP BY sales_agent
    HAVING COUNT(*) > 1
) AS duplicates;



SELECT
    p.product AS pipeline_product,
    pr.product AS catalog_product,
    pr.sales_price AS listed_price,
    COUNT(*) AS won_deals,
    SUM(CASE
        WHEN CAST(TRIM(p.close_value) AS DECIMAL(15,2))
             = CAST(TRIM(pr.sales_price) AS DECIMAL(15,2))
        THEN 1 ELSE 0
    END) AS deals_equal_to_list_price,
    SUM(CASE
        WHEN CAST(TRIM(p.close_value) AS DECIMAL(15,2))
             > CAST(TRIM(pr.sales_price) AS DECIMAL(15,2))
        THEN 1 ELSE 0
    END) AS deals_above_list_price,
    SUM(CASE
        WHEN CAST(TRIM(p.close_value) AS DECIMAL(15,2))
             < CAST(TRIM(pr.sales_price) AS DECIMAL(15,2))
        THEN 1 ELSE 0
    END) AS deals_below_list_price
FROM stg_sales_pipeline p
JOIN stg_products pr
    ON TRIM(
        CASE
            WHEN p.product = 'GTXPro' THEN 'GTX Pro'
            ELSE p.product
        END
    ) = TRIM(pr.product)
WHERE LOWER(TRIM(p.deal_stage)) = 'won'
GROUP BY
    p.product,
    pr.product,
    pr.sales_price
ORDER BY
    p.product;
    
    

SELECT
    st.manager,

    /* Won deals and revenue */
    SUM(CASE
        WHEN LOWER(TRIM(p.deal_stage)) = 'won'
        THEN 1 ELSE 0
    END) AS won_deals,

    SUM(CASE
        WHEN LOWER(TRIM(p.deal_stage)) = 'won'
        THEN CAST(TRIM(p.close_value) AS DECIMAL(15,2))
        ELSE 0
    END) AS won_revenue,

    /* Lost deals */
    SUM(CASE
        WHEN LOWER(TRIM(p.deal_stage)) = 'lost'
        THEN 1 ELSE 0
    END) AS lost_deals,

    /* Win rate among decided deals */
    ROUND(
        100.0 * SUM(CASE
            WHEN LOWER(TRIM(p.deal_stage)) = 'won'
            THEN 1 ELSE 0
        END)
        /
        NULLIF(SUM(CASE
            WHEN LOWER(TRIM(p.deal_stage)) IN ('won', 'lost')
            THEN 1 ELSE 0
        END), 0),
        2
    ) AS win_rate_pct,

    /* Average value of a won deal */
    ROUND(
        SUM(CASE
            WHEN LOWER(TRIM(p.deal_stage)) = 'won'
            THEN CAST(TRIM(p.close_value) AS DECIMAL(15,2))
            ELSE 0
        END)
        /
        NULLIF(SUM(CASE
            WHEN LOWER(TRIM(p.deal_stage)) = 'won'
            THEN 1 ELSE 0
        END), 0),
        2
    ) AS avg_won_deal_size,

    /* Net difference from suggested retail prices */
    SUM(CASE
        WHEN LOWER(TRIM(p.deal_stage)) = 'won'
             AND pr.product IS NOT NULL
        THEN CAST(TRIM(p.close_value) AS DECIMAL(15,2))
             - CAST(TRIM(pr.sales_price) AS DECIMAL(15,2))
        ELSE 0
    END) AS net_price_difference

FROM stg_sales_pipeline p

JOIN stg_sales_teams st
    ON TRIM(p.sales_agent) = TRIM(st.sales_agent)

LEFT JOIN stg_products pr
    ON TRIM(
        CASE
            WHEN TRIM(p.product) = 'GTXPro'
            THEN 'GTX Pro'
            ELSE p.product
        END
    ) = TRIM(pr.product)

GROUP BY st.manager
ORDER BY won_revenue DESC;



SELECT
    st.regional_office,

    SUM(CASE
        WHEN LOWER(TRIM(p.deal_stage)) = 'won'
        THEN 1 ELSE 0
    END) AS won_deals,

    SUM(CASE
        WHEN LOWER(TRIM(p.deal_stage)) = 'won'
        THEN CAST(TRIM(p.close_value) AS DECIMAL(15,2))
        ELSE 0
    END) AS won_revenue,

    SUM(CASE
        WHEN LOWER(TRIM(p.deal_stage)) = 'lost'
        THEN 1 ELSE 0
    END) AS lost_deals,

    ROUND(
        100.0 * SUM(CASE
            WHEN LOWER(TRIM(p.deal_stage)) = 'won'
            THEN 1 ELSE 0
        END)
        /
        NULLIF(SUM(CASE
            WHEN LOWER(TRIM(p.deal_stage)) IN ('won', 'lost')
            THEN 1 ELSE 0
        END), 0),
        2
    ) AS win_rate_pct,

    ROUND(
        SUM(CASE
            WHEN LOWER(TRIM(p.deal_stage)) = 'won'
            THEN CAST(TRIM(p.close_value) AS DECIMAL(15,2))
            ELSE 0
        END)
        /
        NULLIF(SUM(CASE
            WHEN LOWER(TRIM(p.deal_stage)) = 'won'
            THEN 1 ELSE 0
        END), 0),
        2
    ) AS avg_won_deal_size,

    SUM(CASE
        WHEN LOWER(TRIM(p.deal_stage)) = 'won'
             AND pr.product IS NOT NULL
        THEN CAST(TRIM(p.close_value) AS DECIMAL(15,2))
             - CAST(TRIM(pr.sales_price) AS DECIMAL(15,2))
        ELSE 0
    END) AS net_price_difference
    
    
FROM stg_sales_pipeline p

JOIN stg_sales_teams st
    ON TRIM(p.sales_agent) = TRIM(st.sales_agent)

LEFT JOIN stg_products pr
    ON TRIM(
        CASE
            WHEN TRIM(p.product) = 'GTXPro'
            THEN 'GTX Pro'
            ELSE p.product
        END
    ) = TRIM(pr.product)

GROUP BY st.regional_office
ORDER BY won_revenue DESC;



SELECT
    SUM(CASE
        WHEN LOWER(TRIM(deal_stage)) = 'won'
        THEN 1 ELSE 0
    END) AS total_won_deals,

    SUM(CASE
        WHEN LOWER(TRIM(deal_stage)) = 'lost'
        THEN 1 ELSE 0
    END) AS total_lost_deals,

    ROUND(
        100.0 * SUM(CASE
            WHEN LOWER(TRIM(deal_stage)) = 'won'
            THEN 1 ELSE 0
        END)
        /
        NULLIF(SUM(CASE
            WHEN LOWER(TRIM(deal_stage)) IN ('won', 'lost')
            THEN 1 ELSE 0
        END), 0),
        2
    ) AS overall_win_rate_pct

FROM stg_sales_pipeline;



WITH agent_performance AS (
    SELECT
        p.sales_agent,

        COUNT(*) AS total_opportunities,

        SUM(CASE
            WHEN LOWER(TRIM(p.deal_stage)) = 'won'
            THEN 1 ELSE 0
        END) AS won_deals,

        SUM(CASE
            WHEN LOWER(TRIM(p.deal_stage)) = 'lost'
            THEN 1 ELSE 0
        END) AS lost_deals,

        SUM(CASE
            WHEN LOWER(TRIM(p.deal_stage))
                 IN ('prospecting', 'engaging')
            THEN 1 ELSE 0
        END) AS open_opportunities,

        SUM(CASE
            WHEN LOWER(TRIM(p.deal_stage)) = 'won'
            THEN CAST(TRIM(p.close_value) AS DECIMAL(15,2))
            ELSE 0
        END) AS won_revenue,

        ROUND(
            100.0 * SUM(CASE
                WHEN LOWER(TRIM(p.deal_stage)) = 'won'
                THEN 1 ELSE 0
            END)
            /
            NULLIF(SUM(CASE
                WHEN LOWER(TRIM(p.deal_stage))
                     IN ('won', 'lost')
                THEN 1 ELSE 0
            END), 0),
            2
        ) AS win_rate_pct,

        ROUND(
            SUM(CASE
                WHEN LOWER(TRIM(p.deal_stage)) = 'won'
                THEN CAST(TRIM(p.close_value) AS DECIMAL(15,2))
                ELSE 0
            END)
            /
            NULLIF(SUM(CASE
                WHEN LOWER(TRIM(p.deal_stage)) = 'won'
                THEN 1 ELSE 0
            END), 0),
            2
        ) AS avg_won_deal_size,

        SUM(CASE
            WHEN LOWER(TRIM(p.deal_stage)) = 'won'
                 AND pr.product IS NOT NULL
            THEN CAST(TRIM(p.close_value) AS DECIMAL(15,2))
                 - CAST(TRIM(pr.sales_price) AS DECIMAL(15,2))
            ELSE 0
        END) AS net_price_difference

    FROM stg_sales_pipeline p

    LEFT JOIN stg_products pr
        ON TRIM(
            CASE
                WHEN TRIM(p.product) = 'GTXPro'
                THEN 'GTX Pro'
                ELSE p.product
            END
        ) = TRIM(pr.product)

    GROUP BY p.sales_agent
)

SELECT
    *,
    CASE
        WHEN win_rate_pct < 60 THEN 'Poor'
        WHEN win_rate_pct > 65 THEN 'Good'
        ELSE 'Average'
    END AS performance_category

FROM agent_performance

ORDER BY
    won_revenue DESC;
    
    

SELECT
    st.sales_agent,
    st.manager,
    st.regional_office,
    COUNT(p.opportunity_id) AS total_opportunities
FROM stg_sales_teams st
LEFT JOIN stg_sales_pipeline p
    ON TRIM(st.sales_agent) = TRIM(p.sales_agent)
GROUP BY
    st.sales_agent,
    st.manager,
    st.regional_office
HAVING COUNT(p.opportunity_id) = 0
ORDER BY st.sales_agent;



WITH won_sales AS (
    SELECT
        2017 AS sales_year,
        QUARTER(STR_TO_DATE(TRIM(close_date), '%Y-%m-%d')) AS sales_quarter,
        CAST(TRIM(close_value) AS DECIMAL(15,2)) AS close_value
    FROM stg_sales_pipeline
    WHERE LOWER(TRIM(deal_stage)) = 'won'
      AND STR_TO_DATE(TRIM(close_date), '%Y-%m-%d') IS NOT NULL
)
SELECT
    sales_year,
    sales_quarter,
    CONCAT(sales_year, '-Q', sales_quarter) AS quarter_label,
    COUNT(*) AS won_deals,
    SUM(close_value) AS won_revenue
FROM won_sales
GROUP BY sales_year, sales_quarter
ORDER BY sales_year, sales_quarter;



SELECT
    CASE
        WHEN TRIM(product) = 'GTXPro' THEN 'GTX Pro'
        ELSE TRIM(product)
    END AS product_name,

    SUM(CASE
        WHEN LOWER(TRIM(deal_stage)) = 'won' THEN 1
        ELSE 0
    END) AS won_deals,

    SUM(CASE
        WHEN LOWER(TRIM(deal_stage)) = 'lost' THEN 1
        ELSE 0
    END) AS lost_deals,

    ROUND(
        100.0 * SUM(
            CASE WHEN LOWER(TRIM(deal_stage)) = 'won'
                 THEN 1 ELSE 0 END
        )
        / NULLIF(
            SUM(CASE
                WHEN LOWER(TRIM(deal_stage)) IN ('won', 'lost')
                THEN 1 ELSE 0
            END),
            0
        ),
        2
    ) AS win_rate_pct

FROM stg_sales_pipeline
WHERE TRIM(product) <> ''
GROUP BY
    CASE
        WHEN TRIM(product) = 'GTXPro' THEN 'GTX Pro'
        ELSE TRIM(product)
    END
ORDER BY win_rate_pct DESC;