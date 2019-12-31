# OMOP Abstractor Custom NLP Providers

OMOP Abstractor supports the ablity to delegate the generation of suggestions to an external NLP library via a RESTful API.
An external library that implments OMOP Abstractor's RESTful API is called a 'Custom NLP Provider'.

The OMOP Abstactor RESTful API message flow is detailed in the following diagram:

![](OMOP_Abstractor_Custom_NLP_Provder_Message_Flow.png)

# Steps for a Custom NLP Provider to implement the OMOP Abstractor RESTful API
1. Create an endpoint to receive note text embedded in a JSON structure via a POST request. 
   1. Here is an example of the JSON structure that the endpoint must be able to receive: [JSON](1_receive_note_and_abstractor_schema_endpoints.json)
   1. The JSON structure contains the note text, stable identifiers of the note text ('source_id', 'source_type', 'source_method') and an array of abstactor abstraction schemas ('abstractor_abstraction_schemas') to 'abstract' from the note text.
   1. Each abstactor abstraction schema ('schema') contains a stable identifer ('abstractor_abstraction_schema_id').
   1. Each schema  contains a URI (the schema endpoint) to retrieve the schema's definition ('abstractor_abstraction_schema_uri') via a GET request.
   1. Each schema contains a URI (the suggestion endpoint) to submit suggestions via a POST request ('abstractor_abstraction_abstractor_suggestions_uri').
   1. Each schema will contain a stable identifier to subsequently submit to the suggestion endpoint  ('abstractor_abstraction_source_id').
   1. Each schema contains an 'abstractor_rule_type' key.  The 'abstrator_rule_type' key indicates the strategy for how the schema should be derived from the note text.  The possible values for 'abstractor_rule_type' are the following:
       1. **'name/value'**: Both a non-negated variant of the schema's predicate _and_ a non-negated variant of the schema's object should be present in a sentence of the note text.  Examples: 'KPS: 20' or 'The patient has a Karnofsky Performance Status of thirty.'.  In the first example, the key/value pair sentence contains the 'KPS' predicate variant and the '20' object variant for a 'Karnofsky Performance Status' schema.  In the second example, the ordinary English languange sentence contains the 'Karnofsky Performance Status' predicate variant and the 'thirty' object variant for a 'Karnofsky Performance Status' schema.  The 'name/value' rule is appropriate for any schema where the note text is expected to explicty mention both a predicate variant and an object variant.  OMOP Abstactor supports the ablity to display suggestions for the value of 'unknown'.  This might be appropriate for an example where a predicate variant is mentioned without an object variant.  For example, 'The KPS for the patient is hard to determine.'.
       1. **'value'**:  A non-negated variant of the schema's object should be present in a sentence of the note text.  Example: 'The specimen exhibits glioblastoma.'.  In this example, the ordinary English language sentence contains the 'glioblastoma' object variant for a 'Cancer Diagnosis' schema.  The 'value' rule is appropriate for any schema where the note text is expected to only explicitly mention an object variant of the schema.
       1. **'unknown'**: The 'unknown' rule is appropriate for any schema where the note text is expected to not be able to support the suggestion of anything beyond a value of 'unknown'.
   1. Each schema contains an 'updated_at' key that should be used by the Custom NLP provider to bust the caching of schema definitions. 
1. Retrieve the definition of each schema via a GET request to the schema endpoint found in the 'abstractor_abstraction_schema_uri' key from the prior step.
     1. Here is an example of the JSON structure that will be the response: [JSON](2_abstractor_schema_request_response.json)
     1. The JSON structure contains the following keys: 'predicate', 'display_name', 'abstractor_object_type', 'preferred_name', 'predicate_variants'.  The 'predicate_variants' key contains an array of values that express synonymous values for the 'preferred_name' of the schema's predicate.  Each predicate variant value contains a 'value' key.
The 'value' key contains the variant token of the predicate variant.  The 'abstractor_object_type' key indicates the data type of the schema's object.  The possible values for 'abstractor_object_type' are the following:  
         1. 'list' or 'radio button list': This 'abstractor_object_type' is for schema's representing categorical values.  The 'object_values' key contains an array of values that express the schema's list of possible categorical values.  Each object value contains the following keys: 'value', 'vocabulary_code', 'vocabulary', 'vocabulary_version', 'case_sensitive' and 'object_value_variants'.  The 'value' key contains the peferred token of the object value.  The 'case_sensitive' key ('true' or 'false') indicates if the 'value' token should be matched case sensitively.  The 'object_value_variants' contains an array of values that express synonymous values for the 'value' of the object value.  Each object value variant contains the following keys: 'value' and 'case_sensitive'.  The 'value' key contains the variant token of the object value variant.  The 'case_sensitive' key ('true' or 'false') indicates if the 'value' token should be matched case sensitively
         1. **'number'**: This 'abstractor_object_type' is for schema's representing numeric values.  Currently, there is no way to specify if the number should be an integer, a float or have a minnimum/maximum.
         1. **'boolean'**: This 'abstractor_object_type' is for schema's representing boolean values ('true' or 'false').
         1. **'date'**: This 'abstractor_object_type' is for schema's representing date values.
1. Run a NLP engine on the note text for each 'schema', using the the retrieved schema definition, the 'abstractor_rule_type' and 'abstractor_object_type' to  generate suggestions.
1. POST a suggestion for each each schema via a request to the 'suggestion' endpoint found in the first step.  Each suggestion for each schema requires its own request.
    1. Here is an example of the JSON structure that needs to be sent as the body of the POST request to the 'suggestion' endpoint: [JSON](3_post_suggestion.json)
    1. Set the stable identifier keys of the suggestion from the first step: 'abstractor_abstraction_source_id', 'source_id', 'source_type' and 'source_method'.
    1. Set the 'value' key to the value of the abstracted suggestion or set the 'unknown' key to 'true' for when no suggestion can be made.
    1. Within the 'suggestion_sources' key, create an array of substantiating 'match_value' and 'sentence_match_value' entries.
