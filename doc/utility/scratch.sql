--Debugging
select asg.*
from note_stable_identifier_full nsf join note_stable_identifier nsi on nsf.stable_identifier_value = nsi.stable_identifier_value
                                     join abstractor_abstractions aa on nsi.id = aa.about_id
									                   join abstractor_suggestions asg on aa.id = asg.abstractor_abstraction_id
where nsf.note_id = ?


select    aa.value
        , asg.abstractor_abstraction_id
        , asg.suggested_value
        , asg.not_applicable
        , asg.accepted
        , asg.system_rejected
        , asg.system_rejected_reason
        , asg.system_accepted
        , asg.system_accepted_reason
        , ass.match_value
        , ass.sentence_match_value
from note_stable_identifier_full nsf join note_stable_identifier nsi on nsf.stable_identifier_value = nsi.stable_identifier_value
                                     join abstractor_abstractions aa on nsi.id = aa.about_id
									 join abstractor_suggestions asg on aa.id = asg.abstractor_abstraction_id
									 join abstractor_suggestion_sources ass on asg.id = ass.abstractor_suggestion_id
where nsf.note_id = 1
and aa.id in(
 20916
,20917
)
order by asg.abstractor_abstraction_id, asg.suggested_value


select  aa.value
      , asg.abstractor_abstraction_id
      , asg.suggested_value
      , asg.accepted
      , asg.system_rejected
      , asg.system_rejected_reason
      , asg.system_accepted
      , asg.system_accepted_reason
from note_stable_identifier_full nsf join note_stable_identifier nsi on nsf.stable_identifier_value = nsi.stable_identifier_value
                                     join abstractor_abstractions aa on nsi.id = aa.about_id
									 join abstractor_suggestions asg on aa.id = asg.abstractor_abstraction_id
									 join abstractor_suggestion_sources ass on asg.id = ass.abstractor_suggestion_id
where nsf.note_id = 1
and aa.id = 20841
order by asg.abstractor_abstraction_id, asg.suggested_value


