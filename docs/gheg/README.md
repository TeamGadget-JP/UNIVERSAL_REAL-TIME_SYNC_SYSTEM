# GHEG — G-HUB Entangle for Godot

**G-HUB Entangle for Godot (GHEG)** is the Godot .NET endpoint of the **TeamGadget Universal Real-Time Sync System (URSS)**.

GHEG connects Godot to **G-HUB** and provides real-time body synchronization, real-time facial / BlendShape synchronization, Character Slot routing, canonical timeline synchronization, Smart Swizzle diagnostics, offline facial bake, and body-animation transfer through the FBX Bridge.

> GHEG v1.0.0 is designed as an editor-side production endpoint. It delivers body and facial animation assets into the Godot project while keeping final character assembly under normal Godot user control.

![GHEG multi-character workflow](images/gheg-workflow.png)

---

## Overview

GHEG does **not** communicate directly with Cascadeur or ShapeMixer Entangle.
All endpoint registration, Character Slot routing, and canonical synchronization are handled through **G-HUB**.

```text
Cascadeur / GHEC
       │
       ▼
     G-HUB
       │
       ▼
 Godot / GHEG
```

```text
ShapeMixer Entangle / SE
          │
          ▼
        G-HUB
          │
          ▼
      Godot / GHEG
```

Body and facial synchronization can be used together through the same GHEG endpoint.

GHEG supports up to **5 Character Slots**:

```text
C1  →  char_01
C2  →  char_02
C3  →  char_03
C4  →  char_04
C5  →  char_05
```

Character identity is owned by the URSS route / Character Slot. GHEG does not require legacy character prefixes in bone names.

---

## Features

- Real-time body synchronization through G-HUB
- Real-time facial / BlendShape synchronization through G-HUB
- Up to **5 Character Slots**
- Independent C1–C5 Body and Face routing
- Rig-agnostic body synchronization for compatible character structures
- Smart Swizzle reference-pose mapping and persistent cache
- Floating **SS Visualizer** diagnostic window
- Root + up to three pelvis / translation bones
- Configurable local position scale
- Optional body interpolation
- Canonical G-HUB timeline synchronization
- Dedicated timeline transport player separated from character animation playback
- Explicit safe setup assistance through **AUTO ASSIGN** and **ASSIGN ALL**
- FBX Bridge body-animation transfer into the Godot project
- Offline facial animation bake to native Godot `Animation` resources
- User-selectable output folders and asset names
- Reduced normal logging with optional verbose diagnostics

---

## Development / Tested Environment

GHEG v1.0.0 is developed and validated specifically for:

- **Godot 4.7.2 .NET**
- Windows 64-bit

Related TeamGadget components used during validation:

- **G-HUB v1.0**
- **GHEC v1.0.2**
- **ShapeMixer Entangle v1.0**

> GHEG requires a **Godot .NET** project because the endpoint is implemented in C#.
>
> Other Godot versions may work, but GHEG v1.0.0 is validated against Godot 4.7.2 .NET.

---

## Distribution

The release package is distributed as a Godot add-on containing:

```text
addons/
└─ gheg/
   ├─ Editor/
   ├─ Internal/
   ├─ GHEG_Avatar.cs
   ├─ GHEG_FacePlayer.cs
   ├─ GHEG_ShapeKeys.cs
   ├─ GHEG_System.cs
   ├─ GHEG_TimelineAgent.cs
   ├─ GHEG_Transport.cs
   └─ plugin.cfg
```

Copy the `addons/gheg` folder into the target Godot project without renaming it.

---

# Installation

## 1. Prepare a Godot .NET Project

Create or open a **Godot 4.7 .NET** project.

A fresh Godot .NET project may not contain a `.csproj` / `.sln` yet. If the Godot editor does not show the C# build controls, create one temporary C# script from inside Godot to initialize the .NET project files.

Recommended temporary filename:

