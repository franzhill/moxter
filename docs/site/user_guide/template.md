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