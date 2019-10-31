select count(*)
from fact_relationship
where fact_relationship.domain_concept_id_2 = 10
and not exists(
select 1
from procedure_occurrence
where fact_relationship.fact_id_2 = procedure_occurrence.procedure_occurrence_id
)


select count(*)
from fact_relationship
where fact_relationship.domain_concept_id_1 = 10
and not exists(
select 1
from procedure_occurrence
where fact_relationship.fact_id_1 = procedure_occurrence.procedure_occurrence_id
)



select count(*)
from fact_relationship
where fact_relationship.domain_concept_id_1 = 5085
and not exists(
select 1
from note
where fact_relationship.fact_id_1 = note.note_id
)