```text
Bootstrap.cs
```

After Godot creates the project files, the temporary script can be deleted.

> **Important:** Do not name the temporary script `Node.cs`.
>
> A project-level `Node.cs` can collide with `Godot.Node` and produce many misleading C# compile errors. Avoid other Godot engine type names such as `Control.cs`, `Window.cs`, or `Button.cs` for temporary bootstrap scripts as well.

---

## 2. Install GHEG

Copy the release add-on to:

```text
res://addons/gheg/
```

Make sure this file exists:

```text
res://addons/gheg/plugin.cfg
```

Build the C# project once.

Then open:

```text
Project
└─ Project Settings
   └─ Plugins
```

Enable:

```text
G-HUB Entangle for Godot (GHEG)
```

When enabled, the **GHEG** dock becomes available in the Godot editor.

---

# Recommended Scene Structure

GHEG intentionally keeps URSS timeline transport separate from the character's normal animation playback.

> **Node names are arbitrary.**
>
> Names such as `Timeline_C1`, `G_C1`, `Character`, `GHEG_ShapeKeys`, and `AnimationPlayer` in this guide are examples only. You may rename node instances to match your own project conventions.
>
> GHEG identifies the setup primarily through node types, explicit Inspector references, Character Slot assignments, and the expected parent / child relationships used by AUTO ASSIGN. The sample names themselves are not part of the synchronization contract.
>
> Do not rename the `addons/gheg` add-on folder or the distributed GHEG script / class files. For the dedicated timeline transport, using the `GHEG_Transport` node type is strongly recommended.

A recommended one-character setup is:

```text
Node3D                         [Scene Root]
├─ Timeline_C1                 [Node3D + GHEG_TimelineAgent]
│  └─ G_C1                    [Node3D + GHEG_Avatar]
│     ├─ Character             [Imported GLB / FBX character]
│     │  └─ Skeleton3D
│     ├─ GHEG_Transport        [GHEG_Transport / AnimationPlayer]
│     ├─ GHEG_ShapeKeys        [GHEG_ShapeKeys]
│     ├─ GHEG_FacePlayer       [GHEG_FacePlayer]
│     └─ AnimationPlayer       [Normal final animation playback]
└─ GHEG_System                 [GHEG_System]
```

For multiple characters, repeat the same structural pattern for C1–C5. The node instance names may be completely different from the examples shown here.

For AUTO ASSIGN, the important structural rule is that `GHEG_Transport`, `GHEG_ShapeKeys`, and `GHEG_FacePlayer` are unique direct children of the corresponding `GHEG_Avatar` wrapper. The `GHEG_TimelineAgent` is associated through its manually assigned `Avatar` reference.

![Recommended GHEG scene structure](images/gheg-scene-structure.png)

---

## Why GHEG_Transport Is Separate

`GHEG_Transport` is a dedicated empty `AnimationPlayer` used only for canonical URSS timeline transport.

It must **not** be used as the final body-animation player.

This separation prevents the URSS timeline cursor from competing with imported or baked animation tracks for ownership of the character skeleton pose.

Use a normal `AnimationPlayer` for final character animation playback.

---

# Complete C1 Setup Guide — Step by Step

This chapter walks through a complete **C1** setup from an empty Godot scene to a working GHEG character.

Once C1 works, C2–C5 use the same procedure with only the Character Slot changed.

> **The node names used below are examples, not requirements.**
>
> You may use names such as `Hero`, `Timeline_Main`, `MyCharacter`, or any other naming convention. What matters is the node type, the assigned references, the Character Slot, and the structural relationships described below.

## Before You Start

Have the following ready:

- Godot **4.7.2 .NET** project
- GHEG installed and enabled
- C# project builds successfully
- one imported character scene containing a `Skeleton3D`
- G-HUB available for connection
- GHEC available in Cascadeur for Body synchronization
- ShapeMixer Entangle available if Face Live / Facial Bake is required

