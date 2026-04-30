# Extending

TODO

Single Chained Inheritance: Chained inheritance is fully supported to any depth (e.g., Moxture C extends B, which extends A). However, a moxture can only have one direct parent. You can use either the basedOn: or extends: keyword in your YAML definition.

Merge Semantics: When a child extends a parent, maps (like headers and vars) are shallow-merged, with the child's values taking precedence. However, lists and blocks like save and moxtures are replaced entirely by the child, not merged. JSON payloads are deep-merged.

Protocol Lock: A child moxture is not allowed to override the protocol defined by its parent. Attempting to do so will result in an immediate test failure.

Circular Dependencies: If the engine detects a circular inheritance loop during the linking phase (e.g., A relies on B, which relies on A), it tracks the exact resolution stack and immediately throws an IllegalStateException to safely crash the test.


Once the file is found, the engine evaluates the basedOn property to resolve any inheritance. This phase is lazy-loaded—it only links the moxtures strictly required for your current test, preventing initialization slowdowns and ignoring broken "zombie" YAML files elsewhere in your project.

If your moxture extends a parent template, Moxter computes the final specification by merging the child's overrides into the parent's definition. This includes a deep partial merge on JSON payloads, allowing a child to inherit a large JSON body and selectively overwrite just a few nested fields.