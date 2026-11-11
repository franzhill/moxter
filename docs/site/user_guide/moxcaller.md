<div class="moxter-userguide-title" markdown="1">
# ![](../../img/moxter_userguide.png) MoxCaller
</div>

The `MoxCaller` is the base object for configuring and executing a moxture call. Its fluent call API lets you chain call-specific options before calling `.call(...)`. `MoxCaller`s are independant from the `Moxter` engine or the moxture definition and do not change the configuration of either.

For the detailed technical overview of the call sequence, see [Calling a Moxture](basics.md).



## Execute a moxture

Call `.call(...)` on a configured caller to execute the named moxture. It returns a `Moxter.MoxtureResult`:

```java
Moxter.MoxtureResult result = mx.caller()
                                .withVar("p.name", "Doris")
                                .call("create_pet");
```

## Per-call options

### Variables

Use `.withVar(key, value)` for one override or `.withVars(map)` for several. Call-scoped values take precedence over variables in the moxture and the engine's global scope. They apply only to this caller.

```java
Moxter.MoxtureResult result = mx.caller()
        .withVars(Map.of(
                "p.name", "Doris",
                "p.status", "available"))
        .call("create_pet");
```

See the [Variables guide](../variables/variables.md) for variable scopes and precedence.

### Authentication

Use `.withAuth(authentication)` to execute this call with a specific Spring Security `Authentication`. Call-scoped authentication takes precedence over the engine's configured authentication and the `SecurityContextHolder`.

### Expected HTTP status

Use `.expect(status)` to override the expected HTTP status for this call. The status can be a code, a list of acceptable codes, or a status-class string such as `"4xx"`:

```java
mx.caller()
        .expect(403)
        .call("get_secure_resource");
```

Use `.expect().status(status)` to configure the expected status within the fluent call chain. This temporarily switches from `MoxCaller` to an expectation builder. Calling `.and()` returns to a configured `MoxCaller`, so you can continue chaining call options. If you have no more call options to add, you can call `.call(...)` directly on the expectation builder:

```java
mx.caller()
        .expect().status(403)
        .and()
        .withVar("p.name", "Doris")
        .call("get_secure_resource");
```

### Other execution options

- `.verbose(true)` enables detailed request and response output for this call.
- `.allowFailure(true)` logs execution or expectation failures and allows the test to continue. Use this only when the failure is acceptable; an execution failure may leave the result without a response.
- `.withJsonPathLax(true)` makes a failed JsonPath extraction return `null` instead of throwing an exception.

## Quick reference

| Method | Returns | Purpose |
|---|---|---|
| `.withVar(String key, Object value)` | `MoxCaller` | Add one call-scoped variable override. |
| `.withVars(Map<String, Object> values)` | `MoxCaller` | Add multiple call-scoped variable overrides. |
| `.withAuth(Authentication auth)` | `MoxCaller` | Set authentication for this call. |
| `.expect(Object status)` | `MoxCaller` | Override the expected HTTP status. |
| `.expect().status(Object status)` | `ExpectBuilder` | Set a status override in the expectation builder. |
| `.and()` | `MoxCaller` | Return from the expectation builder to the configured caller. |
| `.verbose(boolean enabled)` | `MoxCaller` | Enable or disable detailed request and response output. |
| `.allowFailure(boolean allowed)` | `MoxCaller` | Allow execution or expectation failures without failing the test. |
| `.withJsonPathLax(boolean enabled)` | `MoxCaller` | Make failed JsonPath extractions return `null`. |
| `.call(String moxtureName)` | `Moxter.MoxtureResult` | Execute the moxture and return its result. |

The expectation builder also provides `.call(String moxtureName)` as a shortcut, returning a `Moxter.MoxtureResult` without first calling `.and()`.

## Immutability

A `MoxCaller` is immutable. A call-option method such as `.withVar(...)` returns a new `MoxCaller`. It does not modify the caller you invoked it on.

If you discard the returned caller, the option is not applied:

```java
Moxter.MoxCaller caller = mx.caller();

caller.withVar("p.name", "Doris"); // Returnes a new caller (which gets discarded)
caller.call("create_pet");         // !! Uses the original caller, not the one 
                                   // just above !!
                                   // So the pet name set above will be unknown.
```

Keep and use the returned caller instead:

```java
Moxter.MoxCaller caller = mx.caller()
                            .withVar("p.name", "Doris");
caller.call("create_pet");  // The pet name set above will be known.
```

Because each configuration method returns a new caller, you can also reuse a base caller for separate configurations:

```java
Moxter.MoxCaller base = mx.caller();

Moxter.MoxCaller dorisCall = base.withVar("p.name", "Doris");
Moxter.MoxCaller rexCall = base.withVar("p.name", "Rex");

dorisCall.call("create_pet");
rexCall.call("create_pet");
```

This is what is referred to as "sticky callers"  (TODO see link to page)

Since the base caller remains unchanged, you can also derive separate configurations from it without one call's options affecting another.