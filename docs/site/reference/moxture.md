
<div class="moxter-userguide-title" markdown="1">
# ![](../img/moxter_reference.png) Moxture file reference
</div>

## Root level

### `.templates`
- **Type**: Map of named structured YAML fragments
- **Optional**: yes

Named templates are inserted into the rest of the file via the `__template__` directive.

### `vars`
- **Type**: `Object`
- **Optional**: yes

Global variables available to all moxtures in the file.
Global `vars` may contain arbitrary values. 

### `moxtures`
- **Type**: List of moxture definitions
- **Optional**: yes
- **Supports variable interpolation**: no

The list of moxture definitions (single and group moxtures).


## Single moxture

An entry in the above `moxtures` list.

### `name`
- **Type**: `String`
- **Optional**: no
- **Supports variable interpolation**: no

The name used to refer to this moxture. Used in `extends`, `basedOn`, a group moxture's `moxtures` list, or when calling a moxture from a *JUnit* test.

### `extends`
- **Alias**: basedOn
- **Type**: `String`
- **Optional**: yes
- **Supports variable interpolation**: no

Points to another ***moxture*** name to inherit its configuration. The engine performs a merge, where the inheriting (child) ***moxture*** takes precedence:
- scalar fields such as `endpoint` and `method` are overridden by the child. A child cannot change its parent's `protocol`.
- maps such as `headers`, `query`, and `vars` are shallow-merged, with child values winning for matching keys.
- `body` objects are recursively deep-merged, allowing surgical overrides of nested fields. Arrays and scalar bodies are replaced by the child.
- `save`, `moxtures`, and `multipart` are replaced by the child when specified. The child's `expect` block replaces the parent's block rather than merging with it.

Inheritance is resolved during the loading phase (prior variable interpolation), so the parent name must be a literal string.

See chapter [Extending moxtures](../extending_moxtures.md).

### `basedOn`
- **Alias**: extends
- **Type**: `String`
- **Optional**: yes
- **Supports variable interpolation**: no


### `options.verbose`
- **Type**: `Boolean`
- **Optional**: yes
- **Default value**: false
- **Supports variable interpolation**: no

Enables extensive console feedback for a specific call. When enabled, the engine bypasses standard logger thresholds to print the full request and response envelopes. 

### `options.allowFailure`
- **Type**: `Boolean`
- **Optional**: yes
- **Default value**: false
- **Supports variable interpolation**: no

Determines whether a failure should stop execution of the JUnit test. If set to `true`, execution or expectation failures are logged as warnings and execution continues. On a group moxture, this also lets the group continue after a child fails.

### `protocol`
- **Type**: `String`
- **Optional**: yes
- **Default value**: `HTTP`
- **Values**: `HTTP`, `HTTPS`, `STOMP` (case-insensitive)
- **Supports variable interpolation**: no

Defines the underlying execution engine. `HTTP` and `HTTPS` dispatch the request to **MockMvc**; `STOMP` routes it through **MockWebs**.

### `method`
- **Type**: `String`
- **Optional**: yes
- **Default value**: `GET` (for HTTP)
- **Values**: `GET`, `POST`, `PUT`, `PATCH`, `DELETE`, `HEAD`, `OPTIONS` (for HTTP) (case-insensitive)
- **Supports variable interpolation**: no

The HTTP method to perform. STOMP moxtures always send a `SEND` frame; this field does not select a STOMP action such as `SUBSCRIBE`.


### `endpoint`
- **Type**: `String`
- **Optional**: yes
- **Supports variable interpolation**: yes

The destination URI for the call. For HTTP moxtures, this is the relative path fed to the `MockMvc` builder. It supports full interpolation, allowing for dynamic paths like `/api/pets/${p.id}`.

### `headers`
- **Type**: `Map` of `String`, `Number`, or `Boolean`
- **Optional**: yes
- **Default value**:
    - `Content-Type: application/json` for a non-multipart HTTP request with a body
- **Supports variable interpolation**: yes (values only)

A collection of HTTP headers. While the keys are literal strings, the values support dynamic placeholders (e.g., `Authorization: "Bearer ${token}"`).  
For non-multipart HTTP calls with a body, the engine sets `Content-Type: application/json`. It does not add an `Accept` header automatically. This does not prevent the server from returning JSON; the server may return its default representation.


### `query`
- **Type**: `Map` of `String`, `Number`, or `Boolean`
- **Optional**: yes
- **Supports variable interpolation**: yes (values only)

A map of query parameters appended to the URI (e.g., `?key=val`). Both keys and values are URL-encoded upon execution.

### `vars`
- **Type**: `Map` of arbitrary values
- **Optional**: yes
- **Supports variable interpolation**: yes (values only)

Definitions of variables local to the moxture. Values may be any YAML value. They shadow global variables and are often used to provide default values for the `body` or `endpoint`.

### `body`
- **Type**: Any JSON value
- **Optional**: yes
- **Supports variable interpolation**: yes (string values)

The request payload may be any JSON value. If the moxture `extends` another, object bodies are **deep-merged** with the parent's body; arrays and scalar bodies are replaced.
The engine resolves the payload in three ways:
- **Native YAML** (defined directly in the file), 
- **Inline JSON** (usually via the `|` literal block), or an
- **External File** (a string starting with `classpath:path/to/file.json`).

