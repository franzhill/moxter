<div class="moxter-userguide-title" markdown="1">
# ![](../../../img/moxter_userguide.png) Authentication & CSRF
</div>


## The Idea

***Moxter*** uses *MockMvc* under the hood for HTTP request calls. *MockMVC*  runs the request through the tested application's Spring Security and Spring MVC. Spring Security provides a way for MockMvc to put an `Authentication` (aka user) in the request's `SecurityContext`, so Spring Security can process the request as that user and apply the user's permissions.  ``MoxCaller`'s .withAuth(authentication)` lets us pass an ad hoc `Authentication` through *MockMvc* to the tested Spring application.


## Simulating a user

Create an `Authentication` object in your test representing the user you want the request to be handled as. It will tell Spring Security which user and permissions to use when processing a request. This is a test identity: it does not create an application account or perform a login.

For example, these test identities have different principals and authorities:

```java
import org.springframework.security.authentication.TestingAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;

Authentication clinicIdentity = new TestingAuthenticationToken(
    "clinic-user", null, "ROLE_CLINIC");
Authentication refugeIdentity = new TestingAuthenticationToken(
    "refuge-user", null, "ROLE_REFUGE");

SecurityContextHolder.getContext().setAuthentication(clinicIdentity);
```

Here, `clinicIdentity` represents `clinic-user` with `ROLE_CLINIC`, and `refugeIdentity` represents `refuge-user` with `ROLE_REFUGE`. The last line sets `clinicIdentity` as the current identity, used by default.

To run a particular call as `refuge-user`, pass `refugeIdentity` to `.withAuth(...)`.

## Set a default identity

By default, ***Moxter*** uses the current Spring Security `SecurityContext` when it executes each request. To use one fixed identity for all requests from an engine, configure it when building the engine:

```java
Moxter mx = Moxter.forTestClass(PetTest.class)
    .mockMvc(mockMvc)
    .authentication(clinicIdentity)
    .build();
```

If the active identity can change during the test, provide an `Authentication` supplier instead. ***Moxter*** evaluates it for each request:

```java
Moxter mx = Moxter.forTestClass(PetTest.class)
    .mockMvc(mockMvc)
    .authenticationSupplier(authenticationSupplier)
    .build();
```

## Override the identity for one call

Use `withAuth` to execute one call as a different user:

```java
mx.caller()
  .withAuth(clinicIdentity)
  .call("create_pet");

mx.caller()
  .withAuth(refugeIdentity)
  .call("assign_owner");
```

The first call runs as `clinic-user`; the second runs as `refuge-user`. Each per-call identity takes precedence over the engine's configured identity and the current `SecurityContext`, without changing either for later calls. Calls with the same authentication name reuse that user's session; calls with different names use separate sessions.

## CSRF protection

CSRF protection helps prevent another website from tricking a user's browser into sending an unwanted request to an application where the user is signed in. Browsers automatically include sign-in information, such as cookies, with requests. Spring Security therefore checks for a CSRF token on requests that can change data; the token helps distinguish requests made through the application from forged requests.

Because HTTP `POST`, `PUT`, `PATCH`, and `DELETE` requests are commonly used to change data, ***Moxter*** automatically supplies a CSRF token for them. This lets your test focus on how the application handles the request without needing to fetch or add a token in the moxture YAML. Other HTTP methods do not receive a token automatically.
