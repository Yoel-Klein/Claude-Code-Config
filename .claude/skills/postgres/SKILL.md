---
name: postgres
description: Efficiently execute PostgreSQL database operations via SSH without tunnel overhead
---

# PostgreSQL Operations - Silent Mode

Pre-configured database access. Execute queries silently, show only results to user.

## Connection (Pre-configured)

```bash
ssh -i Keys/sms-platform-key.pem ubuntu@3.149.170.249 \
  "PGPASSWORD=changeme123 psql -h localhost -p 5433 -U smsplatform -d smsplatform_db -c 'QUERY'"
```

Server: 3.149.170.249 | Port: 5433 | DB: smsplatform_db | User: smsplatform

## Command Patterns

**Schema:**
- List tables: `\dt`
- Describe table: `\d+ table_name`
- List columns: `SELECT column_name, data_type FROM information_schema.columns WHERE table_name='X'`

**Queries:**
- Clean output: `-t -A -c "SELECT ..."`
- Formatted: `-c "SELECT ..."`
- Always use `LIMIT` for safety

**Modifications:**
- INSERT/UPDATE/DELETE: Always add `RETURNING *`
- Transactions: Wrap in `BEGIN; ... COMMIT;`
- Escape quotes: Single quotes for SQL strings, backslash for nested quotes

**Output Flags:**
- `-t` = No headers/footers
- `-A` = No padding (clean)
- `-c` = Execute command
- `RETURNING *` = Show affected rows

## Instructions

1. **Execute query silently** - Don't show SSH command to user
2. **Parse output** - Format nicely if needed
3. **Report results** - Show only the data/outcome
4. **Handle errors** - Show clear error message if query fails

Example:
- User asks: "How many customers do we have?"
- You run: `ssh -i ... "PGPASSWORD=... psql ... -t -A -c 'SELECT COUNT(*) FROM customers;'"`
- You show: "There are 2 customers in the database."

## Key Points

- All connection details are pre-configured (no credential search needed)
- All commands are copy-paste ready with PGPASSWORD
- Test queries first (use LIMIT, COUNT before DELETE/UPDATE)
- Use transactions for multi-statement operations
- Format output nicely for user (don't show raw psql output unless asked)

