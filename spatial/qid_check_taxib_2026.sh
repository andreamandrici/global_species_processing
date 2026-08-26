#!/bin/bash
set -euo pipefail

HOST="xxx"
PORT="xxx"
USER="xxx"
DB="xx"

NPROC=140

BASE="/data/swap/species_2026/flattening_sharks"
LOGDIR="$BASE/logs/qid_check"

mkdir -p "$LOGDIR"

PSQL=(psql -h "$HOST" -p "$PORT" -U "$USER" -d "$DB")

# ============================================================
# TABELLA DI LAVORO
# ============================================================

"${PSQL[@]}" -v ON_ERROR_STOP=1 -c "

DROP TABLE IF EXISTS species_2026_sharks.a_qid_check_worker;

CREATE UNLOGGED TABLE species_2026_sharks.a_qid_check_worker (
    qid   integer NOT NULL,
    id_no integer NOT NULL,
    input boolean NOT NULL,
    final boolean NOT NULL
);

"

# ============================================================
# WORKER
# ============================================================

process_worker()
{
    local worker="$1"

    "${PSQL[@]}" -v ON_ERROR_STOP=1 -c "

    -- ========================================================
    -- 1. QID / ID_NO PRESENTI NELL'INPUT
    -- ========================================================

    CREATE TEMP TABLE input_qids_worker
    ON COMMIT DROP AS

    SELECT DISTINCT
        g.qid,
        a.fid AS id_no

    FROM species_2026_sharks.z_grid AS g

    JOIN species_2026_sharks.a_input_sharks AS a
      ON ST_Intersects(g.geom, a.geom)

    WHERE g.qid % $NPROC = $worker;


    CREATE INDEX input_qids_worker_idx
    ON input_qids_worker (qid, id_no);


    -- ========================================================
    -- 2. SALVA INPUT
    -- ========================================================

    INSERT INTO species_2026_sharks.a_qid_check_worker
        (qid, id_no, input, final)

    SELECT
        qid,
        id_no,
        TRUE,
        FALSE

    FROM input_qids_worker;


    -- ========================================================
    -- 3. CONTROLLA IL FINALE
    --
    -- SOLO I QID CHE ESISTONO NELL'INPUT.
    -- NESSUN UNNEST.
    -- ========================================================

    INSERT INTO species_2026_sharks.a_qid_check_worker
        (qid, id_no, input, final)

    SELECT
        i.qid,
        i.id_no,
        FALSE,
        TRUE

    FROM input_qids_worker AS i

    JOIN species_2026_sharks.h_flat AS h
      ON h.qid = i.qid
     AND h.sharks @> ARRAY[i.id_no];


    DROP TABLE input_qids_worker;

    "

    echo "worker $worker DONE"
}

# ============================================================
# AVVIO WORKER
# ============================================================

pids=()

for ((worker=0; worker<NPROC; worker++)); do

    process_worker "$worker" \
        > "$LOGDIR/worker_$(printf '%03d' "$worker").log" 2>&1 &

    pids+=("$!")

done

# ============================================================
# ATTENDI WORKER
# ============================================================

failed=0

for pid in "${pids[@]}"; do

    if ! wait "$pid"; then
        failed=1
    fi

done

if [ "$failed" -ne 0 ]; then
    echo "ERROR: one or more workers failed."
    exit 1
fi

echo "All workers completed."

# ============================================================
# RISULTATO
# ============================================================

"${PSQL[@]}" -v ON_ERROR_STOP=1 -c "

DROP TABLE IF EXISTS species_2026_sharks.sharks_qid_check;

CREATE TABLE species_2026_sharks.sharks_qid_check AS

WITH q AS (

    SELECT
        qid,
        id_no,
        bool_or(input) AS input,
        bool_or(final) AS final

    FROM species_2026_sharks.a_qid_check_worker

    GROUP BY qid, id_no
)

SELECT
    id_no,

    COUNT(*) FILTER (
        WHERE input
    ) AS input_qids,

    COUNT(*) FILTER (
        WHERE final
    ) AS final_qids,

    COUNT(*) FILTER (
        WHERE input AND NOT final
    ) AS lost_qids,

    ARRAY_AGG(qid ORDER BY qid) FILTER (
        WHERE input AND NOT final
    ) AS lost_qids_array

FROM q

GROUP BY id_no

ORDER BY lost_qids DESC, id_no;

"

echo "DONE"
