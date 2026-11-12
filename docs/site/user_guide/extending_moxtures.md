<div class="moxter-userguide-title" markdown="1">
# ![](../../img/moxter_userguide.png) Extending moxtures
</div>


Moxter offers two related ways to reuse and specialize moxtures:

- **Classpath organization** places shared definitions higher in the moxture file hierarchy and more specific definitions closer to the tests that need them.
- **Inheritance** uses `extends` or `basedOn` to derive one named moxture from another.

The classpath hierarchy provides the structure for locating definitions. Inheritance connects definitions across that structure when a child explicitly names its parent.

## Inherit from a parent

Use `extends` (or its equivalent `basedOn`) to name one direct parent. A moxture can have one direct parent.

Start with a parent and its extension in the same file:

```yaml
# src/test/resources/moxtures/moxtures.yaml
moxtures:
  - name: create_pet
    method: POST
    endpoint: /api/pets
    body:
      name: "${petName}"
  - name: create_pet_dog
    extends: create_pet
    body:
      species: dog
  - name: create_pet_cat
    extends: create_pet
    body:
      species: cat
```

The resulting dog and cat moxtures are:

```yaml
moxtures:
  - name: create_pet_dog
    method: POST
    endpoint: /api/pets
    body:
      name: "${petName}"
      species: dog
  - name: create_pet_cat
    method: POST
    endpoint: /api/pets
    body:
      name: "${petName}"
      species: cat
```

Use the two parent fields as alternatives, not together:

```yaml
extends: create_pet
# Or: basedOn: create_pet
```

## Parent lookup in the classpath hierarchy

The parent does not have to be in the same file. Moxter looks for it starting in the directory containing the child definition, then searches ancestor directories in the test's classpath hierarchy. A test's Java package and optional class-specific moxture directory mirror each other:

For this example, keep `create_pet` in the root file and put `create_pet_cat` in the test-specific file:

```text
src/test/
├── java/
│   └── com/petclinic/
│       └── CatCreationTest.java
└── resources/moxtures/
    ├── moxtures.yaml
    └── com/petclinic/
        └── CatCreationTest/
            └── moxtures.yaml
```

The matching test class stub shows the package and test class name:

```java
package com.petclinic;

class CatCreationTest {
    void createsCat() {
        // Test body omitted
    }
}
```

The root `moxtures.yaml` contains the generic `create_pet` parent. The class-specific file contains its cat extension:

```yaml
# src/test/resources/moxtures/com/petclinic/CatCreationTest/moxtures.yaml
moxtures:
  - name: create_pet_cat
    extends: create_pet
    body:
      species: cat
```

Moxter searches upward from that class-specific file and finds `create_pet` in the root file. More generally, shared moxtures can live at the root, with package- or test-specific definitions placed closer to the tests that use them. A lower-level definition can shadow a same-named definition without inheriting from it; inheritance requires a distinct child name and an explicit parent. See [YAML moxture files](./moxture_files.md) for the directory layout and lookup rules.

## Chain extensions

A moxture can extend a child that already extends a parent. Here, `create_pet_cat_siamese` (A) extends `create_pet_cat` (B), which extends `create_pet` (C):

```yaml
moxtures:
  - name: create_pet                 # C
    method: POST
    endpoint: /api/pets
    body:
      name: "${petName}"
  - name: create_pet_cat             # B
    extends: create_pet
    body:
      species: cat
  - name: create_pet_cat_siamese     # A
    extends: create_pet_cat
    body:
      breed: Siamese
```

The resulting `create_pet_cat_siamese` moxture has the values inherited through both parents:

```yaml
moxtures:
  - name: create_pet_cat_siamese
    method: POST
    endpoint: /api/pets
    body:
      name: "${petName}"
      species: cat
      breed: Siamese
```

## What is inherited and how it merges

If a child omits a setting, it generally inherits the parent's value. When a child supplies the setting, the following rules apply:

| Setting | Child behavior |
|---|---|
| `method`, `endpoint` | The child value replaces the parent value. |
| `headers`, `query`, `vars` | Maps are shallow-merged by key; child values win for matching keys. |
| `options.allowFailure`, `options.verbose` | Options are merged field by field; explicitly set child values win. |
| `body` | JSON objects merge recursively. Arrays merge by index, with extra child items appended; scalar values or values of different types are replaced by the child. |
| `expect` | A child `expect` block replaces the parent block as a whole. |
| `save`, `moxtures`, `multipart` | A child block replaces the corresponding parent block as a whole. |
| `protocol` | The parent's protocol is retained. A child cannot change it; a conflicting child definition fails before the request is sent. |

For example, adding `body.breed` in `create_pet_cat_siamese` does not discard the inherited `body.name` or `body.species`. By contrast, defining a child `save` block replaces the parent's `save` block rather than adding entries to it.

The parent must be discoverable from the child. If it is missing, Moxter cannot resolve the child. Keep parent names distinct from child names so the lookup resolves to the intended definition.

An inheritance chain must not contain a cycle. For example, if `A` extends `B` and `B` extends `A`, Moxter rejects the chain and reports the cycle, such as `A -> B -> A`.

## On-demand resolution

Moxter resolves a moxture and its inherited parents when a test needs that moxture; it does not resolve every definition in the project up front. A broken moxture file in an unrelated package outside the test's classpath hierarchy does not prevent that test from running. Files on the relevant lookup path must still be valid.
