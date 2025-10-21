# 🏬 Target E-commerce SQL Analysis

This project analyzes Target's Brazilian e-commerce dataset using **Google BigQuery** to uncover key business insights such as customer behavior, sales trends, delivery performance, and payment patterns.

---

## 📊 Project Overview
As a Data Analyst at Target, the goal is to perform data-driven analysis on e-commerce transactions to help the business improve logistics, delivery speed, and overall customer satisfaction.

---

## 📁 Dataset
The dataset contains multiple tables:
- `customers`
- `orders`
- `order_items`
- `payments`
- `products`
- `sellers`

---

## 🎯 Key Objectives
1. **Exploratory Analysis**
   - Find data types, date ranges, and geographic distribution.
2. **Trend Analysis**
   - Study yearly and monthly order trends and seasonality.
3. **Delivery Performance**
   - Compare actual vs. estimated delivery times.
4. **Economic Impact**
   - Analyze total and average order/freight costs.
5. **Payment Insights**
   - Study payment methods and installment preferences.

---

## 🧮 Tools Used
- **Google BigQuery**
- **SQL**
- **Google Cloud Console**
- **Excel / Google Sheets** (for visualization)
- **Tableau / Power BI** *(optional, if you used them)*

---

## 🚀 Key Insights
- Orders show strong **growth trend from 2017 to 2018**.
- Customers are majorly concentrated in **São Paulo and Rio de Janeiro**.
- Deliveries in **some southern states** are **faster than expected**.
- Majority of payments were made **in installments via credit card**.

---

## 📈 Example Queries
```sql
-- Average delivery time vs estimated
SELECT
  c.customer_state,
  AVG(DATE_DIFF(o.order_delivered_customer_date, o.order_purchase_timestamp, DAY)) AS avg_delivery_days,
  AVG(DATE_DIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date, DAY)) AS diff_estimated_days
FROM `Target_SQL.orders` AS o
JOIN `Target_SQL.customers` AS c
ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY avg_delivery_days ASC
LIMIT 5;

🏁 Results Summary

Fastest Deliveries: SC, PR, SP, RJ, MG

Highest Freight Costs: AM, RR, AC, AP, PA

Strongest Sales Growth: +25% from 2017 → 2018 (Jan–Aug)
