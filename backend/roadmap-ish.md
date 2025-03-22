# Tasks

## Postgres:

- pg_cron for deleting notices
- pg_mooncake for analytics
- pgai (possibly) for text queries
- Use row level security (built in feature in postgres)

## Goals:

- Implement notis for notices and other events
- Selecting more than one/deleting files in upload screen
- Select dates for notices
- Show a preview of the files in the notices
- Add text filtering to notices
- Implement the actual information for the school's scholarhips and benefits
- Job board for ITSU's students
- Only the user who created a notice can edit it or take it down
- Table(s) with hierarchy for access levels and reach levels to the users
- Table with classes taken by each professor
- Tables for group, related to their classes, and therefore, professors
- Add viewers privacy filter (not everyone can see every notice)
- Add polls
- Make user info better (add schedules)
- Community section ¿?

# Steps for PostgreSQL migration:

1. Backup SQLite Data:

```bash
sqlite3 megafonito.db .dump > backup.sql
```

2. Set Up PostgreSQL:

   - Install PostgreSQL
   - Create a Database and User:

   ```sql
   CREATE DATABASE megafonito;
   CREATE USER deno_user WITH PASSWORD 'your_password';
   GRANT ALL PRIVILEGES ON DATABASE megafonito TO deno_user;
   ```

3. Convert SQLite Schema to PostgreSQL:

INTEGER --> SERIAL/BIGSERIAL --> Use SERIAL for auto-incrementing IDs.
TEXT --> VARCHAR or TEXT --> Use TEXT for large strings.
BOOLEAN --> BOOLEAN --> Use TRUE/FALSE instead of 1/0.
DATETIME --> TIMESTAMP -->PostgreSQL has no DATETIME alias.
BLOB (Uint8Array) --> BYTEA --> For binary data.

#### Create .sql Files for Schema:

    Instead of embedding SQL strings in TypeScript, create separate .sql files for better maintainability and readability.

4. Migrate Data

Use tools like pgLoader to automate the migration:

```bash
pgloader ./megafonito.db postgresql://deno_user:your_password@localhost/megafonito
```

5. Update Deno Code

Switch Database Driver: Replace jsr:@db/sqlite with deno-postgres.

6. Implement PostgreSQL-Specific Features

   - Expiry Dates with pg_cron:
   - Row-Level Security (RLS):
   - JSONB for Analytics:
     Add a metadata JSONB column to store flexible data (e.g., user activity logs).

7. Test Thoroughly

   - Validate data integrity after migration.
   - Test CRUD operations, transactions, and new features like expiry dates.
   - Use PostgreSQL logs (log_statement = 'all' in postgresql.conf) for debugging.

8. Use pgAdmin (Optional but Recommended)

   - Why pgAdmin?
     - GUI for Database Management: Easily inspect tables, run queries, and monitor performance.
     - Migration Assistance: Use the import/export tools for data migration.
     - Debugging: Visualize query execution plans and logs.
