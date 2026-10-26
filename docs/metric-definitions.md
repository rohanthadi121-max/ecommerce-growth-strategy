# Metric dictionary and analytical guardrails

| Metric | Definition | Limitation |
|---|---|---|
| Purchase revenue | Sum of positive quantity × positive unit price on non-cancelled invoice lines | Gross positive-sale proxy; not net revenue or profit |
| Monthly orders | Count of distinct qualifying invoices in each month | Invoice ID should be assessed for global uniqueness across sheets |
| Average order value (AOV) | Positive purchase revenue ÷ number of qualifying invoices | No refunds or discounts reconciled |
| Repeat-order customer share | Known-ID customers with >= 2 observed purchase invoices / known-ID customers | Customer IDs missing for some transactions; bounded by observation window |
| RFM recency | Days since final observed purchase at snapshot | No observations after data window |
| RFM frequency | Number of distinct observed purchase invoices | Does not establish lifetime behaviour |
| RFM monetary | Sum of positive observed purchase revenue | Does not reflect refund-adjusted lifetime value |
| Cancellation lines | Source lines flagged by negative quantity or invoice code beginning C | Not equivalent to resolved return amount |

## Quality gates before any claims
- Compare input rows with UCI data dictionary; inspect both workbook sheets.
- Check date type coercion and missingness; never silently turn failed date parsing into valid dates.
- Identify cancellations and any non-sales transactions.
- Validate invoice keys for collisions across time periods.
- Examine outliers and unexpectedly high purchase values.
- State the treatment of negative quantities, zero prices and customer-ID missingness.
- Reconcile a hand-checked subset of invoices against output KPIs.
- Do not call correlation, RFM segments or scenario outputs causal impact.

## Scope warning
Historical transactions allow descriptive sales analysis. They do **not** directly support TikTok Shop GMV, platform conversion rates, merchant acquisition, true retention or customer acquisition costs.
