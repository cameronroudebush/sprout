-- Subscription Query
-- This SQL File contains how we try and guess subscriptions or reoccurring transactions
-- that we can display to the user.
--
-- Expects the following inputs:
-- 1. User ID for who we want the transactions for.
-- 2. How many transactions counts as a subscription as an integer.
-- 3. The amount of variance to allow in increased variance cases. Like `0.65`
-- 4. The amount of variance we allow in our transactions to still be subscriptions, like `0.3`
WITH
    CleanedTransactions AS (
        SELECT
            t.id AS transactionId,
            t.accountId,
            t.description,
            t.categoryId,
            t.amount,
            t.posted,
            REGEXP_REPLACE (
                REGEXP_REPLACE (
                    REGEXP_REPLACE (
                        REGEXP_REPLACE (
                            REGEXP_REPLACE (
                                TRIM(
                                    REPLACE (
                                        REPLACE (
                                            REPLACE (UPPER(t.description), 'WITHDRAWAL ', ''),
                                            'POS DEBIT ',
                                            ''
                                        ),
                                        'ACH ',
                                        ''
                                    )
                                ),
                                -- Remove masked strings (e.g., XXXXXX3592)
                                'X{2,}\d*',
                                ''
                            ),
                            -- Remove phone numbers
                            '\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4}',
                            ''
                        ),
                        -- Remove trailing states
                        '\b(AL|AK|AZ|AR|CA|CO|CT|DE|FL|GA|HI|ID|IL|IN|IA|KS|KY|LA|ME|MD|MA|MI|MN|MS|MO|MT|NE|NV|NH|NJ|NM|NY|NC|ND|OH|OK|OR|PA|RI|SC|SD|TN|TX|UT|VT|VA|WA|WV|WI|WY)\b',
                        ''
                    ),
                    -- Remove zip codes
                    '\b\d{5}(-\d{4})?\b',
                    ''
                ),
                -- Smash multiple spaces
                '\s+',
                ' '
            ) AS standardized_description
        FROM
            "transaction" t
            JOIN "account" a ON t.accountId = a.id
        WHERE
            t.pending = 0
            AND t.amount < 0
            AND a.type IN ('depository', 'credit')
            AND a.userId = ?
    ),
    MatchKeysGenerated AS (
        SELECT
            *,
            -- Compare by only the first N characters for matching keys
            SUBSTR (standardized_description, 1, 12) AS match_key
        FROM
            CleanedTransactions
    ),
    DeduplicatedTransactions AS (
        SELECT
            accountId,
            match_key,
            categoryId,
            amount,
            posted,
            DATE (posted) as posted_date
        FROM
            MatchKeysGenerated
        GROUP BY
            accountId,
            categoryId,
            match_key,
            amount,
            DATE (posted)
    ),
    GroupedByPrefix AS (
        -- Aggregate using the clean match_key and original accountId grouping rules
        SELECT
            m.accountId,
            m.match_key,
            m.categoryId,
            COUNT(*) AS transaction_count,
            MIN(m.amount) AS min_amount,
            MAX(m.amount) AS max_amount,
            AVG(m.amount) AS avg_amount,
            MIN(m.posted) AS first_posted,
            MAX(m.posted) AS last_posted,
            ROUND(
                (
                    julianday (MAX(m.posted)) - julianday (MIN(m.posted))
                ) / (COUNT(*) - 1),
                2
            ) AS avg_days_between
        FROM
            DeduplicatedTransactions m
            JOIN "category" c ON m.categoryId = c.id
        GROUP BY
            m.accountId,
            m.categoryId,
            m.match_key
        HAVING
            transaction_count > ?
            AND (
                julianday (MAX(m.posted)) - julianday (MIN(m.posted))
            ) > 14
            -- Allow change in variance depending on the increasedSubVariance
            AND ABS(MAX(m.amount) - MIN(m.amount)) <= ABS(AVG(m.amount)) * CASE
                WHEN c.increasedSubVariance = 1 THEN ?
                ELSE ?
            END
    ),
    LatestTransactionDetails AS (
        -- Pair the absolute latest row details
        SELECT
            g.*,
            c.transactionId,
            c.description AS latest_description,
            ROW_NUMBER() OVER (
                PARTITION BY
                    g.accountId,
                    g.categoryId,
                    g.match_key
                ORDER BY
                    c.posted DESC
            ) AS rn
        FROM
            GroupedByPrefix g
            JOIN MatchKeysGenerated c ON c.accountId = g.accountId
            AND c.categoryId = g.categoryId
            AND SUBSTR (c.standardized_description, 1, 12) = g.match_key
    )
SELECT
    transactionId,
    accountId,
    match_key,
    categoryId,
    transaction_count,
    min_amount,
    max_amount,
    avg_amount,
    first_posted,
    last_posted,
    avg_days_between,
    latest_description
FROM
    LatestTransactionDetails
WHERE
    rn = 1
ORDER BY
    last_posted DESC,
    transaction_count DESC;