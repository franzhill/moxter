# Variables

Variables allow you to render moxture calls dynamic and reusable. They enable data sharing between different moxture calls, such as capturing an ID from a `POST` response to use it in a subsequent `GET` or `DELETE` request.

## Interpolation in moxtures

***Moxter*** uses the `${variable_name}` syntax for string interpolation inside YAML moxtures. Before a moxture is executed, the engine replaces these placeholders with their current values from the variable context.

Variables can be used in many moxture fields, for example:
- **Endpoint**: `/api/pets/${petId}`
- **Body**: `{"name": "${pet_name}"}`
- **Headers**: `X-Pet-Type: ${type}`
- **Expectations**: `$.name: "${pet_name}"`

> Note: the mustache-style `{{variable_name}}` syntax is also supported.


## The Moxter Variable Context and its scopes
The **Moxter Variable Context** is where all variables reside during the lifetime of a ***Moxter*** engine instance. It is comprised of two distinct **scopes** that determine the lifetime and visibility of your variables.

### The Global Scope
The Global Scope is tied to the Moxter engine instance. It acts as the persistent memory of your test or test suite.

- **Source**: defined via `Moxter.builder().withVar(...)` or captured during a moxture execution as defined by the `save` block.  
- **Lifetime**: persists as long as the engine instance exists. If you use a shared engine (e.g. set up in a `@BeforeAll` method), variables saved in Test_A are available in Test_B.  
- **Purpose**: storing state that needs to "travel" between different moxture calls (e.g., `auth_token`, `new_pet_id`...).


### The Call Scope
The Call Scope is transient. It is created at the start of a moxture call (`mx.call(moxture)`) and destroyed as soon as the call finishes.

- **Source**: comprised of the variables defined in the moxture's YAML vars block and any overrides provided via the fluent API (`mx.caller().withVar(...)`).  
- **Lifetime**: exists only for the duration of a single moxture execution.  
- **Purpose**: providing specific inputs for a call without polluting the global scope.


## How to set variables

### Extract from a return
To capture data from a response and store it in the Global Scope, use the `save` block in the moxture YAML definition. By default, it uses JsonPath to extract values from the response body. You can also capture headers by using the header: prefix.

```YAML
save:
  new_pet_id: "$.id"               # Extracts from JSON body
```  

<!-- TODO add more examples illustrating JsonPath -->

### Define locally in a moxture
To provide default values that only exist within the **Call Scope** of a specific moxture, use the `vars` block. These are useful for making moxtures runnable out-of-the-box, without having to specify them upon calling the moxture.

```YAML
...
    name: create_pet
    vars:
      p.name: "Snowy"   # Starting the variable name with "p." makes it 
      p.age : 15        #  easier to identify it as a moxture overridable
                        #  "parameter" that acts as a default value.
    # In the rest of the moxture, use the variables:
    body: |          # Body given in JSON format.
        { "name"    : "${p.name}",
          "species" : "${species}" # No default for this variable. Will have to 
                                   #  be provided externally or the test might
                                   #  fail or misbehave.
          "address" : "Brussels",
          "age"     : $p.age       # age being a numeric, does not require quotes in JSON
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
  .withVar("p.name" , "Beethoven")  # Override a moxture local (= default) variable
  .withVar("species", "Dog")        # Provide a non defaulted variable
  .call("create_pet");
```


### Set as global in the Moxter engine

To define "constants" or environment-level defaults that should be available to every moxture call, use the builder. These live in the Global Scope.

```Java
mx = Moxter.builder()
        .mockMvc(mockMvc)
        .withVars(Map.of(
            "api_version", "v1",
            "default_owner_id", 1
        ))
        .build();
```


## Variable precedence

As you will have noticed, several mechanisms allow variable instanciation. 
This means variable collision is entirely possible. ***Moxter*** resolves this using a specific yet simple precednce system: if a variable is instanciated in multiple places, the one with the **highest priority** wins.

