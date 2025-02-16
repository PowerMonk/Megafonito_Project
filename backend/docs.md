Closes the database connection.
Should be called when the application is shutting down to ensure all resources are released.

Closes the database connection.
Should be called when the application is shutting down to ensure all resources are released.

Executes a SQL query that modifies the database (e.g., INSERT, UPDATE, DELETE).

@param query - The SQL query string to be executed.

@param params - Optional parameters to be used in the SQL query.
Supported types: string, number, null, Uint8Array, boolean

@return
The result of the query execution.

@return
Will throw an error if the query execution fails.

Executes a SQL query that modifies the database (e.g., INSERT, UPDATE, DELETE).

@param query - The SQL query string to be executed.

@param params - Optional parameters to be used in the SQL query.
Supported types: string, number, null, Uint8Array, boolean

@return
The result of the query execution.

@return
Will throw an error if the query execution fails.

Executes a SQL transaction.

@param queries - An array of SQL query strings to be executed within the transaction.

@param params - An array of arrays containing parameters for each query.

@return
The result of the transaction execution.

@return
Will throw an error if the transaction execution fails.

Executes a SQL transaction.

@param queries - An array of SQL query strings to be executed within the transaction.

@param params - An array of arrays containing parameters for each query.

@return
The result of the transaction execution.

@return
Will throw an error if the transaction execution fails.

Load environment variables from a `.env` file. Loaded variables are accessible
in a configuration object returned by the `load()` function, as well as optionally
exporting them to the process environment using the `export` option.

