import { sql } from "../dbMod.ts";

// Basic database row interface
export interface DatabaseRow {
  [key: string]: any;
}

/**
 * Executes a SQL query that modifies the database (INSERT, UPDATE, DELETE)
 */
export async function execute(
  query: string,
  params: any[] = []
): Promise<number> {
  try {
    const result = await sql.unsafe(query, params);
    return result.count ?? 0;
  } catch (error) {
    console.error("Database execution error:", error);
    throw error;
  }
}

/**
 * Executes a SQL query that retrieves data from the database (SELECT)
 */
export async function queryAll(
  query: string,
  params: any = []
): Promise<any[]> {
  try {
    const result = await sql.unsafe(query, params);
    // Convert to array (result is already array-like)
    return [...result];
  } catch (error) {
    console.error("Database query error:", error);
    throw error;
  }
}

/**
 * Executes a SQL query that retrieves a single row from the database
 */
export async function queryOne(
  query: string,
  params: any[] = []
): Promise<any> {
  try {
    const result = await sql.unsafe(query, params);
    if (!result || result.length === 0) {
      throw new Error("No results found");
    }
    return result[0];
  } catch (error) {
    console.error("Database query error:", error);
    throw error;
  }
}

/**
 * Executes a SQL transaction
 */
export async function executeTransaction(
  queries: string[],
  paramsArray: any[][]
): Promise<number[]> {
  const results: number[] = [];

  try {
    await sql.begin(async (transaction) => {
      for (let i = 0; i < queries.length; i++) {
        const result = await transaction.unsafe(queries[i], paramsArray[i]);
        results.push(result.count ?? 0);
      }
    });

    console.log("Transaction executed successfully!");
    return results;
  } catch (error) {
    console.error("Transaction execution error:", error);
    throw error;
  }
}

/**
 * Executes a transaction with dynamic logic
 */
export async function executeTransactionWithLogic(
  transactionLogic: (transaction: any) => Promise<any>
): Promise<any> {
  try {
    let result: any;

    await sql.begin(async (transaction) => {
      result = await transactionLogic(transaction);
    });

    console.log("Transaction executed successfully!");
    return result;
  } catch (error) {
    console.error("Transaction execution error:", error);
    throw error;
  }
}

/**
 * Executes a paginated query with total count
 */
export async function paginatedQuery<T>(
  query: string,
  page: number = 1,
  limit: number = 12,
  params: any[] = []
): Promise<{ data: any; total: number }> {
  const offset = (page - 1) * limit;

  // Remove the ORDER BY clause for the count query if present
  const queryWithoutOrder = query.replace(/ORDER BY[\s\S]*/i, "");

  // PostgreSQL count query
  const countQuery = `SELECT COUNT(*) as total FROM (${queryWithoutOrder}) AS subquery`;

  try {
    // Execute count query
    const totalResult = await sql.unsafe(countQuery, params);
    const totalRow = totalResult[0] as Record<string, any>;
    const total = Number(totalRow?.total || 0);

    // Add LIMIT and OFFSET for pagination
    const paginatedQuery = `${query} LIMIT $${params.length + 1} OFFSET $${
      params.length + 2
    }`;
    const paginatedParams = [...params, limit, offset];

    // Execute paginated query
    const result = await sql.unsafe(paginatedQuery, paginatedParams);
    const data = [...result];

    return { data, total };
  } catch (error) {
    console.error("Error in paginatedQuery:", error);
    return { data: [], total: 0 };
  }
}
