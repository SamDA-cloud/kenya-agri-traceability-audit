CREATE TABLE agri_traceability (
    batch_id VARCHAR(20),
    product_name VARCHAR(100),
    actor_role VARCHAR(50),
    location VARCHAR(100),
    scan_timestamp TIMESTAMP,
    digital_signature VARCHAR(50)
);
SELECT * FROM agri_traceability

---The Counterfeit detection engine
--Uses Postgre window fxn (LAG) to compare each scan with the one before it 

WITH chain_analysis AS (
    SELECT 
        batch_id,
        product_name,
        actor_role,
        location,
        scan_timestamp,
        -- Get the previous location and role for the same batch
        LAG(location) OVER (PARTITION BY batch_id ORDER BY scan_timestamp) AS prev_location,
        LAG(actor_role) OVER (PARTITION BY batch_id ORDER BY scan_timestamp) AS prev_role,
        LAG(scan_timestamp) OVER (PARTITION BY batch_id ORDER BY scan_timestamp) AS prev_time
    FROM agri_traceability
)
SELECT 
    batch_id,
    product_name,
    location AS "Current_Location",
    scan_timestamp,
    CASE 
        -- 1. Skipped Step: If a product goes from Manufacturer to Retailer without a Distributor
        WHEN actor_role = 'Retailer' AND prev_role = 'Manufacturer' 
            THEN 'FLAG: MISSING DISTRIBUTOR SCAN (Potential Leakage)'
            
        -- 2. Duplicate ID: If the same ID is scanned at the same time in different cities
        WHEN location != prev_location AND scan_timestamp = prev_time
            THEN 'CRITICAL: DUPLICATE ID (Counterfeit Clone detected)'
            
        -- 3. Impossible Speed: If it moves from Mombasa to Kisumu in 1 hour
        WHEN location = 'Kisumu Retail' AND prev_location = 'Mombasa Port' 
             AND (scan_timestamp - prev_time) < interval '6 hours'
            THEN 'FLAG: IMPOSSIBLE TRAVEL TIME (Identity Theft)'
            
        ELSE 'VALID'
    END AS traceability_status
FROM chain_analysis
WHERE prev_role IS NOT NULL; -- Ignore the first scan (Manufacturer)

---Key skills displayed;
--Using LAG to analyse time series data
--Understanding the chain of custody from port o farm
--Using data to prevent financial and agricultural loss

----END OF PROJECT---