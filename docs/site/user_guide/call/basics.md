# Calling a Moxture: Lifecycle overview


Triggering the execution of a moxture from your *JUnit* test is done through the `caller()` method which returns an **immutable** `MoxCaller` object:

```Java
    @Test
    myTest(){
       ...
       mx.caller().call("my_moxture")
       ...
   }
```

The `MoxCaller` provides a fluent API to programmatically prep (configure) your test before triggering the actual request. This includes injecting call-scoped variables, defining or overriding moxture settings such as expectations, users, execution mode etc., on the fly.

***Moxter*** then proceeds through the following steps:


## 1. Resolution (Finding the moxture)
First, ***Moxter*** locates the target moxture by looking for it the moxture files, per the configured discovery mechanism. By default, this is a "walk-up" mechanism through a defined moxture file hierarchy rooted in your test resource folder.

See [Moxture File Resolution](../../../site/user_guide/moxture/moxture_file.md) for the exact lookup rules.

## 2. Linking (inheritance resolution)

Once the moxture is found, the engine evaluates its `extends` property to resolve any inheritance. If that property is set, ***Moxter*** computes the final virtual moxture by merging the child moxture's properties into the parent's (child properties therefore override the parent's).

For JSON `body`, the merge mechanism is actually a bit more elaborate: ***Moxter*** performs a deep partial merge. This allows a child moxture to inherit a massive JSON body from its parent and selectively overwrite just one or two nested fields without redefining the rest.

Example:
```YAML
- name: "create_pet_dog"
  body:
    name: "${pet_name}"
    status: "available"
    category: { id: 1, name: "Dogs" }

- name: create_Rex_german_shepherd
  extends: "create_pet_dog"
  body:                           # parent body is inherited
    name: "Rex"                   # redefined
    breed: "German Shepherd"      # added
                                  # status, category are inherited
```

More on the inheritance mechanism in the chapter [Extending moxtures](../../../site/user_guide/extending_moxtures.md)


## 3. Blending Runtime Options
Before executing, the engine blends the linked moxture specification (its properties) with any runtime options passed via the *fluent Java call API*. This allows for surgical overrides of the moxture spec, at call time: 

Example:
```Java
// We override the moxture's default behavior for this specific execution:

mx.caller()
  .verbose(true)               // Force the execution to verbose, useful in tricky situations.
  .withVar("p.name", "Doris")  // Specify a var / override the local moxture var .
  .expect()
    .status(403)               // Override the expected status.
  .and()                       // Necessary 'syntactic sugar' to move on to the next step.
  .call("get_secure_resource");// Execute the moxture with all the new settings
```



## 4. Building the Variable Context
***Moxter*** builds a unified, layered variable context to be used for interpolation. It blends scopes in the following priority (highest wins):

- Call Scope (Java overrides passed via `.withVar()`)
- Moxture Scope (Variables defined directly in the YAML)
- Global Scope (Persistent engine memory)

*See the [Variables](../../../site/user_guide/variables/variables.md) chapter for detailed scope priority rules.*



## 5. Resolving (Interpolation
***Moxter*** parses the YAML and resolves all placeholders (e.g., `${pet_id}`) by looking up in the Variable Context, and computes a literal, executable final "resolved" moxture.

Also performs "Type Recovery" (turning a string into a Boolean or Long) and handling "Classpath Sniffing" (loading an external file if the body starts with classpath:).

## 6. Execution

With the moxture fully linked and all variables interpolated into concrete strings, ***Moxter*** locates the appropriate **Protocol Executor** (e.g., HTTP or STOMP) and dispatches the request  against your application context, using the underlying *MockMvc* for HTTP or *MockWebs* for STOMP.


## 7. Capture and Extraction
***Moxter*** intercepts the result returned by the **protocol executor** and wraps it into a `MoxResult` object, cleanly capturing the response status, headers, and body payload.

Crucially, before assertions run, ***Moxter*** executes the save: block to extract values from the response and store them in the Global Scope. This ensures that IDs or tokens are captured even if later assertions fail.


## 8. Performing Assertions (Expectations)
Finally, ***Moxter*** evaluates the `expect:` block defined in your YAML moxture against the captured `MoxResult`. 

- If all expectations are met, the call succeeds, and the test continues to the next step.
- If any assertion fails (e.g., you expected a `200 OK` but got a `400 Bad Request`, or a JSON path mismatch occurred), ***Moxter*** immediately throws a test assertion failure, halting the test. A detailed diagnostic report is generated in `target/moxter-failures/` to assist with debugging.

See the [Expectations](../../../site/user_guide/expectations/expectations.md) chapter for the full validation syntax.

