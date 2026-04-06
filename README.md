🛡️ Kenyan Agri-Traceability & Counterfeit Detection

A digital audit engine for Kenyan agriculture. Uses PostgreSQL window functions to detect counterfeit fertilizer and seed batches by identifying 'cloned' IDs and impossible supply chain movements.

📌 Project Overview
In Kenya, the "Fake Fertilizer" and "Certified Seed" crisis costs the agricultural sector over KES 270 Billion ($2.1B) annually in lost yields. Counterfeiters often clone legitimate Batch IDs or leak genuine products into "grey markets" without quality control.

This project is a Digital Audit Engine built with PostgreSQL. It uses advanced time-series analysis to identify "Impossible Logic" in the supply chain—automatically flagging batches that appear in two places at once or skip critical distribution steps.

🛠️ Tech Stack
Database: PostgreSQL 16

Key Logic: SQL Window Functions (LAG), Partitioning, and Interval Math.

Dataset: Synthetic 2026 Kenyan Agricultural Movement Data (Mombasa-Nairobi-Rift Valley).

🚀 The "Audit" Logic
The engine monitors the Chain of Custody from the Port of Mombasa to local retailers in Kitale or Eldoret. It flags three specific types of fraud:

ID Cloning (The Duplicate): Identifies if the same Batch ID is scanned in two different cities simultaneously.

Supply Chain Leakage: Detects if a product reached a retailer without ever being scanned at a certified regional distributor.

Impossible Speed: Flags batches that move across the country (e.g., Mombasa to Kisumu) faster than physically possible by truck.

📊 Sample SQL Implementation
SQL
-- Using Window Functions to detect "Cloned" IDs
WITH chain_analysis AS (
    SELECT 
        batch_id, 
        location, 
        scan_timestamp,
        LAG(location) OVER (PARTITION BY batch_id ORDER BY scan_timestamp) AS prev_location,
        LAG(scan_timestamp) OVER (PARTITION BY batch_id ORDER BY scan_timestamp) AS prev_time
    FROM agri_traceability
)
SELECT batch_id, 
       CASE 
           WHEN location != prev_location AND scan_timestamp = prev_time 
           THEN '🚨 CRITICAL: DUPLICATE ID / CLONE'
           ELSE 'VALID'
       END AS status
FROM chain_analysis;
📈 Business & Social Impact
Food Security: Ensures farmers receive 100% genuine inputs, protecting national crop yields.

Revenue Protection: Helps legitimate manufacturers (like Kenya Seed Co) identify exactly where their supply chain is leaking.

Regulatory Efficiency: Allows government inspectors (KEPHIS/KALRO) to move from "Random Testing" to "Data-Driven Targeted Inspections."

📂 Project Structure
/data: Kenyan_Agri_Traceability_2026.csv (Movement Logs).

/scripts: schema.sql (Table definitions and Audit Queries).

🤝 Connect with Me
I am a Data Professional passionate about using SQL to solve Kenya's toughest logistics and integrity challenges.
https://www.linkedin.com/in/sammy-kimaru-da43322/