### `multipart`
- **Type**: `List` of part objects
- **Optional**: yes
- **Default value**: `type: json`
- **Supports variable interpolation**: yes (part names, filenames, and body string values)

Use this instead of `body` for an HTTP multipart request. Parts may specify `name`, `body`, `type` (`json`, `file`, or `text`), and `filename`. The default type is `json`. A `file` part reads its body from a classpath resource and uses the filename to determine its content type. Other types are sent with `application/json`; string bodies are sent as raw text, while other bodies are serialized as JSON.

```yaml
moxtures:
  - name: submit_pet_profile
    method: POST
    endpoint: /api/pets
    multipart:
      - name: pet
        type: json
        body:
          name: "${petName}"
          species: dog
      - name: photo
        type: file
        filename: "${petName}-photo.jpg"
        body: classpath:fixtures/pet-photo.jpg
      - name: adoption_note
        type: text
        body: Ready for adoption
```

Place the referenced file on the test classpath. Relative file paths are resolved from the directory containing the moxture definition; a path starting with `/` is resolved from the classpath root. The `classpath:` prefix is optional.

### `save`
- **Type**: `Map` of `String`, `Number`, or `Boolean`
- **Optional**: yes
- **Supports variable interpolation**: yes (values)

Extracts data from the response body and saves it as variables into the global context for use in subsequent steps. The **key** is the variable name; the **value** can be a **JsonPath** expression (e.g., `new_pet_id: "$.id"`) or a literal. JsonPath extraction occurs after the call and before expectations are treated; if extraction fails, ***Moxter*** logs a warning and saves the interpolated expression as a literal.

### `expect.status`
- **Type**: `Null` | `Integer` | `List` | `String`
- **Optional**: yes
- **Default value**: No status check when omitted
- **Supports variable interpolation**: no

The expected HTTP status code. Supports exact integers or numeric strings (`201`, `"201"`), a list of acceptable values (`[200, 201]`), and class wildcards (`"1xx"` through `"5xx"`).

### `expect.body.match`
- **Type**: `Object`
- **Optional**: yes
- **Supports variable interpolation**: yes (within `content`)

Performs a structural comparison of the response body.

- `content` defines the expected JSON/YAML value. 
- `mode` can be `full` for strict matching or `partial` (default) for a recursive subset match. 
In `partial` mode, every expected object property and array item must match the response, but the response may contain extra properties or items; array order is not significant.<br />
Mode values are case-insensitive.<br />
For example, this expected content matches a response with an extra `name` property and an extra array item:<br />
Expected:
```json
{"user":{"id":7},"tags":["blue"]}
```
Response:
```json
{"user":{"id":7,"name":"Ada"},"tags":["blue","new"]}
```
Missing or mismatched expected values fail the comparison. 

- `ignorePaths` lists JsonPaths removed from both values before comparison; for example, use `$.timestamp` to ignore a generated timestamp.
- Variable interpolation is supported within `content`, not in `mode` or `ignorePaths`.

### `expect.body.assert`
- **Type**: `Map`
- **Optional**: yes
- **Supports variable interpolation**: yes (values only)

A map of **JsonPath** keys to expected values. It performs equality checks, interpolating values (but not JsonPath keys). With the default strict JsonPath configuration, a listed path must exist in the response body.

### `expect.stomp`
- **Alias**: `broadcast`
- **Type**: `Object` or a list containing at most one object
- **Optional**: yes
- **Supports variable interpolation**: yes (`topic` and `save` values)

Validates an asynchronous STOMP broadcast over WebSocket using **MockWebs**. 

- `topic` (also accepted as `destination`) identifies the destination to monitor.
- `wait` is a string accepting milliseconds, seconds, or minutes (for example, `"200ms"`, `"2s"`, `"2m"`, or `"2min"`), with optional spaces and case-insensitive units; omitting the unit means milliseconds. 
- `type: "String"` captures a String payload; other or omitted types are treated as byte arrays. 
- `save` works the same as the save one level above. Can capture the whole message with `"$"` or extract JsonPath values. 

`topic` and `save` values support interpolation. If a list of broadcast expectations is supplied, it can contain at most one entry, which is the one verified.

Example:

```yaml
...
expect:
  stomp:
    topic: /topic/orders
    wait: 2s
    type: String
    save:
      receivedMessage: "$"
...
```

This waits up to two seconds for a String broadcast on `/topic/orders` and saves its payload as `receivedMessage`.



## Group moxtures

### `moxtures`
- **Type**: List of `String`s
- **Optional**: yes
- **Supports variable interpolation**: no


Defines an ordered sequence of existing moxtures to execute. When called via `mx.caller().call("group_name")`, the engine processes each step in the listed order.

State Sharing: any variable extracted via a save block in an earlier step is automatically available for interpolation in the endpoint, headers, or body of all subsequent steps in the group.

Failure behavior: by default, a child failure stops the sequence and propagates to the test (i.e. the test fails), unless `options.allowFailure` is set to `true` on the specific failing moxture, or on the group, whereby ***Moxter*** simply logs the failure and carries on.

Groups do not roll back side effects from earlier children.
