<div class="moxter-userguide-title" markdown="1">
# ![](../../img/moxter_userguide.png)The Moxture call sequence overview
</div>

## The MoxCaller

Calling a moxture is done via the `call(...)` method of the `MoxCaller` object, which is obtained by applying the method `caller()` on a `Moxter` (engine).


Configuration for your moxture call is performed on the `MoxCaller` before executing it with `call`. See [MoxCaller](caller.md) for more details.



```java
...
class PetTest {
    // Build the local Moxter Engine
    Moxter mx = Moxter.forTestClass(MyTest.class)
                      .mockMvc(mockMvc)
                      .build();

    @Test
    void myTest() {
        mx.caller()              // get a MoxCaller
        .call("my_moxture");   // call by moxture name
    }
```

## How Moxter processes the call

When a moxture gets `call`ed, ***Moxter*** performs the following steps.

### 1. Resolution (finding the moxture)

***Moxter*** starts by locating the called moxture. It searches up the moxture hierarchy, starting from the class provided to the engine at build time.

See [Moxture File Resolution](../../user_guide/moxture/moxture_file.md) for a detailed explanation of the lookup process.

### 2. Linking (inheritance resolution)

Once the moxture is located, the engine resolves inheritance declared with `extends` or `basedOn`. Child values take precedence, with merge behavior depending on the property: maps such as `headers`, `query`, and `vars` are shallow-merged; lists such as `save` and `moxtures` are replaced by the child. The resulting moxture representation is called the "linked moxture".

For JSON `body`, object values are recursively merged, so a child can override or add nested fields. Array and scalar body values are replaced by the child.

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

More on the inheritance mechanism in the chapter [Extending moxtures](../../user_guide/extending_moxtures.md)


### 3. Blending runtime options
Before executing, the engine blends the linked moxture specification (its properties) with any runtime options passed via the `MoxCaller`'s *fluent call API*. This allows for surgical overrides of the moxture spec, at call time: 

Example:
```Java
// We override the moxture's default behavior for this specific execution:

mx.caller()
  .verbose(true)               // Force the execution to verbose, useful in tricky situations.
  .withVar("p.name", "Doris")  // Specify a var / override the local moxture var .
  .expect()
    .status(403)               // Override the expected status.
  .and()                       // Return to the caller if you need to chain more caller options.
  .call("get_secure_resource");// Execute the moxture with all the new settings
```

The expectation builder also supports calling `.call(...)` directly; `.and()` is only needed to return to the `MoxCaller` before adding more caller options.


### 4. Building the Variable Context
***Moxter*** builds a unified, layered variable context to be used for interpolation. It blends scopes in the following priority (highest wins):

- Call Scope (Java overrides passed via `.withVar()`)
- Moxture Scope (Variables defined directly in the YAML)
- Global Scope (Persistent engine memory)

*See the [Variables](../../user_guide/variables/variables.md) chapter for detailed scope priority rules.*



### 5. Resolving (Interpolation)
***Moxter*** parses the YAML and resolves all placeholders (e.g., `${pet_id}`) by looking up in the Variable Context, and computes a literal, executable final "resolved" moxture.

It also preserves resolved number, boolean, and collection values as typed values rather than converting them to strings. A body can reference an external classpath resource with a `classpath:` value.

### 6. Execution

With the moxture fully linked and all variables interpolated into concrete strings, ***Moxter*** locates the appropriate **Protocol Executor** (e.g., HTTP or STOMP) and dispatches the request  against your application context, using the underlying *MockMvc* for HTTP or *MockWebs* for STOMP.


### 7. Capture and Extraction
***Moxter*** captures the response. Before checking expectations, it executes the `save` block and writes extracted values to the global variable scope. If an expectation fails, those values have already been written to the global scope.


### 8. Performing Assertions (aka Expectations)
Finally, ***Moxter*** evaluates the `expect:` block defined in your YAML moxture against the resolved moxture and captured response.

- If all expectations are met, the call succeeds, and the test continues to the next step.
- If an expectation fails (e.g., you expected a `200 OK` but got a `400 Bad Request`, or a JSON path mismatch occurred), ***Moxter***'s default behaviour is to let the test fail (through the normal *JUnit* failure behaviour) and also generates a specific diagnostic report in `target/moxter-failures/` with ***Moxter***-related runtime context information. If `options.allowFailure` is `true`, Moxter logs the failure and continues instead.

When execution completes with a response, `.call(...)` returns a `Moxter.MoxtureResult` that provides access to the response status, headers, and body.

See the [Expectations guide](../../user_guide/expectations/expectations.md) for the supported expectation syntax.