For this example, the guide uses these node names:

```text
Timeline_C1
G_C1
Character
GHEG_Transport
GHEG_ShapeKeys
GHEG_FacePlayer
AnimationPlayer
GHEG_System
```

Again, these names are only for readability.

---

## Step 1 — Create GHEG_System

In the scene root, create one node of type:

```text
GHEG_System
```

The node can be placed anywhere convenient in the edited scene.

Only one `GHEG_System` should manage the GHEG endpoint in the scene.

Leave the default Control Port at:

```text
8000
```

Do not connect yet. Finish the C1 structure first.

---

## Step 2 — Create the C1 Timeline Agent

Create a new `Node3D` and attach / create the global class:

```text
GHEG_TimelineAgent
```

For this guide, name the node:

```text
Timeline_C1
```

The name is arbitrary.

The important point is that the node is a `Node3D`, because `GHEG_TimelineAgent` derives from `Node3D`.

Leave `Transport Player` unassigned for now. AUTO ASSIGN will fill it later.

---

## Step 3 — Create the C1 Avatar Wrapper

Create a `Node3D` below the Timeline Agent and attach / create:

```text
GHEG_Avatar
```

For this guide, name it:

```text
G_C1
```

This wrapper becomes the GHEG configuration owner for C1.

In the Inspector, set:

```text
Active = On
Slot   = C1
```

Do not worry about the other references yet.

---

## Step 4 — Instance the Original Character Under the Avatar Wrapper

Instance or place the imported character scene below the `GHEG_Avatar` wrapper.

Example:

```text
Timeline_C1
└─ G_C1                  [GHEG_Avatar]
   └─ Character          [Imported GLB / FBX scene]
      └─ ...
         └─ Skeleton3D
```

The imported character root may have any name and may contain additional nodes.

Locate the actual `Skeleton3D` that drives the character.

---

## Step 5 — Assign the Skeleton and Translation Bones

Select the `GHEG_Avatar` wrapper.

Assign the imported character's `Skeleton3D` to:

```text
Skeleton
```

Then configure the Body section:

```text
Root Bone
Pelvis 1
Pelvis 2    optional
Pelvis 3    optional
```

Use the bone selectors to choose the correct bones for the character.

Typical humanoid usage is:

```text
Root Bone  → the character root / motion root
Pelvis 1   → the hip / pelvis bone
Pelvis 2   → empty unless another translation bone is required
Pelvis 3   → empty unless another translation bone is required
```

`Local Position Scale` defaults to:

```text
0.01
```

Keep the default unless the character's translation scale requires adjustment.

Body Interpolation is optional and can be enabled later.

![GHEG Avatar Inspector](images/gheg-avatar-inspector.png)

---

## Step 6 — Add the Dedicated Timeline Transport

Create a direct child of the `GHEG_Avatar` wrapper using the node type:

```text
GHEG_Transport
```

Example:

```text
G_C1
└─ GHEG_Transport
```

The **node instance name may be changed** because the node type itself identifies it as `GHEG_Transport`.

For the simplest and least ambiguous setup, keep exactly one `GHEG_Transport` direct child per Avatar wrapper.

Do not put final body animation on this node. It is reserved for URSS timeline transport.

---

## Step 7 — Add GHEG_ShapeKeys

Create a direct child of the Avatar wrapper using:

```text
GHEG_ShapeKeys
```

This node handles **live facial / BlendShape synchronization**.

For AUTO ASSIGN, keep exactly one `GHEG_ShapeKeys` direct child for this character.

Leave these fields unassigned for now:

```text
Avatar
Target Root
```

AUTO ASSIGN will populate them.

![GHEG ShapeKeys Inspector](images/gheg-shapekeys-inspector.png)

---

## Step 8 — Add GHEG_FacePlayer

Create another direct child of the Avatar wrapper using:

```text
GHEG_FacePlayer
```

