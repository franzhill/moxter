
# CHANGELOG

## v0.9.1


### MockWebs: Mockito mock SimpMessagingTemplate reset before every Moxter call 

2026.05.04
Before each moxture call, the MockWebs underlying Mockito mock for the messaging template is reset.
This prevents "broadcast pollution" by ensuring that messages recorded in previous moxture calls do not interfere with the assertions of the current call.


### Multiple mixin support for YAML __template__ 

```YAML
.templates:
  ckeVars:
    p.fieldName: "commentCommercial"
    p.userLockId: "init-lock-id"
  
  adminAuth:
    headers:
      Authorization: "Bearer {{admin_token}}"

moxtures:
  - name: cke.update_field
    # MULTIPLE MIXINS: Injects auth headers AND cke variables
    __template__: adminAuth, ckeVars 
    method: POST
```

### MockWebs: authentication session in Spring session registry

2026.04.27 

MockWebs: when providing an authentication, publish a SessionConnectedEvent to "trick" the Spring context into saving the session in its session registry.

### Added support for extracting variables out of the broadcasted message
2026.04.17

```YAML
    expect:  # expect the return to be...
      broadcast:
        ...
        save:  # save a global context var for possible further assertion on Java side
          content: $   # saves the whole raw return in variable 'content'
          msg    : $.msg   # assumes the return is JSon under the hood, attempts to set the
                           # variable with the provided JSonPath, issues a warning otherwise
```