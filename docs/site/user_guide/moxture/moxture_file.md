# YAML moxture files

A **moxture file** is a YAML collection of `moxtures` i.e. descriptions of tailored API calls with added capabilities that can be executed directly from a *JUnit* test, or chained to form more elaborate business test scenarios.

Moxture files are named `moxtures.yaml`. You can start with a single file or create several to keep your test logic modular.

## The `moxtures.yaml` file structure

Moxtures are introduced at the top-level with the `moxtures:` key. This key acts as a container for all the individual `moxtures` defined within that file.

```yaml
moxtures:
  # This is a moxture (a single API call):
  - name: create_pet
    method: POST
    endpoint: /api/pets
    # ... (details)

  # This is another moxture:
  - name: assign_owner
    method: POST
    endpoint: /api/pets/{id}/owner
    # ... (details)

  # This is a group moxture:
  # (Executes the given moxtures as a sequence)
  - name: create_pet_and_assign_owner
    moxtures:
      - create_pet
      - assign_owner
...
```

> 💡 
> Note on groups: a moxture is considered a group moxture if it defines a list of moxtures. This is the 'configuration-first' way to build multi-step scenarios.



The example shows the basic shape; moxtures can also define options such as headers, a request body, and expectations.

## Where to place moxture files

By default, Moxter looks for moxtures on the test classpath under `moxtures/`. In a Maven project, the corresponding root is usually:

```text
src/test/resources/moxtures/
```

For a small project, put one `moxtures.yaml` file there. Its definitions can be used by any test class.

For a larger project, split definitions into files in subdirectories that mirror the tests' Java packages. Moxter also checks an optional subdirectory named after the test class. For example:

```text
src/test/resources/moxtures/
├── moxtures.yaml                 <-- [ROOT] Global moxtures, available to 
|                                      all tests. 
└── com/
    └── petclinic/
        ├── moxtures.yaml         <-- [PACKAGE] Available to all 
        |                             com.petclinic.*Test.java tests
        └── PetCreationTest/
            └── moxtures.yaml     <-- [CLASS] Only available to 
                                      PetCreationTest.java. Can shadow (redefine)
                                      moxtures from higher levels.
```


## Key benefits
- **Shadowing and precedence:** This hierarchy lets you keep a library of common moxtures in parent folders while allowing specific tests to shadow (redefine) them in child folders. When the same moxture name appears at multiple levels, the definition in the closest folder takes precedence. (This behavior may become configurable in a future version, so as to possibly deactivate it.)
- **Isolation from unrelated files:** Moxter only reads files in a test's hierarchy. A broken or invalid YAML file in an unrelated package is not loaded for that test.
- This hierarchy also supports advanced features such as **variable shadowing** and **moxture inheritance**, which are covered in later chapters.
