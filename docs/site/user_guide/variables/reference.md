
# Reference


## .vars()
- **Return**: VariableContext

The entry point for all variable manipulations. You must call this on the `Moxter` engine instance before any of the management or extraction methods listed below.


### .all()
- **Return**: `Map<String, Object>`

Returns a map containing every variable currently held by the current Moxter engine instance in the Global Scope.

Example: 
```Java
// Inspecting the state in a JUnit test
Map<String, Object> varContext = mx.vars().all();
Object myVar = varContext.get("my_variable");
log.debug("Current variable context:\n{}", mapper.writeValueAsString(varContext));
```

### .clear()
- **Return**: `void`

Wipes the engine variable context.  
An example of use is to call this in a `@AfterEach` method to ensure a clean state for the next test.


### .set(String name, Object value)
- **Return**: `void`

Injects or overwrites a single variable in the Global Scope.

Example:

```Java
mx.vars().set("api_version", "v2");
```

If a variable of that name already exists, it is overwritten by the new value.


### .set(Map<String, Object> variables)
- **Return**: `void`

Batch injection: merges the provided map into the Global Scope. Existing variables with matching names are overwritten, while other existing variables remain untouched.

Example:

```Java
mx.vars().set(Map.of("user", "A", "role", "ADMIN"));
```

### .read(String varName)
- **Return**: `VariableReader`

Initiates the type-safe, fluent extraction API on the given variable.

Example:

```Java
mx.vars().read("pet_id").asLong();
```


#### .isNull()
- **Return**: `boolean`

Returns true if the variable is missing from the Global Scope or is explicitly null.

#### .asObject()
- **Return**: `Object`

Returns the raw value as-is. Equivalent to `mx.vars().all().get(name)`.

#### .asType(Class type)
- **Return**: `T`

Maps the variable to the specified Java class using the engine's `ObjectMapper`. Use this for `Integer`, `Boolean`, or custom POJOs.

Example:

```Java
Integer count = mx.vars().read("item_count").asType(Integer.class);
Pet myPet = mx.vars().read("saved_pet").asType(Pet.class);
```

#### .asString()
- **Return**: `String`

Returns the value as a String.

#### .asLong()
- **Return**: `Long`

Converts and returns the variable as a Long. This is the safest way to retrieve IDs to avoid Integer vs Long mismatch errors.

#### .asInstant()
- **Return**: `java.time.Instant`

Parses the variable into an Instant (supports ISO-8601 strings or numeric Epoch milliseconds).

#### .asInstant(DateTimeFormatter formatter)
- **Return**: `java.time.Instant`

Parses a String variable using the provided custom DateTimeFormatter.

#### .asList(Class elementType)
- **Return**: `List<T>`

Maps a collection variable into a List of the specified elementType.

Example:

```Java
List<Long> ids = mx.vars().read("result_ids").asList(Long.class);
```

#### .asJson()
- **Return**: `String`

Serializes the variable's value back into its JSON string representation using the engine's `ObjectMapper`. This is particularly useful for logging complex objects or verifying the exact JSON structure being passed between moxtures.

Example:

```Java
// Get the raw JSON string of a saved pet object
String json = mx.vars().read("saved_pet").asJson();
System.out.println("Payload: " + json);
```







