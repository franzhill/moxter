
# Moxture reference

## Single moxtures

### extends
- **Alias**: basedOn
- **Type**: `String`
- **Optional**: yes
- **Default value**: N/A
- **Supports variable interpolation**: no

Points to another ***moxture*** name to inherit its configuration. The engine performs a merge, where the inheriting (child) ***moxture*** takes precedence:
- scalars (e.g. `endpoint`, `method`...) are overwritten
- maps (e.g. `headers`) are shallow-merged (high level keys are overwritten),
- `body` is recursilvely deep-merged: nested objects are merged additively, allowing for surgical overrides of specific fields within a complex JSON structure.

Inheritance is resolved during the loading phase (prior variable interpolation), so the parent name must be a literal string.

See chapter [Extending moxtures](../extending_moxtures.md).

### basedOn
- **Alias**: extends


### options.verbose
- **Type**: `Boolean`
- **Optional**: yes
- **Default value**: false
- **Supports variable interpolation**: no

Toggles high-visibility console feedback for a specific call. When enabled, the engine bypasses standard logger thresholds to print the full request and response envelopes —including headers and raw bodies— directly to the console.


### options.allowFailure
- **Type**: `Boolean`
- **Optional**: yes
- **Default value**: false
- **Supports variable interpolation**: no

Determines if an expectation failure (e.g., a status mismatch) should terminate the JUnit test. If set to `true`, the error is logged as a warning and the execution continues. This is intended for non-critical steps or optional cleanup moxtures.

### protocol
- **Type**: `String`
- **Optional**: yes
- **Default value**: `HTTP`
- **Values**: `HTTP`, `STOMP`
- **Supports variable interpolation**: no

Defines the underlying execution engine. `HTTP` dispatches the request to **MockMvc** for standard REST calls; `STOMP` routes the interaction through the **MockWebs** executor for WebSocket flows.

### method
- **Type**: `String`
- **Optional**: no
- **Default value**: `GET` (for HTTP)
- **Values**: `GET`, `POST`, `PUT`, `DELETE`, `PATCH`, `SEND`, `SUBSCRIBE`
- **Supports variable interpolation**: no

The action to perform. For **HTTP**, it accepts standard verbs (`GET`, `POST`...). For **STOMP**, it accepts action verbs like `SEND` or `SUBSCRIBE`.

### endpoint
- **Type**: `String`
- **Optional**: no
- **Default value**: N/A
- **Supports variable interpolation**: yes

The destination URI for the call. For HTTP moxtures, this is the relative path fed to the `MockMvc` builder. It supports full interpolation, allowing for dynamic paths like `/api/pets/${p.id}`.

### headers
- **Type**: `Map`
- **Optional**: yes
- **Default value**: 
    - `Content-Type: application/json` (if `body` is present)
    - `Accept: application/json`
- **Supports variable interpolation**: yes (values only)

A collection of HTTP headers. While the keys are literal strings, the values support dynamic placeholders (e.g., `Authorization: "Bearer ${token}"`).  
For HTTP protocol calls, the engine automatically applies the defaults to ensure compatibility with modern REST APIs. You only need to define these headers explicitly if you wish to override them.

### query
- **Type**: `Map`
- **Optional**: yes
- **Default value**: N/A
- **Supports variable interpolation**: yes (values only)

A map of query parameters appended to the URI (e.g., `?key=val`). Values are automatically URL-encoded by the engine during the resolution phase.

### vars
- **Type**: `Map`
- **Optional**: yes
- **Default value**: N/A
- **Supports variable interpolation**: yes (values only)

Definitions of variables local to the moxture. These values shadow global variables and are often used to provide default values for the `body` or `endpoint`. 

### body
- **Type**: `Object` | `String`
- **Optional**: yes
- **Default value**: N/A
- **Supports variable interpolation**: yes

The request payload. If the moxture `extends` another, this field is **deep-merged** with the parent's body.  
The engine resolves the payload in three ways: 
- **Native YAML** (defined directly in the file), 
- **Inline JSON** (usually via the `|` literal block), or an
- **External File** (a string starting with `classpath:path/to/file.json`).

### save
- **Type**: `Map`
- **Optional**: yes
- **Default value**: N/A
- **Supports variable interpolation**: no

Extracts data from the response body into the global context for use in subsequent steps. The **key** is the variable name; the **value** is a **JsonPath** expression (e.g., `new_pet_id: "$.id"`). Extraction occurs after the call is executed but before expectations are verified.

### expect.status
- **Type**: `Integer` | `List` | `String`
- **Optional**: yes
- **Default value**: `200`
- **Supports variable interpolation**: yes

The expected HTTP status code. Validations support **Exact matches** (`201`), a **List of valid codes** (`[200, 201]`), or **Wildcards** (`"2xx"` or `"4xx"`).

### expect.body.match
- **Type**: `Object`
- **Optional**: yes
- **Default value**: N/A
- **Supports variable interpolation**: yes (within `content`)

Performs a structural comparison of the response body. The `content` field defines the target JSON/YAML structure to match against, while `ignorePaths` provides a list of JsonPaths to exclude from the comparison (useful for fields like `$.timestamp`).

### expect.body.assert
- **Type**: `Map`
- **Optional**: yes
- **Default value**: N/A
- **Supports variable interpolation**: yes (values only)

A map of **JsonPath** keys to expected literal values. It performs a strict equality check. Listing a path here implicitly asserts that the path must exist in the response body.

### expect.stomp
- **Type**: `Object`
- **Optional**: yes
- **Default value**: N/A
- **Supports variable interpolation**: yes

Validates asynchronous WebSocket broadcasts. The `topic` defines the destination to monitor, `wait` defines the max duration to wait for the message (e.g., `"2s"`), and the internal `save` block allows for extraction of message parts into variables using JsonPath.


## Group moxtures

### moxtures
- **Type**: List of `String`s
- **Optional**: no
- **Default value**: N/A
- **Supports variable interpolation**: no


Defines an ordered sequence of existing moxture names to be executed. When a group is called via mx.caller().call("group_name"), the engine processes each step in the order listed.

State Sharing: any variable extracted via a save block in an earlier step is automatically available for interpolation in the endpoint, headers, or body of all subsequent steps in the group.

Atomic Failure: by default, if any moxture in the group fails its expectations, the entire sequence terminates and the JUnit test fails (unless `options.allowFailure: true` is set on the failing step).