This node handles **offline facial bake**.

Leave its `Avatar` field unassigned for now. AUTO ASSIGN will populate it.

![GHEG FacePlayer Inspector](images/gheg-faceplayer-inspector.png)

---

## Step 9 — Add a Normal AnimationPlayer for Final Body Animation

Add a normal Godot:

```text
AnimationPlayer
```

under the character wrapper.

This is the player used later for the final body-animation asset delivered through the FBX Bridge.

At this point, the recommended C1 structure looks like:

```text
Timeline_C1                         [GHEG_TimelineAgent]
└─ G_C1                            [GHEG_Avatar / Slot C1]
   ├─ Character                    [Imported character]
   │  └─ ...
   │     └─ Skeleton3D
   ├─ GHEG_Transport               [URSS timeline only]
   ├─ GHEG_ShapeKeys               [Face Live]
   ├─ GHEG_FacePlayer              [Facial Bake]
   └─ AnimationPlayer              [Final Body animation]

GHEG_System
```

The names may differ. The roles and relationships are what matter.

![Recommended GHEG scene structure](images/gheg-scene-structure.png)

---

## Step 10 — Set the One Required Manual Anchor

Select the `GHEG_TimelineAgent` node.

Manually assign:

```text
Avatar → the C1 GHEG_Avatar wrapper
```

For this guide:

```text
Timeline_C1.Avatar → G_C1
```

This explicit reference is the anchor used by the safe AUTO ASSIGN system.

Leave `Transport Player` empty.

![GHEG Timeline Agent Inspector](images/gheg-timeline-agent-inspector.png)

---

## Step 11 — Run AUTO ASSIGN

Open the GHEG dock.

Under **TARGET**, choose:

```text
C1
```

Press:

```text
AUTO ASSIGN
```

For the standard structure, GHEG fills:

```text
TimelineAgent.TransportPlayer  → C1 GHEG_Transport
GHEG_ShapeKeys.Avatar          → C1 GHEG_Avatar
GHEG_ShapeKeys.TargetRoot      → C1 GHEG_Avatar
GHEG_FacePlayer.Avatar         → C1 GHEG_Avatar
```

The expected result is:

```text
Assign: COMPLETE
```

If it reports `PARTIAL`, do not guess. Check the missing item reported by the dock.

The most common causes are:

- `TimelineAgent.Avatar` was not assigned manually
- more than one matching direct child exists
- `GHEG_Transport` is missing
- `GHEG_ShapeKeys` is missing
- `GHEG_FacePlayer` is missing

---

## Step 12 — Save the Scene

Save the scene after AUTO ASSIGN.

This stores the explicit references and the later Smart Swizzle cache with the scene configuration.

---

## Step 13 — Prepare the C1 Route in G-HUB / GHEC

Before connecting GHEG, confirm the source side is prepared for the same Character Slot:

```text
C1 → char_01
```

For Body Live, GHEC / Cascadeur should expose the intended C1 character.

For Face Live, ShapeMixer Entangle should use the corresponding C1 Face route.

Character identity is provided by the URSS Character Slot. Bone names do not require legacy `character1:`-style prefixes.

---

## Step 14 — Connect GHEG to G-HUB

In the GHEG dock, confirm the Control Port and press:

```text
CONNECT
```

The character status normally progresses through states such as:

```text
WAIT → ROUTED → LIVE
```

Depending on the active routes, C1 may show:

```text
BODY LIVE
FACE LIVE
```

or both.

![GHEG Control Dock](images/gheg-control-dock.png)

---

## Step 15 — Apply Smart Swizzle for C1

Smart Swizzle requires an active G-HUB Character route.

With C1 routed, select the `GHEG_Avatar` wrapper and press:

```text
Apply Smart Swizzle
```

GHEG requests the source reference pose and builds the mapping cache.

The expected cache state is:

```text
Ready
```

