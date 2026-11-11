<div class="moxter-userguide-title" markdown="1">
# ![](../../img/moxter_userguide.png) Expectations (Assertions)
</div>

Verifying that your application behaves as expected is admittedly the central job of a testing framework. ***Moxter*** provides three complementary ways to express and check expectations.

- declare expectations in the YAML moxture, 
- chain assertions directly to a moxture call from a `MoxCaller`,
- or extract values from the result of a moxture call in your *JUnit* test and perform assertions using your usual test framework (*JUnit*, *AssertJ* or other).

YAML expectations and `MoxCaller` assertions add up on the same moxture call: all need to pass for the test to pass*.

Choose the approach (or any combination of) that best fits where you want the expectation to live and how much control your test needs.

!!! note "Note on terminology"
    An *expectation* describes the result a moxture is expected to produce whereas an *assertion* is the check that verifies the actual result against that expectation. In practice, the terms can be used interchangeably.

<small>*Unless `options.allowFailure` is set to true.</small>

## Declare expectations in YAML

YAML expectations live with the moxture and are checked when it runs.
They are intended for straightforward, declarative checks; use Java when an assertion needs custom logic or computation.

### Check the HTTP status

Use `expect.status` to check an exact status code, a list of acceptable codes, or a status-class wildcard such as `"4xx"`. If `status` is omitted, Moxter does not check the status code.

```yaml
expect:
  status: 201
```

### Check the response body

Use `expect.body.match` to compare the response body with an expected structure. Matching is partial by default; set `mode: full` when the entire structure must match.

```yaml
expect:
  body:
    match:
      content:
        name: Snowy
        category:
          name: dogs
```

For equality checks at specific JsonPath expressions, use `expect.body.assert`:

```yaml
expect:
  body:
    assert:
      "$.name": Snowy
      "$.category.name": dogs
```

See the [moxture reference](../../reference/moxture.md) for all supported options, including ignored paths and variable interpolation.

### Check a STOMP broadcast

Use `expect.stomp` to verify that a broadcast is sent to the expected topic:

```yaml
expect:
  stomp:
    topic: /topic/orders
    wait: 2s
    type: String
```

Moxter uses MockWebs for this check. MockWebs invokes the mapped controller logic directly; it does not open a real WebSocket connection or exercise the STOMP network layer. See the [MockWebs guide](../mockwebs.md).

## Chain Moxter's fluent assertions to a call

The result of a call provides fluent assertions for response values and variables saved by the moxture. Use `assertBody` with a JsonPath, or `assertVar` with a saved variable name:

```java
mx.call("get_pet")
  .assertBody("$.id").isNotNull().and()
  .assertBody("$.name").asString().isEqualTo("Snowy");
```

Moxter's fluent API provides a focused set of assertions; it does not expose the full AssertJ API. `assertBody` and `assertVar` support object assertions such as `isEqualTo`, `isNull`, and `isNotNull`. For type-specific checks, use `asString()`, `asLong()`, `asBoolean()`, or `asList()`, each with the assertion methods Moxter provides for that type. The type-specific assertions can also be chained; call `.and()` to return to the result and check another value. For checks not offered by this fluent API, extract the result and use JUnit or AssertJ directly.

The call-scoped status assertion: `MoxCaller.expect(status)` actually lets us override the the YAML expectation `expect.status` "on the fly".

These are Moxter's AssertJ-style assertions. If one fails, Moxter includes the moxture and response path in the diagnostic context.

 Full [MoxCaller reference](../reference/moxcaller.md).


## Extract the result and assert with JUnit or AssertJ

If you need custom test logic, retrieve values from the call result and use your usual assertion library:

```java
Moxter.MoxtureResult result = mx.call("get_pet");

assertEquals(200, result.getStatus());
assertEquals("Snowy", result.returnJPath("$.name"));
```

`MoxtureResult` also provides access to the parsed body, raw body, and full response envelope. Retrieving a value does not itself assert anything; the JUnit or AssertJ assertion you apply to it determines whether the test passes.



## What happens when an assertion fails

YAML execution or expectation failures fail the test by default. To log the failure as a warning and continue, set `options.allowFailure: true` in the moxture.

Moxter's fluent Java assertions report assertion failures with response context. Assertions made with JUnit or AssertJ behave according to the test framework.

## Quick reference: choose the right tool

| Approach | Use it when |
|---|---|
| YAML expectations | You need a straightforward, declarative check, such as a status code, response structure, JsonPath value, or STOMP broadcast. |
| Moxter fluent assertions | You want a concise check tied to a call or saved variable, and Moxter offers the assertion you need. |
| JUnit or AssertJ on extracted results | You need custom test logic or want to use your usual test APIs. |