Inspired by the node modules {@linkcode https://github.com/motdotla/dotenv | dotenv}
and {@linkcode https://github.com/motdotla/dotenv-expand | dotenv-expand}.

Note: The key needs to match the pattern /^[a-zA-Z\_][a-zA-Z0-9_]\*$/.

## Basic usage

```sh
GREETING=hello world
```

Then import the environment variables using the `load` function.

@example
Basic usage
```ts ignore
// app.ts
import { load } from "@std/dotenv";

      console.log(await load({ export: true })); // { GREETING: "hello world" }
      console.log(Deno.env.get("GREETING")); // hello world
      ```

      Run this with `deno run --allow-read --allow-env app.ts`.

      .env files support blank lines, comments, multi-line values and more.
      See Parsing Rules below for more detail.

      ## Auto loading
      Import the `load.ts` module to auto-import from the `.env` file and into
      the process environment.

@example
Auto-loading
```ts ignore
// app.ts
import "@std/dotenv/load";

      console.log(Deno.env.get("GREETING")); // hello world
      ```

      Run this with `deno run --allow-read --allow-env app.ts`.

      ## Files
      Dotenv supports a number of different files, all of which are optional.
      File names and paths are configurable.

      |File|Purpose|
      |----|-------|
      |.env|primary file for storing key-value environment entries

      ## Configuration

      Loading environment files comes with a number of options passed into
      the `load()` function, all of which are optional.

      |Option|Default|Description
      |------|-------|-----------
      |envPath|./.env|Path and filename of the `.env` file.  Use null to prevent the .env file from being loaded.
      |export|false|When true, this will export all environment variables in the `.env` file to the process environment (e.g. for use by `Deno.env.get()`) but only if they are not already set.  If a variable is already in the process, the `.env` value is ignored.

      ### Example configuration

@example
Using with options
```ts ignore
import { load } from "@std/dotenv";

      const conf = await load({
        envPath: "./.env_prod", // Uses .env_prod instead of .env
        export: true, // Exports all variables to the environment
      });
      ```

      ## Permissions

      At a minimum, loading the `.env` related files requires the `--allow-read` permission.  Additionally, if
      you access the process environment, either through exporting your configuration or expanding variables
      in your `.env` file, you will need the `--allow-env` permission.  E.g.

      ```sh
      deno run --allow-read=.env --allow-env=ENV1,ENV2 app.ts
      ```

      ## Parsing Rules

      The parsing engine currently supports the following rules:

      - Variables that already exist in the environment are not overridden with
        `export: true`
      - `BASIC=basic` becomes `{ BASIC: "basic" }`
      - empty lines are skipped
      - lines beginning with `#` are treated as comments
      - empty values become empty strings (`EMPTY=` becomes `{ EMPTY: "" }`)
      - single and double quoted values are escaped (`SINGLE_QUOTE='quoted'` becomes
        `{ SINGLE_QUOTE: "quoted" }`)
      - new lines are expanded in double quoted values (`MULTILINE="new\nline"`
        becomes

      ```
      { MULTILINE: "new\nline" }
      ```

      - inner quotes are maintained (think JSON) (`JSON={"foo": "bar"}` becomes
        `{ JSON: "{\"foo\": \"bar\"}" }`)
      - whitespace is removed from both ends of unquoted values (see more on
        {@linkcode https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/Trim | trim})
        (`FOO= some value` becomes `{ FOO: "some value" }`)
      - whitespace is preserved on both ends of quoted values (`FOO=" some value "`
        becomes `{ FOO: " some value " }`)
      - dollar sign with an environment key in or without curly braces in unquoted
        values will expand the environment key (`KEY=$KEY` or `KEY=${KEY}` becomes
        `{ KEY: "<KEY_VALUE_FROM_ENV>" }`)
      - escaped dollar sign with an environment key in unquoted values will escape the
        environment key rather than expand (`KEY=\$KEY` becomes `{ KEY: "\\$KEY" }`)
      - colon and a minus sign with a default value(which can also be another expand
        value) in expanding construction in unquoted values will first attempt to
        expand the environment key. If itÔÇÖs not found, then it will return the default
        value (`KEY=${KEY:-default}` If KEY exists it becomes
        `{ KEY: "<KEY_VALUE_FROM_ENV>" }` If not, then it becomes
        `{ KEY: "default" }`. Also there is possible to do this case
        `KEY=${NO_SUCH_KEY:-${EXISTING_KEY:-default}}` which becomes
        `{ KEY: "<EXISTING_KEY_VALUE_FROM_ENV>" }`)

@param options
The options

@return
The parsed environment variables

Load environment variables from a `.env` file. Loaded variables are accessible
in a configuration object returned by the `load()` function, as well as optionally
exporting them to the process environment using the `export` option.

Inspired by the node modules {@linkcode https://github.com/motdotla/dotenv | dotenv}
and {@linkcode https://github.com/motdotla/dotenv-expand | dotenv-expand}.

Note: The key needs to match the pattern /^[a-zA-Z\_][a-zA-Z0-9_]\*$/.

## Basic usage

```sh
GREETING=hello world
```

Then import the environment variables using the `load` function.

@example
Basic usage
```ts ignore
// app.ts
import { load } from "@std/dotenv";

      console.log(await load({ export: true })); // { GREETING: "hello world" }
      console.log(Deno.env.get("GREETING")); // hello world
      ```

      Run this with `deno run --allow-read --allow-env app.ts`.

      .env files support blank lines, comments, multi-line values and more.
      See Parsing Rules below for more detail.

      ## Auto loading
      Import the `load.ts` module to auto-import from the `.env` file and into
      the process environment.

@example
Auto-loading
```ts ignore
// app.ts
import "@std/dotenv/load";

      console.log(Deno.env.get("GREETING")); // hello world
      ```

      Run this with `deno run --allow-read --allow-env app.ts`.

      ## Files
      Dotenv supports a number of different files, all of which are optional.
      File names and paths are configurable.

      |File|Purpose|
      |----|-------|
      |.env|primary file for storing key-value environment entries

      ## Configuration

      Loading environment files comes with a number of options passed into
      the `load()` function, all of which are optional.

      |Option|Default|Description
      |------|-------|-----------
      |envPath|./.env|Path and filename of the `.env` file.  Use null to prevent the .env file from being loaded.
      |export|false|When true, this will export all environment variables in the `.env` file to the process environment (e.g. for use by `Deno.env.get()`) but only if they are not already set.  If a variable is already in the process, the `.env` value is ignored.

      ### Example configuration

@example
Using with options
```ts ignore
import { load } from "@std/dotenv";

      const conf = await load({
        envPath: "./.env_prod", // Uses .env_prod instead of .env
        export: true, // Exports all variables to the environment
      });
      ```

      ## Permissions

      At a minimum, loading the `.env` related files requires the `--allow-read` permission.  Additionally, if
      you access the process environment, either through exporting your configuration or expanding variables
      in your `.env` file, you will need the `--allow-env` permission.  E.g.

      ```sh
      deno run --allow-read=.env --allow-env=ENV1,ENV2 app.ts
      ```

      ## Parsing Rules

      The parsing engine currently supports the following rules:

      - Variables that already exist in the environment are not overridden with
        `export: true`
      - `BASIC=basic` becomes `{ BASIC: "basic" }`
      - empty lines are skipped
      - lines beginning with `#` are treated as comments
      - empty values become empty strings (`EMPTY=` becomes `{ EMPTY: "" }`)
      - single and double quoted values are escaped (`SINGLE_QUOTE='quoted'` becomes
        `{ SINGLE_QUOTE: "quoted" }`)
      - new lines are expanded in double quoted values (`MULTILINE="new\nline"`
        becomes

      ```
      { MULTILINE: "new\nline" }
      ```

      - inner quotes are maintained (think JSON) (`JSON={"foo": "bar"}` becomes
        `{ JSON: "{\"foo\": \"bar\"}" }`)
      - whitespace is removed from both ends of unquoted values (see more on
        {@linkcode https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/String/Trim | trim})
        (`FOO= some value` becomes `{ FOO: "some value" }`)
      - whitespace is preserved on both ends of quoted values (`FOO=" some value "`
        becomes `{ FOO: " some value " }`)
      - dollar sign with an environment key in or without curly braces in unquoted
        values will expand the environment key (`KEY=$KEY` or `KEY=${KEY}` becomes
        `{ KEY: "<KEY_VALUE_FROM_ENV>" }`)
      - escaped dollar sign with an environment key in unquoted values will escape the
        environment key rather than expand (`KEY=\$KEY` becomes `{ KEY: "\\$KEY" }`)
      - colon and a minus sign with a default value(which can also be another expand
        value) in expanding construction in unquoted values will first attempt to
        expand the environment key. If itÔÇÖs not found, then it will return the default
        value (`KEY=${KEY:-default}` If KEY exists it becomes
        `{ KEY: "<KEY_VALUE_FROM_ENV>" }` If not, then it becomes
        `{ KEY: "default" }`. Also there is possible to do this case
        `KEY=${NO_SUCH_KEY:-${EXISTING_KEY:-default}}` which becomes
        `{ KEY: "<EXISTING_KEY_VALUE_FROM_ENV>" }`)

@param options
The options

@return
The parsed environment variables

Works identically to {@linkcode load}, but synchronously.

@example
Usage
```ts ignore
import { loadSync } from "@std/dotenv";

      const conf = loadSync();
      ```

@param options
Options for loading the environment variables.

@return
The parsed environment variables.

Works identically to {@linkcode load}, but synchronously.

@example
Usage
```ts ignore
import { loadSync } from "@std/dotenv";

      const conf = loadSync();
      ```

@param options
Options for loading the environment variables.

@return
The parsed environment variables.

Parse `.env` file output in an object.

Note: The key needs to match the pattern /^[a-zA-Z\_][a-zA-Z0-9_]\*$/.

@example
Usage
```ts
import { parse } from "@std/dotenv/parse";
import { assertEquals } from "@std/assert";

      const env = parse("GREETING=hello world");
      assertEquals(env, { GREETING: "hello world" });
      ```

@param text
The text to parse.

@return
The parsed object.

Parse `.env` file output in an object.

Note: The key needs to match the pattern /^[a-zA-Z\_][a-zA-Z0-9_]\*$/.

@example
Usage
```ts
import { parse } from "@std/dotenv/parse";
import { assertEquals } from "@std/assert";

      const env = parse("GREETING=hello world");
      assertEquals(env, { GREETING: "hello world" });
      ```

@param text
The text to parse.

@return
The parsed object.

Executes a SQL query that retrieves data from the database (e.g., SELECT).

@param query - The SQL query string to be executed.

@param params - Optional parameters to be used in the SQL query.
Supported types: string, number, null, Uint8Array, boolean

@return
An array of rows resulting from the query execution.

@return
Will throw an error if the query execution fails.

Executes a SQL query that retrieves data from the database (e.g., SELECT).

@param query - The SQL query string to be executed.

@param params - Optional parameters to be used in the SQL query.
Supported types: string, number, null, Uint8Array, boolean

@return
An array of rows resulting from the query execution.

@return
Will throw an error if the query execution fails.

Executes a SQL query that retrieves a single row from the database (e.g., SELECT).

@param query - The SQL query string to be executed.

@param params - Optional parameters to be used in the SQL query.
Supported types: string, number, null, Uint8Array, boolean

@return
A single row resulting from the query execution.

@return
Will throw an error if the query execution fails.

Executes a SQL query that retrieves a single row from the database (e.g., SELECT).

@param query - The SQL query string to be executed.

@param params - Optional parameters to be used in the SQL query.
Supported types: string, number, null, Uint8Array, boolean

@return
A single row resulting from the query execution.

@return
Will throw an error if the query execution fails.

Stringify an object into a valid `.env` file format.

@example
Usage
```ts
import { stringify } from "@std/dotenv/stringify";
import { assertEquals } from "@std/assert";

      const object = { GREETING: "hello world" };
      assertEquals(stringify(object), "GREETING='hello world'");
      ```

@param object
object to be stringified

@return
string of object

Stringify an object into a valid `.env` file format.

@example
Usage
```ts
import { stringify } from "@std/dotenv/stringify";
import { assertEquals } from "@std/assert";

      const object = { GREETING: "hello world" };
      assertEquals(stringify(object), "GREETING='hello world'");
      ```

@param object
object to be stringified

@return
string of object

Defined in file:///C:/Users/aroml/Megafonito/backend/auth/authMiddleware.ts:4:14

const authMiddleware: Middleware

Defined in file:///C:/Users/aroml/Megafonito/backend/auth/authMiddleware.ts:4:14

const authMiddleware: Middleware

Defined in file:///C:/Users/aroml/Megafonito/backend/routes/userRoutes.ts:15:14

const default: Router

Defined in file:///C:/Users/aroml/Megafonito/backend/utils/errorHandling.ts:49:14

const formatErrorResponse: (status: number, message: string, additionalDetails?: Record<string, unknown>) => unknown

Defined in file:///C:/Users/aroml/Megafonito/backend/utils/errorHandling.ts:49:14

const formatErrorResponse: (status: number, message: string, additionalDetails?: Record<string, unknown>) => unknown

Defined in file:///C:/Users/aroml/Megafonito/backend/utils/logging.ts:85:14

const loggingErrorMiddleware: Middleware

Defined in file:///C:/Users/aroml/Megafonito/backend/utils/logging.ts:85:14

const loggingErrorMiddleware: Middleware

Defined in file:///C:/Users/aroml/Megafonito/backend/utils/logging.ts:56:14

const loggingMiddleware: Middleware

Defined in file:///C:/Users/aroml/Megafonito/backend/utils/logging.ts:56:14

const loggingMiddleware: Middleware

Defined in file:///C:/Users/aroml/Megafonito/backend/utils/rateLimiter.ts:86:14

const rateLimiter

Defined in file:///C:/Users/aroml/Megafonito/backend/utils/rateLimiter.ts:86:14

const rateLimiter

Defined in file:///C:/Users/aroml/Megafonito/backend/auth/authMiddleware.ts:43:14

const requireRole: (roles: UserRole[]) => Middleware
Creates a middleware that checks if the user has required role(s).

@param roles - Array of roles allowed to access the route

@return
Middleware that validates user role against allowed roles

@return
403 if user lacks required role

@example
router.get("/admin", requireRole([UserRole.ADMIN]))

Defined in file:///C:/Users/aroml/Megafonito/backend/auth/authMiddleware.ts:43:14

const requireRole: (roles: UserRole[]) => Middleware
Creates a middleware that checks if the user has required role(s).

@param roles - Array of roles allowed to access the route

@return
Middleware that validates user role against allowed roles

@return
403 if user lacks required role

@example
router.get("/admin", requireRole([UserRole.ADMIN]))

Defined in file:///C:/Users/aroml/Megafonito/backend/routes/userRoutes.ts:15:14

const router: Router

Defined in file:///C:/Users/aroml/Megafonito/backend/routes/userRoutes.ts:15:14

const router: Router

Defined in file:///C:/Users/aroml/Megafonito/backend/routes/userRoutes.ts:14:14

const validation: Validation

Defined in file:///C:/Users/aroml/Megafonito/backend/routes/userRoutes.ts:14:14

const validation: Validation

Defined in file:///C:/Users/aroml/Megafonito/backend/utils/types.ts:31:1

class AppError extends Error

constructor(message: string, status: number, details?: unknown)
status: number
details?: unknown

Defined in file:///C:/Users/aroml/Megafonito/backend/utils/types.ts:31:1

class AppError extends Error

constructor(message: string, status: number, details?: unknown)
status: number
details?: unknown

Defined in file:///C:/Users/aroml/Megafonito/backend/utils/rateLimiter.ts:8:1

class AtomicRateLimiter

rateLimiter: Middleware

Defined in file:///C:/Users/aroml/Megafonito/backend/utils/rateLimiter.ts:8:1

class AtomicRateLimiter

rateLimiter: Middleware

Defined in file:///C:/Users/aroml/Megafonito/backend/utils/logging.ts:5:1

class Logging

constructor()
setupLogger(): void
logRequest(entry: LogEntry): void
logError(error: Error, entry: LogEntry): void

Defined in file:///C:/Users/aroml/Megafonito/backend/utils/logging.ts:5:1

class Logging

constructor()
setupLogger(): void
logRequest(entry: LogEntry): void
logError(error: Error, entry: LogEntry): void

Defined in file:///C:/Users/aroml/Megafonito/backend/utils/validation.ts:4:1

class Validation

validateUserCreation: Middleware
validateNoticeCreation: Middleware

Defined in file:///C:/Users/aroml/Megafonito/backend/utils/validation.ts:4:1

class Validation

validateUserCreation: Middleware
validateNoticeCreation: Middleware

Defined in file:///C:/Users/aroml/Megafonito/backend/auth/userRoles.ts:5:1

enum UserRole
Defines available user roles in the application.
Used for role-based access control (RBAC).

ADMIN
Full access to all system features
USER
Standard access with limited permissions

Defined in file:///C:/Users/aroml/Megafonito/backend/auth/userRoles.ts:5:1

enum UserRole
Defines available user roles in the application.
Used for role-based access control (RBAC).

ADMIN
Full access to all system features
USER
Standard access with limited permissions

Defined in file:///C:/Users/aroml/Megafonito/backend/db/dbQueries.ts:15:1

interface DatabaseRow

[key: string]: string | number | boolean | null | Uint8Array

Defined in file:///C:/Users/aroml/Megafonito/backend/db/dbQueries.ts:15:1

interface DatabaseRow

[key: string]: string | number | boolean | null | Uint8Array

Defined in file:///C:/Users/aroml/Megafonito/backend/utils/types.ts:15:1

interface ErrorResponse

success: boolean
error: { status?: Status; message: string; date: number; }
additionalDetails?: Record<string, unknown>

Defined in file:///C:/Users/aroml/Megafonito/backend/utils/types.ts:15:1

interface ErrorResponse

success: boolean
error: { status?: Status; message: string; date: number; }
additionalDetails?: Record<string, unknown>

Defined in https://jsr.io/@std/dotenv/0.225.3/mod.ts:31:1

interface LoadOptions
Options for {@linkcode load} and {@linkcode loadSync}.

envPath?: string | null
Optional path to `.env` file. To prevent the default value from being
used, set to `null`.

    @default {"./.env"}

export?: boolean
Set to `true` to export all `.env` variables to the current processes
environment. Variables are then accessible via `Deno.env.get(<key>)`.

    @default {false}

Defined in https://jsr.io/@std/dotenv/0.225.3/mod.ts:31:1

interface LoadOptions
Options for {@linkcode load} and {@linkcode loadSync}.

envPath?: string | null
Optional path to `.env` file. To prevent the default value from being
used, set to `null`.

    @default {"./.env"}

export?: boolean
Set to `true` to export all `.env` variables to the current processes
environment. Variables are then accessible via `Deno.env.get(<key>)`.

    @default {false}

Defined in file:///C:/Users/aroml/Megafonito/backend/utils/types.ts:7:1

interface LogEntry

method: string
url: string
startTime: number
endTime: number
duration: number
status?: number

Defined in file:///C:/Users/aroml/Megafonito/backend/utils/types.ts:7:1

interface LogEntry

method: string
url: string
startTime: number
endTime: number
duration: number
status?: number

Defined in file:///C:/Users/aroml/Megafonito/backend/models/noticeModel.ts:13:1

interface Notice extends DatabaseRow

id: number
title: string
content: string
user_id: number
created_at: string

Defined in file:///C:/Users/aroml/Megafonito/backend/models/noticeModel.ts:13:1

interface Notice extends DatabaseRow

id: number
title: string
content: string
user_id: number
created_at: string

Defined in file:///C:/Users/aroml/Megafonito/backend/models/noticeModel.ts:22:1

interface PaginatedResponse<T extends DatabaseRow>

data: T[]
pagination: { currentPage: number; pageSize: number; totalItems: number; totalPages: number; }

Defined in file:///C:/Users/aroml/Megafonito/backend/models/noticeModel.ts:22:1

interface PaginatedResponse<T extends DatabaseRow>

data: T[]
pagination: { currentPage: number; pageSize: number; totalItems: number; totalPages: number; }

Defined in file:///C:/Users/aroml/Megafonito/backend/utils/types.ts:24:1

interface SuccessResponse

success: boolean
message: string
code: number
additionalData?: Record<string, unknown>

Defined in file:///C:/Users/aroml/Megafonito/backend/utils/types.ts:24:1

interface SuccessResponse

success: boolean
message: string
code: number
additionalData?: Record<string, unknown>

Defined in file:///C:/Users/aroml/Megafonito/backend/auth/userRoles.ts:15:1

interface UserClaims
Structure of user data stored in JWT tokens.

id: number
username: string
role: UserRole

Defined in file:///C:/Users/aroml/Megafonito/backend/auth/userRoles.ts:15:1

interface UserClaims
Structure of user data stored in JWT tokens.

id: number
username: string
role: UserRole
