
# Moxture reference

## Single moxtures

### extends
- **Alias**: basedOn
- **Type**: String
- **Optional**: yes
- **Default value**: N/A
- **Supports variable interpolation**: no

Points to another ***moxture*** name to inherit its configuration. The engine performs a merge, where the inheriting (child) ***moxture*** takes precedence:
- scalars (e.g. `endpoint`, `method`...) are overwritten
- maps (e.g. `headers`) are shallow-merged (high level keys are overwritten),
- `body` is recursilvely deep-merged: nested objects are merged additively, allowing for surgical overrides of specific fields within a complex JSON structure.

Inheritance is resolved during the loading phase (prior variable interpolation), so the parent name must be a literal string.

See chapter [Extending moxtures](user_guide/extending_moxtures.md).

### basedOn
- **Alias**: extends


### options.verbose
- **Optional**: true
- **Default value**: false

TODO explanation

### options.allowFailure
- **Optional**: true
- **Default value**: false

TODO explanation




## Group moxtures