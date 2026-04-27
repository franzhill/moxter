# Calling a Moxture: The Lifecycle


Triggering the execution of a moxture from your *JUnit* test is done as follows:

```Java
    @Test
    myTest(){
       ...
       mx.caller().call("my_moxture")
       ...
   }
```

***Moxter*** then proceeds to do the following steps:


### 1. Resolution (Finding the moxture)
First, Moxter locates the target moxture by looking for it in the resource folder per the configured discovery mechanism. By default, this is a "walk-up" mechanism through a defined file hierarchy.

See [Moxture File Resolution](../engine/resolution.md) for the exact lookup rules.*

### 2. Linking (The `basedOn` mechanism)
Once the file is found, the engine checks if the moxture extends another template using the `basedOn` property. If it does, Moxter computes the final moxture by merging the child's overrides into the parent's definition.

* **Chaining**: Chained inheritance is fully supported (e.g., Moxture C is `basedOn` B, which is `basedOn` A).
* **Circular Dependencies**: If the engine detects a circular inheritance loop (e.g., A relies on B, which relies on A), it will immediately throw an exception to prevent infinite loops and crash the test safely.

### 3. Variable Interpolation
Before executing, Moxter parses the YAML and resolves any templated variables (like `${pet_id}`). To do this, it computes a combined **Variable Context** by merging the persistent **Global Scope** with the transient **Call Scope** (variables passed specifically for this execution).

» *See the [Variables](../variables/variables.md) chapter for detailed scope priority rules.*

### 4. Execution via MockMvc
With the moxture fully linked and all variables interpolated into concrete strings, Moxter translates the YAML request definition into a Spring `MockHttpServletRequestBuilder`. This is then passed directly to the underlying `MockMvc` instance to execute natively against your Spring context.

### 5. Capturing the Result
Once Spring processes the request, `MockMvc` returns a raw MVC result. Moxter intercepts this and wraps it into a `MoxResult` object, cleanly capturing the response status, headers, and body payload.

### 6. Performing Assertions (Expectations)
Finally, Moxter evaluates the `expect:` block defined in your YAML against the captured `MoxResult`. 

* If all expectations are met, the call succeeds, and the test continues to the next step.
* If any assertion fails (e.g., you expected a `200 OK` but got a `400 Bad Request`, or a JSON path mismatch occurred), Moxter immediately throws a test assertion failure with a detailed diff, halting the test.

» *See the [Expectations](../expectations/expectations.md) chapter for the full validation syntax.*rigger a moxture from your Java test using 

```Java
`mx.caller().call("my_moxture")`, ***Moxter*** doesn't just fire off a blind HTTP request. It acts as an orchestration engine, passing your YAML blueprint through a strict six-step lifecycle before it ever hits your application.

Here is exactly what happens under the hood during a call:

### 1. Resolution (Finding the file)
First, Moxter looks for the target moxture file (e.g., `my_moxture.yaml`) by scanning your configured file hierarchy. It uses a specific "walk-up" priority logic to allow for local overrides and default fallbacks.

» *See [Moxture File Resolution](../engine/resolution.md) for the exact lookup rules.*

### 2. Linking (The `basedOn` mechanism)
Once the file is found, the engine checks if the moxture extends another template using the `basedOn` property. If it does, Moxter computes the final moxture by merging the child's overrides into the parent's definition.

* **Chaining**: Chained inheritance is fully supported (e.g., Moxture C is `basedOn` B, which is `basedOn` A).
* **Circular Dependencies**: If the engine detects a circular inheritance loop (e.g., A relies on B, which relies on A), it will immediately throw an exception to prevent infinite loops and crash the test safely.

### 3. Variable Interpolation
Before executing, Moxter parses the YAML and resolves any templated variables (like `${pet_id}`). To do this, it computes a combined **Variable Context** by merging the persistent **Global Scope** with the transient **Call Scope** (variables passed specifically for this execution).

» *See the [Variables](../variables/variables.md) chapter for detailed scope priority rules.*

### 4. Execution via MockMvc
With the moxture fully linked and all variables interpolated into concrete strings, Moxter translates the YAML request definition into a Spring `MockHttpServletRequestBuilder`. This is then passed directly to the underlying `MockMvc` instance to execute natively against your Spring context.

### 5. Capturing the Result
Once Spring processes the request, `MockMvc` returns a raw MVC result. Moxter intercepts this and wraps it into a `MoxResult` object, cleanly capturing the response status, headers, and body payload.

### 6. Performing Assertions (Expectations)
Finally, Moxter evaluates the `expect:` block defined in your YAML against the captured `MoxResult`. 

* If all expectations are met, the call succeeds, and the test continues to the next step.
* If any assertion fails (e.g., you expected a `200 OK` but got a `400 Bad Request`, or a JSON path mismatch occurred), Moxter immediately throws a test assertion failure with a detailed diff, halting the test.

» *See the [Expectations](../expectations/expectations.md) chapter for the full validation syntax.*