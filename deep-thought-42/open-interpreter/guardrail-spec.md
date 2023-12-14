```xml

<rail version="0.1">
<output>
    <object name="bank_run" format="length: 2">
        <string
            name="explanation"
            description="A paragraph about what a bank run is."
            format="length: 200 280"
            on-fail-length="reask"
        />
        <url
            name="follow_up_url"
            description="A web URL where I can read more about bank runs."
            format="valid-url"
            on-fail-valid-url="filter"
        />
    </object>
</output>

<prompt>
Explain what a bank run is in a tweet.

${gr.xml_prefix_prompt}

${output_schema}

${gr.json_suffix_prompt_v2_wo_none}
</prompt>
</rail>

```
