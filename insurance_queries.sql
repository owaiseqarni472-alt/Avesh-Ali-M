CREATE DATABASE insurance_project;
USE insurance_project;
CREATE TABLE executive_master (
Executive_ID INT PRIMARY KEY,
Executive_Name VARCHAR(100)
);
select * from executive_master;
CREATE TABLE brokerage (
client_name VARCHAR(150),
policy_number VARCHAR(50),
policy_status VARCHAR(50),
policy_start_date DATE,
policy_end_date DATE,
product_group VARCHAR(100),
Executive_ID INT,
Executive_Name VARCHAR(100),
Branch_name VARCHAR(100),
solution_group VARCHAR(100),
income_class VARCHAR(50),
Brokerage_Amount FLOAT,
income_due_date DATE,
revenue_transaction_type VARCHAR(50),
renewal_status VARCHAR(50),
last_updated_date DATE,
Policy_year INT,
Policy_month VARCHAR(20)
);
select * from brokerage;


ALTER TABLE brokerage
ADD CONSTRAINT fk_exec_brokerage
FOREIGN KEY (Executive_ID)
REFERENCES executive_master(Executive_ID);


CREATE TABLE budget (
Branch VARCHAR(100),
Executive_ID INT,
Executive_Name VARCHAR(100),
New_Role2 VARCHAR(100),
New_Budget INT,
Cross_sell_budget INT,
Renewal_Budget INT,
Total_Budget INT
);
select * from budget;

ALTER TABLE budget
ADD CONSTRAINT fk_exec_budget
FOREIGN KEY (Executive_ID)
REFERENCES executive_master(Executive_ID);

CREATE TABLE opportunity (
opportunity_name VARCHAR(150),
opportunity_id VARCHAR(50),
Executive_ID INT,
Executive_Name VARCHAR(100),
premium_amount INT,
revenue_amount INT,
closing_date DATE,
stage VARCHAR(50),
Branch_name VARCHAR(100),
specialty VARCHAR(100),
product_group VARCHAR(100),
product_sub_group VARCHAR(100),
risk_details VARCHAR(200),
closing_year INT,
closing_month VARCHAR(20)
);
select * from opportunity;

ALTER TABLE opportunity
ADD CONSTRAINT fk_exec_opportunity
FOREIGN KEY (Executive_ID)
REFERENCES executive_master(Executive_ID);

CREATE TABLE meetings (
Executive_ID INT,
Executive_Name VARCHAR(100),
Branch_name VARCHAR(100),
global_attendees VARCHAR(200),
meeting_date DATE
);
select * from meetings;

ALTER TABLE meetings
ADD CONSTRAINT fk_exec_meetings
FOREIGN KEY (Executive_ID)
REFERENCES executive_master(Executive_ID);

CREATE TABLE fees (
client_name VARCHAR(150),
Branch_name VARCHAR(100),
solution_group VARCHAR(100),
Executive_ID INT,
Executive_Name VARCHAR(100),
income_class VARCHAR(50),
Brokerage_Amount INT,
income_due_date DATE,
revenue_transaction_type VARCHAR(50),
fees_year INT,
fees_month VARCHAR(20)
);
select * from fees;

ALTER TABLE fees
ADD CONSTRAINT fk_exec_fees
FOREIGN KEY (Executive_ID)
REFERENCES executive_master(Executive_ID);

CREATE TABLE invoice (
invoice_number BIGINT PRIMARY KEY,
invoice_date DATE,
revenue_transaction_type VARCHAR(50),
Branch_name VARCHAR(100),
solution_group VARCHAR(100),
Executive_ID INT,
Executive_Name VARCHAR(100),
income_class VARCHAR(50),
client_name VARCHAR(150),
policy_number VARCHAR(50),
Brokerage_Amount FLOAT,
income_due_date DATE
);
select * from invoice;

ALTER TABLE invoice
ADD CONSTRAINT fk_invoice_exec
FOREIGN KEY (Executive_ID)
REFERENCES executive_master(Executive_ID);

#BASIC ANALYSIS#

# Total Revenue
SELECT SUM(Brokerage_Amount) AS total_revenue
FROM brokerage;

# Total_Budget
SELECT SUM(Total_Budget) AS Total_Budget
FROM budget;

#Total Target Achivement%
SELECT 
SUM(Brokerage_Amount) AS total_brokerage,
(SELECT SUM(Total_Budget) FROM budget) AS total_budget,
(SUM(Brokerage_Amount) / (SELECT SUM(Total_Budget) FROM budget)) * 100 AS target_percentage
FROM brokerage;

#Total_Meetings by Executive's
SELECT 
Branch_name,
COUNT(meeting_date) AS total_meetings
FROM meetings
GROUP BY Branch_name
ORDER BY total_meetings DESC;

#Total Policies sold by Executive's 
SELECT 
Branch_name,
COUNT(policy_number) AS total_policies
FROM brokerage
GROUP BY Branch_name
ORDER BY total_policies DESC;

#Top Executives
SELECT Executive_Name,
SUM(Brokerage_Amount) AS revenue
FROM brokerage
GROUP BY Executive_Name
ORDER BY revenue DESC;

#Opportunity Stage Analysis
SELECT stage,
COUNT(*) AS total_opportunities
FROM opportunity
GROUP BY stage;

#Meetings Conducted by Executive
SELECT Executive_Name,
COUNT(meeting_date) AS total_meetings
FROM meetings
GROUP BY Executive_Name;

#Stored Procedures
#Procedure 1 — Executive Performance

CREATE PROCEDURE executive_performance()
BEGIN
SELECT 
e.Executive_Name,
SUM(b.Brokerage_Amount) AS revenue
FROM brokerage b
JOIN executive_master e
ON b.Executive_ID = e.Executive_ID
GROUP BY e.Executive_Name
ORDER BY revenue DESC
END//
DELIMITER ;
call insurance_project.executive_performance();

#Procedure 2 — Budget vs Actual
CREATE DEFINER=`root`@`localhost` PROCEDURE `budget_vs_actual`()
BEGIN
SELECT 
e.Executive_Name,
bu.Total_Budget,
SUM(br.Brokerage_Amount) AS actual_revenue
FROM budget bu
JOIN executive_master e
ON bu.Executive_ID = e.Executive_ID
JOIN brokerage br
ON br.Executive_ID = e.Executive_ID
GROUP BY e.Executive_Name, bu.Total_Budget
END//
DELIMITER ;
call insurance_project.budget_vs_actual();

# Rank Executives by Revenue
SELECT 
Executive_Name,
SUM(Brokerage_Amount) AS revenue,
RANK() OVER (ORDER BY SUM(Brokerage_Amount) DESC) AS revenue_rank
FROM brokerage
GROUP BY Executive_Name;

# Month & yearly  Revenue Trend
SELECT Policy_year, Policy_month,
SUM(Brokerage_Amount) AS revenue
FROM brokerage
GROUP BY Policy_year, Policy_month
ORDER BY Policy_year;







