DO $$
DECLARE
    tbl_name text;
    seq_name text;
    func_name text;
    proc_name text;  -- Variable to store procedure names
BEGIN
    -- Drop tables from the "public" schema, excluding spatial_ref_sys
    FOR tbl_name IN (
        SELECT tablename
        FROM pg_tables
        WHERE schemaname = 'public'
        AND tablename != 'spatial_ref_sys'
        AND tablename NOT LIKE '%directus_%'
    )
    LOOP
        EXECUTE 'DROP TABLE IF EXISTS ' || quote_ident(tbl_name) || ' CASCADE;';
    END LOOP;

    -- Drop sequences from the "public" schema
    -- FOR seq_name IN (SELECT sequence_name FROM information_schema.sequences WHERE sequence_schema = 'public')
    -- LOOP
    --     EXECUTE 'DROP SEQUENCE IF EXISTS ' || quote_ident(seq_name) || ';';
    -- END LOOP;

    -- -- Drop functions from the "public" schema
    -- FOR func_name IN (SELECT routine_name FROM information_schema.routines WHERE routine_schema = 'public' AND routine_type='FUNCTION')
    -- LOOP
    --     EXECUTE 'DROP FUNCTION IF EXISTS ' || quote_ident(func_name) || '();';
    -- END LOOP;

    -- -- Drop procedures from the "public" schema
    -- FOR proc_name IN (SELECT routine_name FROM information_schema.routines WHERE routine_schema = 'public' AND routine_type='PROCEDURE')
    -- LOOP
    --     EXECUTE 'DROP PROCEDURE IF EXISTS ' || quote_ident(proc_name) || '();';
    -- END LOOP;

END $$;
