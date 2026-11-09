
<div class="moxter-userguide-title" markdown="1">
# ![](../img/moxter_reference.png) Variables Reference
</div>


## .vars()
- **Called on**: a `Moxter` engine object.
- **Return**: a `MoxVars` object

The entry point for managing and reading variables in the Moxter engine's global scope.



### .view()
- **Called on**: a `MoxVars` object
- **Return**: `Map<String, Object>`


Returns a live, unmodifiable map of the engine-global variables. It does not include moxture defaults or call-scoped overrides.


Example: 
```Java
Moxter mx = Moxter.forTestClass(getClass())...; // Moxter engine
Map<String, Object> varContext = mx.vars().view();
Object myVar = varContext.get("my_variable");
log.debug("Current variable context:\n{}", mapper.writeValueAsString(varContext));
```

### .clear()
- **Called on**: a `MoxVars` object
- **Return**: `void`

Wipes the engine variable context.  
An example of use is to call this in a `@AfterEach` method to ensure a clean state for the next test.


### .put(String key, Object value)
- **Called on**: a `MoxVars` object
- **Return**: `Object`

Adds or overwrites a variable in the Global Scope. Returns the previous value, or `null` if there was none. If the key already exists, strict variable handling makes the overwrite throw; otherwise, replacing a non-null value logs a warning.

Example:

```Java
mx.vars().put("api_version", "v2");
```


### .putIfAbsent(String key, Object value)
- **Called on**: a `MoxVars` object
- **Return**: `boolean`

Adds a variable only if that key is not already present. Returns `true` if the value was added and `false` if the key already exists.

Example:

```Java
boolean added = mx.vars().putIfAbsent("user", "A");
```

### .read(String varName)
- **Called on**: a `MoxVars` object
- **Return**: a `VarReader` object

Returns a reader for the given variable. Throws an `IllegalStateException` if the variable is missing.

Example:

```Java
mx.vars().read("pet_id").asLong();
```
See the [variable usage guide](../../user_guide/variables/variables.md).

#### .isNull()
- **Called on**: a `VarReader` object
- **Return**: `boolean`

Returns true if the variable's stored value is null. `read()` throws if the variable is missing.

#### .asObject()
- **Called on**: a `VarReader` object
- **Return**: `Object`

Returns the raw value as-is. For an existing variable, this is equivalent to `mx.vars().get(name)`. Unlike `read(name)`, `get(name)` returns `null` if the variable is missing.

#### .asType(Class type)
- **Called on**: a `VarReader` object
- **Return**: an object of the specified type

Performs a strict type cast to the specified class. The stored value must already be an instance of that type; this method does not convert values or deserialize JSON.

Example:

```Java
Long ownerId = mx.vars().read("owner_id").asType(Long.class);
```

#### .asString()
- **Called on**: a `VarReader` object
- **Return**: `String`

Returns the value as a String.

#### .asLong()
- **Called on**: a `VarReader` object
- **Return**: `Long`

Converts a numeric value or numeric string to a `Long`. Returns `null` for a null value and throws if the value cannot be converted.

#### .asInstant()
- **Called on**: a `VarReader` object
- **Return**: `java.time.Instant`

Parses an ISO-8601 date-time string into an `Instant`.

#### .asInstant(DateTimeFormatter formatter)
- **Called on**: a `VarReader` object
- **Return**: `java.time.Instant`

Parses a String variable using the provided custom DateTimeFormatter.

#### .asList(Class elementType)
- **Called on**: a `VarReader` object
- **Return**: `List<T>`

Converts a stored `List` into a typed list. Numeric elements are converted to the requested numeric type when supported.

Example:

```Java
List<Long> ids = mx.vars().read("result_ids").asList(Long.class);
```

#### .asJsonNode()
- **Called on**: a `VarReader` object
- **Return**: `JsonNode`

Parses a JSON string value into a Jackson `JsonNode`. This is particularly useful for logging complex objects or verifying the exact JSON structure being passed between moxtures.

Example:

```Java
// Parse a saved JSON string into a JsonNode
JsonNode savedPet = mx.vars().read("saved_pet").asJsonNode();
System.out.println("Saved:\n" + savedPet.toPrettyString());
```

