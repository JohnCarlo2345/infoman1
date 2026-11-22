# INFOMAN1 — Week 13 F1: Lecture & Design Notes

## Project Domain
Inventory & Sales System — tracks customers, products, orders, and order items.

## SIX REQUIREMENTS
1. A customer can view a list of available products
2. A customer can place a new order
3. The system records which items are in each order
4. Staff can view a sales summary report
5. Staff can see current inventory levels and stock status
6. The system prevents duplicate customer emails

## BASELINE AUDIT
| Item                   | Status   | File                                   |
|------------------------|----------|----------------------------------------|
| Database Schema        | Working  | schema.sql                             |
| Seed Data              | Working  | seed.sql                               |
| SQL Views              | Working  | views.sql                              |
| Unique Constraint      | Verified | evidence/05-both-constraint-errors.png |
| Foreign Key Constraint | Verified | evidence/05-both-constraint-errors.png |
| View Updates Live Data | Verified | evidence/04-view-after-update.png      |

## ERD SUMMARY
- **customers (1) < (∞) orders** - one customer can have many orders
- **orders (1) < (∞) order_items** - one order has many items
- **products (1) < (∞) order_items** - one product can be in many orders
- Primary Keys: customer_id, product_id, order_id, order_item_id
- Foreign Keys: orders.customer_id >> customers.customer_id; order_items.order_id >> orders.order_id; order_items.product_id >> products.product_id

## FUNCTIONAL DEPENDENCY & NORMALIZATION
- **Functional Dependency:** order_total >> order_id (the total amount depends only on the order)
- **Problem Prevented:** Without separate tables, customer name/email would repeat in every order row >> updating a name would require changing many places >> **update anomaly avoided**
- **Not Invented Many-to-Many:** Used junction table `order_items` instead - one order <> many products through quantities

## VIEW vs EXPLANATION
- **SQL View:** Stores a SELECT query definition - reads live data from base tables every time you call it
- **Not a Copy:** When I updated product stock, `vw_inventory_status` showed the new value automatically - I never recreated the view
- **Purpose:** Presents joined/reorganized data without storing duplicate information

## CONNECTION SECURITY
- Database password goes in local config only - **never committed to GitHub**
- Placeholder values submitted instead - real credentials stay on my computer only
- Secrets excluded via .gitignore - connection info is private, not public project code
