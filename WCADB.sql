--
-- PostgreSQL database dump
--

-- Dumped from database version 15.1
-- Dumped by pg_dump version 15.1 (Ubuntu 15.1-1.pgdg20.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: auth; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA auth;


ALTER SCHEMA auth OWNER TO supabase_admin;

--
-- Name: extensions; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA extensions;


ALTER SCHEMA extensions OWNER TO postgres;

--
-- Name: graphql; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA graphql;


ALTER SCHEMA graphql OWNER TO supabase_admin;

--
-- Name: graphql_public; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA graphql_public;


ALTER SCHEMA graphql_public OWNER TO supabase_admin;

--
-- Name: pgbouncer; Type: SCHEMA; Schema: -; Owner: pgbouncer
--

CREATE SCHEMA pgbouncer;


ALTER SCHEMA pgbouncer OWNER TO pgbouncer;

--
-- Name: pgsodium; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA pgsodium;


ALTER SCHEMA pgsodium OWNER TO postgres;

--
-- Name: pgsodium; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgsodium WITH SCHEMA pgsodium;


--
-- Name: EXTENSION pgsodium; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgsodium IS 'Pgsodium is a modern cryptography library for Postgres.';


--
-- Name: realtime; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA realtime;


ALTER SCHEMA realtime OWNER TO supabase_admin;

--
-- Name: storage; Type: SCHEMA; Schema: -; Owner: supabase_admin
--

CREATE SCHEMA storage;


ALTER SCHEMA storage OWNER TO supabase_admin;

--
-- Name: pg_graphql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_graphql WITH SCHEMA graphql;


--
-- Name: EXTENSION pg_graphql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_graphql IS 'pg_graphql: GraphQL support';


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_stat_statements WITH SCHEMA extensions;


--
-- Name: EXTENSION pg_stat_statements; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_stat_statements IS 'track planning and execution statistics of all SQL statements executed';


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA extensions;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: pgjwt; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgjwt WITH SCHEMA extensions;


--
-- Name: EXTENSION pgjwt; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgjwt IS 'JSON Web Token API for Postgresql';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: aal_level; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.aal_level AS ENUM (
    'aal1',
    'aal2',
    'aal3'
);


ALTER TYPE auth.aal_level OWNER TO supabase_auth_admin;

--
-- Name: factor_status; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_status AS ENUM (
    'unverified',
    'verified'
);


ALTER TYPE auth.factor_status OWNER TO supabase_auth_admin;

--
-- Name: factor_type; Type: TYPE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TYPE auth.factor_type AS ENUM (
    'totp',
    'webauthn'
);


ALTER TYPE auth.factor_type OWNER TO supabase_auth_admin;

--
-- Name: action; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.action AS ENUM (
    'INSERT',
    'UPDATE',
    'DELETE',
    'TRUNCATE',
    'ERROR'
);


ALTER TYPE realtime.action OWNER TO supabase_admin;

--
-- Name: equality_op; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.equality_op AS ENUM (
    'eq',
    'neq',
    'lt',
    'lte',
    'gt',
    'gte'
);


ALTER TYPE realtime.equality_op OWNER TO supabase_admin;

--
-- Name: user_defined_filter; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.user_defined_filter AS (
	column_name text,
	op realtime.equality_op,
	value text
);


ALTER TYPE realtime.user_defined_filter OWNER TO supabase_admin;

--
-- Name: wal_column; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.wal_column AS (
	name text,
	type_name text,
	type_oid oid,
	value jsonb,
	is_pkey boolean,
	is_selectable boolean
);


ALTER TYPE realtime.wal_column OWNER TO supabase_admin;

--
-- Name: wal_rls; Type: TYPE; Schema: realtime; Owner: supabase_admin
--

CREATE TYPE realtime.wal_rls AS (
	wal jsonb,
	is_rls_enabled boolean,
	subscription_ids uuid[],
	errors text[]
);


ALTER TYPE realtime.wal_rls OWNER TO supabase_admin;

--
-- Name: email(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.email() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  	coalesce(
		nullif(current_setting('request.jwt.claim.email', true), ''),
		(nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'email')
	)::text
$$;


ALTER FUNCTION auth.email() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION email(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.email() IS 'Deprecated. Use auth.jwt() -> ''email'' instead.';


--
-- Name: jwt(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.jwt() RETURNS jsonb
    LANGUAGE sql STABLE
    AS $$
  select 
    coalesce(
        nullif(current_setting('request.jwt.claim', true), ''),
        nullif(current_setting('request.jwt.claims', true), '')
    )::jsonb
$$;


ALTER FUNCTION auth.jwt() OWNER TO supabase_auth_admin;

--
-- Name: role(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.role() RETURNS text
    LANGUAGE sql STABLE
    AS $$
  select 
  	coalesce(
		nullif(current_setting('request.jwt.claim.role', true), ''),
		(nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
	)::text
$$;


ALTER FUNCTION auth.role() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION role(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.role() IS 'Deprecated. Use auth.jwt() -> ''role'' instead.';


--
-- Name: uid(); Type: FUNCTION; Schema: auth; Owner: supabase_auth_admin
--

CREATE FUNCTION auth.uid() RETURNS uuid
    LANGUAGE sql STABLE
    AS $$
  select 
  	coalesce(
		nullif(current_setting('request.jwt.claim.sub', true), ''),
		(nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
	)::uuid
$$;


ALTER FUNCTION auth.uid() OWNER TO supabase_auth_admin;

--
-- Name: FUNCTION uid(); Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON FUNCTION auth.uid() IS 'Deprecated. Use auth.jwt() -> ''sub'' instead.';


--
-- Name: grant_pg_cron_access(); Type: FUNCTION; Schema: extensions; Owner: postgres
--

CREATE FUNCTION extensions.grant_pg_cron_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  schema_is_cron bool;
BEGIN
  schema_is_cron = (
    SELECT n.nspname = 'cron'
    FROM pg_event_trigger_ddl_commands() AS ev
    LEFT JOIN pg_catalog.pg_namespace AS n
      ON ev.objid = n.oid
  );

  IF schema_is_cron
  THEN
    grant usage on schema cron to postgres with grant option;

    alter default privileges in schema cron grant all on tables to postgres with grant option;
    alter default privileges in schema cron grant all on functions to postgres with grant option;
    alter default privileges in schema cron grant all on sequences to postgres with grant option;

    alter default privileges for user supabase_admin in schema cron grant all
        on sequences to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on tables to postgres with grant option;
    alter default privileges for user supabase_admin in schema cron grant all
        on functions to postgres with grant option;

    grant all privileges on all tables in schema cron to postgres with grant option;

  END IF;

END;
$$;


ALTER FUNCTION extensions.grant_pg_cron_access() OWNER TO postgres;

--
-- Name: FUNCTION grant_pg_cron_access(); Type: COMMENT; Schema: extensions; Owner: postgres
--

COMMENT ON FUNCTION extensions.grant_pg_cron_access() IS 'Grants access to pg_cron';


--
-- Name: grant_pg_graphql_access(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.grant_pg_graphql_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
DECLARE
    func_is_graphql_resolve bool;
BEGIN
    func_is_graphql_resolve = (
        SELECT n.proname = 'resolve'
        FROM pg_event_trigger_ddl_commands() AS ev
        LEFT JOIN pg_catalog.pg_proc AS n
        ON ev.objid = n.oid
    );

    IF func_is_graphql_resolve
    THEN
        -- Update public wrapper to pass all arguments through to the pg_graphql resolve func
        DROP FUNCTION IF EXISTS graphql_public.graphql;
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language sql
        as $$
            select graphql.resolve(
                query := query,
                variables := coalesce(variables, '{}'),
                "operationName" := "operationName",
                extensions := extensions
            );
        $$;

        -- This hook executes when `graphql.resolve` is created. That is not necessarily the last
        -- function in the extension so we need to grant permissions on existing entities AND
        -- update default permissions to any others that are created after `graphql.resolve`
        grant usage on schema graphql to postgres, anon, authenticated, service_role;
        grant select on all tables in schema graphql to postgres, anon, authenticated, service_role;
        grant execute on all functions in schema graphql to postgres, anon, authenticated, service_role;
        grant all on all sequences in schema graphql to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on tables to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on functions to postgres, anon, authenticated, service_role;
        alter default privileges in schema graphql grant all on sequences to postgres, anon, authenticated, service_role;
    END IF;

END;
$_$;


ALTER FUNCTION extensions.grant_pg_graphql_access() OWNER TO supabase_admin;

--
-- Name: FUNCTION grant_pg_graphql_access(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.grant_pg_graphql_access() IS 'Grants access to pg_graphql';


--
-- Name: grant_pg_net_access(); Type: FUNCTION; Schema: extensions; Owner: postgres
--

CREATE FUNCTION extensions.grant_pg_net_access() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM pg_event_trigger_ddl_commands() AS ev
    JOIN pg_extension AS ext
    ON ev.objid = ext.oid
    WHERE ext.extname = 'pg_net'
  )
  THEN
    IF NOT EXISTS (
      SELECT 1
      FROM pg_roles
      WHERE rolname = 'supabase_functions_admin'
    )
    THEN
      CREATE USER supabase_functions_admin NOINHERIT CREATEROLE LOGIN NOREPLICATION;
    END IF;

    GRANT USAGE ON SCHEMA net TO supabase_functions_admin, postgres, anon, authenticated, service_role;

    ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
    ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SECURITY DEFINER;
    ALTER function net.http_collect_response(request_id bigint, async boolean) SECURITY DEFINER;

    ALTER function net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
    ALTER function net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) SET search_path = net;
    ALTER function net.http_collect_response(request_id bigint, async boolean) SET search_path = net;

    REVOKE ALL ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
    REVOKE ALL ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) FROM PUBLIC;
    REVOKE ALL ON FUNCTION net.http_collect_response(request_id bigint, async boolean) FROM PUBLIC;

    GRANT EXECUTE ON FUNCTION net.http_get(url text, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    GRANT EXECUTE ON FUNCTION net.http_post(url text, body jsonb, params jsonb, headers jsonb, timeout_milliseconds integer) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
    GRANT EXECUTE ON FUNCTION net.http_collect_response(request_id bigint, async boolean) TO supabase_functions_admin, postgres, anon, authenticated, service_role;
  END IF;
END;
$$;


ALTER FUNCTION extensions.grant_pg_net_access() OWNER TO postgres;

--
-- Name: FUNCTION grant_pg_net_access(); Type: COMMENT; Schema: extensions; Owner: postgres
--

COMMENT ON FUNCTION extensions.grant_pg_net_access() IS 'Grants access to pg_net';


--
-- Name: pgrst_ddl_watch(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.pgrst_ddl_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN SELECT * FROM pg_event_trigger_ddl_commands()
  LOOP
    IF cmd.command_tag IN (
      'CREATE SCHEMA', 'ALTER SCHEMA'
    , 'CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO', 'ALTER TABLE'
    , 'CREATE FOREIGN TABLE', 'ALTER FOREIGN TABLE'
    , 'CREATE VIEW', 'ALTER VIEW'
    , 'CREATE MATERIALIZED VIEW', 'ALTER MATERIALIZED VIEW'
    , 'CREATE FUNCTION', 'ALTER FUNCTION'
    , 'CREATE TRIGGER'
    , 'CREATE TYPE', 'ALTER TYPE'
    , 'CREATE RULE'
    , 'COMMENT'
    )
    -- don't notify in case of CREATE TEMP table or other objects created on pg_temp
    AND cmd.schema_name is distinct from 'pg_temp'
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


ALTER FUNCTION extensions.pgrst_ddl_watch() OWNER TO supabase_admin;

--
-- Name: pgrst_drop_watch(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.pgrst_drop_watch() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  obj record;
BEGIN
  FOR obj IN SELECT * FROM pg_event_trigger_dropped_objects()
  LOOP
    IF obj.object_type IN (
      'schema'
    , 'table'
    , 'foreign table'
    , 'view'
    , 'materialized view'
    , 'function'
    , 'trigger'
    , 'type'
    , 'rule'
    )
    AND obj.is_temporary IS false -- no pg_temp objects
    THEN
      NOTIFY pgrst, 'reload schema';
    END IF;
  END LOOP;
END; $$;


ALTER FUNCTION extensions.pgrst_drop_watch() OWNER TO supabase_admin;

--
-- Name: set_graphql_placeholder(); Type: FUNCTION; Schema: extensions; Owner: supabase_admin
--

CREATE FUNCTION extensions.set_graphql_placeholder() RETURNS event_trigger
    LANGUAGE plpgsql
    AS $_$
    DECLARE
    graphql_is_dropped bool;
    BEGIN
    graphql_is_dropped = (
        SELECT ev.schema_name = 'graphql_public'
        FROM pg_event_trigger_dropped_objects() AS ev
        WHERE ev.schema_name = 'graphql_public'
    );

    IF graphql_is_dropped
    THEN
        create or replace function graphql_public.graphql(
            "operationName" text default null,
            query text default null,
            variables jsonb default null,
            extensions jsonb default null
        )
            returns jsonb
            language plpgsql
        as $$
            DECLARE
                server_version float;
            BEGIN
                server_version = (SELECT (SPLIT_PART((select version()), ' ', 2))::float);

                IF server_version >= 14 THEN
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql extension is not enabled.'
                            )
                        )
                    );
                ELSE
                    RETURN jsonb_build_object(
                        'errors', jsonb_build_array(
                            jsonb_build_object(
                                'message', 'pg_graphql is only available on projects running Postgres 14 onwards.'
                            )
                        )
                    );
                END IF;
            END;
        $$;
    END IF;

    END;
$_$;


ALTER FUNCTION extensions.set_graphql_placeholder() OWNER TO supabase_admin;

--
-- Name: FUNCTION set_graphql_placeholder(); Type: COMMENT; Schema: extensions; Owner: supabase_admin
--

COMMENT ON FUNCTION extensions.set_graphql_placeholder() IS 'Reintroduces placeholder function for graphql_public.graphql';


--
-- Name: get_auth(text); Type: FUNCTION; Schema: pgbouncer; Owner: postgres
--

CREATE FUNCTION pgbouncer.get_auth(p_usename text) RETURNS TABLE(username text, password text)
    LANGUAGE plpgsql SECURITY DEFINER
    AS $$
BEGIN
    RAISE WARNING 'PgBouncer auth request: %', p_usename;

    RETURN QUERY
    SELECT usename::TEXT, passwd::TEXT FROM pg_catalog.pg_shadow
    WHERE usename = p_usename;
END;
$$;


ALTER FUNCTION pgbouncer.get_auth(p_usename text) OWNER TO postgres;

--
-- Name: apply_rls(jsonb, integer); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer DEFAULT (1024 * 1024)) RETURNS SETOF realtime.wal_rls
    LANGUAGE plpgsql
    AS $$
      declare
          -- Regclass of the table e.g. public.notes
          entity_ regclass = (quote_ident(wal ->> 'schema') || '.' || quote_ident(wal ->> 'table'))::regclass;

          -- I, U, D, T: insert, update ...
          action realtime.action = (
              case wal ->> 'action'
                  when 'I' then 'INSERT'
                  when 'U' then 'UPDATE'
                  when 'D' then 'DELETE'
                  else 'ERROR'
              end
          );

          -- Is row level security enabled for the table
          is_rls_enabled bool = relrowsecurity from pg_class where oid = entity_;

          subscriptions realtime.subscription[] = array_agg(subs)
              from
                  realtime.subscription subs
              where
                  subs.entity = entity_;

          -- Subscription vars
          roles regrole[] = array_agg(distinct us.claims_role)
              from
                  unnest(subscriptions) us;

          working_role regrole;
          claimed_role regrole;
          claims jsonb;

          subscription_id uuid;
          subscription_has_access bool;
          visible_to_subscription_ids uuid[] = '{}';

          -- structured info for wal's columns
          columns realtime.wal_column[];
          -- previous identity values for update/delete
          old_columns realtime.wal_column[];

          error_record_exceeds_max_size boolean = octet_length(wal::text) > max_record_bytes;

          -- Primary jsonb output for record
          output jsonb;

      begin
          perform set_config('role', null, true);

          columns =
              array_agg(
                  (
                      x->>'name',
                      x->>'type',
                      x->>'typeoid',
                      realtime.cast(
                          (x->'value') #>> '{}',
                          coalesce(
                              (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                              (x->>'type')::regtype
                          )
                      ),
                      (pks ->> 'name') is not null,
                      true
                  )::realtime.wal_column
              )
              from
                  jsonb_array_elements(wal -> 'columns') x
                  left join jsonb_array_elements(wal -> 'pk') pks
                      on (x ->> 'name') = (pks ->> 'name');

          old_columns =
              array_agg(
                  (
                      x->>'name',
                      x->>'type',
                      x->>'typeoid',
                      realtime.cast(
                          (x->'value') #>> '{}',
                          coalesce(
                              (x->>'typeoid')::regtype, -- null when wal2json version <= 2.4
                              (x->>'type')::regtype
                          )
                      ),
                      (pks ->> 'name') is not null,
                      true
                  )::realtime.wal_column
              )
              from
                  jsonb_array_elements(wal -> 'identity') x
                  left join jsonb_array_elements(wal -> 'pk') pks
                      on (x ->> 'name') = (pks ->> 'name');

          for working_role in select * from unnest(roles) loop

              -- Update `is_selectable` for columns and old_columns
              columns =
                  array_agg(
                      (
                          c.name,
                          c.type_name,
                          c.type_oid,
                          c.value,
                          c.is_pkey,
                          pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                      )::realtime.wal_column
                  )
                  from
                      unnest(columns) c;

              old_columns =
                      array_agg(
                          (
                              c.name,
                              c.type_name,
                              c.type_oid,
                              c.value,
                              c.is_pkey,
                              pg_catalog.has_column_privilege(working_role, entity_, c.name, 'SELECT')
                          )::realtime.wal_column
                      )
                      from
                          unnest(old_columns) c;

              if action <> 'DELETE' and count(1) = 0 from unnest(columns) c where c.is_pkey then
                  return next (
                      jsonb_build_object(
                          'schema', wal ->> 'schema',
                          'table', wal ->> 'table',
                          'type', action
                      ),
                      is_rls_enabled,
                      -- subscriptions is already filtered by entity
                      (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
                      array['Error 400: Bad Request, no primary key']
                  )::realtime.wal_rls;

              -- The claims role does not have SELECT permission to the primary key of entity
              elsif action <> 'DELETE' and sum(c.is_selectable::int) <> count(1) from unnest(columns) c where c.is_pkey then
                  return next (
                      jsonb_build_object(
                          'schema', wal ->> 'schema',
                          'table', wal ->> 'table',
                          'type', action
                      ),
                      is_rls_enabled,
                      (select array_agg(s.subscription_id) from unnest(subscriptions) as s where claims_role = working_role),
                      array['Error 401: Unauthorized']
                  )::realtime.wal_rls;

              else
                  output = jsonb_build_object(
                      'schema', wal ->> 'schema',
                      'table', wal ->> 'table',
                      'type', action,
                      'commit_timestamp', to_char(
                          (wal ->> 'timestamp')::timestamptz,
                          'YYYY-MM-DD"T"HH24:MI:SS"Z"'
                      ),
                      'columns', (
                          select
                              jsonb_agg(
                                  jsonb_build_object(
                                      'name', pa.attname,
                                      'type', pt.typname
                                  )
                                  order by pa.attnum asc
                              )
                          from
                              pg_attribute pa
                              join pg_type pt
                                  on pa.atttypid = pt.oid
                          where
                              attrelid = entity_
                              and attnum > 0
                              and pg_catalog.has_column_privilege(working_role, entity_, pa.attname, 'SELECT')
                      )
                  )
                  -- Add "record" key for insert and update
                  || case
                      when action in ('INSERT', 'UPDATE') then
                          case
                              when error_record_exceeds_max_size then
                                  jsonb_build_object(
                                      'record',
                                      (
                                          select jsonb_object_agg((c).name, (c).value)
                                          from unnest(columns) c
                                          where (c).is_selectable and (octet_length((c).value::text) <= 64)
                                      )
                                  )
                              else
                                  jsonb_build_object(
                                      'record',
                                      (select jsonb_object_agg((c).name, (c).value) from unnest(columns) c where (c).is_selectable)
                                  )
                          end
                      else '{}'::jsonb
                  end
                  -- Add "old_record" key for update and delete
                  || case
                      when action in ('UPDATE', 'DELETE') then
                          case
                              when error_record_exceeds_max_size then
                                  jsonb_build_object(
                                      'old_record',
                                      (
                                          select jsonb_object_agg((c).name, (c).value)
                                          from unnest(old_columns) c
                                          where (c).is_selectable and (octet_length((c).value::text) <= 64)
                                      )
                                  )
                              else
                                  jsonb_build_object(
                                      'old_record',
                                      (select jsonb_object_agg((c).name, (c).value) from unnest(old_columns) c where (c).is_selectable)
                                  )
                          end
                      else '{}'::jsonb
                  end;

                  -- Create the prepared statement
                  if is_rls_enabled and action <> 'DELETE' then
                      if (select 1 from pg_prepared_statements where name = 'walrus_rls_stmt' limit 1) > 0 then
                          deallocate walrus_rls_stmt;
                      end if;
                      execute realtime.build_prepared_statement_sql('walrus_rls_stmt', entity_, columns);
                  end if;

                  visible_to_subscription_ids = '{}';

                  for subscription_id, claims in (
                          select
                              subs.subscription_id,
                              subs.claims
                          from
                              unnest(subscriptions) subs
                          where
                              subs.entity = entity_
                              and subs.claims_role = working_role
                              and (
                                  realtime.is_visible_through_filters(columns, subs.filters)
                                  or action = 'DELETE'
                              )
                  ) loop

                      if not is_rls_enabled or action = 'DELETE' then
                          visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
                      else
                          -- Check if RLS allows the role to see the record
                          perform
                              set_config('role', working_role::text, true),
                              set_config('request.jwt.claims', claims::text, true);

                          execute 'execute walrus_rls_stmt' into subscription_has_access;

                          if subscription_has_access then
                              visible_to_subscription_ids = visible_to_subscription_ids || subscription_id;
                          end if;
                      end if;
                  end loop;

                  perform set_config('role', null, true);

                  return next (
                      output,
                      is_rls_enabled,
                      visible_to_subscription_ids,
                      case
                          when error_record_exceeds_max_size then array['Error 413: Payload Too Large']
                          else '{}'
                      end
                  )::realtime.wal_rls;

              end if;
          end loop;

          perform set_config('role', null, true);
      end;
      $$;


ALTER FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) OWNER TO supabase_admin;

--
-- Name: build_prepared_statement_sql(text, regclass, realtime.wal_column[]); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) RETURNS text
    LANGUAGE sql
    AS $$
      /*
      Builds a sql string that, if executed, creates a prepared statement to
      tests retrive a row from *entity* by its primary key columns.
      Example
          select realtime.build_prepared_statement_sql('public.notes', '{"id"}'::text[], '{"bigint"}'::text[])
      */
          select
      'prepare ' || prepared_statement_name || ' as
          select
              exists(
                  select
                      1
                  from
                      ' || entity || '
                  where
                      ' || string_agg(quote_ident(pkc.name) || '=' || quote_nullable(pkc.value #>> '{}') , ' and ') || '
              )'
          from
              unnest(columns) pkc
          where
              pkc.is_pkey
          group by
              entity
      $$;


ALTER FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) OWNER TO supabase_admin;

--
-- Name: cast(text, regtype); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime."cast"(val text, type_ regtype) RETURNS jsonb
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    declare
      res jsonb;
    begin
      execute format('select to_jsonb(%L::'|| type_::text || ')', val)  into res;
      return res;
    end
    $$;


ALTER FUNCTION realtime."cast"(val text, type_ regtype) OWNER TO supabase_admin;

--
-- Name: check_equality_op(realtime.equality_op, regtype, text, text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) RETURNS boolean
    LANGUAGE plpgsql IMMUTABLE
    AS $$
    /*
    Casts *val_1* and *val_2* as type *type_* and check the *op* condition for truthiness
    */
    declare
      op_symbol text = (
        case
          when op = 'eq' then '='
          when op = 'neq' then '!='
          when op = 'lt' then '<'
          when op = 'lte' then '<='
          when op = 'gt' then '>'
          when op = 'gte' then '>='
          else 'UNKNOWN OP'
        end
      );
      res boolean;
    begin
      execute format('select %L::'|| type_::text || ' ' || op_symbol || ' %L::'|| type_::text, val_1, val_2) into res;
      return res;
    end;
    $$;


ALTER FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) OWNER TO supabase_admin;

--
-- Name: is_visible_through_filters(realtime.wal_column[], realtime.user_defined_filter[]); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) RETURNS boolean
    LANGUAGE sql IMMUTABLE
    AS $_$
    /*
    Should the record be visible (true) or filtered out (false) after *filters* are applied
    */
        select
            -- Default to allowed when no filters present
            $2 is null -- no filters. this should not happen because subscriptions has a default
            or array_length($2, 1) is null -- array length of an empty array is null
            or bool_and(
                coalesce(
                    realtime.check_equality_op(
                        op:=f.op,
                        type_:=coalesce(
                            col.type_oid::regtype, -- null when wal2json version <= 2.4
                            col.type_name::regtype
                        ),
                        -- cast jsonb to text
                        val_1:=col.value #>> '{}',
                        val_2:=f.value
                    ),
                    false -- if null, filter does not match
                )
            )
        from
            unnest(filters) f
            join unnest(columns) col
                on f.column_name = col.name;
    $_$;


ALTER FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) OWNER TO supabase_admin;

--
-- Name: quote_wal2json(regclass); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.quote_wal2json(entity regclass) RETURNS text
    LANGUAGE sql IMMUTABLE STRICT
    AS $$
      select
        (
          select string_agg('' || ch,'')
          from unnest(string_to_array(nsp.nspname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
        )
        || '.'
        || (
          select string_agg('' || ch,'')
          from unnest(string_to_array(pc.relname::text, null)) with ordinality x(ch, idx)
          where
            not (x.idx = 1 and x.ch = '"')
            and not (
              x.idx = array_length(string_to_array(nsp.nspname::text, null), 1)
              and x.ch = '"'
            )
          )
      from
        pg_class pc
        join pg_namespace nsp
          on pc.relnamespace = nsp.oid
      where
        pc.oid = entity
    $$;


ALTER FUNCTION realtime.quote_wal2json(entity regclass) OWNER TO supabase_admin;

--
-- Name: subscription_check_filters(); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.subscription_check_filters() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
    /*
    Validates that the user defined filters for a subscription:
    - refer to valid columns that the claimed role may access
    - values are coercable to the correct column type
    */
    declare
      col_names text[] = coalesce(
        array_agg(c.column_name order by c.ordinal_position),
        '{}'::text[]
      )
      from
        information_schema.columns c
      where
        format('%I.%I', c.table_schema, c.table_name)::regclass = new.entity
        and pg_catalog.has_column_privilege(
          (new.claims ->> 'role'),
          format('%I.%I', c.table_schema, c.table_name)::regclass,
          c.column_name,
          'SELECT'
        );
      filter realtime.user_defined_filter;
      col_type regtype;
    begin
      for filter in select * from unnest(new.filters) loop
        -- Filtered column is valid
        if not filter.column_name = any(col_names) then
          raise exception 'invalid column for filter %', filter.column_name;
        end if;

        -- Type is sanitized and safe for string interpolation
        col_type = (
          select atttypid::regtype
          from pg_catalog.pg_attribute
          where attrelid = new.entity
            and attname = filter.column_name
        );
        if col_type is null then
          raise exception 'failed to lookup type for column %', filter.column_name;
        end if;
        -- raises an exception if value is not coercable to type
        perform realtime.cast(filter.value, col_type);
      end loop;

      -- Apply consistent order to filters so the unique constraint on
      -- (subscription_id, entity, filters) can't be tricked by a different filter order
      new.filters = coalesce(
        array_agg(f order by f.column_name, f.op, f.value),
        '{}'
      ) from unnest(new.filters) f;

    return new;
  end;
  $$;


ALTER FUNCTION realtime.subscription_check_filters() OWNER TO supabase_admin;

--
-- Name: to_regrole(text); Type: FUNCTION; Schema: realtime; Owner: supabase_admin
--

CREATE FUNCTION realtime.to_regrole(role_name text) RETURNS regrole
    LANGUAGE sql IMMUTABLE
    AS $$ select role_name::regrole $$;


ALTER FUNCTION realtime.to_regrole(role_name text) OWNER TO supabase_admin;

--
-- Name: extension(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.extension(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
_filename text;
BEGIN
    select string_to_array(name, '/') into _parts;
    select _parts[array_length(_parts,1)] into _filename;
    -- @todo return the last part instead of 2
    return split_part(_filename, '.', 2);
END
$$;


ALTER FUNCTION storage.extension(name text) OWNER TO supabase_storage_admin;

--
-- Name: filename(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.filename(name text) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
    select string_to_array(name, '/') into _parts;
    return _parts[array_length(_parts,1)];
END
$$;


ALTER FUNCTION storage.filename(name text) OWNER TO supabase_storage_admin;

--
-- Name: foldername(text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.foldername(name text) RETURNS text[]
    LANGUAGE plpgsql
    AS $$
DECLARE
_parts text[];
BEGIN
    select string_to_array(name, '/') into _parts;
    return _parts[1:array_length(_parts,1)-1];
END
$$;


ALTER FUNCTION storage.foldername(name text) OWNER TO supabase_storage_admin;

--
-- Name: get_size_by_bucket(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.get_size_by_bucket() RETURNS TABLE(size bigint, bucket_id text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    return query
        select sum((metadata->>'size')::int) as size, obj.bucket_id
        from "storage".objects as obj
        group by obj.bucket_id;
END
$$;


ALTER FUNCTION storage.get_size_by_bucket() OWNER TO supabase_storage_admin;

--
-- Name: search(text, text, integer, integer, integer, text, text, text); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.search(prefix text, bucketname text, limits integer DEFAULT 100, levels integer DEFAULT 1, offsets integer DEFAULT 0, search text DEFAULT ''::text, sortcolumn text DEFAULT 'name'::text, sortorder text DEFAULT 'asc'::text) RETURNS TABLE(name text, id uuid, updated_at timestamp with time zone, created_at timestamp with time zone, last_accessed_at timestamp with time zone, metadata jsonb)
    LANGUAGE plpgsql STABLE
    AS $_$
declare
  v_order_by text;
  v_sort_order text;
begin
  case
    when sortcolumn = 'name' then
      v_order_by = 'name';
    when sortcolumn = 'updated_at' then
      v_order_by = 'updated_at';
    when sortcolumn = 'created_at' then
      v_order_by = 'created_at';
    when sortcolumn = 'last_accessed_at' then
      v_order_by = 'last_accessed_at';
    else
      v_order_by = 'name';
  end case;

  case
    when sortorder = 'asc' then
      v_sort_order = 'asc';
    when sortorder = 'desc' then
      v_sort_order = 'desc';
    else
      v_sort_order = 'asc';
  end case;

  v_order_by = v_order_by || ' ' || v_sort_order;

  return query execute
    'with folders as (
       select path_tokens[$1] as folder
       from storage.objects
         where objects.name ilike $2 || $3 || ''%''
           and bucket_id = $4
           and array_length(regexp_split_to_array(objects.name, ''/''), 1) <> $1
       group by folder
       order by folder ' || v_sort_order || '
     )
     (select folder as "name",
            null as id,
            null as updated_at,
            null as created_at,
            null as last_accessed_at,
            null as metadata from folders)
     union all
     (select path_tokens[$1] as "name",
            id,
            updated_at,
            created_at,
            last_accessed_at,
            metadata
     from storage.objects
     where objects.name ilike $2 || $3 || ''%''
       and bucket_id = $4
       and array_length(regexp_split_to_array(objects.name, ''/''), 1) = $1
     order by ' || v_order_by || ')
     limit $5
     offset $6' using levels, prefix, search, bucketname, limits, offsets;
end;
$_$;


ALTER FUNCTION storage.search(prefix text, bucketname text, limits integer, levels integer, offsets integer, search text, sortcolumn text, sortorder text) OWNER TO supabase_storage_admin;

--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: storage; Owner: supabase_storage_admin
--

CREATE FUNCTION storage.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW; 
END;
$$;


ALTER FUNCTION storage.update_updated_at_column() OWNER TO supabase_storage_admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: audit_log_entries; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.audit_log_entries (
    instance_id uuid,
    id uuid NOT NULL,
    payload json,
    created_at timestamp with time zone,
    ip_address character varying(64) DEFAULT ''::character varying NOT NULL
);


ALTER TABLE auth.audit_log_entries OWNER TO supabase_auth_admin;

--
-- Name: TABLE audit_log_entries; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.audit_log_entries IS 'Auth: Audit trail for user actions.';


--
-- Name: identities; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.identities (
    id text NOT NULL,
    user_id uuid NOT NULL,
    identity_data jsonb NOT NULL,
    provider text NOT NULL,
    last_sign_in_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email text GENERATED ALWAYS AS (lower((identity_data ->> 'email'::text))) STORED
);


ALTER TABLE auth.identities OWNER TO supabase_auth_admin;

--
-- Name: TABLE identities; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.identities IS 'Auth: Stores identities associated to a user.';


--
-- Name: COLUMN identities.email; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.identities.email IS 'Auth: Email is a generated column that references the optional email property in the identity_data';


--
-- Name: instances; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.instances (
    id uuid NOT NULL,
    uuid uuid,
    raw_base_config text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE auth.instances OWNER TO supabase_auth_admin;

--
-- Name: TABLE instances; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.instances IS 'Auth: Manages users across multiple sites.';


--
-- Name: mfa_amr_claims; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_amr_claims (
    session_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    authentication_method text NOT NULL,
    id uuid NOT NULL
);


ALTER TABLE auth.mfa_amr_claims OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_amr_claims; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_amr_claims IS 'auth: stores authenticator method reference claims for multi factor authentication';


--
-- Name: mfa_challenges; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_challenges (
    id uuid NOT NULL,
    factor_id uuid NOT NULL,
    created_at timestamp with time zone NOT NULL,
    verified_at timestamp with time zone,
    ip_address inet NOT NULL
);


ALTER TABLE auth.mfa_challenges OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_challenges; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_challenges IS 'auth: stores metadata about challenge requests made';


--
-- Name: mfa_factors; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.mfa_factors (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    friendly_name text,
    factor_type auth.factor_type NOT NULL,
    status auth.factor_status NOT NULL,
    created_at timestamp with time zone NOT NULL,
    updated_at timestamp with time zone NOT NULL,
    secret text
);


ALTER TABLE auth.mfa_factors OWNER TO supabase_auth_admin;

--
-- Name: TABLE mfa_factors; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.mfa_factors IS 'auth: stores metadata about factors';


--
-- Name: refresh_tokens; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.refresh_tokens (
    instance_id uuid,
    id bigint NOT NULL,
    token character varying(255),
    user_id character varying(255),
    revoked boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    parent character varying(255),
    session_id uuid
);


ALTER TABLE auth.refresh_tokens OWNER TO supabase_auth_admin;

--
-- Name: TABLE refresh_tokens; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.refresh_tokens IS 'Auth: Store of tokens used to refresh JWT tokens once they expire.';


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE; Schema: auth; Owner: supabase_auth_admin
--

CREATE SEQUENCE auth.refresh_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE auth.refresh_tokens_id_seq OWNER TO supabase_auth_admin;

--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: auth; Owner: supabase_auth_admin
--

ALTER SEQUENCE auth.refresh_tokens_id_seq OWNED BY auth.refresh_tokens.id;


--
-- Name: saml_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_providers (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    entity_id text NOT NULL,
    metadata_xml text NOT NULL,
    metadata_url text,
    attribute_mapping jsonb,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "entity_id not empty" CHECK ((char_length(entity_id) > 0)),
    CONSTRAINT "metadata_url not empty" CHECK (((metadata_url = NULL::text) OR (char_length(metadata_url) > 0))),
    CONSTRAINT "metadata_xml not empty" CHECK ((char_length(metadata_xml) > 0))
);


ALTER TABLE auth.saml_providers OWNER TO supabase_auth_admin;

--
-- Name: TABLE saml_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_providers IS 'Auth: Manages SAML Identity Provider connections.';


--
-- Name: saml_relay_states; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.saml_relay_states (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    request_id text NOT NULL,
    for_email text,
    redirect_to text,
    from_ip_address inet,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "request_id not empty" CHECK ((char_length(request_id) > 0))
);


ALTER TABLE auth.saml_relay_states OWNER TO supabase_auth_admin;

--
-- Name: TABLE saml_relay_states; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.saml_relay_states IS 'Auth: Contains SAML Relay State information for each Service Provider initiated login.';


--
-- Name: schema_migrations; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE auth.schema_migrations OWNER TO supabase_auth_admin;

--
-- Name: TABLE schema_migrations; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.schema_migrations IS 'Auth: Manages updates to the auth system.';


--
-- Name: sessions; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sessions (
    id uuid NOT NULL,
    user_id uuid NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    factor_id uuid,
    aal auth.aal_level,
    not_after timestamp with time zone
);


ALTER TABLE auth.sessions OWNER TO supabase_auth_admin;

--
-- Name: TABLE sessions; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sessions IS 'Auth: Stores session data associated to a user.';


--
-- Name: COLUMN sessions.not_after; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sessions.not_after IS 'Auth: Not after is a nullable column that contains a timestamp after which the session should be regarded as expired.';


--
-- Name: sso_domains; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_domains (
    id uuid NOT NULL,
    sso_provider_id uuid NOT NULL,
    domain text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "domain not empty" CHECK ((char_length(domain) > 0))
);


ALTER TABLE auth.sso_domains OWNER TO supabase_auth_admin;

--
-- Name: TABLE sso_domains; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_domains IS 'Auth: Manages SSO email address domain mapping to an SSO Identity Provider.';


--
-- Name: sso_providers; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_providers (
    id uuid NOT NULL,
    resource_id text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    CONSTRAINT "resource_id not empty" CHECK (((resource_id = NULL::text) OR (char_length(resource_id) > 0)))
);


ALTER TABLE auth.sso_providers OWNER TO supabase_auth_admin;

--
-- Name: TABLE sso_providers; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_providers IS 'Auth: Manages SSO identity provider information; see saml_providers for SAML.';


--
-- Name: COLUMN sso_providers.resource_id; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.sso_providers.resource_id IS 'Auth: Uniquely identifies a SSO provider according to a user-chosen resource ID (case insensitive), useful in infrastructure as code.';


--
-- Name: sso_sessions; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.sso_sessions (
    id uuid NOT NULL,
    session_id uuid NOT NULL,
    sso_provider_id uuid,
    not_before timestamp with time zone,
    not_after timestamp with time zone,
    idp_initiated boolean DEFAULT false,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE auth.sso_sessions OWNER TO supabase_auth_admin;

--
-- Name: TABLE sso_sessions; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.sso_sessions IS 'Auth: A session initiated by an SSO Identity Provider';


--
-- Name: users; Type: TABLE; Schema: auth; Owner: supabase_auth_admin
--

CREATE TABLE auth.users (
    instance_id uuid,
    id uuid NOT NULL,
    aud character varying(255),
    role character varying(255),
    email character varying(255),
    encrypted_password character varying(255),
    email_confirmed_at timestamp with time zone,
    invited_at timestamp with time zone,
    confirmation_token character varying(255),
    confirmation_sent_at timestamp with time zone,
    recovery_token character varying(255),
    recovery_sent_at timestamp with time zone,
    email_change_token_new character varying(255),
    email_change character varying(255),
    email_change_sent_at timestamp with time zone,
    last_sign_in_at timestamp with time zone,
    raw_app_meta_data jsonb,
    raw_user_meta_data jsonb,
    is_super_admin boolean,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    phone character varying(15) DEFAULT NULL::character varying,
    phone_confirmed_at timestamp with time zone,
    phone_change character varying(15) DEFAULT ''::character varying,
    phone_change_token character varying(255) DEFAULT ''::character varying,
    phone_change_sent_at timestamp with time zone,
    confirmed_at timestamp with time zone GENERATED ALWAYS AS (LEAST(email_confirmed_at, phone_confirmed_at)) STORED,
    email_change_token_current character varying(255) DEFAULT ''::character varying,
    email_change_confirm_status smallint DEFAULT 0,
    banned_until timestamp with time zone,
    reauthentication_token character varying(255) DEFAULT ''::character varying,
    reauthentication_sent_at timestamp with time zone,
    is_sso_user boolean DEFAULT false NOT NULL,
    CONSTRAINT users_email_change_confirm_status_check CHECK (((email_change_confirm_status >= 0) AND (email_change_confirm_status <= 2)))
);


ALTER TABLE auth.users OWNER TO supabase_auth_admin;

--
-- Name: TABLE users; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON TABLE auth.users IS 'Auth: Stores user login data within a secure schema.';


--
-- Name: COLUMN users.is_sso_user; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON COLUMN auth.users.is_sso_user IS 'Auth: Set this column to true when the account comes from SSO. These accounts can have duplicate emails.';


--
-- Name: ChatRoom; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public."ChatRoom" (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    name text,
    image text,
    "LastMessageID" uuid
);


ALTER TABLE public."ChatRoom" OWNER TO supabase_admin;

--
-- Name: Message; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public."Message" (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    text text,
    "ChatRoomID" uuid,
    "UserID" text,
    "isMedia" boolean DEFAULT false
);


ALTER TABLE public."Message" OWNER TO supabase_admin;

--
-- Name: User; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public."User" (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    name text,
    status text,
    image text
);


ALTER TABLE public."User" OWNER TO supabase_admin;

--
-- Name: UserChatRoom; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public."UserChatRoom" (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    "ChatRoomID" uuid,
    "UserID" text,
    "LastSeenAt" timestamp with time zone,
    "LastSeenMessageID" uuid
);


ALTER TABLE public."UserChatRoom" OWNER TO supabase_admin;

--
-- Name: UserToken; Type: TABLE; Schema: public; Owner: supabase_admin
--

CREATE TABLE public."UserToken" (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    "PushToken" text
);


ALTER TABLE public."UserToken" OWNER TO supabase_admin;

--
-- Name: schema_migrations; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.schema_migrations (
    version bigint NOT NULL,
    inserted_at timestamp(0) without time zone
);


ALTER TABLE realtime.schema_migrations OWNER TO supabase_admin;

--
-- Name: subscription; Type: TABLE; Schema: realtime; Owner: supabase_admin
--

CREATE TABLE realtime.subscription (
    id bigint NOT NULL,
    subscription_id uuid NOT NULL,
    entity regclass NOT NULL,
    filters realtime.user_defined_filter[] DEFAULT '{}'::realtime.user_defined_filter[] NOT NULL,
    claims jsonb NOT NULL,
    claims_role regrole GENERATED ALWAYS AS (realtime.to_regrole((claims ->> 'role'::text))) STORED NOT NULL,
    created_at timestamp without time zone DEFAULT timezone('utc'::text, now()) NOT NULL
);


ALTER TABLE realtime.subscription OWNER TO supabase_admin;

--
-- Name: subscription_id_seq; Type: SEQUENCE; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE realtime.subscription ALTER COLUMN id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME realtime.subscription_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: buckets; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.buckets (
    id text NOT NULL,
    name text NOT NULL,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    public boolean DEFAULT false
);


ALTER TABLE storage.buckets OWNER TO supabase_storage_admin;

--
-- Name: migrations; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.migrations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    hash character varying(40) NOT NULL,
    executed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE storage.migrations OWNER TO supabase_storage_admin;

--
-- Name: objects; Type: TABLE; Schema: storage; Owner: supabase_storage_admin
--

CREATE TABLE storage.objects (
    id uuid DEFAULT extensions.uuid_generate_v4() NOT NULL,
    bucket_id text,
    name text,
    owner uuid,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    last_accessed_at timestamp with time zone DEFAULT now(),
    metadata jsonb,
    path_tokens text[] GENERATED ALWAYS AS (string_to_array(name, '/'::text)) STORED
);


ALTER TABLE storage.objects OWNER TO supabase_storage_admin;

--
-- Name: refresh_tokens id; Type: DEFAULT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens ALTER COLUMN id SET DEFAULT nextval('auth.refresh_tokens_id_seq'::regclass);


--
-- Data for Name: audit_log_entries; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.audit_log_entries (instance_id, id, payload, created_at, ip_address) FROM stdin;
\.


--
-- Data for Name: identities; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.identities (id, user_id, identity_data, provider, last_sign_in_at, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: instances; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.instances (id, uuid, raw_base_config, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: mfa_amr_claims; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_amr_claims (session_id, created_at, updated_at, authentication_method, id) FROM stdin;
\.


--
-- Data for Name: mfa_challenges; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_challenges (id, factor_id, created_at, verified_at, ip_address) FROM stdin;
\.


--
-- Data for Name: mfa_factors; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.mfa_factors (id, user_id, friendly_name, factor_type, status, created_at, updated_at, secret) FROM stdin;
\.


--
-- Data for Name: refresh_tokens; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.refresh_tokens (instance_id, id, token, user_id, revoked, created_at, updated_at, parent, session_id) FROM stdin;
\.


--
-- Data for Name: saml_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.saml_providers (id, sso_provider_id, entity_id, metadata_xml, metadata_url, attribute_mapping, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: saml_relay_states; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.saml_relay_states (id, sso_provider_id, request_id, for_email, redirect_to, from_ip_address, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.schema_migrations (version) FROM stdin;
20171026211738
20171026211808
20171026211834
20180103212743
20180108183307
20180119214651
20180125194653
00
20210710035447
20210722035447
20210730183235
20210909172000
20210927181326
20211122151130
20211124214934
20211202183645
20220114185221
20220114185340
20220224000811
20220323170000
20220429102000
20220531120530
20220614074223
20220811173540
20221003041349
20221003041400
20221011041400
20221020193600
20221021073300
20221021082433
20221027105023
20221114143122
20221114143410
20221120114718
20221121110412
20221124140122
20221125140132
20221125141029
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sessions (id, user_id, created_at, updated_at, factor_id, aal, not_after) FROM stdin;
\.


--
-- Data for Name: sso_domains; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sso_domains (id, sso_provider_id, domain, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sso_providers; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sso_providers (id, resource_id, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: sso_sessions; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.sso_sessions (id, session_id, sso_provider_id, not_before, not_after, idp_initiated, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: auth; Owner: supabase_auth_admin
--

COPY auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, invited_at, confirmation_token, confirmation_sent_at, recovery_token, recovery_sent_at, email_change_token_new, email_change, email_change_sent_at, last_sign_in_at, raw_app_meta_data, raw_user_meta_data, is_super_admin, created_at, updated_at, phone, phone_confirmed_at, phone_change, phone_change_token, phone_change_sent_at, email_change_token_current, email_change_confirm_status, banned_until, reauthentication_token, reauthentication_sent_at, is_sso_user) FROM stdin;
\.


--
-- Data for Name: key; Type: TABLE DATA; Schema: pgsodium; Owner: postgres
--

COPY pgsodium.key (id, status, created, expires, key_type, key_id, key_context, comment, user_data) FROM stdin;
c44e57ae-8e6c-47d2-8ae6-d7c9366c829f	default	2022-12-14 11:06:04.092341	\N	\N	1	\\x7067736f6469756d	This is the default key used for vault.secrets	\N
\.


--
-- Data for Name: ChatRoom; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--

COPY public."ChatRoom" (id, created_at, name, image, "LastMessageID") FROM stdin;
12282606-8d6c-4c36-acb5-7c4a61056b8d	2022-12-27 13:15:56.006442+00	\N	\N	0e623bde-de23-49ec-b182-041ca42c2449
e40ab7c0-668f-48a7-acbe-8afa9dc0c9f5	2023-01-12 07:16:08.941778+00	\N	\N	5d86a551-ed9c-49d9-b426-561829eb0acf
1eb9228a-2856-4333-8417-dabdd678aa10	2023-01-10 10:29:14.057801+00	\N	\N	232eb0a4-f270-4deb-8fd0-d3cdc680392b
adac3b86-cec4-47f6-b71b-7ad6ee956c2c	2022-12-19 15:05:02+00	\N	\N	ce8bbad9-838d-401e-9c5f-652e56d64f04
dc048925-ba19-4bbc-913a-66c11ed38b04	2023-01-10 15:23:57.899609+00	\N	\N	b15f0db2-87f6-4358-874a-4297ee170240
7048d285-d4a8-4155-8d30-5023afeaa23c	2022-12-26 17:27:29.471207+00	\N	\N	1e8be4d3-ec5c-48aa-80c4-b601c391bf28
9267a9db-1f94-4b7c-a30e-f6a9d2513879	2022-12-22 14:08:11.003167+00	\N	\N	c76035dc-852b-4858-909c-66d3df6b4562
041803f7-f5e3-4825-baa5-e93427d4e8d5	2023-01-11 08:13:11.768686+00	\N	\N	5ca4cf56-bc59-4738-a954-20f9aa3d9164
0f51064e-19a4-403e-a887-9607ebe23765	2022-12-26 17:28:04.917854+00	\N	\N	b15f0db2-87f6-4358-874a-4297ee170240
866ad7be-3d5a-4717-8fd0-5e4abb7820a5	2022-12-26 17:28:22.201778+00	\N	\N	b15f0db2-87f6-4358-874a-4297ee170240
a953afac-954e-4dc7-8d69-58fdadc59d5d	2022-12-29 06:34:33.432072+00	\N	\N	c348161c-4663-4ba8-9376-37bbaed9d1ee
7b8241fe-fa68-4e3f-9fba-64072f649aaf	2022-12-27 13:15:35.673219+00	\N	\N	2541ee90-3bef-4964-a834-55e4b5929440
2cc0f398-5c65-424f-8ee0-fca5d9f7fc42	2022-12-30 13:55:02.566701+00	\N	\N	b15f0db2-87f6-4358-874a-4297ee170240
76cd1ccd-a614-4ff5-a759-8308b20cfc2e	2023-01-06 05:14:15.988416+00	\N	\N	6e3c4a9c-0bb9-4627-ae19-284ba1b04df8
\.


--
-- Data for Name: Message; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--

COPY public."Message" (id, created_at, text, "ChatRoomID", "UserID", "isMedia") FROM stdin;
d365c858-3de9-4588-a004-e384bb992307	2022-12-19 15:37:32.194056+00	Hello	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
b15f0db2-87f6-4358-874a-4297ee170240	2022-12-20 13:41:37.549449+00	Send first message	\N	\N	f
a80368db-44ec-4bac-9be5-53759feb0fbc	2022-12-20 14:15:00.999317+00	Hi	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
e8ba6005-418f-4dea-bff7-80da99147cfb	2022-12-20 14:16:20.670844+00	jjjjj	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
b2c90620-6b2f-43b7-b5db-441d4e1aed58	2022-12-20 14:27:23.630426+00	Hehe	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
c8b9b6b2-ee47-47fd-933c-99866119855c	2022-12-20 14:50:23.690366+00	hi	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
8705e46e-a154-4c2e-ae0b-4ed1e007fd23	2022-12-20 14:59:50.375658+00	Kk	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
a692e585-8370-4002-9c04-38b83e161058	2022-12-20 15:00:12.813224+00	Gg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
2d28051f-edc6-4d55-bc7f-410bf847fc6c	2022-12-20 15:03:27.485534+00	Hi	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
087bb916-d955-4842-9b1c-f1dc1cd7f558	2022-12-20 15:04:25.549802+00	Gg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
8ccde641-3b3e-4db0-9e71-70c71fda7856	2022-12-20 15:16:50.511589+00	New	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
f3d6f561-52f4-4c11-92dd-8eac13fcd234	2022-12-20 15:17:21.050304+00	Gg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
902938ac-86fc-46e4-a6df-c7b638cde7e9	2022-12-20 15:17:33.282548+00	hh	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
90b8f4a9-1692-4aa3-8cb7-c0e9ae8ddc3b	2022-12-20 17:01:22.773698+00	Hi	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
e07ddbd5-0e61-4589-824e-5644ea337570	2022-12-20 17:02:05.50321+00	Hi	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
d47a4237-f27c-48b4-82be-75772a6efdf0	2022-12-20 17:06:18.438276+00	Hehe	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
feef071b-7b72-4bff-a8ef-e018c7b95f48	2022-12-20 17:10:44.421497+00	Gg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
b511d713-cf97-4a8d-b571-929152233236	2022-12-20 17:11:12.512502+00	Jj	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
27da79c4-5ffa-40f1-9595-5511aef06e68	2022-12-20 17:18:54.23497+00	Hiiii	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
079d8b12-f724-476f-9314-1e4d57cc3369	2022-12-20 17:19:22.895983+00	Hi	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
40376138-32f8-468b-9887-fe488af69bbb	2022-12-20 17:22:05.859771+00	hero	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
3c07321f-8126-4a20-b4eb-6e2e97268cab	2022-12-20 17:23:24.492827+00	Zero	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
791d58b1-6ebe-4f61-b7bb-32ccb0912755	2022-12-20 17:25:34.437786+00	Ydgg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
14b330b2-8f99-4f8e-b94d-9ade07fcdd94	2022-12-20 17:26:40.261793+00	Heroooo	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
d2349e1b-947b-4af1-817a-c798d913c685	2022-12-20 17:34:40.123446+00	Hi	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
88a563d7-3537-437d-87ac-c97bd733c01a	2022-12-20 17:35:30.002974+00	Hhh	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
b76e3885-7e9c-4365-8f3b-ca9b981912fe	2022-12-20 17:36:32.751303+00	Gg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
266dd755-7fa5-443c-b18f-ca5108885138	2022-12-20 17:37:10.430482+00	Gg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
a4780e36-1ab9-460a-adcd-cf4ee935bfa8	2022-12-21 12:24:04.054259+00	Hi	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
608baf8c-ccd9-454c-9580-67e0651aa2e5	2022-12-21 12:25:20.654821+00	Gg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
60be71f7-6c61-42dd-ade2-bac3d1c1cb72	2022-12-21 12:26:22.25952+00	Hi	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
5f8b9c00-4e75-42da-8270-67fd969efc53	2022-12-21 12:28:16.857576+00	Gg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
741485e8-5aa5-424d-af54-876f19acb3f5	2022-12-21 12:29:45.243291+00	Hh	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
a6c8a068-3ce7-4fa8-9682-c46f57db7e7c	2022-12-21 12:31:56.400185+00	Kiki	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
a0858bb3-3078-45fc-9d86-f22223546b30	2022-12-21 12:32:11.091936+00	Xxx	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
4a6686b2-fd86-45dd-bdb9-4b2aa52ab187	2022-12-21 12:38:02.053596+00	Hh	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
2552ee22-78a0-4d0a-9441-868d105e773b	2022-12-21 12:39:22.284418+00	Hh	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
b8c5f218-db0b-4f62-bb3a-00849de87444	2022-12-21 12:44:45.05989+00	Ggg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
1b03aa17-c37d-48be-bc3e-6aa4d0aac68c	2022-12-21 12:47:57.222647+00	Pagal	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
64ffcd41-c02f-4e2e-9237-2bf85e85493d	2022-12-21 13:21:11.68834+00	Hehe	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
2663150e-39e7-4e6f-a09b-8537507724b2	2022-12-21 14:03:31.439113+00	Boy	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
0fb808b9-288f-48a7-bd9d-181fef66693c	2022-12-21 14:04:33.76153+00	ggg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
b399ffbb-c067-4081-b9d5-c13690b53f3d	2022-12-21 14:07:49.871548+00	Ggyy	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
ff9a0279-7841-4af1-9f86-ad575fcb7880	2022-12-21 14:08:01.93195+00	Ffyy	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
f47bcb37-1489-48d0-8555-ad7b1c286a53	2022-12-21 15:06:23.769051+00	Hehe	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
89d8cbbd-b39b-40b3-95f0-3b23f141d6be	2022-12-21 15:07:51.09575+00	Gg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
73f1f01b-f4aa-4e75-9623-90b4a8915d57	2022-12-21 15:09:21.753823+00	ff	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
329f1ce7-81d3-41cc-82c4-e33e4bcbe49c	2022-12-21 15:13:00.817823+00	poppoo	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
7e675045-0264-4697-96ce-87990c8513a4	2022-12-21 15:14:16.486609+00	qwqwqwqw	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
597144ce-d1bb-4a08-89e4-3200c61f1e98	2022-12-21 15:15:17.672871+00	Ggg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
2dbb5725-b8b0-4bf0-baff-532f6f42ad6f	2022-12-22 13:25:53.792114+00	Hehe	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
dba4e6ae-a166-4da2-a20d-0f66b79b6781	2022-12-22 13:34:28.339783+00	Gg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
d04d136f-bac9-4a36-bd52-155c5b5e0fd1	2022-12-22 13:34:50.198258+00	Ff	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
c72340b3-9deb-47dd-9a9b-2758e1387016	2022-12-22 13:35:23.623995+00	Gg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
7243a13b-8594-42f3-a778-743ae38a5f45	2022-12-22 14:04:39.110415+00	hi	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
c76035dc-852b-4858-909c-66d3df6b4562	2022-12-22 14:08:34.780781+00	mmmmm	9267a9db-1f94-4b7c-a30e-f6a9d2513879	usOWdwZr9XeOwdkIyjbJixXDmC12	f
036498b3-c740-4f4e-9f23-7629b6b2dff6	2022-12-22 14:09:20.038649+00	Hehe	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
09aa9764-18c7-4e04-b38b-8f64f15440ba	2022-12-22 14:12:22.234582+00	Gshis	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
4bb48351-917d-460b-b52b-a69f08162a88	2022-12-23 14:44:39.364106+00	Hhh	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
fafe3559-f6d0-4d28-941f-357e6abfe7d6	2022-12-23 16:33:15.525531+00	hi	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
db278b75-9d37-4c49-a0d8-a85ce7401283	2022-12-23 16:33:31.859647+00	Hh	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
83caa034-9ecd-4c39-96cf-953920131005	2022-12-23 16:35:39.390218+00	g	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
42ac525f-972e-4283-8a64-65d2d223f71b	2022-12-23 16:35:48.747424+00	Gg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
236f9917-c3d2-49b8-8ac4-1b6270fe497e	2022-12-23 16:36:47.503727+00	Gg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
6eb82482-58c1-499a-b8f5-945352548856	2022-12-23 16:37:03.050906+00	Ff	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
d651c27d-ef2e-4489-a460-1461cfc14bd3	2022-12-23 16:37:09.265985+00	Ff	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
133263ca-d509-49f3-8800-7c5cc35d1b90	2022-12-24 09:43:35.298137+00	Hi	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
0bb7315a-8c60-449c-83be-aa162ebe41b1	2022-12-24 11:10:07.335556+00	hii	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
e03ccf68-ad20-4e96-9da7-98e32fac2bd5	2022-12-24 11:11:07.545296+00	Gg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
29de9348-95da-4291-a59d-32500fdc6125	2022-12-24 11:11:29.198512+00	Ff	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
4bbee547-8e4d-4bef-b79c-82f3c840fbce	2022-12-24 11:12:34.146281+00	Tt	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
164ee758-a8cd-4cb9-a20c-1ab982b7babd	2022-12-24 12:12:32.862808+00	Gg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
600e5bf7-3b59-4106-a81f-72575cc4fb6f	2022-12-24 12:14:48.31241+00	Hh	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
add1a27a-7a11-4d96-9fd6-5f436d9e937b	2022-12-24 12:18:42.227548+00	Cc	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
b8112f69-42eb-4033-9fb3-0a2b702d2a65	2022-12-24 12:19:25.63508+00	Hh	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
f610c4b6-b78f-4490-b517-b049bd8f615d	2022-12-24 12:20:38.847361+00	Gg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
4a28de77-56e2-4715-9dfb-770863cab7a7	2022-12-24 12:21:25.261243+00	Uu	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
91331ead-5c72-47e0-bc69-76aae077b80e	2022-12-24 12:22:39.746712+00	Rr	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
c9294dd9-896c-46df-bd11-4cf018185aad	2022-12-24 12:24:11.991825+00	Dd	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
65bd5b4a-cf3c-463f-bef1-98ab768b7d27	2022-12-24 12:35:55.479989+00	Bb	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
c9ab57b9-838d-4fa6-880d-1bb5417b999b	2022-12-24 12:36:29.411582+00	Gg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
fb9ddcec-f287-47cb-b5f7-b040a843b161	2022-12-24 13:00:30.669501+00	Dd	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
7c3a94c5-8fea-480b-91bb-75e2e4b9b9a0	2022-12-24 13:01:36.686206+00	Hi	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
9c8355f3-e4f8-49aa-aa8b-228d70ef913f	2022-12-24 13:23:23.336992+00	Tt	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
849d6d76-a308-4bc9-8ed7-10559cca2482	2022-12-24 13:23:32.500244+00	Yy	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
5a45d340-b350-4092-a40f-7d8dbe99d68e	2022-12-24 13:25:04.823343+00	Tt	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
912939ea-4f27-4369-a6ac-c44903159d6f	2022-12-24 13:03:59.122307+00	Gg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
1829642f-c4f2-4b6c-83b4-5ef237d00860	2022-12-24 13:04:27.110379+00	Hh	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
e7514a56-cfe7-4d80-aa56-02e33b4cf180	2022-12-24 13:26:17.750521+00	Ggg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
8fa13ae8-2384-478c-b32d-1720041c52cd	2022-12-24 13:05:48.099997+00	Ff	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
d191d452-83b6-43d6-afd2-7ad0ed8aba85	2022-12-24 13:06:00.37394+00	Zz	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
3bf33126-ef66-4b8b-8f09-e0eb0212a7d4	2022-12-24 13:06:41.657501+00	Gg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
daeaecf2-cb45-48b9-92ef-9bd115ac5cd9	2022-12-24 13:22:38.010857+00	Dd	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
1340d725-c33c-4f88-be20-60403ac4e1e0	2022-12-24 13:25:15.552281+00	Gg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
10ea884c-bdcd-439a-9d6a-1e096ebc2750	2022-12-24 13:26:32.619917+00	Gggg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
b4ed74ea-3479-4aa1-8c03-6bc891d7678c	2022-12-24 13:28:11.186982+00	Vvv	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
b0fa3e01-1be7-47fe-b0e3-df0d1712a5dd	2022-12-24 13:29:07.19863+00	Ddd	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
e09001e3-cad6-4e17-be3e-6962554bc222	2022-12-24 13:31:39.548807+00	Hhh	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
7366e307-9511-4e97-a2fb-3923ab9d55e7	2022-12-24 13:31:47.343492+00	Tttt	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
c09a3350-dd96-4235-97c4-091172812ade	2022-12-24 13:32:27.524648+00	Ff	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
480df6b9-5c5c-4ad4-a928-75bd6f8ead3a	2022-12-24 13:32:38.968117+00	Fff	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
26a055bf-149f-4688-82b3-f8db5e279386	2022-12-24 13:32:45.090037+00	Yyy	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
454d5f25-de74-46fe-84da-b790f6aac963	2022-12-24 13:32:53.580997+00	Ttt	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
0735dc4e-17c6-46ba-b1f4-24460734b8ca	2022-12-24 13:33:32.841295+00	Ggg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
b918a534-00f1-47d8-9429-506bfb51e05c	2022-12-24 13:33:49.012891+00	Qqq	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
a54e7da5-676f-49a1-a737-e502318f5115	2022-12-24 13:34:10.189456+00	Nnnn	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
7fcb3f20-0bb2-441a-aee0-8a92f7b6bfd1	2022-12-24 13:34:27.214252+00	Jjjj	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
5a071ebf-7203-437d-af9d-91476d2351f4	2022-12-24 13:34:34.6356+00	Hhhh	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
41f4fd02-ad5b-4573-96ce-35ac6a3b112a	2022-12-24 13:34:43.732395+00	Ccccc	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
4a3b3832-dfbc-4600-9373-b0f77b8f5c6a	2022-12-25 06:17:43.717149+00	hi	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
bf7f5f6d-9349-4ada-9352-fb5144d5373d	2022-12-25 09:29:45.071033+00	Dd	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
d7e69497-4280-4668-ae65-4b66797c468c	2022-12-25 09:30:19.850255+00	Yy	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
41eb55d1-31b7-4e79-9449-ab1b55f9e645	2022-12-25 09:30:35.011068+00	Rr	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
3cf245f3-cf7d-439c-bf2d-ead55ab480fa	2022-12-25 09:31:04.205705+00	Ttttt	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
31de02f8-630a-4b80-8adb-c225fbcbe8be	2022-12-25 09:32:12.767928+00	Gg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
48f449c1-e859-437c-850e-2dba3a805b31	2022-12-25 09:32:56.472949+00	Rrr	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
cb3ce9a5-2714-45c0-a749-26a3cd7d7d95	2022-12-25 09:33:10.69508+00	Ppppp	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
e9673516-68d7-41ff-ab09-3a4e4119ebb5	2022-12-25 09:33:27.469427+00	Gggggggg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
26eb30f5-a957-48a6-aea3-e68322fe77f5	2022-12-25 09:33:32.144863+00	Jjjjjjjjj	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
60ba9299-b6d9-42da-be2b-9fd4d154e7f2	2022-12-25 09:33:54.196873+00	Hhhhhh	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
929f07f2-b99d-40b7-bd5b-aedeb4fe230b	2022-12-25 09:34:08.094174+00	Jjjjjjj	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
f887e2ef-5955-4bfb-912c-de45db0315fa	2022-12-26 05:40:06.348777+00	Hi	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
098c4652-7e32-40b0-b784-cb50c7740ef8	2022-12-26 06:43:14.616291+00	Dd	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
780f4007-4626-40d6-bf8e-120f3e5ee42b	2022-12-26 16:04:16.767092+00	Hi	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
71cd2d31-99c5-45d3-bc06-72b16ba3c6c3	2022-12-26 16:07:41.31846+00	Gg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
d20dd7d2-942a-4b71-8e17-07b272454463	2022-12-26 16:08:02.143778+00	hi man	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
6adc77fd-7d94-410e-a65f-d95d9677baa9	2022-12-26 17:27:42.141555+00	Hi	7048d285-d4a8-4155-8d30-5023afeaa23c	NxZgtwaQrLO4nfkr8MVIthvJ6Py1	f
b864a095-5fb4-4c47-a656-f9318d9e2e22	2022-12-26 17:27:55.902619+00	Hi 	7048d285-d4a8-4155-8d30-5023afeaa23c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
894468b0-6456-4758-b898-7cbdfdbc5aad	2022-12-26 17:33:46.268987+00	Ggggg	7048d285-d4a8-4155-8d30-5023afeaa23c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
0902b3b2-37bc-49ee-8f5a-a4417f720018	2022-12-26 17:34:08.232491+00	Mmmmm	7048d285-d4a8-4155-8d30-5023afeaa23c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
3d368ee8-20b0-46f2-b131-850eb1bface3	2022-12-26 17:34:13.760891+00	Gamdu	7048d285-d4a8-4155-8d30-5023afeaa23c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
30b52a90-7acf-4905-9523-49b7578fa60b	2022-12-26 17:37:57.478542+00	Bye	7048d285-d4a8-4155-8d30-5023afeaa23c	NxZgtwaQrLO4nfkr8MVIthvJ6Py1	f
ff8c7a25-7317-4ed2-bce2-7e06a8d6d197	2022-12-26 17:44:46.403735+00	Dyhg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
600501da-b5e7-4def-8dee-e9738a1a75d2	2022-12-27 13:15:41.286551+00	Hello	7b8241fe-fa68-4e3f-9fba-64072f649aaf	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
07e52990-7321-4cb7-b9ba-febd7349c0e9	2022-12-27 13:17:26.556959+00	Y there's nothing here?	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
eff98fe4-1037-4f64-9b76-e9b84989c2f8	2022-12-27 13:42:10.985764+00	Because iam not using AWS anymore 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
082dfd85-13ae-4d24-a6f0-16a9bac1d584	2022-12-27 13:43:06.913736+00	Hehe	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
3efacd1e-a097-4f78-aacd-be108e0bffb0	2022-12-27 13:43:40.677574+00	Wt abt typing..	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
a40fcb43-5c3c-4967-98f2-71194c5bb085	2022-12-27 13:44:42.196212+00	Every one only tells me what I haven't implemented yet 🙂	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
6deb8eac-9e8c-4906-b0b4-f4d762fb3973	2022-12-27 13:45:00.626662+00	I'm asking this	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
91bcdd5d-abb9-45e0-9add-107d82680c93	2022-12-27 13:45:07.178079+00	Because u said	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
cd6e19ff-23e0-4d5c-9d4e-e6b245f5162d	2022-12-27 13:45:18.271589+00	I changed the entire backend 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
a704211b-01b6-470b-ba5b-06138319e4ca	2022-12-27 13:45:19.147571+00	U would implement it	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
d52a4b55-5494-4ba4-96f1-9bcce3c59428	2022-12-27 13:45:33.379523+00	Entire means wt all	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
5dddfd70-51fb-4cd6-bf0d-e25b3e0431a0	2022-12-27 13:45:50.402291+00	Everything 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
0ffe0bca-cc2a-495b-b63c-625c871703e0	2022-12-27 13:46:26.022125+00	Noice 	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
cad0784a-4fa6-407f-b0bf-b7cde8ce80cb	2022-12-27 13:46:41.442769+00	I also made it so you can change your name	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
d38a4a60-de09-4e21-a9ae-47cbd03a4cce	2022-12-27 13:46:46.566422+00	And status 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
dc96d193-b423-429f-91fd-abeabae70d70	2022-12-27 13:47:26.803304+00	What's my name now	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
d7a5ab5c-4877-4932-a07f-ccd7b7d67fa6	2022-12-27 13:47:48.970609+00	Anonymous 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
be2ae287-18d2-4486-8c3e-6bcba4b60d9e	2022-12-27 13:48:22.000546+00	How to change name	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
b019e43c-e115-46fe-8fcf-8839585f0113	2022-12-27 13:48:31.948793+00	What's mine?	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
2dae88d0-6e72-435a-8b94-de74aa8f693b	2022-12-27 13:48:52.768529+00	Refresh it in chat room 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
c3ba9fba-a43c-4d36-9687-ad6d78488cff	2022-12-27 13:49:46.623626+00	😑😑	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
64e36707-98b1-41e8-8c6a-3090c3f8d84f	2022-12-27 13:50:09.587403+00	I will implement typing soon	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
fe7b3684-e9a8-43b1-aee8-1b2036d56433	2022-12-27 13:52:00.373957+00	Okay 	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
dc57556c-2d1f-45ab-b338-a1fd6389c443	2022-12-27 13:52:50.555449+00	Press the check mark on the keyword to confirm it	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
bbc5c633-07af-46e0-8475-57dede2b7a23	2022-12-27 13:54:09.177062+00	This seen or not is a very good feature 🙂	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
a924da34-2b17-4dc2-99c1-ce364b7aa7ac	2022-12-27 13:54:25.410669+00	🥲 not supported emoji 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
524ad03b-9b88-49e5-bd39-790ffaf70c73	2022-12-27 13:54:29.823458+00	Ohhk	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
6b8bc77f-a325-4552-ac0a-c9fd8da92013	2022-12-27 13:54:42.668063+00	😂😂😂	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
4ff19748-45b6-4cc0-9de8-97b7e8097a7c	2022-12-27 14:04:32.365059+00	ಠ‿ಠ	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
b6e78deb-df9b-4d85-a74e-b914e08d2957	2022-12-27 13:55:42.789883+00	That's the best name you could think of?	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
11bcc5d6-a636-4740-9b04-336166c84cbe	2022-12-27 13:58:31.254733+00	👍	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
4009d26d-101f-44d6-b1b4-a608d7a8a005	2022-12-27 13:59:02.758651+00	\\0	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
83e6d274-caeb-40d5-b6d5-c2e90101a250	2022-12-27 13:59:08.85047+00	😂😂	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
541eb2ca-6db1-4f15-afb9-3d23a105d327	2022-12-27 13:59:50.581304+00	And that reply to a perticular message is also good to have	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
872a2248-4090-4b66-94d5-6c755ec2d576	2022-12-27 14:00:27.619585+00	And a few touch feedbacks .	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
631a6d69-b308-46af-afaf-e5781fea3879	2022-12-27 14:00:29.294124+00	Even reacting to particular message 	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
a50e8086-cdff-4ddb-9b1c-b852c8da226f	2022-12-27 14:00:49.372881+00	Ha ha reels bhi chalu kar tu	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
47a8e62c-8a2e-410e-a255-a6726d383a9b	2022-12-27 14:01:09.251749+00	Wt abt voice message 	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
dcc4a455-d65c-412a-8a86-728a17c9db9d	2022-12-27 14:01:22.512987+00	🥲	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
ed6fcb5c-4d75-4193-b6b1-a3dea04b65f7	2022-12-27 14:01:33.254418+00	🥲 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
584a937b-3eab-436d-9dca-2f8bccb20a8d	2022-12-27 14:01:51.088694+00	🥲  	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
f4ccfa50-fbb1-4cbe-8e88-c4e6a480c68d	2022-12-27 14:01:55.729977+00	Aaram se karo	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
f0d2851c-b4a9-4153-96df-c03201f30387	2022-12-27 14:02:01.468943+00	I will wait 	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
ed2dec0f-6f62-4011-b6d8-676db8417832	2022-12-27 14:02:02.446732+00	🥲   	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
1446498b-a7ab-4a4e-9829-9e2b1d37959b	2022-12-27 14:02:35.733535+00	Ok ok thanks for motivation 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
825e25aa-720b-446a-a7eb-c84cde1d9e0c	2022-12-27 14:02:53.85422+00	Padh lo ab.	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
8d7c5245-5dd9-4b41-875f-8a178ae9a9a3	2022-12-27 14:03:15.732323+00	Was that motivating?	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
a16535ff-44ed-42fd-bcc2-3877d3da9f3b	2022-12-27 14:03:39.564748+00	1/10^100	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
542f550f-5ad4-46fc-9b4e-3284af282535	2022-12-27 14:03:56.522029+00	🥲👍	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
f6fb6550-4ed2-486f-906f-9f877c5efb8e	2022-12-27 14:04:50.549049+00	•́  ‿ ,•̀	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
1928db96-b3fb-448f-a045-4cdd3c29cc7e	2022-12-27 14:04:57.290404+00	༎ຶ‿༎ຶ	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
09185562-dc49-4712-8d48-58f1c753cfb9	2022-12-27 14:05:28.711696+00	Wt	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
f847550a-e6d8-4542-b270-a4c8b1bce20e	2022-12-27 14:06:01.991312+00	Crying 😭 of before emoji era	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
a82859b9-ab28-4d77-aa31-e0c709cc136d	2022-12-27 14:06:09.06811+00	Ye kaha se laare 	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
636baa89-31fe-4279-a39a-8a64137a1384	2022-12-27 14:06:22.379371+00	Magic	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
f8efa8af-46c1-4bd3-ad12-d2ae6dbaea9e	2022-12-27 14:06:40.637848+00	Noice 	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
e9061961-49de-4a10-ba6f-a6232b884787	2022-12-27 14:06:47.973399+00	NOICE 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
78482b42-d903-42a3-8a0b-ef9b9129bb8d	2022-12-27 14:07:05.382933+00	Padooooooooooo	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
98cdbb42-0ba8-4ce9-8064-065b211dda3b	2022-12-27 14:07:30.624671+00	Cancel 2mrws cie too	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
585ec334-2a6f-4d46-b8a6-82a3d1480da3	2022-12-27 14:08:04.600417+00	Tum sir ko kidnap kar lo	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
cb3326e0-8787-4bea-a740-cfb0bbed016a	2022-12-27 14:08:40.090068+00	Na rehega baas na baje ge basure	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
f014c720-37ec-479b-8464-8394ee964af8	2022-12-27 14:08:45.054796+00	Sir ko gayab kardo	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
72fa9f91-8b20-4931-9dd6-cfbcfbad2200	2022-12-27 14:09:18.535587+00	Aur?	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
46046809-e469-47fb-b69c-50479fb17ea5	2022-12-27 14:10:01.222801+00	Bring Doraemon in this century 	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
af87459a-6d10-4b04-9960-851a60a73b25	2022-12-27 14:10:37.790488+00	You want a anywhere door?	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
e6821eb6-c524-4b4b-ad48-edf830db9cad	2022-12-27 14:10:54.37617+00	I want Doraemon 	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
e3ce2f6a-bced-445c-a383-c7bdda5ced4c	2022-12-27 14:11:46.130123+00	😤	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
039a9abf-e706-49d4-a385-d9a7bf4060ca	2022-12-27 14:11:57.78719+00	⛄	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
97b63ee8-6e56-4ae6-a058-53ada2f0d8ff	2022-12-27 14:11:59.041679+00	I thought 💭 u would say 	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
0d5acd7f-fa17-4e5d-85c6-169dca2237a8	2022-12-27 14:12:09.892517+00	I'll be ur Doraemon 	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
5c51dae3-022e-4f4a-828c-f2545797a6f8	2022-12-27 14:12:39.069653+00	Well iam NOT 4 feet	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
0bb8a3eb-92fa-47c2-913d-67e7094b66df	2022-12-27 14:13:23.880672+00	Well U r not even blue	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
ac83b4de-672d-4f7e-8792-6e1b511ac936	2022-12-27 14:13:29.123938+00	But I can be Doraemon for you but without the gadgets 🙂	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
846a0665-0746-4817-ba3c-262684a435eb	2022-12-27 14:13:58.665089+00	What is the a feature girls want?blue?	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
c69c8a6b-8ce4-41f5-955f-8e5912d6c547	2022-12-27 14:15:04.486788+00	I know u Can build a gadgets, if u ...	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
a5a7bd74-4dfd-4792-a950-66da68a38e14	2022-12-27 14:16:11.73602+00	Let me show you my powers	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
3427ed84-3c6d-479c-9073-5d84738ff599	2022-12-27 14:11:18+00	I'll be ur Doraemon	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
73e12c5a-ac5b-40d0-a02c-e00bd6058a46	2022-12-27 14:19:32.090947+00	And look back at my Doraemon message 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
c7facccc-faa4-4a8f-9adf-4a1011f08438	2022-12-27 14:20:23.55334+00	😁😁😁😁😁	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
325762a8-50f1-43ea-975e-b5dcd40236c6	2022-12-27 14:21:32.241221+00	😮😮😮	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
e9e79475-f566-45c0-8e49-7d78981d6d49	2022-12-27 14:21:39.82157+00	😂😂	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
ff56b7e5-2ec0-4f43-a0da-38a5188618bd	2022-12-27 14:22:39.566029+00	Look at your name	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
e00c975f-ca8c-4585-a85d-8044f0afb194	2022-12-27 14:23:08.567283+00	Refresh it 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
1004770f-ee3e-4f38-8bb2-d36eb65afe4b	2022-12-27 14:24:03.404885+00	Now u look	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
d139b062-3c83-4f75-982d-4aa4af91d1cb	2022-12-27 14:24:29.871818+00	😂😂	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
96efd81c-8bf2-4de0-8a7c-32d6512e7e52	2022-12-27 14:16:17.62147+00	Wait	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
1004d663-959d-4ea3-b1f5-0d9029d19e8d	2022-12-27 14:19:08.273433+00	Refresh the chat	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
7dbcca0a-e20d-49cc-aaa5-aaed4635499a	2022-12-27 14:24:48.686039+00	Reality can be whatever i want	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
bc7a78fa-36e5-4079-8115-405bef74e27b	2022-12-27 14:24:59.703484+00	But with great powers	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
ae4f82f1-9bd9-4bef-94e6-0befb212cade	2022-12-27 14:25:09.797875+00	Comes great responsibility 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
1a701935-d419-4dc9-9316-a4de591f69b6	2022-12-27 14:25:15.976334+00	🤣	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
e061e794-db53-4f9a-99bf-38765e8bec1a	2022-12-27 14:25:48.016691+00	🫡🫡	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
bcff419e-8d4d-46ea-8326-8d97e69a320a	2022-12-27 14:25:59.099549+00	🎅	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
4312b64e-0de6-4ef6-98a4-a44ac9ca926f	2022-12-27 14:26:09.937805+00	Ab padho	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
f12b535c-9b9e-4c78-a67b-5d76cbff936b	2022-12-27 14:26:23.301438+00	Aur app bhi	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
3357aef0-1c70-4f94-b9be-788d3cf9e79d	2022-12-29 06:31:18.118597+00	Hi	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
c348161c-4663-4ba8-9376-37bbaed9d1ee	2022-12-29 06:34:38.144851+00	Hi	a953afac-954e-4dc7-8d69-58fdadc59d5d	o8awADAwnFhzarRwBHQ20f1NCum1	f
887bf8b7-1f7d-494e-8824-14ff8622a49d	2022-12-29 16:22:11.602713+00	Hey	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
0fcea6e1-d66a-4b35-8655-e3b087102ac9	2022-12-29 16:46:23.408466+00	Hmm	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
2541ee90-3bef-4964-a834-55e4b5929440	2022-12-30 13:54:40.219817+00	Hi	7b8241fe-fa68-4e3f-9fba-64072f649aaf	NxZgtwaQrLO4nfkr8MVIthvJ6Py1	f
b4986897-2b60-4653-b808-962f5540cb64	2023-01-06 05:14:21.779213+00	Hi	76cd1ccd-a614-4ff5-a759-8308b20cfc2e	NyntbilHO2X7ARTy6EHw4uKDGeV2	f
1c72e8f7-b253-4880-a37e-e18acfb2f9a1	2023-01-06 05:14:28.658612+00	Hi	76cd1ccd-a614-4ff5-a759-8308b20cfc2e	NyntbilHO2X7ARTy6EHw4uKDGeV2	f
f54e5f2c-ba17-454c-9816-05ced22eb569	2023-01-06 05:14:34.219604+00	Hlo	76cd1ccd-a614-4ff5-a759-8308b20cfc2e	NyntbilHO2X7ARTy6EHw4uKDGeV2	f
6e3c4a9c-0bb9-4627-ae19-284ba1b04df8	2023-01-06 05:14:45.422808+00	Gigty	76cd1ccd-a614-4ff5-a759-8308b20cfc2e	usOWdwZr9XeOwdkIyjbJixXDmC12	f
3d4dd63a-0959-45cb-93e5-a795dbfa832c	2023-01-07 11:21:41.065975+00	Hello	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
ce6cc7d0-a8cf-43be-b805-71d71db9b462	2023-01-09 08:48:14.164232+00	hi	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
e666ddbc-21c6-4e46-9aa1-ee746af03ddd	2023-01-09 08:52:25.637941+00	Gg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
eadfbea6-9bb8-49a2-a883-b0b01ea7e9a3	2023-01-09 08:52:31.465532+00	Gg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
e1ac8b92-cf0b-4b8b-a424-f299270675a6	2023-01-09 08:57:00.876643+00	Ggggggg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
052a478a-554d-45a5-8ce7-6e891472fdb1	2023-01-09 08:57:03.089736+00	Ggg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
32421d46-ccb7-4b9a-8012-6132424d964a	2023-01-09 08:57:05.597564+00	G	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
bce95619-ce99-4563-8023-caf986c2dc3c	2023-01-09 10:08:16.409701+00	Hi	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
949f71e3-68ef-41c4-8bbb-392d88a83a9c	2023-01-09 10:08:38.502243+00	Hi	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
66ff7612-8057-41e1-901c-32c3c35305fb	2023-01-09 10:09:44.455332+00	Hh	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
8249e6e3-caf3-4882-9167-9974a0036706	2023-01-09 10:10:28.485194+00	Gg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
0553e6ab-f7d6-4379-a70f-786f81f81844	2023-01-09 10:12:19.099103+00	Ggg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
1bc0ed1c-909a-44c5-8449-b4d0b956cbf5	2023-01-09 10:43:35.972227+00	Yyyy	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
fb5e1f8c-76e6-4d9b-b983-49f037b8de88	2023-01-09 11:16:13.563958+00	Gggg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
a62b8594-fbce-425b-93d5-14ce969353b3	2023-01-09 11:18:12.486704+00	ujjjj	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
ec997b86-699b-425a-a8d2-bfaf537d34e5	2023-01-09 11:19:34.500488+00	ffff	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
ba8e3df9-b844-4155-82b3-6ee16b809f95	2023-01-09 11:25:07.056219+00	Rrf	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
34940a16-585f-470e-8eae-3fe26651fdc6	2023-01-09 11:49:49.549428+00	Gggg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
17ece904-8afa-4afc-877b-dbb8cc059cbc	2023-01-09 11:50:28.737833+00	Ffff	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
572847e1-2351-472a-9418-cf478ea3cb70	2023-01-09 11:50:53.685987+00	Yyy	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
dbc58480-0607-4d7f-834e-ff705b76c022	2023-01-09 11:51:51.127978+00	ddddd	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
a325dc71-2ce2-46c8-b33b-9544d5d10bb0	2023-01-09 12:19:27.315037+00	Ppp	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
f0e990dd-f9ec-43ad-995e-5c1be20f126b	2023-01-09 12:19:47.598611+00	Ggg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
778cf08f-f5f9-4722-984e-4f0e3518087c	2023-01-09 14:43:54.062429+00	Hey creator of this app	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
2b4a5154-cb6e-48ae-a813-ee93686e7f3e	2023-01-09 14:45:17.440473+00	U there!?	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
8f232726-82ab-4bae-8035-de9a40369f14	2023-01-09 14:45:51.669685+00	🙂	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
64bcae72-3130-4086-8f32-b433f98b8f8f	2023-01-09 14:46:10.728367+00	You should sign out and log in again 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
f603956d-d0b9-4cf8-92aa-3b13646c6365	2023-01-09 15:56:30.52656+00	I did	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
5da5622b-117a-4cb5-a77f-154524020643	2023-01-09 15:57:02.100452+00	NOICE	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
77f4431a-19bb-4258-bea8-399384d7272e	2023-01-09 15:57:19.865805+00	It took you 25 years	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
bbcb4fd1-1137-4dbd-97a6-5ddfe08bedc1	2023-01-09 15:57:57.112445+00	And yes when you press the notification app doesn't open	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
af4e9132-eae6-491f-98aa-621a12fe91c3	2023-01-09 15:57:58.022758+00	Wow 	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
c4fdf2f1-da74-4c81-a957-10d7327aa141	2023-01-09 15:58:13.704832+00	Notification aayi	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
ddffe234-bdaf-4feb-959d-aef8267dbd3a	2023-01-09 15:58:28.920249+00	Hu	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
505092f2-1b81-40f1-9a33-2350b8badd12	2023-01-09 15:58:36.596263+00	🥳	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
016d2f36-85f2-400f-89f2-81f4b1630733	2023-01-09 15:58:52.611015+00	🥳🥳🥳	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
7dfef67c-481a-41d8-a907-e3c11008596f	2023-01-09 15:59:51.166051+00	💥💥💥	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
173a0cd9-5fab-4f4f-87fc-494c2788a6c8	2023-01-09 15:59:59.815362+00	💥💥💥	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
3311a215-79ca-4fbc-a1d7-405e9f9e96dc	2023-01-09 16:00:09.568136+00	App icon correct nehi aara	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
7d9f8239-1ae3-4408-b32e-1960e2999787	2023-01-09 16:00:22.397625+00	Aaya na	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
d0d63863-786e-47f2-bd91-9605630f598a	2023-01-09 16:00:31.695071+00	Aur app open nehi ho ra jab notification press karte	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
49ca46d3-4de4-4799-bacb-4343af273b16	2023-01-09 16:01:46.194346+00	Why is it showing your name in notification and not mine	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
47f99b7e-878c-4b9f-965c-699b2e5f1434	2023-01-09 16:02:06.34005+00	U should be knowing 	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
15c0a5a9-ffc2-4fc2-a7d0-cef1bb17936f	2023-01-09 16:03:24.934185+00	Send me a msg	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
c2984e04-5b07-40e0-a910-4676fe8d2e96	2023-01-09 16:03:40.588326+00	Msg	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
890059de-c5f2-4925-aadb-80d7659ad1f9	2023-01-09 16:03:54.220365+00	I sent msg	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
9f39a080-d641-4461-8129-b33110d02966	2023-01-09 16:04:10.770007+00	❄️❄️❄️	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
62546d4b-0921-433f-b663-cecddb4ac2a8	2023-01-09 16:04:33.959166+00	Hello 1 2 3 mic testing 	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
555e617b-64a8-4ac5-abdf-63a1eb7bf559	2023-01-09 16:05:16.149682+00	Name mismatch 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
7cddb4be-de22-4f59-89c0-c2fa0eec27d8	2023-01-09 16:12:23.387378+00	Hu	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
a78894ac-d006-4204-a5c0-d30c505540f0	2023-01-09 16:19:47.503813+00	⦸  This message was deleted	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
237ff2c2-23d6-4b96-9fa2-504a1fa1dc90	2023-01-09 16:24:59.763925+00	⦸  This message was deleted	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
216379c5-618a-4c73-8881-1f22eb514d04	2023-01-09 16:36:33.780863+00	Ggg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
8912e307-29cc-4daa-bd39-491d6eff18a2	2023-01-10 09:59:21.606123+00	Gandu	7048d285-d4a8-4155-8d30-5023afeaa23c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
a4cc128d-1f2e-4a46-9353-b81d9a8cf85b	2023-01-10 10:04:27.92461+00	Hdhdhdhdhdhdhdhdhfkkknchfhdjfbd	7048d285-d4a8-4155-8d30-5023afeaa23c	NxZgtwaQrLO4nfkr8MVIthvJ6Py1	f
e91b0bf6-db4d-46d7-83e7-9538d287b1ca	2023-01-10 10:05:32.808603+00	Laudo	7048d285-d4a8-4155-8d30-5023afeaa23c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
0d67a3ab-240a-4829-8e07-91b98fcdb81a	2023-01-10 10:05:58.200633+00	Hhh	7048d285-d4a8-4155-8d30-5023afeaa23c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
0b622e40-efa2-4606-a974-3aa1be3b1f12	2023-01-10 10:06:16.433477+00	Gudj	7048d285-d4a8-4155-8d30-5023afeaa23c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
1993773a-3357-45c9-acfa-6d6c183b7dbd	2023-01-10 10:06:29.120004+00	Gandu	7048d285-d4a8-4155-8d30-5023afeaa23c	NxZgtwaQrLO4nfkr8MVIthvJ6Py1	f
8c3aa964-2244-47e6-b9b7-54a7c872e046	2023-01-10 10:06:35.020958+00	Gautam	7048d285-d4a8-4155-8d30-5023afeaa23c	NxZgtwaQrLO4nfkr8MVIthvJ6Py1	f
4c45abab-35f5-4d37-9749-cb20260d0a01	2023-01-10 10:29:23.65765+00	Hey 👋	1eb9228a-2856-4333-8417-dabdd678aa10	ObxIOuq35pY4QhHJiHDBqNyg0tS2	f
f099d933-7ab3-45fc-99db-4fa0826ff8ea	2023-01-10 10:30:00.14606+00	Hello	1eb9228a-2856-4333-8417-dabdd678aa10	ObxIOuq35pY4QhHJiHDBqNyg0tS2	f
b13ae5ce-d408-407e-95f0-026696adc3ef	2023-01-10 10:30:19.642383+00	Ggggg	1eb9228a-2856-4333-8417-dabdd678aa10	usOWdwZr9XeOwdkIyjbJixXDmC12	f
c0c063e4-fe46-45b7-ac82-b19d2f67cd28	2023-01-10 10:31:03.539881+00	Hehe	1eb9228a-2856-4333-8417-dabdd678aa10	usOWdwZr9XeOwdkIyjbJixXDmC12	f
232eb0a4-f270-4deb-8fd0-d3cdc680392b	2023-01-10 10:38:28.000649+00	Hi	1eb9228a-2856-4333-8417-dabdd678aa10	usOWdwZr9XeOwdkIyjbJixXDmC12	f
40a68eb5-2035-4ea2-be2e-3d79e54ff847	2023-01-10 15:02:43.958882+00	Hehe	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
b4c97253-e893-469d-9a01-a01414e8ef14	2023-01-10 17:23:32.043777+00	Haha	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
290e87a0-be5b-459e-b13c-f752cdff9fab	2023-01-10 17:24:27.271835+00	Phir se install karo	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
653808c7-518e-409a-bd2d-0ef01b2d972c	2023-01-10 17:31:42.566629+00	U there?	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
20ded637-6d7e-4f82-9610-5107857946a4	2023-01-10 17:33:04.173849+00	Hu	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
74fe8952-a332-46c8-a21c-fdd34a6e6fe2	2023-01-10 17:35:14.341767+00	Noice	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
c6ce9bfd-580b-4cae-b5a5-58b4cd351230	2023-01-10 17:36:49.276925+00	Kya karre?	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
6501f568-ac19-435b-95d3-054a3408879b	2023-01-10 17:37:06.053039+00	Nothing 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
1f757c4a-4415-4376-ba84-6fa4e8aabea2	2023-01-10 17:37:23.985613+00	Aara notification?	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
ce443896-a394-4995-8252-5b3d275fb7c8	2023-01-10 17:38:18.447903+00	??	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
c0d7f123-1077-43cf-a227-2aaee43e7e61	2023-01-10 17:41:21.167404+00	Hehe	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
b2635a63-43a1-4ecc-b5de-7259cb3d4bf2	2023-01-10 17:41:26.697946+00	Haha	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
17ef6710-beb8-4fcb-bd20-09de5124b8ec	2023-01-10 17:41:32.097748+00	Huhu	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
607c8981-458c-445c-a3b0-52c3bca7c878	2023-01-10 17:43:27.075989+00	🙂🙂🙂	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
6c13b9a5-864e-4c68-aed3-da73ef16da6c	2023-01-10 17:43:47.081627+00	Typing dikhari	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
e7c53092-6ce7-41f5-bea2-0f3cbf57f602	2023-01-10 17:43:53.446655+00	Yes	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
22a92f89-26d7-43b4-a965-8697c77635bb	2023-01-10 17:44:23.361745+00	And there is a secret feature 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
a5a44094-e1f3-499f-8d75-8641d8dc065e	2023-01-10 17:44:34.407383+00	Only for admin	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
72f6bb17-6e93-4882-83fd-726a4a441a4b	2023-01-10 17:44:44.971061+00	Wts that	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
9101e2c4-9eaf-4da6-a524-1873ba9d9f27	2023-01-10 17:45:00.556739+00	Hi	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
64e83e42-fe45-42f4-8d01-dddeb172f9cd	2023-01-10 17:45:05.31129+00	How did this happen 	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
fefe18c0-3350-4640-9894-2babd14db05a	2023-01-10 17:45:47.435949+00	U 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
f85b31ce-2d83-4175-b7b2-a942a3ab08a5	2023-01-10 17:46:18.850906+00	Wt u?	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
80dce674-5c1b-4145-9acf-f01173ec8eec	2023-01-10 17:46:38.701967+00	Type a long sentence 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
b9e09dce-94a2-4613-a3cf-6a3e6498422c	2023-01-10 17:46:50.300268+00	But don't send it	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
2e508080-9fa3-453b-8c56-a59a44895f90	2023-01-10 17:47:26.81012+00	A for Apple 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
863c610d-e3c0-4801-b968-741d21d8b0f1	2023-01-10 17:47:35.047626+00	B for ball	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
45710339-cb39-408b-bc5e-d16869dd00f3	2023-01-10 17:47:56.267572+00	C for cat	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
fc0885bc-6838-4a2c-8c25-f93c85a44074	2023-01-10 17:48:21.033356+00	Nandini for ediot	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
0f7b2067-a053-405e-818a-f7235a0805eb	2023-01-10 17:48:37.231982+00	😁😁😁😁😁	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
31a6e6c1-7111-4a75-a863-5c4f5d86caff	2023-01-10 17:49:24.194149+00	Before you asking 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
ddc5a3c9-b421-4ecd-8cd9-5cce80946eb7	2023-01-10 17:49:40.875469+00	Iam using telekinesis 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
653d8e2e-57de-433e-9be4-09781eac7377	2023-01-10 17:49:52.202163+00	🙂	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
1e30a412-3d46-4ea8-85da-cc81335a398b	2023-01-10 17:50:10.150337+00	A for Apple, b for ball, c for cat, e for ediot, 🙄😑😑😑😑😑😑😑😑😑😑😑👍😑😑😑😑😑😑😑😑😑😑😑😑😑😑😑😑😑😑😑😑😑😑😑😑😑😑😑😑😑😑😑😑😑😑😑😑😑	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
01ccc0cf-3ccd-4c6c-af2b-6b0b0dcac6c6	2023-01-10 17:50:34.027891+00	Tbh it's Amazing 	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
83ed7e35-599f-4689-bb26-aca32c5546ba	2023-01-10 17:50:48.90646+00	Thanku 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
b2afbddd-2e4e-4232-86f2-ec640536a7c1	2023-01-10 17:51:17.939548+00	Khana 	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
a155c925-b61f-4e81-9094-2a33bf1eec20	2023-01-10 17:51:34.376297+00	Kab khila te?	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
5fe45836-28fe-42a5-93b1-ed7b9e7ec54c	2023-01-10 17:51:57.379192+00	Vahi karte baithe kya tab se	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
245d4ef8-77a8-418b-b135-84bee3860d49	2023-01-10 17:52:05.100023+00	Aao abhich	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
d09d828a-909c-4072-a0c8-180b5b35f463	2023-01-10 17:52:51.75985+00	Aami nehi manenge	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
b6ed0a58-e11e-4272-a5ae-615717aa3b4a	2023-01-10 17:53:12.169244+00	Toh puche hi kyu phir 	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
4d084867-197f-4e68-829e-06eb94032e72	2023-01-10 17:53:28.234183+00	Jao khana Khao 	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
90a1a7ad-22d0-43f0-aa13-5d08a023dd9f	2023-01-10 17:53:30.609792+00	🥲.  	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
a6b21add-8f53-421e-b81d-e587fe99da86	2023-01-10 17:53:31.05681+00	Sojao	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
c67ff9a9-fd6b-4816-8595-fa53b7101e20	2023-01-10 17:53:50.160271+00	Hua register page?	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
7815fe37-484e-4180-87a1-95507cf92b56	2023-01-10 17:54:13.793827+00	Html page is ready	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
b10cee8e-85a6-4c01-9466-648a8ae842ae	2023-01-10 17:54:39.344347+00	Vo to sirf copy paste kare shyad 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
7eacacc5-dedc-4dbc-9cc7-804c36a95cf4	2023-01-10 17:55:18.421292+00	Usme hai hi kya	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
039ff190-3d98-471a-988d-0a041abf7cb5	2023-01-10 17:55:41.663788+00	Suno	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
bd1b2a27-b667-4e5a-9855-ad15b5870ef3	2023-01-10 17:56:01.99922+00	Nhi mein kaan band karru	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
435969ea-c72a-4c00-9ddc-29afd27a44ab	2023-01-10 17:56:06.699479+00	Typing bol kar upar naam ke neche	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
caaff188-da89-4ad2-84fa-e1228c7bf1e5	2023-01-10 17:56:21.121304+00	Nhi aati	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
a2940c2e-3a9d-4f75-9e33-74a42e7f4143	2023-01-10 17:56:25.041377+00	Dhika na ya it is good as it is	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
764b174e-6d56-4be9-a72d-37e315376daa	2023-01-10 17:56:26.128603+00	Aari*	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
0614d78d-6aff-4d3f-808a-00f52ab4bcf3	2023-01-10 17:56:41.848015+00	Is it good as it is	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
31c8d567-7579-414b-946e-2e75aead003e	2023-01-10 17:56:51.587944+00	It is*	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
7e9309c4-311c-4480-90f7-a154296526e5	2023-01-10 17:57:36.881899+00	Of knowing what you are typing?	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
ca380736-75bc-43e0-9734-7450023f9d54	2023-01-10 17:58:02.404984+00	Privacy policy mai mention karna padega 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
98f69cb4-2903-48ce-9f77-2703142bbf07	2023-01-10 18:00:26.146849+00	Next feature	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
dfe2c175-4fe7-4cf0-834d-39cb7907f36a	2023-01-10 17:57:17.855916+00	And should I keep this feature 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
c141e302-bcda-4c59-862b-e222ce928806	2023-01-10 17:57:43.121779+00	🙂	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
d4c98abe-776b-4a09-a5e7-272830ec47ab	2023-01-10 17:58:43.205222+00	It is only for admin na	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
a4fcd08c-a474-4ecb-8658-4bf8270f71d6	2023-01-10 17:59:01.895404+00	App banake 	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
ca86db89-929a-4317-9539-fef5bd8c5f3f	2023-01-10 17:59:31.473039+00	Mark Zuckerberg will agree with you 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
f997974b-14cb-4849-92e6-3baf143019de	2023-01-10 17:58:47.427872+00	Chalta lo	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
add96d9c-9bc6-413f-b1b6-c308abc78043	2023-01-10 17:59:15.020087+00	Inta bhi rights nhi hai bole toh kaisa	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
2571a210-7667-4884-81e4-e1e19a2f0a5f	2023-01-10 18:00:50.439214+00	Encryption or image sharing?	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
4fefd32c-26d4-41a0-97b3-546806e0c849	2023-01-10 18:01:10.301111+00	Wt u mean by encryption 	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
700ebd40-338a-4892-9df7-d2bf8a9a99d6	2023-01-10 18:01:12.260175+00	End to end	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
392c5ce8-2acb-494c-83b1-a0cb1e2d2106	2023-01-10 18:01:26.582941+00	Wt does it mean 	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
4afd9f26-f959-4efb-b8a3-fe72e3d0196b	2023-01-10 18:01:42.999458+00	Message is encrypted and then stored in the data base	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
a90d1641-595a-4f0b-94d0-f53abfb962b8	2023-01-10 18:01:57.435519+00	Then	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
26f06864-7224-41f2-9d50-e4342c43eda4	2023-01-10 18:02:29.734478+00	Only the users can read them	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
ad0ce7ed-21f8-48f4-9c99-3836d6792de2	2023-01-10 18:02:36.094893+00	Not me	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
673630b5-22d6-4e51-a0ff-8531e6f6af50	2023-01-10 18:02:51.70413+00	Image sharing karo	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
a90be3c8-bf42-4a44-952e-a0d217a52061	2023-01-10 18:03:11.368212+00	Hu it will be more useful 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
7b1c6391-d5d1-4f36-995a-a1e8173d2b56	2023-01-10 18:03:24.791642+00	Khana kha liya?	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
a3cedfab-6aea-4b6f-a468-61dd3907f89c	2023-01-10 18:03:50.067042+00	Wt u expect 	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
d45d35bd-b0ad-432b-ad5a-71dc25b62787	2023-01-10 18:04:05.276478+00	Tum puchne tak bhooki rahungi	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
7ab1c0ab-9027-42b8-9ff7-9bd28b9468bd	2023-01-10 18:04:07.363457+00	?	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
a9f7c712-4341-40c4-bb88-70d29fdc79b8	2023-01-10 18:04:08.644755+00	Hu	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
f6570755-7f6b-43c8-b782-8139ae58363f	2023-01-10 18:04:13.606017+00	Nhi 	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
fd0cfa54-5512-4fad-bbdf-2a9d890fff7c	2023-01-10 18:04:23.548938+00	🤣	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
313b1f29-b87c-4c8d-bb4a-4d683cf73b08	2023-01-10 18:04:30.273895+00	Achi baat hai 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
cc487916-ddb8-4469-a81a-e489183524fa	2023-01-10 18:04:52.097953+00	Idk	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
2276c663-9254-46be-a18e-c497041cf188	2023-01-10 18:05:01.97164+00	Kyu nehi ja re?	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
dd29b534-d3fa-445c-94a1-f95b3d654586	2023-01-10 18:05:15.486831+00	H	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
aa4bd609-45e2-4218-87b2-006d2cc4ae27	2023-01-10 18:05:50.031878+00	Yes	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
baea42a3-ff57-424a-998e-6cfac36b4da2	2023-01-10 18:06:01.685757+00	The person using it	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
42f4c907-8a6b-473d-a304-9d3303da23b2	2023-01-10 18:06:16.71653+00	😒	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
08660ad6-113d-45ed-8e6d-2bfa1204ad93	2023-01-10 18:06:18.30179+00	Is pagal 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
16b12afa-a3cf-4e27-9efa-3c2671023db0	2023-01-10 18:06:23.989404+00	🤣🤣🤣	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
09596a77-989b-492c-bdf2-beaca3555e5f	2023-01-10 18:06:45.184985+00	Kal aa re?	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
4bd34d4f-4f40-43d6-80f5-d7ff8490ce10	2023-01-10 18:06:58.406615+00	Btw	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
35bc44a1-343c-426a-810f-83a4391755f3	2023-01-10 18:07:09.003232+00	Ajj itna jaldi kaise?	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
5becc36b-3322-4059-a9fe-838bd8974bc3	2023-01-10 18:08:24.601933+00	So gaye?	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
03689285-68de-4cd5-8567-8d735801f94a	2023-01-10 18:09:28.842138+00	Good night pagli 🙂	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
e3d792a8-3ed6-4d04-9982-0e62a8316180	2023-01-10 18:09:55.825314+00	Dress?	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
a3cf9e99-f65d-40f1-a9c2-a1110d5df6c4	2023-01-10 18:10:35.327752+00	Kyaaaaaaaaaaaaaaaàaaaaaaaa	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
655aceb5-bd35-4950-99ae-8638a8030207	2023-01-10 18:12:28.538709+00	😐	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
d8c70b41-a0e4-4a3b-9f5e-ceadd43cd1fe	2023-01-10 18:12:42.837943+00	Response?	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
b9e7aa38-3be9-4e7a-90a3-58e18ece5110	2023-01-10 18:16:03.781202+00	You really online or is that a bug?	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
6bcadf6c-9494-4588-83e5-1526774caca5	2023-01-10 18:16:10.303006+00	Gn	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
6208a1ea-2689-42df-8135-6c9137c79e06	2023-01-11 00:55:35.028435+00	Sry aankh lag gayi...	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
f1bde3dd-aca1-40d7-9a17-6b978a7d3bda	2023-01-11 00:55:39.744141+00	Morning 🌞	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
7011e0b3-2b7e-4cf1-83c7-4c1a714f0637	2023-01-11 03:16:01.008412+00	 😒	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
5159840a-1a8c-415c-b461-2f1e3e0fe4be	2023-01-11 06:29:12.374209+00	Focus	7048d285-d4a8-4155-8d30-5023afeaa23c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
36f477fe-829f-4c9e-86bd-e1d0f3218f4d	2023-01-11 06:31:56.817968+00	Gandu 	7048d285-d4a8-4155-8d30-5023afeaa23c	NxZgtwaQrLO4nfkr8MVIthvJ6Py1	f
1e8be4d3-ec5c-48aa-80c4-b601c391bf28	2023-01-11 06:32:36.920455+00	 Hehe	7048d285-d4a8-4155-8d30-5023afeaa23c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
5c122d66-9bfa-4e2d-a3da-778a42559916	2023-01-11 08:13:22.157037+00	Hi	041803f7-f5e3-4825-baa5-e93427d4e8d5	6m1sYDALflWXdONzQtNj7ODUM9v2	f
4be05fbf-0436-41dd-9cde-55beb523eb2a	2023-01-11 08:13:42.310251+00	Hehe	041803f7-f5e3-4825-baa5-e93427d4e8d5	usOWdwZr9XeOwdkIyjbJixXDmC12	f
5ca4cf56-bc59-4738-a954-20f9aa3d9164	2023-01-11 08:14:00.552423+00	Gandu	041803f7-f5e3-4825-baa5-e93427d4e8d5	usOWdwZr9XeOwdkIyjbJixXDmC12	f
0de7880e-166a-47b0-aac5-20197e6403f4	2023-01-11 16:11:22.193101+00	qqq	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
c6a93faf-184f-4bd4-ab6d-cf6286518e53	2023-01-11 16:36:04.942445+00	Good night 💫	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
9c60a2a9-45d8-4a52-ba52-46bffa1d4e3c	2023-01-11 16:43:14.684554+00	Good night pagli 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
ecf003b0-77fb-4599-85ea-81fd1c69c71c	2023-01-12 07:16:14.005028+00	Hii	e40ab7c0-668f-48a7-acbe-8afa9dc0c9f5	uxJiWSJDRbdrCPnSg60gV92chN23	f
9200e514-5cdc-4276-9b2f-80f8f831d924	2023-01-12 07:17:06.843678+00	Hi	e40ab7c0-668f-48a7-acbe-8afa9dc0c9f5	usOWdwZr9XeOwdkIyjbJixXDmC12	f
824a4960-1c05-40f2-9e26-2469666f0d7c	2023-01-12 07:18:49.112721+00	Gandu	e40ab7c0-668f-48a7-acbe-8afa9dc0c9f5	usOWdwZr9XeOwdkIyjbJixXDmC12	f
f51b4f50-424b-43f9-94b9-18ab4c03b1ab	2023-01-12 07:19:58.492824+00	Hehe	e40ab7c0-668f-48a7-acbe-8afa9dc0c9f5	usOWdwZr9XeOwdkIyjbJixXDmC12	f
95168ae5-9e89-4d66-81e2-1e97ee9b33be	2023-01-13 16:39:11.532748+00	Hii	e40ab7c0-668f-48a7-acbe-8afa9dc0c9f5	uxJiWSJDRbdrCPnSg60gV92chN23	f
da855a7f-78f9-445e-a126-77060dbf187c	2023-01-13 16:39:43.283006+00	Hi	e40ab7c0-668f-48a7-acbe-8afa9dc0c9f5	usOWdwZr9XeOwdkIyjbJixXDmC12	f
ebf91e62-48e2-447b-b5d0-e1ab0a44b4eb	2023-01-13 16:39:46.486905+00	Bolo	e40ab7c0-668f-48a7-acbe-8afa9dc0c9f5	usOWdwZr9XeOwdkIyjbJixXDmC12	f
99fc0b8f-5a64-48f5-a183-377df394b1d7	2023-01-13 16:40:18.992922+00	Check kar raha tha be 😅	e40ab7c0-668f-48a7-acbe-8afa9dc0c9f5	uxJiWSJDRbdrCPnSg60gV92chN23	f
85c3324e-a999-4993-a01d-43d5d4842321	2023-01-13 16:40:31.160581+00	NOICE 	e40ab7c0-668f-48a7-acbe-8afa9dc0c9f5	usOWdwZr9XeOwdkIyjbJixXDmC12	f
885864a6-8a6e-4604-9db7-c93e4b016245	2023-01-13 16:40:45.830273+00	Spam karu?	e40ab7c0-668f-48a7-acbe-8afa9dc0c9f5	usOWdwZr9XeOwdkIyjbJixXDmC12	f
f222c0ee-3db5-4044-bb91-3e11910d9c01	2023-01-13 16:41:04.614625+00	Uninstall kartu mai	e40ab7c0-668f-48a7-acbe-8afa9dc0c9f5	uxJiWSJDRbdrCPnSg60gV92chN23	f
accee6b1-57f2-42d1-949f-214f5bd4446f	2023-01-13 16:41:11.004845+00	Gandu 	e40ab7c0-668f-48a7-acbe-8afa9dc0c9f5	usOWdwZr9XeOwdkIyjbJixXDmC12	f
5336eba6-4af3-4db0-9b99-58a79be91292	2023-01-13 16:41:29.879118+00	Data Bach detu	e40ab7c0-668f-48a7-acbe-8afa9dc0c9f5	usOWdwZr9XeOwdkIyjbJixXDmC12	f
af391ba1-79bb-4940-8561-aac336b2bc6d	2023-01-13 16:41:45.398879+00	You agreed to my privacy policy 	e40ab7c0-668f-48a7-acbe-8afa9dc0c9f5	usOWdwZr9XeOwdkIyjbJixXDmC12	f
001f03fe-f873-40ab-92d1-b48401c0c5cc	2023-01-13 16:41:58.662683+00	😅	e40ab7c0-668f-48a7-acbe-8afa9dc0c9f5	uxJiWSJDRbdrCPnSg60gV92chN23	f
b6ae4f90-4409-4f53-974d-0520ccca5ac3	2023-01-14 04:12:09.019112+00	Snap Streak 🥲. 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
017c094d-7a8a-40ae-95f4-56f89f3444a3	2023-01-14 04:12:19.140485+00	🙄	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
a647ba92-d5f9-4adb-943e-29036f841dc6	2023-01-14 09:35:28.244743+00	Gg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
0fdd5138-e7a6-4aab-a5b2-7dd53a967e95	2023-01-14 09:38:13.109391+00	Gg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
581889b6-5f81-4a08-8d51-319dd981d57b	2023-01-18 09:27:23.380367+00	Hello	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
f4ead921-d660-47b7-996a-1dc2d713729a	2023-01-14 10:48:43.491678+00	adac3b86-cec4-47f6-b71b-7ad6ee956c2c/eaf9795d-bd61-44d7-a90f-6660a6c3f4b6.png	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	t
1047bbe2-3e47-476c-a174-aa7b0676192d	2023-01-18 16:04:52.971242+00	Ho?	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
8db84e3d-15c7-440b-ad50-d235eccad30d	2023-01-18 16:07:27.171025+00	 Itna jaldi?	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
2670a774-8b6e-49e9-bf18-efd3496e2496	2023-01-18 16:08:20.791588+00	Hu	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
da937a03-90fc-406c-8f17-2cdb5689543b	2023-01-18 16:09:23.592775+00	?	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
919a5d43-b696-4342-8022-a0c7c9a1b234	2023-01-18 16:09:45.741911+00	Neend aare?	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
49f6d357-6b37-48fc-b38e-090e4d061e08	2023-01-18 16:10:34.913702+00	Aankh band kare toh aajayegi	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
9ee77e61-4184-4feb-acc5-4063781ea330	2023-01-18 16:10:43.209677+00	Usme kya 	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
415d18e1-96bd-427c-bdbe-bdb4b6b9bf32	2023-01-18 16:10:59.571222+00	Kal aare?	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
a7744e36-f4d5-4976-a921-b4fe0d6c1084	2023-01-14 10:58:31+00	⦸  This message was deleted	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
24ba3898-1fa2-4e40-97dc-c508b94398cd	2023-01-14 11:05:28+00	⦸  This message was deleted	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
ab514ff2-12d9-4060-8c8f-ae2c87212a24	2023-01-14 10:06:30+00	⦸  This message was deleted	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
f99bcd2f-1c43-4880-ab23-70386989cb38	2023-01-14 10:01:38.318327+00	⦸  This message was deleted	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
a2c6562a-a279-49c5-971c-74b25084d1e9	2023-01-18 13:52:41.902964+00	1	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
f1750cea-bde8-464d-984b-f5e669fbad72	2023-01-18 13:52:45.828845+00	2	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
727e5e46-54b2-4439-8563-3cbf0327ab46	2023-01-18 13:52:50.065515+00	3	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
3605625e-7bf2-4d86-9db1-5dfe06cb4c46	2023-01-18 16:09:09.431171+00	Gala kaisa hai	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
653f1137-7445-4c73-b803-a28c68ea5bf1	2023-01-18 16:10:50.888369+00	Good girl 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
0d663580-d178-4244-8e0d-e57e7c1aef5d	2023-01-18 16:01:09.044904+00	Good night 💫	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
8517eca1-7f3e-44d6-8fd8-151caaf4327d	2023-01-18 16:09:32.199475+00	Not bad	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
48421ea5-42ff-4d0c-af3e-78974a6c44a8	2023-01-18 16:10:53.690944+00	So jao 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
fcef442b-08fe-43f5-8640-bdeb3c449058	2023-01-18 16:11:33.330455+00	May be	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
6e806f79-2d34-4c33-a03a-1d808b997398	2023-01-18 16:11:35.117894+00	👍	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
ad836b8a-3427-4dd3-8812-f0e9b781f5d9	2023-01-18 16:11:51.397554+00	Shayad aatu	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
d3aa0576-7a8b-4108-9fe4-6a052b3408ca	2023-01-18 16:12:08.735261+00	Ok cu	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
30ef3fd4-92dd-4cde-aaf1-e302e8aa6f00	2023-01-18 16:12:17.254289+00	Good night 🙂	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
2fb08e19-0c01-4653-a86d-a7be44da0b00	2023-01-19 05:12:40.221065+00	Dagabaaz re hai dagabaaz 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
1b943abd-75b7-4100-8c9f-6905a48b8955	2023-01-19 05:28:48.090079+00	😒😒😒	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
fab47cb0-583e-45d2-a695-4112b40f7a4f	2023-01-19 05:31:25.538814+00	Tose Naina bade dagabaaz re 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
5d86a551-ed9c-49d9-b426-561829eb0acf	2023-01-19 05:31:38.29155+00	Focus gandu	e40ab7c0-668f-48a7-acbe-8afa9dc0c9f5	usOWdwZr9XeOwdkIyjbJixXDmC12	f
b100f6ea-4aec-4014-991b-5fc9bf0628f8	2023-01-19 05:32:29.752774+00	Class suno	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
65d6bf93-fdb7-4176-9950-4a4b5c59a592	2023-01-19 05:32:32.431439+00	Pagal	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
b105e7f3-8bd1-48d6-8cf4-43e73b3b9981	2023-01-19 05:32:47.37105+00	Good night 	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
ecd0ccec-5243-4dc8-8b95-ed8fe634ded0	2023-01-19 05:34:59.450052+00	Ab ho ra tumhare good night 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
31e3f4ae-0f87-4ff6-9a22-eaa70b24b8e4	2023-01-19 05:35:38.346075+00	Noice	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
7a15f1a0-8f9b-46d3-b22f-0e76c4afc672	2023-01-19 09:05:05.824487+00	Hello	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
7d548e62-8b9b-4672-9c28-e3c385824524	2023-01-19 09:05:24.437006+00	Hi	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
bb497a77-1acf-4cd1-af82-2068d37d95a4	2023-01-19 09:05:46.141083+00	CN assignment 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
0c1efff4-48ad-4fe9-b0c4-c4ed52401edb	2023-01-19 09:05:50.357443+00	Kya karre?	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
18fa99db-3d9f-4cbd-94ed-8ddc718f873b	2023-01-19 09:05:57.157095+00	Likhe ru	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
3f4f4be9-9b11-4fb0-a6a5-55acc365c4f6	2023-01-19 09:06:20.350799+00	Kaha tak likhe	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
44f8f413-6e14-4750-8182-ad7e320cc508	2023-01-19 09:06:37.915693+00	22 ARP	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
0034d035-1fc6-4616-90f8-3647c1775817	2023-01-19 09:07:07.05078+00	23 tak likhi mein	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
b3116cff-cdc9-489b-b3e8-fa841f31119d	2023-01-19 09:07:21.548418+00	Humming distance?	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
dfdc819d-35c6-4dce-baa9-6c60a3f55341	2023-01-19 09:07:25.889571+00	Impossible 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
ba172e32-1963-4c81-a361-3d560ffc1f0b	2023-01-19 09:07:29.419377+00	Hamming*	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
f05d6064-42d8-49fb-ad72-d268d6582cbf	2023-01-19 09:07:42.701456+00	🙂	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
714becf1-0dcf-4d3f-a686-ab5cb988431f	2023-01-19 09:09:00.886865+00	Likho ab	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
65641c47-2fd3-4a9a-b941-30907fe7c266	2023-01-19 09:09:11.004952+00	K	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
050aecd2-e3f2-4553-ae04-25346d4dc571	2023-01-19 09:09:17.345672+00	Aur aap bhi 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
e409d4d1-df4d-4900-922a-33bf9722175e	2023-01-19 09:17:25.927675+00	Snap Streak broken again 🥲. 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
d39268c8-9a41-4098-9a02-92272e0533de	2023-01-19 09:17:36.916224+00	🥲 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
0ded7e08-cdfa-4126-8ccc-95976c948362	2023-01-19 09:25:15.178041+00	Lab aajao	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
61edfc29-ce19-4af6-8526-5cfe5dc7d924	2023-01-19 10:52:28.058634+00	I WANT A SMILING FACE SNAP	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
82476709-a93e-4495-a8ce-bd7de79a30f2	2023-01-19 10:53:50.091523+00	Don't you send a smiley emoji instead. I expect you would 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
bb6501e2-646b-41da-af18-53d1144cfe7f	2023-01-19 12:51:06.074154+00	Not funny 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
77d23881-84ce-4ac4-9ed4-1bdd98bff630	2023-01-19 16:40:24.207027+00	Only after this ur wish can be fulfilled 	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
1f223d84-f219-4528-9136-6694c90760a3	2023-01-19 16:41:02.963617+00	Snaps will be backed up by Snapchat 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
9414ce30-4581-4ab6-85b2-88c331f3a0c5	2023-01-19 16:41:22.720772+00	Camera roll is not they are stored locally 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
648ad94c-2181-4507-92fa-05342c5f079a	2023-01-19 16:44:25.253112+00	I logged out from my device and logged in with another 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
f7be2199-67eb-4700-96ce-37f12666a470	2023-01-19 16:35:30.106166+00	Good night💫	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
ce003506-3a12-4d83-abfa-2ed9a509ca8b	2023-01-19 16:35:54.52169+00	Itna jaldi 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
a6918e38-eb78-4e9d-9b45-522f0406f9aa	2023-01-19 16:36:22.097391+00	Ye konsi jaldi hai?	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
6851fcfc-bd36-4f55-87ba-78b2d96ecfd0	2023-01-19 16:36:44.722141+00	My requests were not full filled.	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
c2913f7e-fcf1-4e66-a2ce-6da8ea38cb2b	2023-01-19 16:38:37.785744+00	😐	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
eab87c26-a53e-4242-9b50-a7c5e23c4689	2023-01-19 16:38:46.874809+00	Gn	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
9ddbf7ed-5b97-41cf-a775-9b618efa3460	2023-01-19 16:39:18.100834+00	Once check 	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
fa5678df-cb47-45dc-a5a7-61aa99479562	2023-01-19 16:39:41.942181+00	Ek mobile se Snapchat log out karke	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
e65f51ef-aa86-44c6-b924-721722319194	2023-01-19 16:39:53.964463+00	Dusre mobile se login kare toh 	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
ce645bdd-20d4-4991-97bd-4b7de6965406	2023-01-19 16:40:05.669359+00	Photos rehte ki nhi bolkar	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
d70b9ae0-75f4-4ebc-9263-5c75cb0efce8	2023-01-19 16:44:48.579127+00	New device had all snaps 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
a835a581-2131-4f03-9346-faf3fcacaeec	2023-01-19 16:45:15.839789+00	Again i logged back in old device all snaps were there too	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
57f354f5-7196-42c6-a3c9-ebd104a2609a	2023-01-19 16:45:20.726225+00	🙂	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
7657737c-9911-4643-82df-9d82492a0b5a	2023-01-19 16:48:01.944947+00	Noice 	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
e2a8d064-f68b-419b-bf41-f5f0adefc4da	2023-01-19 16:48:09.076943+00	Thanku	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
525ffaf0-3dbb-443a-b5e3-c9ceb70dc19d	2023-01-19 16:48:39.916666+00	So jao ab 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
85920ae7-ffb3-4b89-9d7f-00251eb1111c	2023-01-19 16:48:53.104803+00	Kal mai nehi aaru	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
3cd743b5-ff54-4240-adf2-1e31744e5c44	2023-01-19 16:48:57.214178+00	Shyad 	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	f
0e623bde-de23-49ec-b182-041ca42c2449	2023-01-19 16:51:56.033601+00	Okay 	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	f
d19a95f2-f78a-4847-976c-c46277a14b08	2023-01-09 10:43:28.118107+00	⦸  This message was deleted	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
0851b2b4-a26d-42bf-8f58-a154848a6189	2023-01-09 16:24:45.624132+00	⦸  This message was deleted	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
2fa434fb-c2d2-41cb-ae32-c3db8af60464	2023-01-09 16:24:27.720799+00	⦸  This message was deleted	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
ce5a5a12-375a-4575-80a3-fce89dea8e58	2023-01-09 16:26:12.175042+00	⦸  This message was deleted	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
38429f3e-53b0-4410-820f-4448d315328f	2023-01-19 15:54:00+00	⦸  This message was deleted	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
9f456b99-d310-4a78-95ce-392c0299ba3b	2023-01-19 15:58:09.86734+00	⦸  This message was deleted	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
b3c80a68-9fe7-47e4-b1e2-4a0311cd2971	2023-01-19 16:04:37.137109+00	⦸  This message was deleted	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
2a014793-abd8-417a-975d-269a5ec873d9	2023-01-20 10:17:37.56446+00	Hi bye hi	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
3660820a-de39-4d4e-b4bd-357385f8f10e	2023-01-20 11:54:12.438461+00	.	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
71c4efd7-8646-421b-bac6-b021e22ead0a	2023-01-20 11:56:49.054461+00	gdsf yjgd gsygduygv	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	f
729be5f8-457f-48b4-84c1-da531ab77707	2023-01-20 12:02:57.843908+00	adac3b86-cec4-47f6-b71b-7ad6ee956c2c/707cfc94-df00-44d2-bd18-16c47abd632a.jpeg	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	t
ce8bbad9-838d-401e-9c5f-652e56d64f04	2023-01-20 12:08:42.995505+00	Hi bye bye hi.	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	f
\.


--
-- Data for Name: User; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--

COPY public."User" (id, created_at, name, status, image) FROM stdin;
nkp5WRREr8cnvXzbQ3FUzbMtyQa2	2022-12-20 15:34:43.619147+00	BOT2	Hey there, I'am using WC.	https://notjustdev-dummy.s3.us-east-2.amazonaws.com/avatars/4.jpg
NyntbilHO2X7ARTy6EHw4uKDGeV2	2023-01-06 05:11:51.854419+00	Kushal	Hey there, I'am using WC.	https://notjustdev-dummy.s3.us-east-2.amazonaws.com/avatars/4.jpg
Fm0lB4F7oMeKsojeVmmX7f77SjO2	2022-12-27 13:06:49+00	Anonymous 	Hey there, I'am using WC.	https://notjustdev-dummy.s3.us-east-2.amazonaws.com/avatars/4.jpg
usOWdwZr9XeOwdkIyjbJixXDmC12	2022-12-19 14:00:19+00	Who Cares!	Hehehehehehe	https://notjustdev-dummy.s3.us-east-2.amazonaws.com/avatars/5.jpg
ObxIOuq35pY4QhHJiHDBqNyg0tS2	2023-01-10 10:29:06.320271+00	Dex	Hey there, I'am using WC.	https://notjustdev-dummy.s3.us-east-2.amazonaws.com/avatars/4.jpg
6m1sYDALflWXdONzQtNj7ODUM9v2	2023-01-11 08:12:57.507035+00	Boss	Hey there, I'am using WC.	https://notjustdev-dummy.s3.us-east-2.amazonaws.com/avatars/3.jpg
uxJiWSJDRbdrCPnSg60gV92chN23	2023-01-12 07:15:23.371772+00	Rachesh Patil	Hey there, I'am using WC.	https://notjustdev-dummy.s3.us-east-2.amazonaws.com/avatars/3.jpg
NxZgtwaQrLO4nfkr8MVIthvJ6Py1	2022-12-26 17:27:16.623523+00	Sam	Hey there, I'am using WC.	https://notjustdev-dummy.s3.us-east-2.amazonaws.com/avatars/3.jpg
JK2Ww9wLsuTXgFVwj9U6BCxUw703	2022-12-19 14:17:09.584631+00	BOT1	Hey there, I'am using WC.	https://notjustdev-dummy.s3.us-east-2.amazonaws.com/avatars/2.jpg
o8awADAwnFhzarRwBHQ20f1NCum1	2022-12-29 06:34:20.449901+00	UMAIR	Hey there, I'am using WC.	https://notjustdev-dummy.s3.us-east-2.amazonaws.com/avatars/3.jpg
\.


--
-- Data for Name: UserChatRoom; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--

COPY public."UserChatRoom" (id, created_at, "ChatRoomID", "UserID", "LastSeenAt", "LastSeenMessageID") FROM stdin;
501e4262-d20c-4929-9c23-c631af6f6fab	2022-12-22 14:08:11.201978+00	9267a9db-1f94-4b7c-a30e-f6a9d2513879	usOWdwZr9XeOwdkIyjbJixXDmC12	\N	\N
569a884e-da03-46d6-8e89-1cf8e9fd308f	2022-12-22 14:08:11.201978+00	9267a9db-1f94-4b7c-a30e-f6a9d2513879	nkp5WRREr8cnvXzbQ3FUzbMtyQa2	\N	\N
31f9c4e2-2f75-43cc-9627-87dc75610c19	2022-12-26 17:27:29.659037+00	7048d285-d4a8-4155-8d30-5023afeaa23c	NxZgtwaQrLO4nfkr8MVIthvJ6Py1	\N	\N
2c2c04d0-f3b6-4f96-824b-a93f97fe856b	2022-12-26 17:27:29.659037+00	7048d285-d4a8-4155-8d30-5023afeaa23c	usOWdwZr9XeOwdkIyjbJixXDmC12	\N	\N
5ff0a8fc-abd9-424d-a756-52c2237e3b11	2022-12-26 17:28:05.124084+00	0f51064e-19a4-403e-a887-9607ebe23765	NxZgtwaQrLO4nfkr8MVIthvJ6Py1	\N	\N
8bce563c-a1fd-4393-ac7e-1f862b5d4695	2022-12-26 17:28:05.124084+00	0f51064e-19a4-403e-a887-9607ebe23765	JK2Ww9wLsuTXgFVwj9U6BCxUw703	\N	\N
fdf3b46e-7072-49f8-8441-62978060a8bd	2022-12-26 17:28:22.421586+00	866ad7be-3d5a-4717-8fd0-5e4abb7820a5	NxZgtwaQrLO4nfkr8MVIthvJ6Py1	\N	\N
a11662c9-d702-41f2-82e1-6b24668a9a6c	2022-12-26 17:28:22.421586+00	866ad7be-3d5a-4717-8fd0-5e4abb7820a5	nkp5WRREr8cnvXzbQ3FUzbMtyQa2	\N	\N
d12d3434-99cf-4cf3-8b94-98b6ca2b6e5b	2022-12-27 13:15:35.96212+00	7b8241fe-fa68-4e3f-9fba-64072f649aaf	Fm0lB4F7oMeKsojeVmmX7f77SjO2	\N	\N
2d2945a0-2f71-4662-a467-e314a4317382	2022-12-27 13:15:35.96212+00	7b8241fe-fa68-4e3f-9fba-64072f649aaf	NxZgtwaQrLO4nfkr8MVIthvJ6Py1	\N	\N
ae0e82af-e0c5-4775-9183-0eee37f1783e	2022-12-27 13:15:56.29607+00	12282606-8d6c-4c36-acb5-7c4a61056b8d	Fm0lB4F7oMeKsojeVmmX7f77SjO2	\N	\N
cec53a22-d74f-43f4-a18f-6106fc54895c	2022-12-29 06:34:33.733408+00	a953afac-954e-4dc7-8d69-58fdadc59d5d	o8awADAwnFhzarRwBHQ20f1NCum1	\N	\N
b2614583-8f4f-4548-8c14-7ae9110e85ed	2022-12-29 06:34:33.733408+00	a953afac-954e-4dc7-8d69-58fdadc59d5d	usOWdwZr9XeOwdkIyjbJixXDmC12	\N	\N
a69761ed-98d8-4e01-b683-cfb448b9e91a	2022-12-30 13:55:02.831092+00	2cc0f398-5c65-424f-8ee0-fca5d9f7fc42	NxZgtwaQrLO4nfkr8MVIthvJ6Py1	\N	\N
570f97a0-2ff6-4fab-8658-2f2b764b049d	2022-12-30 13:55:02.831092+00	2cc0f398-5c65-424f-8ee0-fca5d9f7fc42	o8awADAwnFhzarRwBHQ20f1NCum1	\N	\N
dd9bb5df-7565-4b68-a033-85b4e45afdc3	2023-01-06 05:14:16.195678+00	76cd1ccd-a614-4ff5-a759-8308b20cfc2e	NyntbilHO2X7ARTy6EHw4uKDGeV2	\N	\N
2e1426b1-a58b-45ee-940c-2f45e81e2613	2023-01-06 05:14:16.195678+00	76cd1ccd-a614-4ff5-a759-8308b20cfc2e	usOWdwZr9XeOwdkIyjbJixXDmC12	\N	\N
5c082b54-25a3-4b24-8039-f64cf3187780	2023-01-10 10:29:14.752027+00	1eb9228a-2856-4333-8417-dabdd678aa10	ObxIOuq35pY4QhHJiHDBqNyg0tS2	\N	\N
95cb5101-2d77-4466-b3e4-c60ee34de94c	2023-01-10 10:29:14.752027+00	1eb9228a-2856-4333-8417-dabdd678aa10	usOWdwZr9XeOwdkIyjbJixXDmC12	\N	\N
57f5a866-4188-420a-b074-9694b5b940bd	2023-01-10 15:23:58.078221+00	dc048925-ba19-4bbc-913a-66c11ed38b04	NxZgtwaQrLO4nfkr8MVIthvJ6Py1	\N	\N
1e849ddf-c52a-4a33-ae09-38393cd9bf89	2023-01-10 15:23:58.078221+00	dc048925-ba19-4bbc-913a-66c11ed38b04	ObxIOuq35pY4QhHJiHDBqNyg0tS2	\N	\N
2571ee6f-0b5c-4ac3-af42-017987c1c657	2023-01-11 08:13:13.257645+00	041803f7-f5e3-4825-baa5-e93427d4e8d5	6m1sYDALflWXdONzQtNj7ODUM9v2	\N	\N
933868ea-310a-4f1f-ac8f-2f64407effeb	2023-01-11 08:13:13.257645+00	041803f7-f5e3-4825-baa5-e93427d4e8d5	usOWdwZr9XeOwdkIyjbJixXDmC12	\N	\N
279165be-6cb2-4100-91ed-aee02d699b42	2023-01-12 07:16:09.320002+00	e40ab7c0-668f-48a7-acbe-8afa9dc0c9f5	uxJiWSJDRbdrCPnSg60gV92chN23	\N	\N
5ebbdf46-1a3e-499c-a07d-0860d4d4d772	2023-01-12 07:16:09.320002+00	e40ab7c0-668f-48a7-acbe-8afa9dc0c9f5	usOWdwZr9XeOwdkIyjbJixXDmC12	\N	\N
85c04a2f-8d22-430a-96c4-1a42e339ab37	2022-12-27 13:15:56.29607+00	12282606-8d6c-4c36-acb5-7c4a61056b8d	usOWdwZr9XeOwdkIyjbJixXDmC12	2023-01-20 11:56:27.649+00	0e623bde-de23-49ec-b182-041ca42c2449
dcd96c7f-22c8-4f56-abd7-57ae055ef93a	2022-12-19 15:05:03.134155+00	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	JK2Ww9wLsuTXgFVwj9U6BCxUw703	2023-01-20 12:07:01.029+00	729be5f8-457f-48b4-84c1-da531ab77707
1eaa4983-ed6a-4da6-b7a6-b0b954b5dcce	2022-12-19 15:05:03.134155+00	adac3b86-cec4-47f6-b71b-7ad6ee956c2c	usOWdwZr9XeOwdkIyjbJixXDmC12	2023-01-20 12:09:00.665+00	ce8bbad9-838d-401e-9c5f-652e56d64f04
\.


--
-- Data for Name: UserToken; Type: TABLE DATA; Schema: public; Owner: supabase_admin
--

COPY public."UserToken" (id, created_at, "PushToken") FROM stdin;
6m1sYDALflWXdONzQtNj7ODUM9v2	2023-01-11 08:12:58.620643+00	ExponentPushToken[f8CP_uE2wKWMf6Bl3yWSDC]
uxJiWSJDRbdrCPnSg60gV92chN23	2023-01-12 07:15:27.081688+00	ExponentPushToken[gSwKhmE6H3a0-LrKuiWn-U]
NxZgtwaQrLO4nfkr8MVIthvJ6Py1	2023-01-10 09:41:34.770034+00	ExponentPushToken[rE6-dIBBGc0M0DgvM1ar4i]
Fm0lB4F7oMeKsojeVmmX7f77SjO2	2023-01-09 15:56:20.46652+00	ExponentPushToken[3xOX0CNHr2xIIwmHCJQpcP]
ObxIOuq35pY4QhHJiHDBqNyg0tS2	2023-01-10 10:29:07.282146+00	ExponentPushToken[tE6Q42EQkvzGcdKAqpv-yB]
usOWdwZr9XeOwdkIyjbJixXDmC12	2023-01-09 08:36:38.557377+00	ExponentPushToken[PlxIdIGFQ44qPmNJZPQTQ5]
\.


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.schema_migrations (version, inserted_at) FROM stdin;
20211116024918	2022-12-20 15:03:25
20211116045059	2022-12-20 15:03:25
20211116050929	2022-12-20 15:03:26
20211116051442	2022-12-20 15:03:27
20211116212300	2022-12-20 15:03:27
20211116213355	2022-12-20 15:03:28
20211116213934	2022-12-20 15:03:29
20211116214523	2022-12-20 15:03:30
20211122062447	2022-12-20 15:03:30
20211124070109	2022-12-20 15:03:31
20211202204204	2022-12-20 15:03:31
20211202204605	2022-12-20 15:03:32
20211210212804	2022-12-20 15:03:34
20211228014915	2022-12-20 15:03:35
20220107221237	2022-12-20 15:03:35
20220228202821	2022-12-20 15:03:36
20220312004840	2022-12-20 15:03:36
20220603231003	2022-12-20 15:03:37
20220603232444	2022-12-20 15:03:38
20220615214548	2022-12-20 15:03:39
20220712093339	2022-12-20 15:03:39
20220908172859	2022-12-20 15:03:40
20220916233421	2022-12-20 15:03:41
\.


--
-- Data for Name: subscription; Type: TABLE DATA; Schema: realtime; Owner: supabase_admin
--

COPY realtime.subscription (id, subscription_id, entity, filters, claims, created_at) FROM stdin;
6478	68daa8d6-98ba-11ed-9fd8-665128c90a40	public."Message"	{"(ChatRoomID,eq,adac3b86-cec4-47f6-b71b-7ad6ee956c2c)"}	{"exp": 1987033797, "iat": 1671457797, "iss": "supabase", "ref": "kllspqoqajlddmvgnsft", "role": "anon"}	2023-01-20 12:03:10.911791
6479	7abc8754-98ba-11ed-8481-665128c90a40	public."ChatRoom"	{"(id,eq,adac3b86-cec4-47f6-b71b-7ad6ee956c2c)"}	{"exp": 1987033797, "iat": 1671457797, "iss": "supabase", "ref": "kllspqoqajlddmvgnsft", "role": "anon"}	2023-01-20 12:03:40.915384
6385	0ad8a4d0-98b1-11ed-b59d-ea824c3b6cbe	public."ChatRoom"	{"(id,eq,0f51064e-19a4-403e-a887-9607ebe23765)"}	{"exp": 1987033797, "iat": 1671457797, "iss": "supabase", "ref": "kllspqoqajlddmvgnsft", "role": "anon"}	2023-01-20 10:56:07.7297
6484	7ac00ca8-98ba-11ed-9a19-665128c90a40	public."ChatRoom"	{"(id,eq,76cd1ccd-a614-4ff5-a759-8308b20cfc2e)"}	{"exp": 1987033797, "iat": 1671457797, "iss": "supabase", "ref": "kllspqoqajlddmvgnsft", "role": "anon"}	2023-01-20 12:03:41.132137
6489	f0ee3ff8-98ba-11ed-bc2d-665128c90a40	public."Message"	{"(ChatRoomID,eq,adac3b86-cec4-47f6-b71b-7ad6ee956c2c)"}	{"exp": 1987033797, "iat": 1671457797, "iss": "supabase", "ref": "kllspqoqajlddmvgnsft", "role": "anon"}	2023-01-20 12:06:59.212086
6480	7abeb8d0-98ba-11ed-928d-665128c90a40	public."ChatRoom"	{"(id,eq,e40ab7c0-668f-48a7-acbe-8afa9dc0c9f5)"}	{"exp": 1987033797, "iat": 1671457797, "iss": "supabase", "ref": "kllspqoqajlddmvgnsft", "role": "anon"}	2023-01-20 12:03:40.927836
6486	7af79fec-98ba-11ed-9109-665128c90a40	public."ChatRoom"	{"(id,eq,9267a9db-1f94-4b7c-a30e-f6a9d2513879)"}	{"exp": 1987033797, "iat": 1671457797, "iss": "supabase", "ref": "kllspqoqajlddmvgnsft", "role": "anon"}	2023-01-20 12:03:41.300578
6464	55281b08-98b9-11ed-9b59-665128c90a40	public."ChatRoom"	{"(id,eq,0f51064e-19a4-403e-a887-9607ebe23765)"}	{"exp": 1987033797, "iat": 1671457797, "iss": "supabase", "ref": "kllspqoqajlddmvgnsft", "role": "anon"}	2023-01-20 11:55:28.369178
6372	09aa32c2-98b1-11ed-9722-ea824c3b6cbe	public."ChatRoom"	{"(id,eq,1eb9228a-2856-4333-8417-dabdd678aa10)"}	{"exp": 1987033797, "iat": 1671457797, "iss": "supabase", "ref": "kllspqoqajlddmvgnsft", "role": "anon"}	2023-01-20 10:56:05.904829
6481	7abe8540-98ba-11ed-929d-665128c90a40	public."ChatRoom"	{"(id,eq,12282606-8d6c-4c36-acb5-7c4a61056b8d)"}	{"exp": 1987033797, "iat": 1671457797, "iss": "supabase", "ref": "kllspqoqajlddmvgnsft", "role": "anon"}	2023-01-20 12:03:40.93169
6485	7ac040c4-98ba-11ed-a403-665128c90a40	public."ChatRoom"	{"(id,eq,1eb9228a-2856-4333-8417-dabdd678aa10)"}	{"exp": 1987033797, "iat": 1671457797, "iss": "supabase", "ref": "kllspqoqajlddmvgnsft", "role": "anon"}	2023-01-20 12:03:41.163362
6465	5527b6c2-98b9-11ed-bf4a-665128c90a40	public."ChatRoom"	{"(id,eq,adac3b86-cec4-47f6-b71b-7ad6ee956c2c)"}	{"exp": 1987033797, "iat": 1671457797, "iss": "supabase", "ref": "kllspqoqajlddmvgnsft", "role": "anon"}	2023-01-20 11:55:28.3716
6373	09b4f388-98b1-11ed-a508-ea824c3b6cbe	public."ChatRoom"	{"(id,eq,a953afac-954e-4dc7-8d69-58fdadc59d5d)"}	{"exp": 1987033797, "iat": 1671457797, "iss": "supabase", "ref": "kllspqoqajlddmvgnsft", "role": "anon"}	2023-01-20 10:56:05.939486
6482	7abef476-98ba-11ed-8c14-665128c90a40	public."ChatRoom"	{"(id,eq,041803f7-f5e3-4825-baa5-e93427d4e8d5)"}	{"exp": 1987033797, "iat": 1671457797, "iss": "supabase", "ref": "kllspqoqajlddmvgnsft", "role": "anon"}	2023-01-20 12:03:40.93089
6487	7af7e20e-98ba-11ed-b0a1-665128c90a40	public."ChatRoom"	{"(id,eq,a953afac-954e-4dc7-8d69-58fdadc59d5d)"}	{"exp": 1987033797, "iat": 1671457797, "iss": "supabase", "ref": "kllspqoqajlddmvgnsft", "role": "anon"}	2023-01-20 12:03:41.304218
6483	7abfd472-98ba-11ed-aabe-665128c90a40	public."ChatRoom"	{"(id,eq,7048d285-d4a8-4155-8d30-5023afeaa23c)"}	{"exp": 1987033797, "iat": 1671457797, "iss": "supabase", "ref": "kllspqoqajlddmvgnsft", "role": "anon"}	2023-01-20 12:03:40.941028
6384	0ad86c7c-98b1-11ed-b9ed-ea824c3b6cbe	public."ChatRoom"	{"(id,eq,adac3b86-cec4-47f6-b71b-7ad6ee956c2c)"}	{"exp": 1987033797, "iat": 1671457797, "iss": "supabase", "ref": "kllspqoqajlddmvgnsft", "role": "anon"}	2023-01-20 10:56:07.727773
6374	09b519e4-98b1-11ed-8740-ea824c3b6cbe	public."ChatRoom"	{"(id,eq,9267a9db-1f94-4b7c-a30e-f6a9d2513879)"}	{"exp": 1987033797, "iat": 1671457797, "iss": "supabase", "ref": "kllspqoqajlddmvgnsft", "role": "anon"}	2023-01-20 10:56:05.939836
6371	09b4c78c-98b1-11ed-afbf-ea824c3b6cbe	public."ChatRoom"	{"(id,eq,76cd1ccd-a614-4ff5-a759-8308b20cfc2e)"}	{"exp": 1987033797, "iat": 1671457797, "iss": "supabase", "ref": "kllspqoqajlddmvgnsft", "role": "anon"}	2023-01-20 10:56:05.911597
\.


--
-- Data for Name: buckets; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.buckets (id, name, owner, created_at, updated_at, public) FROM stdin;
chatroom	chatroom	\N	2023-01-11 16:04:24.641617+00	2023-01-11 16:04:24.641617+00	t
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.migrations (id, name, hash, executed_at) FROM stdin;
0	create-migrations-table	e18db593bcde2aca2a408c4d1100f6abba2195df	2022-12-19 13:51:02.387978
1	initialmigration	6ab16121fbaa08bbd11b712d05f358f9b555d777	2022-12-19 13:51:02.40002
2	pathtoken-column	49756be03be4c17bb85fe70d4a861f27de7e49ad	2022-12-19 13:51:02.402867
3	add-migrations-rls	bb5d124c53d68635a883e399426c6a5a25fc893d	2022-12-19 13:51:02.426693
4	add-size-functions	6d79007d04f5acd288c9c250c42d2d5fd286c54d	2022-12-19 13:51:02.43045
5	change-column-name-in-get-size	fd65688505d2ffa9fbdc58a944348dd8604d688c	2022-12-19 13:51:02.434543
6	add-rls-to-buckets	63e2bab75a2040fee8e3fb3f15a0d26f3380e9b6	2022-12-19 13:51:02.439826
7	add-public-to-buckets	82568934f8a4d9e0a85f126f6fb483ad8214c418	2022-12-19 13:51:02.443517
8	fix-search-function	1a43a40eddb525f2e2f26efd709e6c06e58e059c	2022-12-19 13:51:02.447896
9	search-files-search-function	34c096597eb8b9d077fdfdde9878c88501b2fafc	2022-12-19 13:51:02.451792
10	add-trigger-to-auto-update-updated_at-column	37d6bb964a70a822e6d37f22f457b9bca7885928	2022-12-19 13:51:02.459114
\.


--
-- Data for Name: objects; Type: TABLE DATA; Schema: storage; Owner: supabase_storage_admin
--

COPY storage.objects (id, bucket_id, name, owner, created_at, updated_at, last_accessed_at, metadata) FROM stdin;
61f1f222-8b4b-42f9-9ccc-a3e554ecb41d	chatroom	adac3b86-cec4-47f6-b71b-7ad6ee956c2c/.emptyFolderPlaceholder	\N	2023-01-11 16:13:20.05724+00	2023-01-11 16:13:20.264672+00	2023-01-11 16:13:20.05724+00	{"eTag": "\\"d41d8cd98f00b204e9800998ecf8427e\\"", "size": 0, "mimetype": "application/octet-stream", "cacheControl": "max-age=3600", "lastModified": "2023-01-11T16:13:21.000Z", "contentLength": 0, "httpStatusCode": 200}
2e12197e-d33b-41a6-9e11-94e993bd7407	chatroom	adac3b86-cec4-47f6-b71b-7ad6ee956c2c/eaf9795d-bd61-44d7-a90f-6660a6c3f4b6.png	\N	2023-01-14 10:48:41.867664+00	2023-01-14 10:48:42.572516+00	2023-01-14 10:48:41.867664+00	{"eTag": "\\"e68062be59e193bf6f578d10d3015761\\"", "size": 2563756, "mimetype": "image/png", "cacheControl": "max-age=3600", "lastModified": "2023-01-14T10:48:43.000Z", "contentLength": 2563756, "httpStatusCode": 200}
f113fc6f-9861-43bf-b92d-a3d1de0face3	chatroom	adac3b86-cec4-47f6-b71b-7ad6ee956c2c/707cfc94-df00-44d2-bd18-16c47abd632a.jpeg	\N	2023-01-20 12:02:50.587631+00	2023-01-20 12:02:50.759908+00	2023-01-20 12:02:50.587631+00	{"eTag": "\\"7d0f41ae6c6cd82b08cbc961b41c46ec\\"", "size": 318145, "mimetype": "image/jpeg", "cacheControl": "max-age=3600", "lastModified": "2023-01-20T12:02:51.000Z", "contentLength": 318145, "httpStatusCode": 200}
\.


--
-- Name: refresh_tokens_id_seq; Type: SEQUENCE SET; Schema: auth; Owner: supabase_auth_admin
--

SELECT pg_catalog.setval('auth.refresh_tokens_id_seq', 1, false);


--
-- Name: subscription_id_seq; Type: SEQUENCE SET; Schema: realtime; Owner: supabase_admin
--

SELECT pg_catalog.setval('realtime.subscription_id_seq', 6489, true);


--
-- Name: mfa_amr_claims amr_id_pk; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT amr_id_pk PRIMARY KEY (id);


--
-- Name: audit_log_entries audit_log_entries_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.audit_log_entries
    ADD CONSTRAINT audit_log_entries_pkey PRIMARY KEY (id);


--
-- Name: identities identities_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_pkey PRIMARY KEY (provider, id);


--
-- Name: instances instances_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_authentication_method_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_authentication_method_pkey UNIQUE (session_id, authentication_method);


--
-- Name: mfa_challenges mfa_challenges_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_pkey PRIMARY KEY (id);


--
-- Name: mfa_factors mfa_factors_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_pkey PRIMARY KEY (id);


--
-- Name: refresh_tokens refresh_tokens_token_unique; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_token_unique UNIQUE (token);


--
-- Name: saml_providers saml_providers_entity_id_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_entity_id_key UNIQUE (entity_id);


--
-- Name: saml_providers saml_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_pkey PRIMARY KEY (id);


--
-- Name: saml_relay_states saml_relay_states_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sso_domains sso_domains_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_pkey PRIMARY KEY (id);


--
-- Name: sso_providers sso_providers_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_providers
    ADD CONSTRAINT sso_providers_pkey PRIMARY KEY (id);


--
-- Name: sso_sessions sso_sessions_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_sessions
    ADD CONSTRAINT sso_sessions_pkey PRIMARY KEY (id);


--
-- Name: users users_phone_key; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_phone_key UNIQUE (phone);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: ChatRoom ChatRoom_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public."ChatRoom"
    ADD CONSTRAINT "ChatRoom_pkey" PRIMARY KEY (id);


--
-- Name: Message Message_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public."Message"
    ADD CONSTRAINT "Message_pkey" PRIMARY KEY (id);


--
-- Name: UserChatRoom UserChatRoom_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public."UserChatRoom"
    ADD CONSTRAINT "UserChatRoom_pkey" PRIMARY KEY (id);


--
-- Name: UserToken UserToken_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public."UserToken"
    ADD CONSTRAINT "UserToken_pkey" PRIMARY KEY (id);


--
-- Name: User User_pkey; Type: CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public."User"
    ADD CONSTRAINT "User_pkey" PRIMARY KEY (id);


--
-- Name: subscription pk_subscription; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.subscription
    ADD CONSTRAINT pk_subscription PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: realtime; Owner: supabase_admin
--

ALTER TABLE ONLY realtime.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: buckets buckets_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_pkey PRIMARY KEY (id);


--
-- Name: migrations migrations_name_key; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_name_key UNIQUE (name);


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: objects objects_pkey; Type: CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_pkey PRIMARY KEY (id);


--
-- Name: audit_logs_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX audit_logs_instance_id_idx ON auth.audit_log_entries USING btree (instance_id);


--
-- Name: confirmation_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX confirmation_token_idx ON auth.users USING btree (confirmation_token) WHERE ((confirmation_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_current_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_current_idx ON auth.users USING btree (email_change_token_current) WHERE ((email_change_token_current)::text !~ '^[0-9 ]*$'::text);


--
-- Name: email_change_token_new_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX email_change_token_new_idx ON auth.users USING btree (email_change_token_new) WHERE ((email_change_token_new)::text !~ '^[0-9 ]*$'::text);


--
-- Name: factor_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX factor_id_created_at_idx ON auth.mfa_factors USING btree (user_id, created_at);


--
-- Name: identities_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_email_idx ON auth.identities USING btree (email text_pattern_ops);


--
-- Name: INDEX identities_email_idx; Type: COMMENT; Schema: auth; Owner: supabase_auth_admin
--

COMMENT ON INDEX auth.identities_email_idx IS 'Auth: Ensures indexed queries on the email column';


--
-- Name: identities_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX identities_user_id_idx ON auth.identities USING btree (user_id);


--
-- Name: mfa_factors_user_friendly_name_unique; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX mfa_factors_user_friendly_name_unique ON auth.mfa_factors USING btree (friendly_name, user_id) WHERE (TRIM(BOTH FROM friendly_name) <> ''::text);


--
-- Name: reauthentication_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX reauthentication_token_idx ON auth.users USING btree (reauthentication_token) WHERE ((reauthentication_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: recovery_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX recovery_token_idx ON auth.users USING btree (recovery_token) WHERE ((recovery_token)::text !~ '^[0-9 ]*$'::text);


--
-- Name: refresh_tokens_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_idx ON auth.refresh_tokens USING btree (instance_id);


--
-- Name: refresh_tokens_instance_id_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_instance_id_user_id_idx ON auth.refresh_tokens USING btree (instance_id, user_id);


--
-- Name: refresh_tokens_parent_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_parent_idx ON auth.refresh_tokens USING btree (parent);


--
-- Name: refresh_tokens_session_id_revoked_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_session_id_revoked_idx ON auth.refresh_tokens USING btree (session_id, revoked);


--
-- Name: refresh_tokens_token_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX refresh_tokens_token_idx ON auth.refresh_tokens USING btree (token);


--
-- Name: saml_providers_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_providers_sso_provider_id_idx ON auth.saml_providers USING btree (sso_provider_id);


--
-- Name: saml_relay_states_for_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_for_email_idx ON auth.saml_relay_states USING btree (for_email);


--
-- Name: saml_relay_states_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX saml_relay_states_sso_provider_id_idx ON auth.saml_relay_states USING btree (sso_provider_id);


--
-- Name: sessions_user_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sessions_user_id_idx ON auth.sessions USING btree (user_id);


--
-- Name: sso_domains_domain_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_domains_domain_idx ON auth.sso_domains USING btree (lower(domain));


--
-- Name: sso_domains_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sso_domains_sso_provider_id_idx ON auth.sso_domains USING btree (sso_provider_id);


--
-- Name: sso_providers_resource_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX sso_providers_resource_id_idx ON auth.sso_providers USING btree (lower(resource_id));


--
-- Name: sso_sessions_session_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sso_sessions_session_id_idx ON auth.sso_sessions USING btree (session_id);


--
-- Name: sso_sessions_sso_provider_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX sso_sessions_sso_provider_id_idx ON auth.sso_sessions USING btree (sso_provider_id);


--
-- Name: user_id_created_at_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX user_id_created_at_idx ON auth.sessions USING btree (user_id, created_at);


--
-- Name: users_email_partial_key; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE UNIQUE INDEX users_email_partial_key ON auth.users USING btree (email) WHERE (is_sso_user = false);


--
-- Name: users_instance_id_email_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_email_idx ON auth.users USING btree (instance_id, lower((email)::text));


--
-- Name: users_instance_id_idx; Type: INDEX; Schema: auth; Owner: supabase_auth_admin
--

CREATE INDEX users_instance_id_idx ON auth.users USING btree (instance_id);


--
-- Name: ix_realtime_subscription_entity; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE INDEX ix_realtime_subscription_entity ON realtime.subscription USING hash (entity);


--
-- Name: subscription_subscription_id_entity_filters_key; Type: INDEX; Schema: realtime; Owner: supabase_admin
--

CREATE UNIQUE INDEX subscription_subscription_id_entity_filters_key ON realtime.subscription USING btree (subscription_id, entity, filters);


--
-- Name: bname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bname ON storage.buckets USING btree (name);


--
-- Name: bucketid_objname; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE UNIQUE INDEX bucketid_objname ON storage.objects USING btree (bucket_id, name);


--
-- Name: name_prefix_search; Type: INDEX; Schema: storage; Owner: supabase_storage_admin
--

CREATE INDEX name_prefix_search ON storage.objects USING btree (name text_pattern_ops);


--
-- Name: subscription tr_check_filters; Type: TRIGGER; Schema: realtime; Owner: supabase_admin
--

CREATE TRIGGER tr_check_filters BEFORE INSERT OR UPDATE ON realtime.subscription FOR EACH ROW EXECUTE FUNCTION realtime.subscription_check_filters();


--
-- Name: objects update_objects_updated_at; Type: TRIGGER; Schema: storage; Owner: supabase_storage_admin
--

CREATE TRIGGER update_objects_updated_at BEFORE UPDATE ON storage.objects FOR EACH ROW EXECUTE FUNCTION storage.update_updated_at_column();


--
-- Name: identities identities_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.identities
    ADD CONSTRAINT identities_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: mfa_amr_claims mfa_amr_claims_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_amr_claims
    ADD CONSTRAINT mfa_amr_claims_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: mfa_challenges mfa_challenges_auth_factor_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_challenges
    ADD CONSTRAINT mfa_challenges_auth_factor_id_fkey FOREIGN KEY (factor_id) REFERENCES auth.mfa_factors(id) ON DELETE CASCADE;


--
-- Name: mfa_factors mfa_factors_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.mfa_factors
    ADD CONSTRAINT mfa_factors_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: refresh_tokens refresh_tokens_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.refresh_tokens
    ADD CONSTRAINT refresh_tokens_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: saml_providers saml_providers_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_providers
    ADD CONSTRAINT saml_providers_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: saml_relay_states saml_relay_states_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.saml_relay_states
    ADD CONSTRAINT saml_relay_states_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: sessions sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sessions
    ADD CONSTRAINT sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE CASCADE;


--
-- Name: sso_domains sso_domains_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_domains
    ADD CONSTRAINT sso_domains_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: sso_sessions sso_sessions_session_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_sessions
    ADD CONSTRAINT sso_sessions_session_id_fkey FOREIGN KEY (session_id) REFERENCES auth.sessions(id) ON DELETE CASCADE;


--
-- Name: sso_sessions sso_sessions_sso_provider_id_fkey; Type: FK CONSTRAINT; Schema: auth; Owner: supabase_auth_admin
--

ALTER TABLE ONLY auth.sso_sessions
    ADD CONSTRAINT sso_sessions_sso_provider_id_fkey FOREIGN KEY (sso_provider_id) REFERENCES auth.sso_providers(id) ON DELETE CASCADE;


--
-- Name: ChatRoom ChatRoom_LastMessageID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public."ChatRoom"
    ADD CONSTRAINT "ChatRoom_LastMessageID_fkey" FOREIGN KEY ("LastMessageID") REFERENCES public."Message"(id);


--
-- Name: Message Message_ChatRoomID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public."Message"
    ADD CONSTRAINT "Message_ChatRoomID_fkey" FOREIGN KEY ("ChatRoomID") REFERENCES public."ChatRoom"(id);


--
-- Name: Message Message_UserID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public."Message"
    ADD CONSTRAINT "Message_UserID_fkey" FOREIGN KEY ("UserID") REFERENCES public."User"(id);


--
-- Name: UserChatRoom UserChatRoom_ChatRoomID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public."UserChatRoom"
    ADD CONSTRAINT "UserChatRoom_ChatRoomID_fkey" FOREIGN KEY ("ChatRoomID") REFERENCES public."ChatRoom"(id);


--
-- Name: UserChatRoom UserChatRoom_LastSeenMessageID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public."UserChatRoom"
    ADD CONSTRAINT "UserChatRoom_LastSeenMessageID_fkey" FOREIGN KEY ("LastSeenMessageID") REFERENCES public."Message"(id);


--
-- Name: UserChatRoom UserChatRoom_UserID_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public."UserChatRoom"
    ADD CONSTRAINT "UserChatRoom_UserID_fkey" FOREIGN KEY ("UserID") REFERENCES public."User"(id);


--
-- Name: UserToken UserToken_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: supabase_admin
--

ALTER TABLE ONLY public."UserToken"
    ADD CONSTRAINT "UserToken_id_fkey" FOREIGN KEY (id) REFERENCES public."User"(id);


--
-- Name: buckets buckets_owner_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.buckets
    ADD CONSTRAINT buckets_owner_fkey FOREIGN KEY (owner) REFERENCES auth.users(id);


--
-- Name: objects objects_bucketId_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT "objects_bucketId_fkey" FOREIGN KEY (bucket_id) REFERENCES storage.buckets(id);


--
-- Name: objects objects_owner_fkey; Type: FK CONSTRAINT; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE ONLY storage.objects
    ADD CONSTRAINT objects_owner_fkey FOREIGN KEY (owner) REFERENCES auth.users(id);


--
-- Name: objects All Allowed nsbodv_0; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY "All Allowed nsbodv_0" ON storage.objects FOR DELETE USING ((bucket_id = 'chatroom'::text));


--
-- Name: objects All Allowed nsbodv_1; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY "All Allowed nsbodv_1" ON storage.objects FOR UPDATE USING ((bucket_id = 'chatroom'::text));


--
-- Name: objects All Allowed nsbodv_2; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY "All Allowed nsbodv_2" ON storage.objects FOR INSERT WITH CHECK ((bucket_id = 'chatroom'::text));


--
-- Name: objects All Allowed nsbodv_3; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY "All Allowed nsbodv_3" ON storage.objects FOR SELECT USING ((bucket_id = 'chatroom'::text));


--
-- Name: buckets Alll; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY "Alll" ON storage.buckets;


--
-- Name: objects Allow all; Type: POLICY; Schema: storage; Owner: supabase_storage_admin
--

CREATE POLICY "Allow all" ON storage.objects;


--
-- Name: buckets; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.buckets ENABLE ROW LEVEL SECURITY;

--
-- Name: migrations; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.migrations ENABLE ROW LEVEL SECURITY;

--
-- Name: objects; Type: ROW SECURITY; Schema: storage; Owner: supabase_storage_admin
--

ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

--
-- Name: supabase_realtime; Type: PUBLICATION; Schema: -; Owner: postgres
--

CREATE PUBLICATION supabase_realtime WITH (publish = 'insert, update, delete, truncate');


ALTER PUBLICATION supabase_realtime OWNER TO postgres;

--
-- Name: supabase_realtime ChatRoom; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public."ChatRoom";


--
-- Name: supabase_realtime Message; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public."Message";


--
-- Name: supabase_realtime User; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public."User";


--
-- Name: supabase_realtime UserChatRoom; Type: PUBLICATION TABLE; Schema: public; Owner: postgres
--

ALTER PUBLICATION supabase_realtime ADD TABLE ONLY public."UserChatRoom";


--
-- Name: SCHEMA auth; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA auth TO anon;
GRANT USAGE ON SCHEMA auth TO authenticated;
GRANT USAGE ON SCHEMA auth TO service_role;
GRANT ALL ON SCHEMA auth TO supabase_auth_admin;
GRANT ALL ON SCHEMA auth TO dashboard_user;
GRANT ALL ON SCHEMA auth TO postgres;


--
-- Name: SCHEMA extensions; Type: ACL; Schema: -; Owner: postgres
--

GRANT USAGE ON SCHEMA extensions TO anon;
GRANT USAGE ON SCHEMA extensions TO authenticated;
GRANT USAGE ON SCHEMA extensions TO service_role;
GRANT ALL ON SCHEMA extensions TO dashboard_user;


--
-- Name: SCHEMA graphql_public; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA graphql_public TO postgres;
GRANT USAGE ON SCHEMA graphql_public TO anon;
GRANT USAGE ON SCHEMA graphql_public TO authenticated;
GRANT USAGE ON SCHEMA graphql_public TO service_role;


--
-- Name: SCHEMA public; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA public TO postgres;
GRANT USAGE ON SCHEMA public TO anon;
GRANT USAGE ON SCHEMA public TO authenticated;
GRANT USAGE ON SCHEMA public TO service_role;


--
-- Name: SCHEMA realtime; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT USAGE ON SCHEMA realtime TO postgres;


--
-- Name: SCHEMA storage; Type: ACL; Schema: -; Owner: supabase_admin
--

GRANT ALL ON SCHEMA storage TO postgres;
GRANT USAGE ON SCHEMA storage TO anon;
GRANT USAGE ON SCHEMA storage TO authenticated;
GRANT USAGE ON SCHEMA storage TO service_role;
GRANT ALL ON SCHEMA storage TO supabase_storage_admin;
GRANT ALL ON SCHEMA storage TO dashboard_user;


--
-- Name: FUNCTION email(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.email() TO dashboard_user;


--
-- Name: FUNCTION jwt(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.jwt() TO postgres;
GRANT ALL ON FUNCTION auth.jwt() TO dashboard_user;


--
-- Name: FUNCTION role(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.role() TO dashboard_user;


--
-- Name: FUNCTION uid(); Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON FUNCTION auth.uid() TO dashboard_user;


--
-- Name: FUNCTION algorithm_sign(signables text, secret text, algorithm text); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.algorithm_sign(signables text, secret text, algorithm text) TO dashboard_user;


--
-- Name: FUNCTION armor(bytea); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.armor(bytea) TO dashboard_user;


--
-- Name: FUNCTION armor(bytea, text[], text[]); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.armor(bytea, text[], text[]) TO dashboard_user;


--
-- Name: FUNCTION crypt(text, text); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.crypt(text, text) TO dashboard_user;


--
-- Name: FUNCTION dearmor(text); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.dearmor(text) TO dashboard_user;


--
-- Name: FUNCTION decrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.decrypt(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION decrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.decrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION digest(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.digest(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION digest(text, text); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.digest(text, text) TO dashboard_user;


--
-- Name: FUNCTION encrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.encrypt(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION encrypt_iv(bytea, bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.encrypt_iv(bytea, bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION gen_random_bytes(integer); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.gen_random_bytes(integer) TO dashboard_user;


--
-- Name: FUNCTION gen_random_uuid(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.gen_random_uuid() TO dashboard_user;


--
-- Name: FUNCTION gen_salt(text); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.gen_salt(text) TO dashboard_user;


--
-- Name: FUNCTION gen_salt(text, integer); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.gen_salt(text, integer) TO dashboard_user;


--
-- Name: FUNCTION grant_pg_cron_access(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.grant_pg_cron_access() TO dashboard_user;


--
-- Name: FUNCTION grant_pg_net_access(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.grant_pg_net_access() TO dashboard_user;


--
-- Name: FUNCTION hmac(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.hmac(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION hmac(text, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.hmac(text, text, text) TO dashboard_user;


--
-- Name: FUNCTION pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT blk_read_time double precision, OUT blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.pg_stat_statements(showtext boolean, OUT userid oid, OUT dbid oid, OUT toplevel boolean, OUT queryid bigint, OUT query text, OUT plans bigint, OUT total_plan_time double precision, OUT min_plan_time double precision, OUT max_plan_time double precision, OUT mean_plan_time double precision, OUT stddev_plan_time double precision, OUT calls bigint, OUT total_exec_time double precision, OUT min_exec_time double precision, OUT max_exec_time double precision, OUT mean_exec_time double precision, OUT stddev_exec_time double precision, OUT rows bigint, OUT shared_blks_hit bigint, OUT shared_blks_read bigint, OUT shared_blks_dirtied bigint, OUT shared_blks_written bigint, OUT local_blks_hit bigint, OUT local_blks_read bigint, OUT local_blks_dirtied bigint, OUT local_blks_written bigint, OUT temp_blks_read bigint, OUT temp_blks_written bigint, OUT blk_read_time double precision, OUT blk_write_time double precision, OUT temp_blk_read_time double precision, OUT temp_blk_write_time double precision, OUT wal_records bigint, OUT wal_fpi bigint, OUT wal_bytes numeric, OUT jit_functions bigint, OUT jit_generation_time double precision, OUT jit_inlining_count bigint, OUT jit_inlining_time double precision, OUT jit_optimization_count bigint, OUT jit_optimization_time double precision, OUT jit_emission_count bigint, OUT jit_emission_time double precision) TO dashboard_user;


--
-- Name: FUNCTION pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.pg_stat_statements_info(OUT dealloc bigint, OUT stats_reset timestamp with time zone) TO dashboard_user;


--
-- Name: FUNCTION pg_stat_statements_reset(userid oid, dbid oid, queryid bigint); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.pg_stat_statements_reset(userid oid, dbid oid, queryid bigint) TO dashboard_user;


--
-- Name: FUNCTION pgp_armor_headers(text, OUT key text, OUT value text); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.pgp_armor_headers(text, OUT key text, OUT value text) TO dashboard_user;


--
-- Name: FUNCTION pgp_key_id(bytea); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.pgp_key_id(bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt(bytea, bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt(bytea, bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_decrypt_bytea(bytea, bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.pgp_pub_decrypt_bytea(bytea, bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt(text, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt(text, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea) TO dashboard_user;


--
-- Name: FUNCTION pgp_pub_encrypt_bytea(bytea, bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.pgp_pub_encrypt_bytea(bytea, bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt(bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt(bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_decrypt_bytea(bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.pgp_sym_decrypt_bytea(bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt(text, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt(text, text, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text) TO dashboard_user;


--
-- Name: FUNCTION pgp_sym_encrypt_bytea(bytea, text, text); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.pgp_sym_encrypt_bytea(bytea, text, text) TO dashboard_user;


--
-- Name: FUNCTION sign(payload json, secret text, algorithm text); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.sign(payload json, secret text, algorithm text) TO dashboard_user;


--
-- Name: FUNCTION try_cast_double(inp text); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.try_cast_double(inp text) TO dashboard_user;


--
-- Name: FUNCTION url_decode(data text); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.url_decode(data text) TO dashboard_user;


--
-- Name: FUNCTION url_encode(data bytea); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.url_encode(data bytea) TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v1(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v1() TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v1mc(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v1mc() TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v3(namespace uuid, name text); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v3(namespace uuid, name text) TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v4(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v4() TO dashboard_user;


--
-- Name: FUNCTION uuid_generate_v5(namespace uuid, name text); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.uuid_generate_v5(namespace uuid, name text) TO dashboard_user;


--
-- Name: FUNCTION uuid_nil(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.uuid_nil() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_dns(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.uuid_ns_dns() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_oid(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.uuid_ns_oid() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_url(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.uuid_ns_url() TO dashboard_user;


--
-- Name: FUNCTION uuid_ns_x500(); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.uuid_ns_x500() TO dashboard_user;


--
-- Name: FUNCTION verify(token text, secret text, algorithm text); Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON FUNCTION extensions.verify(token text, secret text, algorithm text) TO dashboard_user;


--
-- Name: FUNCTION comment_directive(comment_ text); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION graphql.comment_directive(comment_ text) TO postgres;
GRANT ALL ON FUNCTION graphql.comment_directive(comment_ text) TO anon;
GRANT ALL ON FUNCTION graphql.comment_directive(comment_ text) TO authenticated;
GRANT ALL ON FUNCTION graphql.comment_directive(comment_ text) TO service_role;


--
-- Name: FUNCTION exception(message text); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION graphql.exception(message text) TO postgres;
GRANT ALL ON FUNCTION graphql.exception(message text) TO anon;
GRANT ALL ON FUNCTION graphql.exception(message text) TO authenticated;
GRANT ALL ON FUNCTION graphql.exception(message text) TO service_role;


--
-- Name: FUNCTION get_schema_version(); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION graphql.get_schema_version() TO postgres;
GRANT ALL ON FUNCTION graphql.get_schema_version() TO anon;
GRANT ALL ON FUNCTION graphql.get_schema_version() TO authenticated;
GRANT ALL ON FUNCTION graphql.get_schema_version() TO service_role;


--
-- Name: FUNCTION increment_schema_version(); Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON FUNCTION graphql.increment_schema_version() TO postgres;
GRANT ALL ON FUNCTION graphql.increment_schema_version() TO anon;
GRANT ALL ON FUNCTION graphql.increment_schema_version() TO authenticated;
GRANT ALL ON FUNCTION graphql.increment_schema_version() TO service_role;


--
-- Name: FUNCTION graphql("operationName" text, query text, variables jsonb, extensions jsonb); Type: ACL; Schema: graphql_public; Owner: supabase_admin
--

GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO postgres;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO anon;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO authenticated;
GRANT ALL ON FUNCTION graphql_public.graphql("operationName" text, query text, variables jsonb, extensions jsonb) TO service_role;


--
-- Name: FUNCTION get_auth(p_usename text); Type: ACL; Schema: pgbouncer; Owner: postgres
--

REVOKE ALL ON FUNCTION pgbouncer.get_auth(p_usename text) FROM PUBLIC;
GRANT ALL ON FUNCTION pgbouncer.get_auth(p_usename text) TO pgbouncer;


--
-- Name: SEQUENCE key_key_id_seq; Type: ACL; Schema: pgsodium; Owner: postgres
--

GRANT ALL ON SEQUENCE pgsodium.key_key_id_seq TO pgsodium_keyiduser;


--
-- Name: FUNCTION apply_rls(wal jsonb, max_record_bytes integer); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO postgres;
GRANT ALL ON FUNCTION realtime.apply_rls(wal jsonb, max_record_bytes integer) TO dashboard_user;


--
-- Name: FUNCTION build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO postgres;
GRANT ALL ON FUNCTION realtime.build_prepared_statement_sql(prepared_statement_name text, entity regclass, columns realtime.wal_column[]) TO dashboard_user;


--
-- Name: FUNCTION "cast"(val text, type_ regtype); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO postgres;
GRANT ALL ON FUNCTION realtime."cast"(val text, type_ regtype) TO dashboard_user;


--
-- Name: FUNCTION check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO postgres;
GRANT ALL ON FUNCTION realtime.check_equality_op(op realtime.equality_op, type_ regtype, val_1 text, val_2 text) TO dashboard_user;


--
-- Name: FUNCTION is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO postgres;
GRANT ALL ON FUNCTION realtime.is_visible_through_filters(columns realtime.wal_column[], filters realtime.user_defined_filter[]) TO dashboard_user;


--
-- Name: FUNCTION quote_wal2json(entity regclass); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO postgres;
GRANT ALL ON FUNCTION realtime.quote_wal2json(entity regclass) TO dashboard_user;


--
-- Name: FUNCTION subscription_check_filters(); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO postgres;
GRANT ALL ON FUNCTION realtime.subscription_check_filters() TO dashboard_user;


--
-- Name: FUNCTION to_regrole(role_name text); Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO postgres;
GRANT ALL ON FUNCTION realtime.to_regrole(role_name text) TO dashboard_user;


--
-- Name: FUNCTION extension(name text); Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON FUNCTION storage.extension(name text) TO anon;
GRANT ALL ON FUNCTION storage.extension(name text) TO authenticated;
GRANT ALL ON FUNCTION storage.extension(name text) TO service_role;
GRANT ALL ON FUNCTION storage.extension(name text) TO dashboard_user;
GRANT ALL ON FUNCTION storage.extension(name text) TO postgres;


--
-- Name: FUNCTION filename(name text); Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON FUNCTION storage.filename(name text) TO anon;
GRANT ALL ON FUNCTION storage.filename(name text) TO authenticated;
GRANT ALL ON FUNCTION storage.filename(name text) TO service_role;
GRANT ALL ON FUNCTION storage.filename(name text) TO dashboard_user;
GRANT ALL ON FUNCTION storage.filename(name text) TO postgres;


--
-- Name: FUNCTION foldername(name text); Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON FUNCTION storage.foldername(name text) TO anon;
GRANT ALL ON FUNCTION storage.foldername(name text) TO authenticated;
GRANT ALL ON FUNCTION storage.foldername(name text) TO service_role;
GRANT ALL ON FUNCTION storage.foldername(name text) TO dashboard_user;
GRANT ALL ON FUNCTION storage.foldername(name text) TO postgres;


--
-- Name: TABLE audit_log_entries; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.audit_log_entries TO dashboard_user;
GRANT ALL ON TABLE auth.audit_log_entries TO postgres;


--
-- Name: TABLE identities; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.identities TO postgres;
GRANT ALL ON TABLE auth.identities TO dashboard_user;


--
-- Name: TABLE instances; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.instances TO dashboard_user;
GRANT ALL ON TABLE auth.instances TO postgres;


--
-- Name: TABLE mfa_amr_claims; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.mfa_amr_claims TO postgres;
GRANT ALL ON TABLE auth.mfa_amr_claims TO dashboard_user;


--
-- Name: TABLE mfa_challenges; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.mfa_challenges TO postgres;
GRANT ALL ON TABLE auth.mfa_challenges TO dashboard_user;


--
-- Name: TABLE mfa_factors; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.mfa_factors TO postgres;
GRANT ALL ON TABLE auth.mfa_factors TO dashboard_user;


--
-- Name: TABLE refresh_tokens; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.refresh_tokens TO dashboard_user;
GRANT ALL ON TABLE auth.refresh_tokens TO postgres;


--
-- Name: SEQUENCE refresh_tokens_id_seq; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO dashboard_user;
GRANT ALL ON SEQUENCE auth.refresh_tokens_id_seq TO postgres;


--
-- Name: TABLE saml_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.saml_providers TO postgres;
GRANT ALL ON TABLE auth.saml_providers TO dashboard_user;


--
-- Name: TABLE saml_relay_states; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.saml_relay_states TO postgres;
GRANT ALL ON TABLE auth.saml_relay_states TO dashboard_user;


--
-- Name: TABLE schema_migrations; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.schema_migrations TO dashboard_user;
GRANT ALL ON TABLE auth.schema_migrations TO postgres;


--
-- Name: TABLE sessions; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.sessions TO postgres;
GRANT ALL ON TABLE auth.sessions TO dashboard_user;


--
-- Name: TABLE sso_domains; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.sso_domains TO postgres;
GRANT ALL ON TABLE auth.sso_domains TO dashboard_user;


--
-- Name: TABLE sso_providers; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.sso_providers TO postgres;
GRANT ALL ON TABLE auth.sso_providers TO dashboard_user;


--
-- Name: TABLE sso_sessions; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.sso_sessions TO postgres;
GRANT ALL ON TABLE auth.sso_sessions TO dashboard_user;


--
-- Name: TABLE users; Type: ACL; Schema: auth; Owner: supabase_auth_admin
--

GRANT ALL ON TABLE auth.users TO dashboard_user;
GRANT ALL ON TABLE auth.users TO postgres;


--
-- Name: TABLE pg_stat_statements; Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON TABLE extensions.pg_stat_statements TO dashboard_user;


--
-- Name: TABLE pg_stat_statements_info; Type: ACL; Schema: extensions; Owner: postgres
--

GRANT ALL ON TABLE extensions.pg_stat_statements_info TO dashboard_user;


--
-- Name: SEQUENCE seq_schema_version; Type: ACL; Schema: graphql; Owner: supabase_admin
--

GRANT ALL ON SEQUENCE graphql.seq_schema_version TO postgres;
GRANT ALL ON SEQUENCE graphql.seq_schema_version TO anon;
GRANT ALL ON SEQUENCE graphql.seq_schema_version TO authenticated;
GRANT ALL ON SEQUENCE graphql.seq_schema_version TO service_role;


--
-- Name: TABLE valid_key; Type: ACL; Schema: pgsodium; Owner: postgres
--

GRANT ALL ON TABLE pgsodium.valid_key TO pgsodium_keyiduser;


--
-- Name: TABLE "ChatRoom"; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public."ChatRoom" TO postgres;
GRANT ALL ON TABLE public."ChatRoom" TO anon;
GRANT ALL ON TABLE public."ChatRoom" TO authenticated;
GRANT ALL ON TABLE public."ChatRoom" TO service_role;


--
-- Name: TABLE "Message"; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public."Message" TO postgres;
GRANT ALL ON TABLE public."Message" TO anon;
GRANT ALL ON TABLE public."Message" TO authenticated;
GRANT ALL ON TABLE public."Message" TO service_role;


--
-- Name: TABLE "User"; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public."User" TO postgres;
GRANT ALL ON TABLE public."User" TO anon;
GRANT ALL ON TABLE public."User" TO authenticated;
GRANT ALL ON TABLE public."User" TO service_role;


--
-- Name: TABLE "UserChatRoom"; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public."UserChatRoom" TO postgres;
GRANT ALL ON TABLE public."UserChatRoom" TO anon;
GRANT ALL ON TABLE public."UserChatRoom" TO authenticated;
GRANT ALL ON TABLE public."UserChatRoom" TO service_role;


--
-- Name: TABLE "UserToken"; Type: ACL; Schema: public; Owner: supabase_admin
--

GRANT ALL ON TABLE public."UserToken" TO postgres;
GRANT ALL ON TABLE public."UserToken" TO anon;
GRANT ALL ON TABLE public."UserToken" TO authenticated;
GRANT ALL ON TABLE public."UserToken" TO service_role;


--
-- Name: TABLE schema_migrations; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.schema_migrations TO postgres;
GRANT ALL ON TABLE realtime.schema_migrations TO dashboard_user;


--
-- Name: TABLE subscription; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON TABLE realtime.subscription TO postgres;
GRANT ALL ON TABLE realtime.subscription TO dashboard_user;


--
-- Name: SEQUENCE subscription_id_seq; Type: ACL; Schema: realtime; Owner: supabase_admin
--

GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO postgres;
GRANT ALL ON SEQUENCE realtime.subscription_id_seq TO dashboard_user;


--
-- Name: TABLE buckets; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.buckets TO anon;
GRANT ALL ON TABLE storage.buckets TO authenticated;
GRANT ALL ON TABLE storage.buckets TO service_role;
GRANT ALL ON TABLE storage.buckets TO postgres;


--
-- Name: TABLE migrations; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.migrations TO anon;
GRANT ALL ON TABLE storage.migrations TO authenticated;
GRANT ALL ON TABLE storage.migrations TO service_role;
GRANT ALL ON TABLE storage.migrations TO postgres;


--
-- Name: TABLE objects; Type: ACL; Schema: storage; Owner: supabase_storage_admin
--

GRANT ALL ON TABLE storage.objects TO anon;
GRANT ALL ON TABLE storage.objects TO authenticated;
GRANT ALL ON TABLE storage.objects TO service_role;
GRANT ALL ON TABLE storage.objects TO postgres;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON SEQUENCES  TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON FUNCTIONS  TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: auth; Owner: supabase_auth_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_auth_admin IN SCHEMA auth GRANT ALL ON TABLES  TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON SEQUENCES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON FUNCTIONS  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: graphql; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql GRANT ALL ON TABLES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON SEQUENCES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON FUNCTIONS  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: graphql_public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA graphql_public GRANT ALL ON TABLES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: pgsodium; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pgsodium GRANT ALL ON SEQUENCES  TO pgsodium_keyiduser;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: pgsodium; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA pgsodium GRANT ALL ON TABLES  TO pgsodium_keyiduser;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON SEQUENCES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON SEQUENCES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON FUNCTIONS  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON FUNCTIONS  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA public GRANT ALL ON TABLES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA public GRANT ALL ON TABLES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON SEQUENCES  TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON FUNCTIONS  TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: realtime; Owner: supabase_admin
--

ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin IN SCHEMA realtime GRANT ALL ON TABLES  TO dashboard_user;


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON SEQUENCES  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON FUNCTIONS  TO service_role;


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: storage; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES  TO postgres;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES  TO anon;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES  TO authenticated;
ALTER DEFAULT PRIVILEGES FOR ROLE postgres IN SCHEMA storage GRANT ALL ON TABLES  TO service_role;


--
-- Name: issue_graphql_placeholder; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_graphql_placeholder ON sql_drop
         WHEN TAG IN ('DROP EXTENSION')
   EXECUTE FUNCTION extensions.set_graphql_placeholder();


ALTER EVENT TRIGGER issue_graphql_placeholder OWNER TO supabase_admin;

--
-- Name: issue_pg_cron_access; Type: EVENT TRIGGER; Schema: -; Owner: postgres
--

CREATE EVENT TRIGGER issue_pg_cron_access ON ddl_command_end
         WHEN TAG IN ('CREATE SCHEMA')
   EXECUTE FUNCTION extensions.grant_pg_cron_access();


ALTER EVENT TRIGGER issue_pg_cron_access OWNER TO postgres;

--
-- Name: issue_pg_graphql_access; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER issue_pg_graphql_access ON ddl_command_end
         WHEN TAG IN ('CREATE FUNCTION')
   EXECUTE FUNCTION extensions.grant_pg_graphql_access();


ALTER EVENT TRIGGER issue_pg_graphql_access OWNER TO supabase_admin;

--
-- Name: issue_pg_net_access; Type: EVENT TRIGGER; Schema: -; Owner: postgres
--

CREATE EVENT TRIGGER issue_pg_net_access ON ddl_command_end
         WHEN TAG IN ('CREATE EXTENSION')
   EXECUTE FUNCTION extensions.grant_pg_net_access();


ALTER EVENT TRIGGER issue_pg_net_access OWNER TO postgres;

--
-- Name: pgrst_ddl_watch; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER pgrst_ddl_watch ON ddl_command_end
   EXECUTE FUNCTION extensions.pgrst_ddl_watch();


ALTER EVENT TRIGGER pgrst_ddl_watch OWNER TO supabase_admin;

--
-- Name: pgrst_drop_watch; Type: EVENT TRIGGER; Schema: -; Owner: supabase_admin
--

CREATE EVENT TRIGGER pgrst_drop_watch ON sql_drop
   EXECUTE FUNCTION extensions.pgrst_drop_watch();


ALTER EVENT TRIGGER pgrst_drop_watch OWNER TO supabase_admin;

--
-- PostgreSQL database dump complete
--

