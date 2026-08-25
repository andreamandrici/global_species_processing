#!/bin/bash

set -euo pipefail

HOST="s-jrciprap321p.jrc.it"
PORT="5434"
USER="h05ibex"
DB="wolfe"

SCHEMA="species_2026_amphibians"
TABLE="h_flat"

NPROC=32

BASE="/data/swap/species_2026/flattening_amphibians"
OUTDIR="$BASE/range_by_qid"

mkdir -p "$OUTDIR"

PSQL="psql -h $HOST -p $PORT -U $USER -d $DB"

# ------------------------------------------------------------
# Crea tabella staging
# ------------------------------------------------------------

$PSQL -c "
DROP TABLE IF EXISTS species_2026.amphibians_ranges_by_species_worker;

CREATE TABLE species_2026.amphibians_ranges_by_species_worker (
    worker integer,
    id_no integer,
    range_sqkm double precision
);
"

# ------------------------------------------------------------
# Lista dei qid realmente presenti
# ------------------------------------------------------------

$PSQL -Atc "
    SELECT DISTINCT qid
    FROM ${SCHEMA}.${TABLE}
    ORDER BY qid;
" > "$OUTDIR/qids.txt"

for ((i=0; i<NPROC; i++)); do
    : > "$OUTDIR/qids_$i"
done

while read -r qid; do
    worker=$((qid % NPROC))
    echo "$qid" >> "$OUTDIR/qids_$worker"
done < "$OUTDIR/qids.txt"

# ------------------------------------------------------------
# Worker
# ------------------------------------------------------------

process_worker() {

    worker="$1"

    [ -s "$OUTDIR/qids_$worker" ] || return

    echo "WORKER $worker START"

    qids=$(paste -sd, "$OUTDIR/qids_$worker")

    $PSQL -c "
        INSERT INTO species_2026.amphibians_ranges_by_species_worker
            (worker, id_no, range_sqkm)
        SELECT
            $worker,
            id_no,
            SUM(sqkm)
        FROM ${SCHEMA}.${TABLE}
        CROSS JOIN LATERAL unnest(amphibians) AS id_no
        WHERE qid IN ($qids)
        GROUP BY id_no;
    "

    echo "WORKER $worker DONE"
}

export HOST PORT USER DB SCHEMA TABLE OUTDIR PSQL
export -f process_worker

# ------------------------------------------------------------
# Executa em paralelo
# ------------------------------------------------------------

for ((i=0; i<NPROC; i++)); do
    process_worker "$i" &
done

wait

# ------------------------------------------------------------
# Resultado finale
# ------------------------------------------------------------

$PSQL -c "
DROP TABLE IF EXISTS species_2026.amphibians_ranges_by_species;

CREATE TABLE species_2026.amphibians_ranges_by_species AS
SELECT
    id_no,
    SUM(range_sqkm) AS range_sqkm
FROM species_2026.amphibians_ranges_by_species_worker
GROUP BY id_no;

ALTER TABLE species_2026.amphibians_ranges_by_species
ADD PRIMARY KEY (id_no);

DROP TABLE species_2026.amphibians_ranges_by_species_worker;
"

echo "DONE"
echo "species_2026.amphibians_ranges_by_species created."