If the cache is `Stale` after changing the character, Skeleton, or request signature, apply Smart Swizzle again.

Use the SS Visualizer if you need to inspect Rest pose, Resolved Target, Actual Applied pose, translation mapping, or individual bones.

---

## Step 16 — Verify Body Live

Move or play the C1 character in Cascadeur.

Confirm in Godot that:

- the expected bones move
- the Root / Pelvis translation behaves correctly
- no unrelated character receives C1 data
- the GHEG dock reports `BODY LIVE`

If translation distance is incorrect, adjust `Local Position Scale` on the C1 `GHEG_Avatar`.

If motion requires smoothing, enable Body Interpolation and adjust Lerp Speed.

---

## Step 17 — Verify Face Live

If ShapeMixer Entangle is part of the workflow, change one or more C1 facial controls.

Confirm that the expected Godot BlendShapes respond and the dock reports:

```text
FACE LIVE
```

`GHEG_ShapeKeys.TargetRoot` normally points to the Avatar wrapper, allowing it to scan the imported character hierarchy below that wrapper.

---

## Step 18 — Optional Timeline Test

Timeline synchronization is OFF by default at the endpoint level.

Enable it from the GHEG dock only when required.

Scrub or play the canonical URSS timeline and confirm that C1 follows through its dedicated `GHEG_Transport`.

The normal final-animation `AnimationPlayer` must remain separate from the transport player.

---

## Step 19 — C1 Setup Complete

At this point, the C1 authoring setup is complete.

You can now use:

- Body Live synchronization
- Face Live synchronization
- canonical Timeline synchronization
- SS Visualizer diagnostics
- FBX Bridge Body bake / transfer
- Offline Facial Bake

For C2–C5, repeat the same structure and change only the Avatar Character Slot and the corresponding URSS route assignment.

After all Avatar anchors are set, **ASSIGN ALL** can populate the safe references for every configured slot in one operation.

---

# Component Setup Reference

## 1. Add GHEG_System

Create one node and attach:

```text
GHEG_System
```

Only one GHEG endpoint system is required for the scene.

The endpoint control port defaults to:

```text
8000
```

---

## 2. Add GHEG_TimelineAgent

Create a `Node3D` for the character timeline, for example:

```text
Timeline_C1
```

Attach:

```text
GHEG_TimelineAgent
```

`GHEG_TimelineAgent` derives from `Node3D`, so use a `Node3D`, not a plain `Node`.

Set its `Avatar` field manually to the corresponding `GHEG_Avatar` node. This explicit Avatar reference is the setup anchor used by GHEG's safe assignment system.

![GHEG Timeline Agent Inspector](images/gheg-timeline-agent-inspector.png)

---

## 3. Add GHEG_Avatar

Create the character wrapper, for example:

```text
G_C1
```

Attach:

```text
GHEG_Avatar
```

Place the imported character scene below this wrapper and assign the character's `Skeleton3D` in the Inspector.

Configure:

- **Slot** — C1 to C5
- **Skeleton** — destination `Skeleton3D`
- **Root B** — root translation bone
- **Pelvis 1** — primary pelvis / hip translation bone
- **Pelvis 2** — optional additional translation bone
- **Pelvis 3** — optional additional translation bone
- **Body Interpolation** — optional smoothing
- **Lerp Speed** — interpolation speed
- **Local Position Scale** — translation scale, default `0.01`

Root / Pelvis bone selectors use the assigned Skeleton3D bone list.

![GHEG Avatar Inspector](images/gheg-avatar-inspector.png)

---

## 4. Add GHEG_Transport

Add a new node of type:

```text
GHEG_Transport
```

as a direct child of the character wrapper.

`GHEG_Transport` is available directly from Godot's **Create New Node** dialog.

---

## 5. Add GHEG_ShapeKeys

If real-time facial synchronization is required, add:

```text
GHEG_ShapeKeys
```

as a direct child of the character wrapper.

