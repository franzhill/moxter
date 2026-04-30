# Providing Variables

When requiring a moxture for a test, you will often find yourself needing to either provide new runtime values or override existing moxture defaults. 

The `MoxCaller` provides a [fluent API](https://en.wikipedia.org/wiki/Fluent_interface) that lets you inject **call-scoped variables** using `.withVar()` and `.withVars()`.

## Syntax & Usage

You can inject a single variable or an entire map of variables into the caller before triggering the request:

```java
// 1. Injecting a single variable
mx.caller()
  .withVar("petId", 4321L)
  .call("update_pet");

// 2. Injecting multiple variables at once
Map<String, Object> baseVars = Map.of(
    "petName", "Rex",
    "status", "AVAILABLE",
    "ownerId", 998
);

mx.caller()
  .withVars(baseVars)
  .call("create_pet");

// 3. Multiple calls
mx.caller()
  .withVars(baseVars)
  .withVar("petId", 4321L)
  .withVar("petName", "Rex")
  .call("create_pet");
```

Once injected, these variables are immediately available for placeholder interpolation (e.g., `${petName}` or `${petId}`) anywhere inside your YAML moxture definition.

If you define the same variable key multiple times within the same chain, **the last value provided wins**. 

The standard map-put behavior can also be used to load a large map of default scenario variables using `.withVars()`, and then immediately follow it with a `.withVar()` to surgically overwrite just one specific key for that execution:

```java
mx.caller()
  .withVars(baseVars)                
  .withVar("status", "UNAVAILABLE")  // Overwrites the "status" from baseVars
  .call("create_pet");
```

## Scope & Ephemeral State

Variables injected via the fluent API are placed in the **Call Scope**. This scope has the absolute highest priority, meaning your injected variables will temporarily shadow any YAML-defined or Global variables that share the same name.

For the complete rules on how Moxter merges scopes, see the [Variables chapter](../../../site/user_guide/variables/variables.md).

These overrides are strictly **ephemeral**. Because the `MoxCaller` is immutable, any variables you inject are discarded immediately after the `.call()` returns. This guarantees you do not accidentally pollute the global test state for subsequent steps.

*(Note: If your moxture contains a `save:` block, the extracted response values are always written to the Global Scope, never to this temporary Call Scope).*

## Scope and Precedence

When you provide variables via the fluent API, you are placing them into the **Call Scope**. 

Before executing a moxture, ***Moxter*** aggregates variables from three distinct layers to create a single "Source of Truth" for that specific execution. **The Call Scope has the absolute highest priority**. 

If there is a naming collision (i.e., the same variable name exists in multiple places), the priority is:

1. **Call Scope** (Java overrides passed via `.withVar()`) -> *Always wins*
2. **Moxture Scope** (Variables defined directly in the YAML `vars:` block)
3. **Global Scope** (Persistent variables stored in the engine's memory)

This design allows you to define sensible default variables in your YAML file or Global Scope, and surgically override them for just one test step using `.withVar()`.

## Ephemeral State

Variables injected via `.withVar()` are strictly **ephemeral**. They exist only for the duration of that specific `.call()`. 

* **Reads:** When the engine resolves a template (like an endpoint URL or a JSON body), it checks your call-scoped variables first. 
* **Writes (The `save:` block):** If the moxture specifies a `save:` block to extract data from the network response (like capturing a newly generated token), those extracted values are **always written to the Global Scope**, never to the Call Scope. 
* **Groups:** If you execute a Group Moxture, the call-scoped variables you provided are passed down recursively to every child moxture in that group.

Because the `MoxCaller` is immutable, temporary overrides provided via `.withVar()` are discarded immediately after the call returns. This guarantees you do not accidentally pollute the global test state for subsequent steps.