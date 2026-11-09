<div class="moxter-userguide-title" markdown="1">
# ![](../../img/moxter_userguide.png) Variables
</div>

Variables make moxture calls dynamic and reusable. They enable data sharing between calls, such as capturing an ID from a `POST` response and using it in a subsequent `GET` or `DELETE` request.

## 1. Interpolation in moxtures

***Moxter*** supports `${variable_name}` interpolation inside YAML moxtures. Before a moxture is executed, the engine replaces placeholders with their values from the variable context.


> **Note**: the mustache-style `{{variable_name}}` syntax is also supported.

Variables can be used in many moxture fields, for example:  

- **Endpoint**: `/api/pets/${petId}`
- **Body**: `{"name": "${pet_name}"}`
- **Headers**: `X-Pet-Type: ${type}`
- **Expectations**: `$.name: "${pet_name}"`

## 2. The Moxter Variable Context and its scopes
The **Moxter Variable Context** holds the engine's global variables. Each moxture call also combines that context with moxture-local defaults and call-scope overrides. These three scopes determine variable visibility and precedence.

### The Global Scope
The Global Scope is tied to the Moxter engine instance. It acts as the persistent memory of your test or test suite.

- **Source**: set through `mx.vars().put(...)` or captured during a moxture execution through its `save` block.
- **Lifetime**: persists as long as the engine instance exists. If you use a shared engine (e.g. set up in a `@BeforeAll` method), variables saved in Test_A are available in Test_B.  
- **Purpose**: storing state that needs to "travel" between different moxture calls (e.g., `auth_token`, `new_pet_id`...).


### The Call Scope
The Call Scope is transient. It is created at the start of a moxture call (`mx.caller().call()`) and destroyed when it finishes.

- **Source**: combines defaults in the moxture's YAML `vars` block with overrides provided through the fluent API (`mx.caller().withVar(...)`).
- **Lifetime**: exists only for the duration of a single moxture execution.  
- **Purpose**: providing specific inputs for a call without polluting the global scope.


## 3. How to set variables

### Extract from a return
To capture data from a response and store it in the Global Scope, use the `save` block in the moxture YAML definition. By default, it uses JsonPath to extract values from the response body.

```YAML
save:
  new_pet_id: "$.id"               # Root-level field
```  

For a response body such as:

```JSON
{
  "id": 42,
  "owner": { "id": 7 },
  "pets": [
    { "id": 1, "status": "active" },
    { "id": 2, "status": "inactive" }
  ]
}
```

you can use JsonPath to select nested fields, array elements, or matching values:

```YAML
save:
  new_pet_id: "$.id"
  owner_id: "$.owner.id"
  first_pet_id: "$.pets[0].id"
  active_pet_ids: "$.pets[?(@.status == 'active')].id"  # returns a list of ids
```

### Define locally in a moxture
To provide default values that only exist within the **Call Scope** of a specific moxture, use the `vars` block. These are useful for making moxtures runnable out-of-the-box, without having to specify them upon calling the moxture.

```YAML
...
    name: create_pet
    vars:
      p.name: "Snowy"   # Starting the variable name with "p." makes it 
      p.age : 15        # easier to identify it as a moxture overridable
                        # "parameter" that acts as a default value
                        # ("p" is for "parameter").
    # In the rest of the moxture, use the variables:
    body: |          # Body given in JSON format.
        { "name"    : "${p.name}",
          "species" : "${species}", # No default provisioned => should be 
                                    # provided upon moxture call.
          "address" : "Brussels",
          "age"     : ${p.age}     # Note: numeric values do not require
                                   # quotes in JSON.
        }
    expect:
      body:
        assert:
          $.name: "${p.name}"  # The returned name should match the provided.
          $.age : ${p.age}     # For numeric assertions, omit quotes to match 
                               # the type (Integer vs String).
...
```


### Set upon a moxture call
To inject or override values at runtime for a specific execution, use the fluent Caller API. These values are placed in the **Call Scope**.

```Java
mx.caller()
  .withVar("p.name" , "Beethoven")  # Override a moxture local (= default)
                                    # variable
  .withVar("species", "Dog")        # Provide a non defaulted variable
  .call("create_pet");
```


### Set as global in the Moxter engine

To define constant-like values or environment-level defaults that should be available to every moxture call, add them to the engine's global context.

```Java
mx = Moxter.forTestClass(MyTest.class)
        .mockMvc(mockMvc)
        .build();

mx.vars().put("api_version", "v1");
mx.vars().put("default_owner_id", 1);
```


## 4. Variable precedence

Variables can be defined at multiple scopes as we have seen. When the same variable name appears in more than one scope, ***Moxter*** resolves it using this precedence order:

