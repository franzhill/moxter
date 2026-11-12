<div class="moxter-userguide-title" markdown="1">
# ![](../../img/moxter_userguide.png) Group moxtures (chaining)
</div>

A group moxture runs a sequence of named moxtures in order. It is a convenient and powerful way to quickly assemble a test scenario from reusable steps and expose it through a single name.

## Define a group

List moxture names under `moxtures`. Each listed moxture is a step in the group, and the steps run in the order listed:

```yaml
moxtures:
  - name: create_pet
    method: POST
    endpoint: /api/pets
    body:
      name: ${pet_name}
    save:
      pet_id: "$.id"

  - name: adopt_pet
    method: POST
    endpoint: /api/pets/${pet_id}/adopt

  # The group moxture
  - name: create_and_adopt_pet
    vars:
      pet_name: Snowy
    moxtures:
      - create_pet
      - adopt_pet
```

In this example, the group provides `pet_name` to its steps. `create_pet` runs first and saves the returned ID; `adopt_pet` then uses that value in its endpoint.

A group is an orchestration entry, not an HTTP request. Define request details and expectations on the individual step moxtures. Unlike [moxture inheritance](extending_moxtures.md), a group does not merge one moxture's configuration into another; it runs the listed steps one after another.

## Call a group

Call the group by name just like any other moxture:

```java
...
mx.caller()
  .call("create_and_adopt_pet");
```

You can configure the group call with the `MoxCaller` API. Call-scoped variables and variables defined on the group are available to its steps. A call-scoped variable can override a group variable for that execution:

```java
...
mx.caller()
  .withVar("pet_name", "Doris")
  .call("create_and_adopt_pet");
```

See the [Variables guide](variables.md) and [MoxCaller reference](../reference/moxcaller.md).

## Share data between steps

Variables saved by one step are written to the global variable scope and can be used by later steps. In the example above, the `save` block in `create_pet` makes `pet_id` available to `adopt_pet`.

Each step moxture can also have its own `vars`, `save`, and `expect` sections. Expectations are evaluated as each step runs; the group does not define a single response expectation of its own. See the [Expectations guide](expectations.md).

## Handle step failures

By default, a step failure stops the group, so later steps are not executed. To continue to the next step when one fails, set `options.allowFailure: true` on the group:

```yaml
- name: cleanup_scenario
  options:
    allowFailure: true
  moxtures:
    - delete_pet
    - clear_test_data
```

Failed steps are logged as warnings, and the group continues. Use this best-effort behavior only when it is acceptable for a step to fail—for example, when cleanup may target a resource that does not exist.

## Example: put a pet up for adoption

The following fictional animal-shelter scenario prepares a pet for adoption in five steps: create the pet, examine it, take its photo, create its file, and place it in a pen. Each step uses values saved by earlier steps.

```yaml
moxtures:
  - name: create_pet
    method: POST
    endpoint: /api/pets
    body:
      name: "${pet_name}"
      species: "${pet_species}"
    save:
      pet_id: "$.id"
    expect:
      status: 201

  - name: examine_pet
    method: POST
    endpoint: /api/pets/${pet_id}/examinations
    body:
      examiner: "${examiner}"
    save:
      examination_id: "$.id"
      pet_weight_kg: "$.weightKg"
      pet_age_years: "$.ageYears"
    expect:
      status: 201

  - name: take_pet_photo
    method: POST
    endpoint: /api/pets/${pet_id}/photos
    body:
      imageUrl: "${photo_url}"
    save:
      photo_id: "$.id"
    expect:
      status: 201

  - name: create_pet_file
    method: POST
    endpoint: /api/pets/${pet_id}/file
    body:
      examinationId: "${examination_id}"
      photoId: "${photo_id}"
      species: "${pet_species}"
      weightKg: ${pet_weight_kg}
      ageYears: ${pet_age_years}
    save:
      pet_file_id: "$.id"
    expect:
      status: 201

  - name: place_pet_in_pen
    method: POST
    endpoint: /api/pens/${pen_id}/pets
    body:
      petId: "${pet_id}"
      fileId: "${pet_file_id}"
    expect:
      status: 201

  - name: put_up_pet_for_adoption
    vars:
      pet_name: Snowy
      pet_species: dog
      examiner: Dr. Paws
      photo_url: "classpath:photos/snowy.jpg"
      pen_id: 7
    moxtures:
      - create_pet
      - examine_pet
      - take_pet_photo
      - create_pet_file
      - place_pet_in_pen
```

Run the scenario as one named moxture:

```java
mx.caller()
  .call("put_up_pet_for_adoption");
```

