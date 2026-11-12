<div class="moxter-userguide-title" markdown="1">
# ![](../img/moxter_reference.png) Moxter Caller Reference
</div>

## `.caller()`

- **Called on**: `Moxter`
- **Return**: `MoxCaller`
- **Required**: yes to use the per-call API
- **Applicable**: all moxtures

Creates a caller for configuring an individual moxture call.

## `.call(String moxtureName)`

- **Called on**: `MoxCaller`
- **Return**: `Moxter.MoxtureResult`
- **Required**: yes to execute the call
- **Applicable**: all moxtures

Executes the named moxture using the options configured on the caller and returns the result.

## `.withVar(String key, Object value)`

- **Called on**: `MoxCaller`
- **Return**: `MoxCaller` (new instance)
- **Required**: no
- **Applicable**: all moxtures

Adds one call-scoped variable override. Call-scoped variables take precedence over variables defined in the moxture and in the engine's global scope.

```java
Moxter.MoxtureResult result = mx.caller()
                                .withVar("p.name", "Doris")
                                .call("create_pet");
```

## `.withVars(Map<String, Object> overrides)`

- **Called on**: `MoxCaller`
- **Return**: `MoxCaller` (new instance)
- **Required**: no
- **Applicable**: all moxtures

Adds multiple call-scoped variable overrides. The overrides take precedence over moxture and global variables.

See the [Variables guide](../user_guide/variables/variables.md) for scope details.

## `.withAuth(Authentication auth)`

- **Called on**: `MoxCaller`
- **Return**: `MoxCaller` (new instance)
- **Required**: no
- **Applicable**: HTTP and STOMP moxtures

Sets the authentication for this call. Call-scoped authentication takes precedence over the engine's authentication and the authentication in Spring's `SecurityContextHolder`.

## `.expect(Object status)`

- **Called on**: `MoxCaller`
- **Return**: `MoxCaller` (new instance)
- **Required**: no
- **Applicable**: HTTP moxtures

Overrides only the expected HTTP status from the YAML moxture for this call. This is the concise form of `.expect().status(status)`: both replace the YAML `expect.status` value for this call. The status can be a single code, a list of acceptable codes, or a status-class string such as `"4xx"`.

Other expectations in the YAML, including body checks, remain in effect. The `MoxCaller` expectation API does not merge or override those checks; Java assertions on the returned `MoxtureResult` are separate checks.

```java
mx.caller()
  .expect(403)
  .call("get_secure_resource");
```

## `.expect()`

- **Called on**: `MoxCaller`
- **Return**: `Moxter.MoxCaller.ExpectBuilder`
- **Required**: no
- **Applicable**: HTTP moxtures

Opens an expectation builder for overriding the expected HTTP status for this call. The builder's `.status(...)` method is the only expectation override it currently provides.

### `.status(Object status)`

- **Called on**: `Moxter.MoxCaller.ExpectBuilder`
- **Return**: `Moxter.MoxCaller.ExpectBuilder`
- **Required**: yes when using the builder
- **Applicable**: HTTP moxtures

Sets the expected status override. 
Same as `.expect(status)` (which is a short alias).

### `.and()`

- **Called on**: `Moxter.MoxCaller.ExpectBuilder`
- **Return**: `MoxCaller`
- **Required**: no
- **Applicable**: HTTP moxtures

Returns an immutable `MoxCaller` with the status override applied. Use `.and()` when you want to continue adding call options after setting the expected status:

```java
Moxter.MoxtureResult result = mx.caller()
                                .expect().status(403)
                                .and()
                                .withVar("p.name", "Doris")
                                .call("get_secure_resource");
```

If there are no more call options to add, you can call `.call(...)` directly on the expectation builder:

```java
mx.caller()
  .expect().status(403)
  .call("get_secure_resource");
```

## `.verbose(boolean enabled)`

- **Called on**: `MoxCaller`
- **Return**: `MoxCaller`
- **Required**: no
- **Applicable**: all moxtures

Enables or disables detailed request and response output for this call.

## `.allowFailure(boolean allowed)`

- **Called on**: `MoxCaller`
- **Return**: `MoxCaller`
- **Required**: no
- **Applicable**: all moxtures

When enabled, execution and expectation failures are logged as warnings rather than failing the test.

## `.withJsonPathLax(boolean enabled)`

- **Called on**: `MoxCaller`
- **Return**: `MoxCaller`
- **Required**: no
- **Applicable**: calls that perform JsonPath extraction

When enabled, the call uses lenient JsonPath evaluation for YAML `save:` extractions and body expectations, including `expect.body.assert`. A missing path is read as `null` instead of raising a path-not-found exception; the YAML assertion is still evaluated against that value. This option does not affect fluent result assertions such as `.assertBody(...)`.

Suppose the response body has no `name` field:

```json
{"id": 42}
```

With this moxture, `pet_name` is saved as `null`, and the body assertion passes because it expects `null`:

```yaml
save:
  pet_name: "$.name"   # saved as 'null'
```