| Priority | Source | Scope | Definition Method |
| :--- | :--- | :--- | :--- |
| **1 (Highest)** | **JUnit call**                | Call   | `mx.caller().withVar("key", "val")` |
| **2**           | **Moxture YAML**              | Call   | The `vars:` block in the YAML file. |
| **3**           | **Moxture result extraction** | Global | `.builder().withVar("key", "val")` |
| **4 (Lowest)**  | **Engine Builder**            | Global | `.builder().withVars(Map.of("key", "val"))` |

If several instanciations of a same variable compete at the same level, then precedence is obtained by chronology (last wins).

With the examples given above, the resolved (interpolated) moxture would hence be:
```YAML
    body: |          # Body given in JSON format.
        { "name"    : "Beethoven",
          "species" : "Dog"
          "address" : "Brussels",
          "age"     : 15
        }
    expect:
      body:
        assert:
          $.name: "Beethoven"
          $.age : 15
```

> **Note**  
> If no value is resolved, then the literal string `${var_name}` will be used by ***Moxter***, thus resulting in a either a test failure or possibly unintended (or not) behaviour.

<!-- TODO improve example so we get all combinations -->


## Accessing the variables in the Variable Context

While you often interact with variables inside your YAML moxtures, you may find yourself needing to pull these variables back into your Java code, perhaps to perform a custom assertion for example, or manually having to set variables for the purpose of a specific test configuration.

You can interact with the variable context programmatically through the Moxter engine instance.

### Reading from the Global Scope

Accessing variables from Java is always made against the Global Scope. Because the Call Scope is transient (it is created and destroyed within the mx.call() lifecycle), it is logically impossible to retrieve a "call variable" once the execution has returned to your Java test method.

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
        assertNotNull(petId, "The pet ID should have been saved to the Global Scope");
...
```

#### Type-safe Extraction (read)
While accessing the raw context variable map (via getVars()) returns plain Objects, the read() method allows you to extract and cast variables in a single, type-safe operation. This is the preferred way to interact with your data from Java.

- First access the variable fom the variable context via: `vars().read("var_name")`.
- Then chain the caster method: `.as(<Class>)`, `.asLong()`, `.asString()`, `.asBoolean()` ... The value will automatically converted/cast to the desired type using Moxter's ObjectMapper.

Example:

```Java
// Extracting a nested field from a JSON object saved in 'last_response':
String petName = mx.read("pet_name").asString();  // E.g. saved in the "create_pet" moxture

// Extracting a numeric ID and ensuring it is a Long:
Long ownerId = mx.read("owner_id").as(Long.class); // Eliminates manual casting and provides 
                                                   // clearer error messages if a type mismatch 
                                                   // occurs.

// Mapping a saved JSON variable to a Java Object
Pet myPet = mx.read("saved_pet_data").as(Pet.class);
```

See page [Reference](site/user_guide/variables/reference.md) for the full list of extraction methods.




### Managing the Variable Context Lifecycle

Since the Global Scope persists for the lifetime of the engine instance by default, resetting the state (wiping out all variables) can be performed manually:

- `mx.vars().clear()`: wipes the Global Scope completely. This is the "reset button."

> **Vigilance Note**  
> It is highly recommended to call `mx.clearVars()` in an `@AfterEach` method if you are using a shared engine across multiple tests. This prevents "state leaking" where Test_A's variables accidentally satisfy the requirements of Test_B.


## A word of caution

The Global Scope is what makes Moxter simple for complex integration scenarios. By allowing variables to persist across different moxture calls, you can build elaborate end-to-end flows without manually passing IDs or tokens between Java methods.

However, this simplicity requires vigilance:

- **Unintended overwrites**: since any `save` block writes to the same global map, using generic variable names (like `id`) across different moxtures increases the risk of one call silently overwriting data needed by another.
- **State Pollution**: if you use a shared engine, the global scope acts as shared state. A failure in one test might leave the context "dirty," causing subsequent tests to fail unpredictably.

> **Recommendation**  
> Use descriptive names (e.g., `created_pet_id` instead of just `id`) when "globality" is not a desired effect, and consider using `mx.clearVars()` in an `@AfterEach` method if you need to ensure a clean slate between tests.