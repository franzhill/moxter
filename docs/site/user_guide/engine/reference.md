# Moxter engine building reference

The `Moxter.builder()` is used to configure the ***Moxter*** execution engine. Settings defined here are "sticky" and apply to every moxture called by the resulting engine instance.


## .mockMvc()
- **Type**: MockMvc 
- **Required**: yes if executing HTTP moxtures
- **Applicable**: HTTP moxtures

The *Spring MockMvc* instance used to dispatch HTTP requests natively within the application context.

## .objectMapper()
- **Type**: ObjectMapper 
- **Required**: yes
- **Applicable**: All moxtures

Used for JSON/YAML serialization and JsonPath evaluations. Using the application's existing bean ensures consistent data formatting and property naming strategies (e.g., snake_case vs camelCase).

## .basePath()
- **Type**: String 
- **Required**: no
- **Default**: `moxtures`
- **Applicable**: All moxtures

Defines the moxture root folder (relative to your test resources folder). For example; If your YAMLs are located at `src/test/resources/myPetProject/moxtures`, then the base path would be `myPetProject/moxtures`.

## .withCsrf()
- **Type**: N/A (Method call)
- **Required**: no
- **Applicable**: HTTP moxtures

Enables automatic CSRF token inclusion for all HTTP requests. The engine applies the Spring Security csrf() request post-processor during execution via *MockMvc*, satisfying security requirements for state-changing operations (POST, PUT, DELETE).

## .header()
- **Type**: (String name, String value)
- **Required**: no
- **Applicable**: HTTP moxtures

Adds a permanent HTTP header to every HTTP request. This is useful for static authentication or custom headers required by your gateway/proxy.

## .withVar()
- **Type**: (String name, String value)
- **Required**: no
- **Applicable**: All moxtures

Injects a variable into the global engine context. These values are available for interpolation in any moxture called by this engine using the `${variable}` syntax.