`GHEG_ShapeKeys` owns **live facial synchronization**.

![GHEG ShapeKeys Inspector](images/gheg-shapekeys-inspector.png)

---

## 6. Add GHEG_FacePlayer

If offline facial bake is required, add:

```text
GHEG_FacePlayer
```

as a direct child of the character wrapper.

`GHEG_FacePlayer` derives from `AnimationPlayer` and owns **offline facial bake**.

![GHEG FacePlayer Inspector](images/gheg-faceplayer-inspector.png)

---

## 7. Add a Normal AnimationPlayer

Add a normal Godot `AnimationPlayer` for final body animation playback.

This is intentionally separate from:

```text
GHEG_Transport
```

The normal `AnimationPlayer` is where the final body animation should be placed after FBX Bridge transfer.

---

# AUTO ASSIGN / ASSIGN ALL

GHEG v1.0.0 does **not** aggressively reconstruct the user's scene hierarchy.

Instead, it provides explicit safe assignment tools.

Before using AUTO ASSIGN:

1. Build the character node structure.
2. Set `GHEG_TimelineAgent.Avatar` manually.
3. Select the target Character Slot in the GHEG dock.
4. Press **AUTO ASSIGN**.

AUTO ASSIGN fills only references that are structurally unambiguous:

```text
TimelineAgent.TransportPlayer  → GHEG_Transport
GHEG_ShapeKeys.Avatar          → GHEG_Avatar
GHEG_ShapeKeys.TargetRoot      → GHEG_Avatar
GHEG_FacePlayer.Avatar         → GHEG_Avatar
```

If a required node is missing or ambiguous, GHEG reports a partial assignment instead of guessing.

For a configured multi-character scene, press **ASSIGN ALL** to run the same safe assignment for every valid Character Slot. Empty slots are skipped.

> AUTO ASSIGN never guesses the Skeleton, Root bone, Pelvis bones, or imported character hierarchy.

---

# GHEG Control Dock

The GHEG dock is the daily operation panel.
Advanced rig configuration remains in the Godot Inspector.

![GHEG Control Dock](images/gheg-control-dock.png)

The dock contains:

### HUB

- G-HUB session state
- Endpoint ID
- Session ID
- Control Port
- Connect / Disconnect
- Timeline ON / OFF
- Canonical timeline monitor

### CHARACTERS

Displays C1–C5 Body and Face state.

Typical state progression is:

```text
-- → WAIT → ROUTED → LIVE
```

### TARGET

Selects the Character Slot used by setup, FBX Bridge, Facial Bake, and Inspector selection actions.

### FBX BRIDGE

- Output folder
- Asset name
- FBX Bridge request
- Godot FBX import
- Import / operation status

### FACIAL BAKE

- Start / End frame
- FPS
- Output folder
- Asset name
- Bake / Cancel

### DIAGNOSTICS

Opens the floating **SS Visualizer**.

---

# Connecting to G-HUB

1. Start G-HUB.
2. Start / open GHEC in Cascadeur if body synchronization is required.
3. Start ShapeMixer Entangle if facial synchronization is required.
4. Confirm matching C1–C5 assignments.
5. In Godot, press **CONNECT** in the GHEG dock.

When routing succeeds, the relevant Character Slot changes to `BODY LIVE` and/or `FACE LIVE`.

GHEG supports up to five active Character Slots in one endpoint session.

---

# Smart Swizzle

Smart Swizzle resolves reference-pose coordinate differences between compatible source and destination skeletons.

For each character:

1. Assign the destination `Skeleton3D`.
2. Confirm the source and destination characters are in compatible reference poses.
3. Use **Apply Smart Swizzle** in `GHEG_Avatar`.
4. Confirm the SS Cache reports `Ready`.

A cached Smart Swizzle result is stored with the scene configuration.

If the character structure or request signature changes, the cache may become `Stale`. Rebuild it when required.

---

# SS Visualizer

