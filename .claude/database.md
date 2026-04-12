# Database Guidelines

> **Note:** These guidelines apply regardless of your database system (PostgreSQL, MySQL, SQLite, MongoDB) or ORM/query builder. Adapt migration formats and commands to your specific tooling.

## Migration Files

- Create migration files for all schema changes
- Apply all database changes through migration files (not directly in production)
- Name migrations: `{number}_{description}_{issue-number}.sql` (e.g., `001_add_user_roles_73.sql`)
- Add indexes for frequently queried columns
- Test migrations on copy of production data
- Keep database queries optimized (avoid N+1 queries)
- Document schema changes in migration comments

## Migration Best Practices

- Keep existing migrations immutable — create new ones for changes
- Backup database before running migrations in production
- Use transactions for multi-step migrations
- Make migrations reversible when possible (include DOWN/rollback logic)
- Test both up AND down migrations
- Keep migrations small and focused (one logical change per migration)
- Run migrations as part of deployment process

## Migration Structure

Each migration should have:
1. **Up migration**: Apply the change
2. **Down migration**: Rollback the change (if possible)
3. **Comments**: Explain why change is needed

**Example migration (raw SQL):**
```sql
-- Migration: 005_add_user_roles_73.sql
-- Issue: #73
-- Description: Add role column to support admin/user permissions

-- Up Migration
ALTER TABLE users ADD COLUMN role VARCHAR(20) NOT NULL DEFAULT 'user';
CREATE INDEX idx_users_role ON users(role);

-- Down Migration
DROP INDEX idx_users_role;
ALTER TABLE users DROP COLUMN role;
```

If using an ORM/migration tool (Prisma, Drizzle, Eloquent, SQLAlchemy, GORM, etc.), follow that tool's migration format instead. The same principles apply: reversible, small, focused, and documented.

## Dangerous Operations

- Adding NOT NULL columns: Add as nullable first, populate data, then add constraint
- Dropping columns: Deprecate first, then drop in later migration
- Renaming columns: Create new column, copy data, drop old column
- Large data migrations: Use batch processing, not single transaction

## Indexing Strategy

- Add indexes AFTER initial table creation (speeds up creation)
- Index foreign key columns used in JOINs
- Index columns used in WHERE clauses
- Index columns used in ORDER BY (for common sorting)
- Avoid over-indexing (slows down INSERT/UPDATE operations)
- Use partial indexes for common filtered queries
- Monitor slow queries and add indexes as needed

## Query Optimization

- Use parameterized queries exclusively (prevent SQL injection)
- Specify needed columns instead of SELECT *
- Use EXPLAIN to analyze query performance
- Use JOINs or eager loading to prevent N+1 queries
- Use database query logging in development
- Set up slow query logging in production
- Use connection pooling (one pool per application, not per query)