| Priority | Source | Scope | Definition Method |
| :--- | :--- | :--- | :--- |
| **1 (Highest)** | **Call override** | Call | `mx.caller().withVar("key", "val")` |
| **2** | **Moxture YAML defaults** | Moxture | The `vars:` block in the YAML file |
| **3 (Lowest)** | **Engine-global variables** | Global | `mx.vars().put(...)` or a moxture's `save` block |

Values captured by `save` and values added with `mx.vars().put(...)` share the same global map; `save` is not a separate precedence level. Writing over an existing global variable replaces its value and logs a warning, or issues an error if strict variable handling is enabled.

Within a moxture inheritance chain, a child moxture's `vars` override the inherited parent `vars`'s value for the same key.

Within a same moxture call,  if one same variable is supplied more than once through `withVar(...)`, the last supplied value wins.




With the examples given above, the resolved (or 'interpolated') moxture would hence be:
```YAML
    body: |          # Body given in JSON format.
        { "name"    : "Beethoven",
          "species" : "Dog",
          "address" : "Brussels",
          "age"     : 15
        }
    expect:
      body:
        assert:
          $.name: "Beethoven"
          $.age : 15
```

!!! note
    If a variable is missing, ***Moxter*** logs a warning and leaves its placeholder (for example, `${var_name}`) in place. The resulting request or assertion may then fail or behave unexpectedly.


## 5. Accessing the variables in the Variable Context

While you often interact with variables inside your YAML moxtures, you may find yourself needing to pull these variables back into your Java code, perhaps to perform a custom assertion for example, or manually having to set variables for the purpose of a specific test configuration.

You can interact with the variable context programmatically through the Moxter engine instance.

### Reading from the Global Scope

Using `mx.vars()` in your JUnit tests will access the engine-global scope of the variable context. Call-scoped overrides are transient, so they cannot be retrieved after the moxture call has finished.

```Java
...
    // --- Inside the test class: ---
    private Moxter mx;   //  <-- our Moxter engine
...
        // --- Inside the test: method: ---
        // Execute the moxture that saves 'new_pet_id'
        mx.caller().call("create_pet");

        // Retrieve the variable from the Global Scope
        Long petId = mx.vars().read("new_pet_id").asLong(); 

        // Example: Using the variable in a standard JUnit assertion
        assertNotNull(petId, 
                      "The pet ID should have been saved to the Global Scope");
...
```

#### Reading and converting values
`mx.vars().view()` provides a read-only view of the variable context map, whose values are plain Java objects. 
While accessing the raw context variable map via `getVars()` returns plain Objects, the `read()` method returns a value wrapper with methods for accessing or converting that value.

Use the method that matches the value and conversion you need. ***Moxter*** will uses its internal ObjectMapper to perform the conversion or cast. 

Example:

```Java
// Extracting a nested field from a JSON object saved in 'last_response':
// from e.g. a call to the "create_pet" moxture:
String petName = mx.vars().read("pet_name")
                          .asString();  


// Extracting a numeric ID and ensuring it is a Long:
Long ownerId = mx.vars().read("owner_id").asLong();

// Extracting a value to meet its internal type:
mx.vars().put("owner_id", 42L);  // stored as Long
...
Long ownerId = mx.vars().read("owner_id")
                        .asType(Long.class);  // retrieved as Long

// Read a saved JSON value as a Jackson JsonNode
JsonNode savedPet = mx.vars().read("saved_pet_data").asJsonNode();
```

!!! Note
    `asType(Long.class)` only succeeds if the stored value is already a `Long`. It will not convert an `Integer` or parse `"42"`. Use `asLong()` for those conversions.

See the [Reference](../../reference/variables.md) for the full list of extraction methods.




### Managing the Variable Context Lifecycle

Since the Global Scope persists for the lifetime of the engine instance by default, resetting the state (wiping out all variables) can be performed manually:

- `mx.vars().clear()`: wipes the Global Scope completely. This is the "reset button."

!!! tip
    If you use a shared engine across multiple tests, it is highly recommended calling `mx.vars().clear()` in an `@AfterEach` method. This prevents state leaking where variables from one test will be available (and set) to another, possibly and silently messing up that test's context.


## 6. A word of caution

The Global Scope is what makes Moxter simple for complex integration scenarios. By allowing variables to persist across different moxture calls, you can build elaborate end-to-end flows without manually passing IDs or tokens between Java methods.

However, this simplicity requires vigilance:

- **Unintended overwrites**: since every `save` block writes to the same global map, generic names (like `id`) can replace values needed by another call. By default, Moxter logs a warning when a global value is overwritten; strict variable handling can be enabled to make overwrites illegal instead.
- **State Pollution**: if you use a shared engine between tests, the global scope acts as shared state. A failure in one test might leave the context "dirty," causing subsequent tests to fail unpredictably.

!!! tip "Recommendation"
    Use descriptive names (e.g., `created_pet_id` instead of just `id`) to reduce accidental collisions. If you need a clean slate between tests, call `mx.vars().clear()` in an `@AfterEach` method.