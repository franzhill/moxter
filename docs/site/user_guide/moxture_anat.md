

<div class="moxter-userguide-title" markdown="1">
# ![](../../img/moxter_userguide.png) Anatomy of a moxture
</div>




## YAML overview

Here is an overview of the settings that can be configured in a moxture file.

```yaml
moxtures:

  # Single moxture 
  # ---------------
  - name: create_pet             # Unique identifier used by mx.caller().call(...)
    extends: create_generic      # Optional alias for basedOn.
                                 # Lets us build on 'top' of another existing
                                 #  moxture.
    # --- Runtime Options ---
    options:                     # Tweak engine behavior.
      verbose: true              # Include detailed request/response logging.
      allowFailure: false        # If the call fails, should the test fail?
                                 # If 'true', a warning only will be issued.

    # --- Call configuration ---
    protocol: HTTP               # Optional. 
                                 # Default is 'HTTP'.
                                 # 'STOMP' will make this a Websocket request.
    method: POST                 # 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH' 
                                 #    for 'HTTP'
                                 # 'SEND' | 'SUBSCRIBE' for 'STOMP'
    endpoint: /api/pets          # The relative URI for the call (as fed to 
                                 #  MockMvc).
    headers:                     # Map of HTTP headers.
      Content-Type: application/json
      Authorization: "Bearer ${token}"
    query:                       # Map of query parameters (?key=val)
      firstCreation: true        # <key>: <val>
    vars:                        # Local variables for this moxture only.
      p.name: "Snowy"            # The "p." prefix is a namespace convention
                                 #  ("p" is for "parameter").
      p.age: 13                                    
    body: |                      # Request payload as JSON text (here, inlined).
      {                          
        "name": "${p.name}",
        "address": "Alleyways and rooftops",
        "age": ${p.age}
      }
    # (The payload can also be provided in native YAML)
    
    # --- Return processing ---
    save:                        # Extract response data into Moxter global 
                                 #  variables.
      new_pet_id: "$.id"         # varName: "<JsonPath>"
    
    # --- Expectations ---
    expect:                     # Moxter will automatically assert these.
      status: 201               # int, list ([201, 202]), or wildcards ("2xx").
      body:                     # Response body assertions.
        match:                  # Comparison with provided expected response.
          mode: partial         # 'partial' (default) | 'full'
          content: { status: "OK" } # The expected full or partial JSON.
                                # If partial, actual response is allowed to contain additional fields.
          ignorePaths: ["$.date"]   # List of jsonPaths to ignore while comparing.
        assert:                 # Surgical JsonPath checks.
          $.name: "${p.name}"   # <JsonPath>: value (Exact value check) 


  # STOMP moxture
  # --------------
  - name: publish_pet
    protocol: STOMP
    endpoint: /app/pets         # Destination to send the message to.
    body:
      event: pet-created
    expect:
      stomp:                    # Verify an asynchronous broadcast.
        topic: /topic/pets      # The destination to watch.
        wait: "2s"              # How long to wait for the message.
        save:                   # Save parts of the message using JsonPath.
          broadcasted_message: "$"  # Save the whole message into this variable.


  # Group moxture
  # --------------
  # Executed in the same way as a single moxture.
  - name: create_pet_and_process  # Unique identifier
    moxtures:                   # List of moxtures to execute sequentially.
      - create_pet              # Saves the id in var 'pet_id' (e.g.)
      - process_pet_1           # Uses the var 'pet_id' in its input (e.g.)
      - process_pet_2
      - ...

```

For a detailed explanation on each item, please refer to the chapter [Reference](../../reference/moxture.md)


## Variable interpolation

Many fields in a ***moxture*** support dynamic placeholders using the `${variable_name}` syntax.

This allows you to inject data into calls at runtime—such as tokens, keys, or scenario-specific values—or reuse variables extracted from a previous ***moxture*** execution.

***Moxter*** resolves these placeholders immediately before executing the ***moxture***. The scope and management of these variables is explored in further detail in the [Variables](../variables/variables.md) chapter.


## Group moxtures
Group moxtures allow you to chain several interactions into a single named sequence. This is the primary tool for building business test scenarios.



## IDE moxture syntax support

To improve the development experience, ***Moxter*** provides a JSON schema. Configuring this in your IDE enables:

- **Autocompletion**: Suggestions for valid YAML keys (e.g., `expect`, `save`, `options`).
- **Validation**: Detection of typos or incorrect data types.
- **Documentation**: Tooltips describing the purpose of each field.

### Schema
This is the schema that needs to be configured in your IDE: [Schema]({{ schema_path }}).

Alternatively, you can retrieve it from the ***Moxter*** library JAR (`moxture-schema.json` at the root of the package).


### Configuration
#### IntelliJ IDEA
IntelliJ provides native support for YAML schema mapping:

- Open Settings (`Ctrl+Alt+S`) and navigate to `Languages & Frameworks > Schemas and DTDs > JSON Schema Mappings`.  
- Click `+` to add a new mapping and name it "Moxter".
- Paste the schema URL above into the `URL` field or provide it directly.
- Set the `JSON Schema Version` to `JSON Schema version 7`.
- In the `Files` section, add a path pattern to match your moxture files, such as:
  - `src/test/resources/moxtures/*.yaml`
  - `*moxtures.yaml`

#### VSCode
Using the Red Hat YAML extension (Identifier: `redhat.vscode-yaml`), update your `settings.json` file:

```JSON
"yaml.schemas": {
  "{{ schema_url }}": ["*moxtures.yaml", "moxtures/*.yaml"]
}
```

