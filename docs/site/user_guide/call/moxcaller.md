# The MoxCaller

TODO improve
The Moxcaller is like a "buffer" zone between the Moxter Engine and your moexture call execution.
It receives the configuration (vars, expectations etc.)


## Careful! Moxter callers are immutable

***Moxter*** callers are typically immutable. The .withVar() method returns a new instance of the caller with that variable added. (TODO other methods too?)

You need to reassign it, if you want to keep using the same caller!

This design choice was made to avoid the following scenario, had we not:

```Java
callerA = ...// instatiation

// We need a specific var for that specific call 
callerA.withVar(...).call(...) 
...
// somwehere down the line we re-use
callerA.call(...)   // callerA has the variable that we set earlier on just for that specific call. That's possibly NOT a behaviour we're having in mind.
```

## Tips on using the callers

Use the callers to "bake" a call configuration. 
E.g. In a scenario where you would simulate several users operating, use one caller for each.
E.g. in a scenario where a user operates on several resources (materialised by variables passed to moxtures) dedicate a tailored caller to each of these resource.

Have a look in the Cookbook section for recipes using the MoxCaller.