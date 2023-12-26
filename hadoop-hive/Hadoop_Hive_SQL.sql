# Creating a table for telecom data

CREATE TABLE telecom_data (
customerID STRING,
gender STRING,
SeniorCitizen INT,
Partner STRING,
Dependents STRING,
tenure INT,
PhoneService STRING,
MultipleLines STRING,
InternetService STRING,
OnlineSecurity STRING,
OnlineBackup STRING,
DeviceProtection STRING,
TechSupport STRING,
StreamingTV STRING,
StreamingMovies STRING,
Contract STRING,
PaperlessBilling STRING,
PaymentMethod STRING,
MonthlyCharges FLOAT,
TotalCharges FLOAT,
Churn STRING
)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ','
STORED AS TEXTFILE;

# Loading the data into the table and querying it to check

load data local inpath 'file:///home/darshanas05/Telecom_customer_churn_data.csv' into table telecom_data;

set hive.cli.print.header = true;

SELECT * FROM telecom_data LIMIT 10;

# HiveQL query to find the total number of customers in the dataset

SELECT COUNT(*) FROM telecom_data;

# HiveQL query to find the number of customers who have churned

SELECT COUNT(*) FROM telecom_data WHERE Churn = 'Yes';

# HiveQL query to find the number of customers who have churned, grouped by their Contract type

SELECT Contract, COUNT(*)
FROM telecom_data
WHERE Churn = 'Yes'
GROUP BY Contract;

# HiveQL query to find the average MonthlyCharges for customers who have churned vs those who have not

SELECT Churn, AVG(MonthlyCharges)
FROM telecom_data
GROUP BY Churn;

# Determine the maximum, minimum, and average tenure of the customers

SELECT MAX(tenure), MIN(tenure), AVG(tenure)
FROM telecom_data;

#  Find out which PaymentMethod is most popular among customers

SELECT PaymentMethod, COUNT(*)
FROM telecom_data
GROUP BY PaymentMethod
ORDER BY COUNT(*) DESC LIMIT 1;

#Analyze the relationship between PaperlessBilling and churn rate

SELECT PaperlessBilling, COUNT(*)
FROM telecom_data
WHERE Churn = 'Yes'
GROUP BY PaperlessBilling;

# Create a partitioned table by Contract and load the data from the original table

CREATE TABLE telecom_data_partitioned (customerID STRING,
gender STRING,
SeniorCitizen INT,
Partner STRING,
Dependents STRING,
tenure INT,
PhoneService STRING,
MultipleLines STRING,
InternetService STRING,
OnlineSecurity STRING,
OnlineBackup STRING,
DeviceProtection STRING,
TechSupport STRING,
StreamingTV STRING,
StreamingMovies STRING,
PaperlessBilling STRING,
PaymentMethod STRING,
MonthlyCharges FLOAT,
TotalCharges FLOAT,
Churn STRING)
PARTITIONED BY (Contract STRING);

INSERT OVERWRITE TABLE telecom_data_partitioned PARTITION(Contract)
SELECT * FROM telecom_data;

# HiveQL query to find the number of customers who have churned in each Contract type using the partitioned table

SELECT Contract, COUNT(*)
FROM telecom_data_partitioned
WHERE Churn = 'Yes'
GROUP BY Contract;

# Creating a bucketed table by tenure into 6 buckets.

CREATE TABLE telecom_data_bucketed ( 
customerID STRING,
gender STRING,
SeniorCitizen INT,
Partner STRING,
Dependents STRING,
PhoneService STRING,
MultipleLines STRING,
InternetService STRING,
OnlineSecurity STRING,
OnlineBackup STRING,
DeviceProtection STRING,
TechSupport STRING,
StreamingTV STRING,
StreamingMovies STRING,
Contract STRING,
PaperlessBilling STRING,
PaymentMethod STRING,
MonthlyCharges FLOAT,
TotalCharges FLOAT,
Churn STRING)
CLUSTERED BY (tenure) INTO 6 BUCKETS;

#  Load the data from the original table into the bucketed table

INSERT OVERWRITE TABLE telecom_data_bucketed
SELECT * FROM telecom_data;

# Joining the tables to check performance

SELECT *
FROM telecom_data t
JOIN demographic_data d ON t.customerID = d.customerID
LIMIT 10;
