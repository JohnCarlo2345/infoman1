# INFOMAN1 — Week 14 F2: CRUD and Reliable Transactions

## 🎯 Business Workflow
**Domain:** Inventory & Sales System
**Operation:** Place customer order → decrease product stock
**Business Invariant:** Stock quantity must never become negative. Every successful order must have exactly one matching stock deduction.

## 🔄 Transaction Boundary
- **Starts:** Begin transaction and lock the product row
- **Operations:** Validate stock → decrement product quantity → create order record → create order item record
- **Commit:** Only if ALL steps succeed
- **Rollback:** If ANY step fails — no partial changes remain

## ⚛️ ACID Properties
| Property        | Explanation                                               | Applied to My Workflow                                           |
|-----------------|-----------------------------------------------------------|------------------------------------------------------------------|
| **Atomicity**   | All or nothing — every related change succeeds or none do | If order creation fails, stock deduction is undone automatically |
| **Consistency** | Database rules stay valid before and after transaction    | Stock never goes below zero; foreign keys always valid           |
| **Isolation**   | Concurrent transactions don't interfere with each other   | Row lock prevents two orders from selling the last item          |
| **Durability**  | Committed changes persist after system restart            | Once committed, order and stock changes remain permanent         |

## 📊 Savepoint vs Full Rollback
- **SAVEPOINT:** Marks a position inside a transaction. `ROLLBACK TO SAVEPOINT` undoes only changes after that point — earlier work stays and the transaction stays open.
- **FULL ROLLBACK:** Cancels every change since `START TRANSACTION` — nothing from that transaction remains.
- **Example flow:** Update A → SAVEPOINT sp1 → Update B → ROLLBACK TO sp1 (B gone, A remains) → ROLLBACK (A also gone)

## ⚠️ Concurrency Risk & Control
- **Risk:** Two customers try buying the last item at the same time. Both read stock = 1 before either updates → both succeed → oversell.
- **Control Strategy:** Use `SELECT ... FOR UPDATE` to lock the row during checks. Use conditional update: `UPDATE products SET stock = stock - 1 WHERE id = ? AND stock >= 1`. Check `ROW_COUNT() = 1` — if zero, item is already taken.
