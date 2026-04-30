

# Anatomy of a moxture

## 1. In a nutshell

A ***moxture*** is a declarative YAML blueprint of a tailored API or WebSocket interaction with added capabilities that can be executed directly from a *JUnit* test or chained together to form multiple-step test scenarios.

Technically, these calls are executed natively within your *Spring* application context and dispatched to *MockMvc* for REST or [*MockWebs*](../mockwebs.md) for STOMP/WebSocket interactions.

Beyond describing standard request parameters, a ***moxture*** provides configuration for built-in logic such as: 
- declarative assertions: define what success looks like (status codes, full/partial/surgical JSON matching...) directly in the YAML.
- variable extraction: extract fields from a response and save them into variables for subsequent steps.
- inheritance: build new moxtures on top of existing ones to reduce repetition
- and more 

***Moxtures*** are ultimately called from within a *JUnit* test, in the following fashion:

```Java
// Example: Creating a pet and asserting the returned name
mx.caller()
  .withVar("p.name", "Rex")         // Inject variables into the YAML
  .call("create_pet")               // Trigger the call
  .assertBody("$.name")             // Verify the outcome
     .isEqualTo("Rex");
```

<!-- All features regarding calling ***moxtures*** will be examined in detail in the [Calling moxtures](../calling_moxtures.md) chapter. -->


## 2. YAML overview

```YAML
moxtures:

  # --- Single moxture ---
  - name: create_pet             # Unique identifier used by mx.caller().call(...)
    extends : create_generic     # Optional. 
                                 # Lets us build on 'top' of another existing
                                 #  moxture.

    # --- Runtime Options ---
    options:                     # Tweak engine behavior.
      verbose: true              # Force log request/response to console.
      allowFailure: false        # If the call fails, should the test fail?
                                 # If 'true', a warning only will be issued.

    # --- Call configuration ---
    protocol: HTTP               # Optional. 
                                 # Default is 'HTTP' (=> REST request).
                                 # 'STOMP' will make it a Websocket request.
    method: POST                 # 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH' 
                                 #    for 'HTTP'
                                 # 'SEND' | 'SUBSCRIBE' for STOMP')
    endpoint: /api/pets          # The relative URI for the call (as fed to 
                                 #  MockMvc).
    headers:                     # Map of HTTP headers.
      Content-Type: application/json   # Example.
      Authorization: "Bearer ${token}" # Example.
    query:                       # Map of query parameters (?key=val)
      firstCreation: true        # Example.
    vars:                        # Local variables for this moxture only.
      p.name: "Snowy"            # The "p." prefix is a just makeshift 
                                 #  namespace ("p" is for "parameter").
      p.age: 13                                    
    body: |                      # Request payload (given here as inline JSON).
      { "name"     : "${p.name}"
        "address"  : "Alleyways and rooftops"
        "age"      : ${p.age}
        }                        # The payload can also be provided as native 
                                 #  YAML.
    
    # --- Return processing ---
    save:                        # Extract response data into Moxter global 
                                 #  variables.
      new_pet_id: "$.id"         # varName: "<JsonPath>"
    
    # --- Expectations ---
    expect:                     # Moxter will automatically assert these.
      status: 201               # int, list ([201, 202]), or wildcards ("2xx").
      body:                     # Body assertions.
        match:                  # Full structural comparison.
          content: { status: "OK" } # The expected JSON.
          ignorePaths: ["$.date"]   # Paths to skip in comparison.
        assert:                 # Surgical JsonPath checks.
          $.name: "${p.name}"   # <JsonPath>: value (Exact value check) 
      stomp:                    # Verify async side-effects (broadcasts).
        topic: /topic/pets      # The WebSocket topic to watch.
                                #  (Aka 'destination')
        wait: "2s"              # How long to wait for the message.
        save:                   # Save parts of the message using JsonPath.
          broadcasted_message: "$"  # Saving the whole message into this variable.

  # --- Group moxture ---
  # Executed in the same way as a single moxture.
  - name: create_pet_and_process  # Unique identifier
    moxtures:                   # List of moxtures to execute sequentially.
      - create_pet              # Saves the id in var 'pet_id' (e.g.)
      - process_pet_1           # Uses the var 'pet_id' in its input (e.g.)
      - process_pet_2
      - ...

```

For a detailed explanation on each item, please refer to the chapter [Reference](../moxture/moxture_reference.md)


## 3. Variable interpolation

Many fields in a ***moxture*** support dynamic placeholders using the `${variable_name}` syntax. 

This allows you to inject data into calls at runtime—such as tokens, keys, or scenario-specific values—or reuse variables extracted from a previous ***moxture*** execution.

***Moxter*** "bakes" these placeholders into their final literal values just before the ***moxture*** gets executed. The scope and management of these variables is explored in further detail in the [Variables](../variables.md) chapter.


## 4. Group Moxtures
Group moxtures allow you to chain several interactions into a single named sequence. This is the primary tool for building Business Test Scenarios.