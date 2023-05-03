-- creates all the tables and produces csv files
-- takes a few minutes to run
-- should be run as user asgnxt rather than eicu based on what worked for me
-- this script worked on 5/03/2023 using :
-- conda environment: pytorch-gpu
-- switched to directory : /Users/asgnxt/hcnet/eICU-GNN-LSTM
-- connect to psql server as: psql 'dbname=eicudemo user=asgnxt options=--search_path=public'
-- then run this script as: \i eICU_preprocessing/create_all_tables_alt.sql
-- all timeseries scripts etc comnmrnted out as we are not using them

\i /Users/asgnxt/hcnet/eICU-GNN-LSTM/eICU_preprocessing/labelsalt.sql
\i /Users/asgnxt/hcnet/eICU-GNN-LSTM/eICU_preprocessing/diagnosesalt.sql
\i /Users/asgnxt/hcnet/eICU-GNN-LSTM/eICU_preprocessing/flat_features_alt.sql
-- \i /Users/asgnxt/hcnet/eICU-GNN-LSTM/eICU_preprocessing/timeseries.sql

-- -- we need to make sure that we have at least some form of time series for every patient in diagnoses, flat and labels
-- drop materialized view if exists timeseries_patients cascade;
-- create materialized view timeseries_patients as
--   with repeats as (
--     select distinct patientunitstayid
--       from timeserieslab
--     union
--     select distinct patientunitstayid
--       from timeseriesresp
--     union
--     select distinct patientunitstayid
--       from timeseriesperiodic
--     union
--     select distinct patientunitstayid
--       from timeseriesaperiodic)
--   select distinct patientunitstayid
--     from repeats;

\copy (select * from labelsalt) to '/Users/asgnxt/hcnet/eICU-GNN-LSTM/eICU_data/labelsalt.csv' with csv header
-- \copy (select * from labels as l where l.patientunitstayid in (select * from timeseries_patients)) to '/Users/asgnxt/hcnet/eICU-GNN-LSTM/eICU_data/labels.csv' with csv header
\copy (select * from diagnosesalt) to '/Users/asgnxt/hcnet/eICU-GNN-LSTM/eICU_data/diagnosesalt.csv' with csv header
-- \copy (select * from diagnoses as d where d.patientunitstayid in (select * from timeseries_patients)) to '/Users/asgnxt/hcnet/eICU-GNN-LSTM/eICU_data/diagnosesalt.csv' with csv header
\copy (select * from flatalt) to '/Users/asgnxt/hcnet/eICU-GNN-LSTM/eICU_data/flat_features_alt.csv' with csv header
-- \copy (select * from flat as f where f.patientunitstayid in (select * from timeseries_patients)) to '/Users/asgnxt/hcnet/eICU-GNN-LSTM/eICU_data/flat_features_alt.csv' with csv header
-- \copy (select * from timeserieslab) to '/Users/asgnxt/hcnet/eICU-GNN-LSTM/eICU_data/timeserieslab.csv' with csv header
-- \copy (select * from timeseriesresp) to '/Users/asgnxt/hcnet/eICU-GNN-LSTM/eICU_data/timeseriesresp.csv' with csv header
-- \copy (select * from timeseriesperiodic) to '/Users/asgnxt/hcnet/eICU-GNN-LSTM/eICU_data/timeseriesperiodic.csv' with csv header
-- \copy (select * from timeseriesaperiodic) to '/Users/asgnxt/hcnet/eICU-GNN-LSTM/eICU_data/timeseriesaperiodic.csv' with csv header