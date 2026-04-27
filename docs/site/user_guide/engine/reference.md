# Moxter Engine building reference

The `Moxter.builder()` is used to configure the ***Moxter*** execution engine. Methods presented below are meant to be chained onto it (`Moxter.builder().method1().method2()...`). The configurations they define are "sticky" and apply to every moxture called by the resulting engine instance.


## .mockMvc()
- **Argument Type**: `MockMvc`
- **Required**: yes if executing HTTP moxtures
- **Applicable**: HTTP moxtures

The *Spring MockMvc* instance used to dispatch HTTP requests natively within the application context. This is the core engine for all REST-based testing in ***Moxter***.


## .mockWebs()
- **Argument Type**: `MockWebs`
- **Required**: yes if executing STOMP moxtures
- **Applicable**: STOMP moxtures

Integrates the engine with an instance of the **MockWebs** library (provided in the ***Moxter*** jar). This instance will be responsible for managing the WebSocket interactions defined by your moxtures, and performing assertions on outbound messages.

See chapter [Mockwebs](../mockwebs.md).


## .authentication()
- **Argument Type**: `org.springframework.security.core.Authentication`
- **Required**: yes if executing STOMP moxtures; optional for HTTP
- **Applicable**: HTTP and STOMP moxtures

Sets a default *Spring Security Authentication* object for the engine. All requests will be executed within this security context by default. This is equivalent to applying `.with(authentication(...))` to every *MockMvc* call. . For STOMP, it ensures the socket handshake and subsequent messages are associated with the correct user principal.


Beyond the standard `UsernamePasswordAuthenticationToken` used in the setup chapter, here are other ways to generate an `Authentication` object to pass to this method, depending on how your *Spring Security Filter* is set up.

```Java
  /**
   * If you don't need credentials (password) and just want a lightweight 
   * object specifically designed for unit tests, Spring provides this utility.
   */
  private Authentication getTestAuthentication_light() {
      return new TestingAuthenticationToken("admin", "principal", "ROLE_ADMIN");
  }

  /**
   * If your security logic is very complex and you only need to satisfy the 
   * method signature without actually checking roles, you can mock the 
   * interface.
   */
  private Authentication getTestAuthentication_mocked() {
      Authentication auth = Mockito.mock(Authentication.class);
      Mockito.when(auth.getName()).thenReturn("mockUser");
      Mockito.when(auth.isAuthenticated()).thenReturn(true);
      return auth;
  }
```


## .objectMapper()
- **Argument Type**: `ObjectMapper` 
- **Required**: yes
- **Applicable**: all moxtures

Used for JSON/YAML serialization and JsonPath evaluations. Using the application's existing bean (typically the one configured by *Spring Boot*) ensures consistent data formatting and property naming strategies (e.g., snake_case vs camelCase).


## .basePath()
- **Argument Type**: `String` 
- **Required**: no
- **Default**: `moxtures`
- **Applicable**: all moxtures

Defines the Moxture Root Folder (relative to your test resources folder). For example; If your YAMLs are located at `src/test/resources/myPetProject/moxtures`, then specify the the base path as `myPetProject/moxtures`.  
Use this method only if you did not instantiate the builder with `.forTestClass(getClass())`.
See chapter [The Moxture File](../moxture/moxture_file.md) for more information on the Moxture Root Folder.


## .withCsrf()
- **Argument Type**: N/A (Method call)
- **Required**: no
- **Applicable**: HTTP moxtures

Enables automatic CSRF token inclusion for all HTTP requests. The engine applies the *Spring Security* csrf() request post-processor during execution via *MockMvc*, satisfying security requirements for state-changing operations (POST, PUT, DELETE) without requiring manual token management.


## .header()
- **Argument Type**: (`String` name, `String` value)
- **Required**: no
- **Applicable**: HTTP moxtures

Adds a permanent HTTP header to every HTTP request dispatched by the engine. This is useful for static authentication or custom headers required by your gateway/proxy.


## .withVars()
- **Argument Type**: `Map<String, Object>`
- **Required**: no
- **Applicable**: all moxtures

Injects a map of variables into the **Global Scope** of the engine.

Example:

```Java
mx = Moxter.builder()
        .mockMvc(mockMvc)
        .withVars(Map.of(
            "api_version", "v1",
            "default_owner_id", 1
        ))
        .build();
```
 See chapter [Variables](../variables/variables.md) for further information.