The **SS Visualizer** is a floating diagnostic tool for Smart Swizzle and resolved pose inspection.

![GHEG SS Visualizer](images/gheg-ss-visualizer.png)

It provides:

- C1–C5 Slot selection
- route / UDP state
- pose contract state
- Smart Swizzle cache state
- mapped bone and translation counts
- local position scale
- searchable bone browser
- Godot Rest
- Cascadeur Rest
- Live Sample
- Resolved Target
- Actual Applied pose
- scene-view marker
- XYZ axes
- parent link visualization

Use the SS Visualizer for diagnosis and validation. It is not required for normal operation after the character has been configured successfully.

---

# Timeline Synchronization

GHEG participates in the G-HUB canonical timeline system.

Timeline synchronization is controlled from the GHEG dock and is **OFF by default** for the endpoint system.

Each Character Slot uses its own `GHEG_TimelineAgent` and dedicated `GHEG_Transport` player.

The transport player contains no character animation tracks. Its purpose is only to represent canonical time and playback state.

This keeps timeline transport independent from live body pose ownership and final animation playback.

---

# Body Animation — FBX Bridge

The FBX Bridge transfers baked body animation from the URSS / Cascadeur workflow into the Godot project.

## Basic Workflow

1. Select the Character Slot in the GHEG dock.
2. Set the output folder and asset name.
3. Press **FBX BRIDGE**.
4. Wait for the transfer to complete.
5. Press **IMPORT FBX** if the imported resource is not already available.
6. Confirm the imported FBX appears in the Godot FileSystem as a `PackedScene`.
7. Open the imported result and verify the animation.

The default output root is:

```text
res://
```

GHEG remembers the most recently selected Body output folder during the current editor session when switching Character Slots.

---

## Applying the Body Animation to the Original Character

GHEG v1.0.0 intentionally stops after delivering a valid body-animation asset into the Godot project.

The final application to the production character is a normal Godot workflow and is performed manually.

Godot may mark the imported FBX `AnimationLibrary` as:

```text
[foreign]
```

If the animation cannot be copied:

1. Open the imported FBX scene.
2. Locate its `AnimationPlayer` / `AnimationLibrary`.
3. Use **Make Animation Library Unique**.
4. Copy the required animation.
5. Paste it into the original character's normal `AnimationPlayer`.

> Do **not** paste final body animation into `GHEG_Transport`.
>
> `GHEG_Transport` is reserved for URSS timeline transport only.

After the animation has been transferred, the user's production character can be returned to its normal project hierarchy and used like any other Godot animated character.

---

# Facial Synchronization

`GHEG_ShapeKeys` handles real-time facial synchronization.

For a routed Face Slot:

```text
ShapeMixer Entangle
        │
        ▼
      G-HUB
        │
        ▼
GHEG_ShapeKeys
        │
        ▼
Godot Blend Shapes
```

The character's `Avatar` and `Target Root` references can be populated through AUTO ASSIGN when the standard GHEG node structure is used.

---

# Offline Facial Bake

`GHEG_FacePlayer` converts routed ShapeMixer Entangle animation into a native Godot `Animation` resource.

## Basic Workflow

1. Confirm the Face route is live.
2. Select the Character Slot in the GHEG dock.
3. Set Start frame, End frame, and FPS.
4. Choose the output folder and asset name.
5. Press **FACIAL BAKE**.
6. Wait for the bake to complete.

The baked result is saved as a standalone `.tres` Godot `Animation` resource and is also available through the `GHEG_FacePlayer` preview library.

GHEG remembers the most recently selected Facial Bake output folder during the current editor session when switching Character Slots.

The resulting animation can then be applied to the production character through the project's normal Godot animation workflow.

---

# Multi-Character Workflow

GHEG v1.0.0 supports C1–C5 in one Godot endpoint.

A validated five-character scene follows this pattern. The names shown are examples only; each node instance may be renamed:

