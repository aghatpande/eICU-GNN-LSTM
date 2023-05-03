-- MUST BE RUN FIRST

-- creates a materialized view labelsalt which looks like this:
/*
 patientunitstayid | predictedhospitalmortality | actualhospitalmortality |  predictediculos  | actualiculos
-------------------+----------------------------+-------------------------+-------------------+--------------
            141265 | 5.2291724973649173E-2      | ALIVE                   |  2.04551427140529 |       4.2138
            141650 | 9.8379312792900908E-2      | ALIVE                   |   4.0173515857653 |       4.0187
            141806 | 0.61324392319420928        | ALIVE                   |  8.47993403963615 |      26.9763
            141920 | 0.1220932810791483         | ALIVE                   |   5.7713323573653 |       2.0868
*/

-- delete the materialized view labelsalt if it already exists
drop materialized view if exists labelsalt cascade;
create materialized view labelsalt as
  -- select all the data we need from the apache predictions table, plus patient identifier and hospital identifier
  -- information because we only want to select one episode per patient (more on this later)
  with all_labels as (
    select p.uniquepid, p.patienthealthsystemstayid, apr.patientunitstayid, p.unitvisitnumber,
      apr.predictedhospitalmortality, apr.actualhospitalmortality, apr.predictediculos, apr.actualiculos
      from patient as p
      inner join apachepatientresult as apr
        on p.patientunitstayid = apr.patientunitstayid
      -- only use the most recent apache prediction model
      where apr.apacheversion = 'IVa'
      -- removed the length of stay filter 'and apr.actualiculos >= 1' in the original script
      -- there are two apache versions:
      -- eicudemo=# select distinct(apacheversion) from apachepatientresult;
      -- apacheversion
      --   IV
      --   IVa
      --   (2 rows)
  )
  select al.patientunitstayid, al.predictedhospitalmortality, al.actualhospitalmortality,
    al.predictediculos, al.actualiculos
    from all_labels as al
    -- 'selection' is a table which will choose a random hospital stay (the lowest number is fine because the stays
    -- are randomly ordered). In the case of multiple ICU stays within that hospital admission, it will choose the
    -- first ICU stay 
    inner join (
      select p.uniquepid, p.patienthealthsystemstayid, min(p.unitvisitnumber) as unitvisitnumber
        from patient as p
        inner join (
          select uniquepid, min(patienthealthsystemstayid) as patienthealthsystemstayid
            from all_labels
            group by uniquepid
          ) as intermediate_selection
          on p.patienthealthsystemstayid = intermediate_selection.patienthealthsystemstayid
        group by p.uniquepid, p.patienthealthsystemstayid
      ) as selection
      on al.patienthealthsystemstayid = selection.patienthealthsystemstayid
      and al.unitvisitnumber = selection.unitvisitnumber;