# __template__


## Multiple mixin support

You can define "Trait" templates and mix them into your calls like Lego bricks.

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
    endpoint: "/api/cke/update"
    vars:
      p.fieldName: "OVERRIDE_LOCAL" # This wins over cke_vars because of putIfAbsent
```

Think if this as a low-level pre-compiler copy-paste.
This will result in the following moxture

```YAML
  - name: cke.update_field

    # Injection of __template__: adminAuth 
    headers:
      Authorization: "Bearer {{admin_token}}"
    
    # Injection of __template__: ckeVars
    p.fieldName: "commentCommercial"
    p.userLockId: "init-lock-id"
     
    method: POST
    endpoint: "/api/cke/update"
    vars:
      p.fieldName: "OVERRIDE_LOCAL" # This wins over cke_vars because of putIfAbsent
```

Naturally the template snippets must be cnceived and inserted in such a way that the resulting moxture conforms with the YAML schema of the moxture.


templates can also be referenced with the "<<" object merge key instead of __template__
(this requires a plugin/extension in YAML processing I think TODO)