```text
Timeline_C1 → G_C1 → C1 character components
Timeline_C2 → G_C2 → C2 character components
Timeline_C3 → G_C3 → C3 character components
Timeline_C4 → G_C4 → C4 character components
Timeline_C5 → G_C5 → C5 character components
GHEG_System
```

During validation, the following were confirmed across C1–C5:

- body live synchronization
- facial live synchronization
- timeline synchronization
- FBX Bridge body-animation transfer
- body-animation application to original characters
- offline facial bake
- route separation without cross-talk

---

# Logging / Diagnostics

Normal GHEG logging is intentionally compact.

Operational completion messages, warnings, and errors remain visible, while detailed internal routing and packet diagnostics are hidden by default.

For deeper troubleshooting, enable:

```text
GHEG_System
└─ Diagnostics
   └─ Verbose Logging
```

Verbose mode restores detailed endpoint, route, channel, pose, and internal diagnostic logging.

---

# Known Notes / Limitations

## Godot FBX Import Warnings

Godot 4.7.2 may print normalization / rendering warnings during some FBX imports.

During GHEG validation, imported assets and animation data remained valid despite these messages.

Treat the imported result itself as the functional validation point.

## Final Character Assembly Is Manual

GHEG v1.0.0 delivers Body and Facial animation assets into the project, but it does not automatically reconstruct the user's final production character hierarchy.

This is intentional.

The user remains in control of:

- the final character scene hierarchy
- the final normal `AnimationPlayer`
- imported AnimationLibrary organization
- production asset naming and storage
- final runtime playback integration

## Safe Assignment Only

AUTO ASSIGN does not infer or rewrite ambiguous scene structures.

It does not:

- generate character wrappers automatically
- modify imported character hierarchies
- guess the Skeleton3D
- guess Root / Pelvis bones
- replace the user's normal AnimationPlayer
- reconstruct production scenes

---

# Troubleshooting

## The GHEG plugin does not appear

Confirm:

```text
res://addons/gheg/plugin.cfg
```

exists and the C# project builds successfully.

If the project has no `.csproj`, initialize the Godot .NET project by creating a temporary C# script first.

---

## Many C# errors appeared after creating a temporary script

If the script was named `Node.cs`, rename or delete it and rebuild.

The filename can conflict with `Godot.Node` and trigger many unrelated-looking errors.

Use a neutral name such as:

```text
Bootstrap.cs
```

---

## AUTO ASSIGN reports PARTIAL

Confirm:

- `GHEG_TimelineAgent.Avatar` is manually assigned
- exactly one `GHEG_Transport` exists for the character
- exactly one `GHEG_ShapeKeys` exists if Face Live is required
- exactly one `GHEG_FacePlayer` exists if Facial Bake is required

GHEG intentionally refuses ambiguous assignment.

---

## Face route remains unavailable

Confirm `GHEG_ShapeKeys` is active and its Avatar / Target Root references are assigned.

An unassigned ShapeKeys component is treated as a setup WAIT state rather than a fatal endpoint error.

---

## FBX Bridge completed but I cannot copy the animation

The imported AnimationLibrary may be marked `[foreign]`.

Use **Make Animation Library Unique** before copying the animation into the original character's normal `AnimationPlayer`.

---

# License

GHEG is distributed under the license terms included with the release package and in this documentation directory.

See:

[`LICENSE.txt`](LICENSE.txt)

---

# Related URSS Components

- **G-HUB** — central endpoint / route / timeline controller
- **GHEC** — Cascadeur endpoint
- **GHEU** — Unity endpoint
- **GHEB** — Blender endpoint
- **ShapeMixer Entangle (SE)** — facial / Shape Key authoring endpoint

All synchronization routes are coordinated through G-HUB.

---

## GHEG v1.0.0

**G-HUB Entangle for Godot**  
TeamGadget  
Godot 4.7 .NET Endpoint

