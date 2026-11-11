<div class="moxter-userguide-title" markdown="1">
# ![](../../img/moxter_userguide.png) Moxter in a nutshell
</div>

A ***moxture*** is a declarative YAML blueprint for a tailored HTTP or STOMP request, with added capabilities. It can be called directly from a *JUnit* test or chained with other moxtures to form multi-step test scenarios.

These calls run in-process within your *Spring* application context: HTTP moxtures are dispatched to *MockMvc*, and STOMP moxtures to [*MockWebs*](../mockwebs.md).

Beyond describing standard request parameters, a ***moxture*** provides configuration for built-in logic such as: 

- **declarative assertions**: define what success looks like (status codes, full/partial/surgical JSON matching...) directly in the YAML.
- **variable extraction**: extract fields from a response and save them into variables for subsequent steps.
- **inheritance**: build new moxtures on top of existing ones to reduce repetition
- and more 

***Moxtures*** are ultimately called from within a *JUnit* test, with a `MoxCaller` derived from a Moxter Engine, in the following fashion:

```java


// Example: Creating a pet and asserting the returned name
Moxter mx = Moxter. ...             // Build the Moxter Engine
mx.caller()                         // The MoxCaller
  .withVar("p.name", "Rex")         // Inject variables into the YAML
  .call("create_pet")               // Trigger the call
  .assertBody("$.name")             // Verify the outcome
     .isEqualTo("Rex");
```

Many of the features provided by configuration in the YAML can also be defined or overridden at call time through the `MoxCaller`. That dual approach makes for a conveniant, versatile test writing exeperience.

<!-- All features regarding calling ***moxtures*** will be examined in detail in the [Calling moxtures](../calling_moxtures.md) chapter. -->