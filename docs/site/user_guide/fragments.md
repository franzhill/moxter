<div class="moxter-userguide-title" markdown="1">
# ![](../../img/moxter_userguide.png) Reuse YAML fragments
</div>



## Use case

Imagine finding yourself in the situation where several requests require sharing the same parameters or configuration:

```yaml
moxtures:
  - name: audit_list_pets
    endpoint: /api/pets
    query:
      clinicId: north-clinic        #  \
      auditID: Nov2026              #   |  Needs to be the same
      locale: en-GB                 #   |  
      reportFormat: pdf             #  / 
  - name: audit_list_visits
    endpoint: /api/visits           #             ↕
    query:
      clinicId: north-clinic        #  \
      auditID: Nov2026              #   |  Needs to be the same
      locale: en-GB                 #   |  
      reportFormat: pdf             #  / 
      ignoreIfOver: 1year

```

The usual approach would be to just copy and paste the shared bits of settings around. As with any copy-paste, this works until one of those bits changes; then every copy needs updating, and a missed update will make the tests all wrong.

**Fragment reuse** lets you define a YAML fragement once and re-use wherever needed. It is useful when several requests need the same settings. 
To reuse a whole moxture rather than a few settings, use [`extends` or `basedOn`](./extending_moxtures.md).

- **YAML's native approach:** Use anchors (`&`), aliases (`*`), and the merge key (`<<`). Moxter reads YAML through Jackson's YAML dependency, which uses the SnakeYAML parser, and enables merge-key processing automatically when the runtime version supports it.
- **Moxter's alternative:** Depending on the actual version of the YAML reader brought in, the merge keys feature might not be supported. In this case, ***Moxter*** provides the `__template__` directive as an alternative.

!!! note "Why the native approach might not be available"
    To read YAML files such as `moxtures.yaml`, ***Moxter*** declares a dependency on Jackson's `jackson-dataformat-yaml` module in its `pom.xml`. That module brings in *SnakeYAML*, the the YAML parser. SnakeYAML is a runtime dependency, not a separate plugin.

    The `<<` merge key dates back to YAML 1.1 and is not part of YAML 1.2's core. SnakeYAML 2.0 introduced the option to enable it, and earlier versions do not expose that option. So depending on the actual SnakeYAML parser version brought in by Maven's dependency resolution, the feature might or might not be available.

    The SnakeYAML version Maven resolves depends on the dependency management of your application (with ***Moxter*** as a test dependency). Your application may well override the version brought in by Jackson. If the resolved version does not provide the merge-processing option and you can change the Maven dependencies, set `org.yaml:snakeyaml` to a version compatible with Jackson and your framework. Otherwise, use ***Moxter***'s `__template__` alternative which does not rely on merge-key processing.


## YAML anchors and merge keys (if available)

YAML lets you give a block a name with `&` ('anchor') and reuse it with `*`. The `<<` merge key places the named block into another block:


```yaml
.templates:
  template_1: &audit_params    # anchor ('pointer') to this bit of YAML.
    clinicId: north-clinic
    auditID: Nov2026
    locale: en-GB
    reportFormat: pdf
  template_2: &other_anchor
    ...

moxtures:
  - name: audit_list_pets
    endpoint: /api/pets
    query:
      <<: *audit_params       # reference the anchor
  - name: audit_list_visits
    endpoint: /api/visits
    query:
      <<: *audit_params
      ignoreIfOver: 1year     # additional non-shared param
```

This results in the following YAML, before ***Moxter*** processes it:

```yaml
.templates:
  template_1:
    clinicId: north-clinic
    auditID: Nov2026
    locale: en-GB
    reportFormat: pdf

moxtures:
  - name: audit_list_pets
    endpoint: /api/pets
    query:
      clinicId: north-clinic
      auditID: Nov2026
      locale: en-GB
      reportFormat: pdf
  - name: audit_list_visits
    endpoint: /api/visits
    query:
      clinicId: north-clinic
      auditID: Nov2026
      locale: en-GB
      reportFormat: pdf
      ignoreIfOver: 1year
```


Both requests now share the same block of query parameters.

Anchors, aliases, and `<<` are pure YAML features handled by the YAML parser, not by Moxter. They are scoped to the current YAML file: an anchor in one `moxtures.yaml` cannot be referenced from another file, even if both files are in the same classpath hierarchy.

!!! note
    An anchor can, in theory, be placed on any YAML node. 
    For structure, ***Moxter*** defines `.templates` as a root-level YAML node designed to store the template YAML nodes.


## `__template__` alternative

Define a named block in the root-level `.templates` section and refer to it with `__template__`:

```yaml
.templates:
  audit_params:
    clinicId: north-clinic
    auditID: Nov2026
    locale: en-GB
    reportFormat: pdf

moxtures:
  - name: audit_list_pets
    endpoint: /api/pets
    query:
      __template__: audit_params
  - name: audit_list_visits
    endpoint: /api/visits
    query:
      __template__: audit_params
      ignoreIfOver: 1year
```

Settings written alongside `__template__` take precedence over the template. `__template__` also accepts a list of template names or an inline block:

```yaml
headers:
  __template__:
    Accept: application/json
    X-Client: petclinic-tests
```

Think of `__template__` as a small preprocessor directive, similar in spirit to `#define` or `#include` in C: Moxter inserts the reusable block where it is referenced before processing the moxture. You can use it in nested sections such as headers, variables, or request bodies. Like anchors and aliases, named templates are local to the YAML file that defines `.templates`; they cannot reference a template in another moxture file or a parent classpath directory. Use [`extends` or `basedOn`](./extending_moxtures.md) to reuse a complete moxture across files.

Use [`extends` or `basedOn`](./extending_moxtures.md) when reusing and specializing a complete named moxture, rather than a fragment.
