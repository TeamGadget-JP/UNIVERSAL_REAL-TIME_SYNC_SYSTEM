# GHEG — G-HUB Entangle for Godot

**G-HUB Entangle for Godot (GHEG)** は、**TeamGadget Universal Real-Time Sync System (URSS)** のGodot .NET Endpointです。

GHEGはGodotを **G-HUB** へ接続し、リアルタイムBody同期、Facial / BlendShape同期、Character Slot Routing、Canonical Timeline同期、Smart Swizzle診断、Offline Facial Bake、FBX BridgeによるBody Animation転送を提供します。

> GHEG v1.0.0はEditor-side Production Endpointとして設計されています。Body / Facial Animation AssetをGodot Projectへ届け、最終的なCharacter Assemblyは通常のGodot Workflowとしてユーザー側で管理します。

![GHEG multi-character workflow](images/gheg-workflow.png)

---

## 概要

GHEGはCascadeurやShapeMixer Entangleと**直接通信しません**。Endpoint登録、Character Slot Routing、Canonical同期はすべて **G-HUB** を介して行われます。

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

Body / Facial同期は同じGHEG Endpoint内で同時に利用できます。

GHEGは最大 **5 Character Slots** をサポートします。

```text
C1  →  char_01
C2  →  char_02
C3  →  char_03
C4  →  char_04
C5  →  char_05
```

Character IdentityはURSS Route / Character Slotが所有します。GHEGではBone名に旧式Character Prefixを必要としません。

---

## 機能

- G-HUB経由のリアルタイムBody同期
- G-HUB経由のリアルタイムFacial / BlendShape同期
- 最大 **5 Character Slots**
- C1～C5の独立Body / Face Routing
- 互換Character Structure向けRig-Agnostic Body同期
- Smart Swizzle Reference Pose Mapping / Persistent Cache
- Floating **SS Visualizer** Diagnostic Window
- Root + 最大3つのPelvis / Translation Bone
- 設定可能なLocal Position Scale
- 任意のBody Interpolation
- Canonical G-HUB Timeline同期
- Character Animation Playbackと分離された専用Timeline Transport Player
- **AUTO ASSIGN** / **ASSIGN ALL**による明示的で安全なSetup支援
- FBX BridgeによるBody AnimationのGodot Projectへの転送
- Native Godot `Animation` ResourceへのOffline Facial Animation Bake
- User-selectable Output Folder / Asset Name
- 通常時の簡潔なLog + 任意Verbose Diagnostics

---

## 開発 / 検証環境

GHEG v1.0.0は以下で開発・検証されています。

- **Godot 4.7.2 .NET**
- Windows 64-bit

Validation時に使用した関連TeamGadget Component:

- **G-HUB v1.0**
- **GHEC v1.0.2**
- **ShapeMixer Entangle v1.0**

> GHEGはC#で実装されているため、**Godot .NET** Projectが必要です。
>
> 他Versionでも動作する可能性はありますが、GHEG v1.0.0の検証基準はGodot 4.7.2 .NETです。

---

## 配布

Release Packageは以下のGodot Add-on構成で配布されます。

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

`addons/gheg` Folder名は変更せず、そのままTarget Godot ProjectへCopyしてください。

---

# インストール

## 1. Godot .NET Projectを準備

**Godot 4.7 .NET** Projectを作成または開きます。

完全な新規Godot .NET Projectでは、まだ`.csproj` / `.sln`が存在しない場合があります。Godot EditorにC# Build Control（ハンマー）が表示されない場合は、Godot内で一度だけTemporary C# Scriptを作成し、.NET Project Fileを初期化してください。

推奨Temporary Filename:

```text
Bootstrap.cs
```

GodotがProject Fileを生成した後、このTemporary Scriptは削除して構いません。

> **重要:** Temporary Scriptを`Node.cs`という名前にしないでください。
>
> Project内の`Node.cs`は`Godot.Node`と衝突し、多数の誤解を招くC# Compile Errorを発生させることがあります。`Control.cs`、`Window.cs`、`Button.cs`などGodot Engine Typeと同名のFileも避けてください。

---

## 2. GHEGをInstall

Release Add-onを以下へCopyします。

```text
res://addons/gheg/
```

以下が存在することを確認してください。

```text
res://addons/gheg/plugin.cfg
```

C# Projectを一度Buildします。

その後、以下を開きます。

```text
Project
└─ Project Settings
   └─ Plugins
```

以下をEnableします。

```text
G-HUB Entangle for Godot (GHEG)
```

Enable後、Godot Editorに**GHEG** Dockが表示されます。

---

# 推奨Scene構成

GHEGはURSS Timeline TransportをCharacterの通常Animation Playbackから意図的に分離します。

> **Node名は任意です。**
>
> このGuideに登場する`Timeline_C1`、`G_C1`、`Character`、`GHEG_ShapeKeys`、`AnimationPlayer`などは例です。ProjectのNaming Ruleに合わせてNode Instance名を自由に変更できます。
>
> GHEGがSetupを識別する主な要素は、Node Type、Inspectorの明示Reference、Character Slot Assignment、AUTO ASSIGNが使用するParent / Child関係です。Sample Nameそのものは同期Contractではありません。
>
> `addons/gheg` Add-on Folderや配布GHEG Script / Class File名は変更しないでください。専用Timeline Transportには`GHEG_Transport` Node Typeの使用を強く推奨します。

1 Characterの推奨構成:

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

Multi-Characterの場合はC1～C5ごとに同じStructural Patternを繰り返します。Node Instance名は例と全く異なっても構いません。

AUTO ASSIGNで重要なのは、`GHEG_Transport`、`GHEG_ShapeKeys`、`GHEG_FacePlayer`が対応`GHEG_Avatar` WrapperのUnique Direct Childであることです。`GHEG_TimelineAgent`は手動設定した`Avatar` Referenceで関連付けます。

![Recommended GHEG scene structure](images/gheg-scene-structure.png)

---

## GHEG_Transportを分離する理由

`GHEG_Transport`はCanonical URSS Timeline Transport専用の空`AnimationPlayer`です。

Final Body Animation Playerとして使用してはいけません。

この分離により、URSS Timeline CursorがImported / Baked Animation TrackとSkeleton Pose Ownershipを競合することを防ぎます。

Final Character Animation Playbackには通常の`AnimationPlayer`を使用してください。

---

# C1完全Setup Guide — Step by Step

この章では、空Godot Sceneから動作するGHEG C1 Characterを作るまでを順番に説明します。

C1が動作すれば、C2～C5はCharacter Slotを変更するだけで同じ手順を使用できます。

> **以下のNode名は例であり必須ではありません。**
>
> `Hero`、`Timeline_Main`、`MyCharacter`など自由なNaming Conventionを使用できます。重要なのはNode Type、Assigned Reference、Character Slot、以下で説明するStructural Relationshipです。

## 始める前に

以下を準備してください。

- Godot **4.7.2 .NET** Project
- GHEG Install / Enable済み
- C# Projectが正常Build可能
- `Skeleton3D`を含むImported Character Scene
- 接続可能なG-HUB
- Body同期に使用するCascadeur / GHEC
- Face Live / Facial Bakeを使用する場合はShapeMixer Entangle

この例では次のNode名を使用します。

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

繰り返しますが、名前は可読性のための例です。

---

## Step 1 — GHEG_Systemを作成

Scene Rootに以下TypeのNodeを1つ作成します。

```text
GHEG_System
```

Edited Scene内の都合の良い場所へ置いて構いません。

1 Sceneにつき1つの`GHEG_System`でGHEG Endpointを管理します。

Control Port Default:

```text
8000
```

まだConnectしません。先にC1構造を完成させます。

---

## Step 2 — C1 Timeline Agentを作成

新しい`Node3D`を作成し、Global ClassをAttach / Createします。

```text
GHEG_TimelineAgent
```

このGuideでは以下の名前にします。

```text
Timeline_C1
```

名前は任意です。

`GHEG_TimelineAgent`は`Node3D`を継承しているため、Plain `Node`ではなく`Node3D`を使用する点が重要です。

`Transport Player`はまだ未設定にします。後でAUTO ASSIGNが設定します。

---

## Step 3 — C1 Avatar Wrapperを作成

Timeline AgentのChildとして`Node3D`を作成し、以下をAttach / Createします。

```text
GHEG_Avatar
```

このGuideでは以下の名前にします。

```text
G_C1
```

このWrapperがC1のGHEG Configuration Ownerになります。

Inspectorで以下を設定します。

```text
Active = On
Slot   = C1
```

他Referenceはまだ気にしなくて構いません。

---

## Step 4 — Original CharacterをAvatar Wrapper配下へInstance

Imported Character Sceneを`GHEG_Avatar` WrapperのChildとしてInstance / Placeします。

例:

```text
Timeline_C1
└─ G_C1                  [GHEG_Avatar]
   └─ Character          [Imported GLB / FBX scene]
      └─ ...
         └─ Skeleton3D
```

Imported Character Root名は任意で、追加Nodeを含んでいても構いません。

Characterを実際に駆動する`Skeleton3D`を確認してください。

---

## Step 5 — Skeleton / Translation Boneを割り当て

`GHEG_Avatar` Wrapperを選択します。

Imported Characterの`Skeleton3D`を以下へ割り当てます。

```text
Skeleton
```

次にBody Sectionを設定します。

```text
Root Bone
Pelvis 1
Pelvis 2    optional
Pelvis 3    optional
```

Bone SelectorからCharacterに適切なBoneを選択します。

一般的なHumanoid例:

```text
Root Bone  → character root / motion root
Pelvis 1   → hip / pelvis bone
Pelvis 2   → additional translation boneが必要な場合のみ
Pelvis 3   → additional translation boneが必要な場合のみ
```

`Local Position Scale` Default:

```text
0.01
```

Character側のTranslation Scaleに調整が必要な場合を除きDefaultのまま使用してください。

Body Interpolationは任意で、後からEnableできます。

![GHEG Avatar Inspector](images/gheg-avatar-inspector.png)

---

## Step 6 — 専用Timeline Transportを追加

`GHEG_Avatar` WrapperのDirect Childとして以下TypeのNodeを作成します。

```text
GHEG_Transport
```

例:

```text
G_C1
└─ GHEG_Transport
```

Node Instance名は変更可能です。Typeそのものが`GHEG_Transport`として識別されます。

最も単純で曖昧さのないSetupでは、Avatar Wrapperごとに`GHEG_Transport` Direct Childを1つだけ置いてください。

Final Body AnimationをこのNodeへ置かないでください。URSS Timeline Transport専用です。

---

## Step 7 — GHEG_ShapeKeysを追加

Avatar WrapperのDirect Childとして以下を作成します。

```text
GHEG_ShapeKeys
```

このNodeは**Live Facial / BlendShape同期**を担当します。

AUTO ASSIGNを使う場合、Characterごとに`GHEG_ShapeKeys` Direct Childを1つだけ置きます。

以下は未設定のままにします。

```text
Avatar
Target Root
```

AUTO ASSIGNが後で設定します。

![GHEG ShapeKeys Inspector](images/gheg-shapekeys-inspector.png)

---

## Step 8 — GHEG_FacePlayerを追加

Avatar Wrapperの別Direct Childとして以下を作成します。

```text
GHEG_FacePlayer
```

このNodeは**Offline Facial Bake**を担当します。

`Avatar` Fieldは未設定のままにします。AUTO ASSIGNが設定します。

![GHEG FacePlayer Inspector](images/gheg-faceplayer-inspector.png)

---

## Step 9 — Final Body Animation用Normal AnimationPlayerを追加

Character Wrapper配下に通常のGodot:

```text
AnimationPlayer
```

を追加します。

これはFBX BridgeでProjectへ届けられたFinal Body Animation Assetを再生するためのPlayerです。

ここまでの推奨C1構造:

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

名前は変更可能です。重要なのはRole / Relationshipです。

![Recommended GHEG scene structure](images/gheg-scene-structure.png)

---

## Step 10 — 必須のManual Anchorを1つ設定

`GHEG_TimelineAgent` Nodeを選択します。

以下を手動設定します。

```text
Avatar → C1 GHEG_Avatar wrapper
```

このGuideの場合:

```text
Timeline_C1.Avatar → G_C1
```

このExplicit ReferenceがSafe AUTO ASSIGN SystemのAnchorです。

`Transport Player`は空のままにします。

![GHEG Timeline Agent Inspector](images/gheg-timeline-agent-inspector.png)

---

## Step 11 — AUTO ASSIGNを実行

GHEG Dockを開きます。

**TARGET**で以下を選択します。

```text
C1
```

以下を押します。

```text
AUTO ASSIGN
```

標準構造ではGHEGが以下を設定します。

```text
TimelineAgent.TransportPlayer  → C1 GHEG_Transport
GHEG_ShapeKeys.Avatar          → C1 GHEG_Avatar
GHEG_ShapeKeys.TargetRoot      → C1 GHEG_Avatar
GHEG_FacePlayer.Avatar         → C1 GHEG_Avatar
```

期待結果:

```text
Assign: COMPLETE
```

`PARTIAL`の場合、推測せずDockに表示されるMissing Itemを確認してください。

代表的原因:

- `TimelineAgent.Avatar`をManual Assignmentしていない
- 一致Direct Childが複数存在する
- `GHEG_Transport`がない
- `GHEG_ShapeKeys`がない
- `GHEG_FacePlayer`がない

---

## Step 12 — Sceneを保存

AUTO ASSIGN後にSceneを保存します。

Explicit Referenceと、後で作成するSmart Swizzle CacheがScene Configurationへ保存されます。

---

## Step 13 — G-HUB / GHEC側のC1 Routeを準備

GHEG接続前に、Source側でも同じCharacter Slotを用意します。

```text
C1 → char_01
```

Body LiveではGHEC / Cascadeur側で対象C1 Characterを公開してください。

Face LiveではShapeMixer Entangle側で対応C1 Face Routeを使用します。

Character IdentityはURSS Character Slotが提供します。Bone名に`character1:`形式のLegacy Prefixは不要です。

---

## Step 14 — GHEGをG-HUBへ接続

GHEG DockでControl Portを確認し、以下を押します。

```text
CONNECT
```

Character Statusは通常、以下のように進みます。

```text
WAIT → ROUTED → LIVE
```

Active Routeに応じてC1は以下を表示します。

```text
BODY LIVE
FACE LIVE
```

または両方。

![GHEG Control Dock](images/gheg-control-dock.png)

---

## Step 15 — C1へSmart Swizzleを適用

Smart SwizzleにはActive G-HUB Character Routeが必要です。

C1がRoutedになったら`GHEG_Avatar` Wrapperを選択し、以下を押します。

```text
Apply Smart Swizzle
```

GHEGがSource Reference PoseをRequestし、Mapping Cacheを作成します。

期待Cache State:

```text
Ready
```

Character / Skeleton / Request Signature変更後に`Stale`になった場合はSmart Swizzleを再適用してください。

Rest Pose、Resolved Target、Actual Applied Pose、Translation Mapping、個別Boneを確認したい場合はSS Visualizerを使用します。

---

## Step 16 — Body Liveを確認

CascadeurでC1 Characterを動かすかPlaybackします。

Godot側で以下を確認します。

- 期待Boneが動く
- Root / Pelvis Translationが正しく動く
- 別CharacterへC1 Dataが混線しない
- GHEG Dockが`BODY LIVE`を表示

Translation Distanceが正しくない場合、C1 `GHEG_Avatar`の`Local Position Scale`を調整します。

Smooth化が必要ならBody InterpolationをEnableし、Lerp Speedを調整します。

---

## Step 17 — Face Liveを確認

ShapeMixer Entangleを使用する場合、C1のFacial Controlを変更します。

Godot側で想定BlendShapeが反応し、Dockが以下を表示することを確認します。

```text
FACE LIVE
```

`GHEG_ShapeKeys.TargetRoot`は通常Avatar Wrapperを指し、その配下Imported Character HierarchyをScanします。

---

## Step 18 — 任意Timeline Test

Endpoint LevelのTimeline同期はDefault OFFです。

必要な場合のみGHEG DockからEnableします。

Canonical URSS TimelineをScrub / Playし、C1が専用`GHEG_Transport`を通して追従することを確認します。

通常のFinal-animation `AnimationPlayer`はTransport Playerから分離したままにしてください。

---

## Step 19 — C1 Setup完了

ここまででC1 Authoring Setupは完了です。

利用可能:

- Body Live同期
- Face Live同期
- Canonical Timeline同期
- SS Visualizer診断
- FBX Bridge Body Bake / Transfer
- Offline Facial Bake

C2～C5も同じ構造を繰り返し、Avatar Character Slotと対応URSS Route Assignmentだけ変更します。

すべてのAvatar Anchorを設定後、**ASSIGN ALL**でConfigured SlotすべてのSafe Referenceを一括設定できます。

---

# Component Setup Reference

## 1. GHEG_Systemを追加

以下をAttachしたNodeを1つ作成します。

```text
GHEG_System
```

Sceneに必要なGHEG Endpoint Systemは1つです。

Default Control Port:

```text
8000
```

---

## 2. GHEG_TimelineAgentを追加

Character Timeline用`Node3D`を作成します。

例:

```text
Timeline_C1
```

Attach:

```text
GHEG_TimelineAgent
```

`GHEG_TimelineAgent`は`Node3D`を継承するためPlain `Node`ではなく`Node3D`を使用します。

`Avatar` Fieldは対応`GHEG_Avatar` Nodeへ手動設定します。このExplicit Avatar ReferenceがGHEG Safe Assignment SystemのSetup Anchorです。

![GHEG Timeline Agent Inspector](images/gheg-timeline-agent-inspector.png)

---

## 3. GHEG_Avatarを追加

Character Wrapperを作成します。

例:

```text
G_C1
```

Attach:

```text
GHEG_Avatar
```

Imported Character SceneをこのWrapper配下へ置き、InspectorでCharacterの`Skeleton3D`を割り当てます。

設定項目:

- **Slot** — C1～C5
- **Skeleton** — Destination `Skeleton3D`
- **Root B** — Root Translation Bone
- **Pelvis 1** — Primary Pelvis / Hip Translation Bone
- **Pelvis 2** — 任意Additional Translation Bone
- **Pelvis 3** — 任意Additional Translation Bone
- **Body Interpolation** — 任意Smooth化
- **Lerp Speed** — Interpolation Speed
- **Local Position Scale** — Translation Scale、Default `0.01`

Root / Pelvis Bone SelectorはAssigned Skeleton3D Bone Listを使用します。

![GHEG Avatar Inspector](images/gheg-avatar-inspector.png)

---

## 4. GHEG_Transportを追加

Character WrapperのDirect Childに以下TypeのNodeを追加します。

```text
GHEG_Transport
```

`GHEG_Transport`はGodot **Create New Node** Dialogから直接作成できます。

---

## 5. GHEG_ShapeKeysを追加

Real-time Facial同期が必要な場合、Character WrapperのDirect Childへ以下を追加します。

```text
GHEG_ShapeKeys
```

`GHEG_ShapeKeys`は**Live Facial Synchronization**を所有します。

![GHEG ShapeKeys Inspector](images/gheg-shapekeys-inspector.png)

---

## 6. GHEG_FacePlayerを追加

Offline Facial Bakeが必要な場合、Character WrapperのDirect Childへ以下を追加します。

```text
GHEG_FacePlayer
```

`GHEG_FacePlayer`は`AnimationPlayer`を継承し、**Offline Facial Bake**を所有します。

![GHEG FacePlayer Inspector](images/gheg-faceplayer-inspector.png)

---

## 7. Normal AnimationPlayerを追加

Final Body Animation Playback用に通常Godot `AnimationPlayer`を追加します。

これは以下と意図的に分離します。

```text
GHEG_Transport
```

FBX Bridge転送後のFinal Body Animationは通常`AnimationPlayer`へ配置します。

---

# AUTO ASSIGN / ASSIGN ALL

GHEG v1.0.0はユーザーScene HierarchyをAggressiveに再構築しません。

代わりに明示的で安全なAssignment Toolを提供します。

AUTO ASSIGN前:

1. Character Node Structureを作成
2. `GHEG_TimelineAgent.Avatar`を手動設定
3. GHEG DockでTarget Character Slotを選択
4. **AUTO ASSIGN**を押す

AUTO ASSIGNはStructure上曖昧でないReferenceだけを設定します。

```text
TimelineAgent.TransportPlayer  → GHEG_Transport
GHEG_ShapeKeys.Avatar          → GHEG_Avatar
GHEG_ShapeKeys.TargetRoot      → GHEG_Avatar
GHEG_FacePlayer.Avatar         → GHEG_Avatar
```

Required NodeがMissing / Ambiguousの場合、推測せずPartial Assignmentを報告します。

Multi-Character Sceneでは**ASSIGN ALL**でValid Character Slotすべてへ同じSafe Assignmentを実行できます。Empty SlotはSkipされます。

> AUTO ASSIGNはSkeleton、Root Bone、Pelvis Bone、Imported Character Hierarchyを推測しません。

---

# GHEG Control Dock

GHEG Dockは日常操作Panelです。Advanced Rig ConfigurationはGodot Inspector側に残します。

![GHEG Control Dock](images/gheg-control-dock.png)

### HUB

- G-HUB Session State
- Endpoint ID
- Session ID
- Control Port
- Connect / Disconnect
- Timeline ON / OFF
- Canonical Timeline Monitor

### CHARACTERS

C1～C5 Body / Face Stateを表示します。

代表State Progression:

```text
-- → WAIT → ROUTED → LIVE
```

### TARGET

Setup、FBX Bridge、Facial Bake、Inspector Selectionで使用するCharacter Slotを選択します。

### FBX BRIDGE

- Output Folder
- Asset Name
- FBX Bridge Request
- Godot FBX Import
- Import / Operation Status

### FACIAL BAKE

- Start / End Frame
- FPS
- Output Folder
- Asset Name
- Bake / Cancel

### DIAGNOSTICS

Floating **SS Visualizer**を開きます。

---

# G-HUBへ接続

1. G-HUBを起動します。
2. Body同期が必要ならCascadeurでGHECを起動 / Openします。
3. Facial同期が必要ならShapeMixer Entangleを起動します。
4. C1～C5 Assignmentが対応していることを確認します。
5. GodotでGHEG Dockの**CONNECT**を押します。

Routing成功後、対応Character Slotは`BODY LIVE` / `FACE LIVE`へ変化します。

GHEGは1 Endpoint Sessionで最大5 Character SlotをActiveにできます。

---

# Smart Swizzle

Smart Swizzleは互換Source / Destination Skeleton間のReference Pose Coordinate差を解決します。

Characterごとに:

1. Destination `Skeleton3D`を割り当て
2. Source / Destination Characterが互換Reference Poseにあることを確認
3. `GHEG_Avatar`の**Apply Smart Swizzle**を使用
4. SS Cacheが`Ready`であることを確認

Cached Smart Swizzle結果はScene Configurationへ保存されます。

Character Structure / Request Signature変更時に`Stale`になる場合があります。必要に応じて再構築してください。

---

# SS Visualizer

**SS Visualizer**はSmart Swizzle / Resolved Pose確認用Floating Diagnostic Toolです。

![GHEG SS Visualizer](images/gheg-ss-visualizer.png)

主な機能:

- C1～C5 Slot Selection
- Route / UDP State
- Pose Contract State
- Smart Swizzle Cache State
- Mapped Bone / Translation Count
- Local Position Scale
- Searchable Bone Browser
- Godot Rest
- Cascadeur Rest
- Live Sample
- Resolved Target
- Actual Applied Pose
- Scene-view Marker
- XYZ Axis
- Parent Link Visualization

診断 / Validationに使用してください。正常設定後の通常運用には必須ではありません。

---

# Timeline同期

GHEGはG-HUB Canonical Timeline Systemへ参加します。

Timeline同期はGHEG Dockから制御し、Endpoint Systemでは**Default OFF**です。

各Character Slotは専用`GHEG_TimelineAgent`と`GHEG_Transport` Playerを使用します。

Transport PlayerにはCharacter Animation Trackを置きません。Canonical Time / Playback Stateを表現するだけです。

これによりTimeline TransportはLive Body Pose Ownership / Final Animation Playbackから独立します。

---

# Body Animation — FBX Bridge

FBX BridgeはURSS / Cascadeur WorkflowでBakeしたBody AnimationをGodot Projectへ転送します。

## 基本Workflow

1. GHEG DockでCharacter Slotを選択します。
2. Output Folder / Asset Nameを設定します。
3. **FBX BRIDGE**を押します。
4. Transfer完了を待ちます。
5. Imported Resourceがまだ利用できない場合は**IMPORT FBX**を押します。
6. Imported FBXがGodot FileSystemで`PackedScene`として表示されることを確認します。
7. Imported Resultを開き、Animationを確認します。

Default Output Root:

```text
res://
```

GHEGは現在Editor Session中、Character Slot切替時も直前に選択したBody Output Folderを保持します。

---

## Body AnimationをOriginal Characterへ適用

GHEG v1.0.0はValid Body Animation AssetをGodot Projectへ届けた時点で意図的に処理を止めます。

Production Characterへの最終適用は通常Godot Workflowとして手動で行います。

GodotはImported FBX `AnimationLibrary`を以下のようにMarkすることがあります。

```text
[foreign]
```

AnimationをCopyできない場合:

1. Imported FBX Sceneを開く
2. `AnimationPlayer` / `AnimationLibrary`を探す
3. **Make Animation Library Unique**を実行
4. 必要AnimationをCopy
5. Original Characterの通常`AnimationPlayer`へPaste

> Final Body Animationを`GHEG_Transport`へPasteしないでください。
>
> `GHEG_Transport`はURSS Timeline Transport専用です。

Animation転送後、Production Characterは通常Project Hierarchyへ戻し、一般的なGodot Animated Characterとして利用できます。

---

# Facial同期

`GHEG_ShapeKeys`がリアルタイムFacial同期を担当します。

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

標準GHEG Node StructureではAUTO ASSIGNによって`Avatar` / `Target Root` Referenceを設定できます。

---

# Offline Facial Bake

`GHEG_FacePlayer`はRouted ShapeMixer Entangle AnimationをNative Godot `Animation` Resourceへ変換します。

## 基本Workflow

1. Face RouteがLiveであることを確認します。
2. GHEG DockでCharacter Slotを選択します。
3. Start Frame / End Frame / FPSを設定します。
4. Output Folder / Asset Nameを選択します。
5. **FACIAL BAKE**を押します。
6. Bake完了を待ちます。

Bake結果はStandalone `.tres` Godot `Animation` Resourceとして保存され、`GHEG_FacePlayer` Preview Libraryからも利用できます。

GHEGは現在Editor Session中、Character Slot切替時も直前に選択したFacial Bake Output Folderを保持します。

生成Animationは通常Godot Animation WorkflowでProduction Characterへ適用できます。

---

# Multi-Character Workflow

GHEG v1.0.0は1 Godot Endpoint内でC1～C5をサポートします。

検証済み5 Character Scene Pattern（名前は例）:

```text
Timeline_C1 → G_C1 → C1 character components
Timeline_C2 → G_C2 → C2 character components
Timeline_C3 → G_C3 → C3 character components
Timeline_C4 → G_C4 → C4 character components
Timeline_C5 → G_C5 → C5 character components
GHEG_System
```

C1～C5全体で以下を確認済みです。

- Body Live同期
- Facial Live同期
- Timeline同期
- FBX Bridge Body Animation転送
- Original CharacterへのBody Animation適用
- Offline Facial Bake
- Cross-talkなしのRoute分離

---

# Logging / Diagnostics

通常GHEG Logは意図的にCompactです。

Operation完了Message、Warning、Errorは表示し、Detailed Internal Routing / Packet DiagnosticはDefault非表示です。

詳細Troubleshooting時は以下をEnableします。

```text
GHEG_System
└─ Diagnostics
   └─ Verbose Logging
```

Verbose ModeではEndpoint、Route、Channel、Pose、内部Diagnostic Logが復帰します。

---

# Known Notes / Limitations

## Godot FBX Import Warning

Godot 4.7.2は一部FBX Import時にNormalization / Rendering Warningを出す場合があります。

GHEG Validationでは、これらMessageが出てもImported Asset / Animation Dataは正常でした。

機能判定はMessageそのものではなくImported Resultで行ってください。

## Final Character Assemblyは手動

GHEG v1.0.0はBody / Facial Animation AssetをProjectへ届けますが、User Production Character Hierarchyを自動再構築しません。

これは意図した仕様です。

ユーザーが管理する範囲:

- Final Character Scene Hierarchy
- Final Normal `AnimationPlayer`
- Imported AnimationLibrary Organization
- Production Asset Name / Storage
- Final Runtime Playback Integration

## Safe Assignmentのみ

AUTO ASSIGNはAmbiguous Scene Structureを推測・書き換えません。

実行しないこと:

- Character Wrapperの自動生成
- Imported Character Hierarchyの変更
- Skeleton3Dの推測
- Root / Pelvis Boneの推測
- User Normal AnimationPlayerの置換
- Production Sceneの再構築

---

# トラブルシューティング

## GHEG Pluginが表示されない

以下が存在することを確認します。

```text
res://addons/gheg/plugin.cfg
```

さらにC# Projectが正常Buildできることを確認してください。

`.csproj`がない場合、Temporary C# Scriptを作成してGodot .NET Projectを初期化してください。

---

## Temporary Script作成後、多数のC# Errorが出た

Script名が`Node.cs`だった場合はRename / Deleteして再Buildしてください。

`Godot.Node`と衝突し、無関係に見える多数のErrorを引き起こす可能性があります。

安全な名前例:

```text
Bootstrap.cs
```

---

## AUTO ASSIGNがPARTIALになる

以下を確認してください。

- `GHEG_TimelineAgent.Avatar`がManual Assignment済み
- Characterに`GHEG_Transport`がExactly One存在
- Face Liveを使う場合`GHEG_ShapeKeys`がExactly One存在
- Facial Bakeを使う場合`GHEG_FacePlayer`がExactly One存在

GHEGは曖昧なAssignmentを意図的に拒否します。

---

## Face Routeが利用できない

`GHEG_ShapeKeys`がActiveで、Avatar / Target Root Referenceが設定されていることを確認します。

未AssignmentのShapeKeys ComponentはFatal Endpoint ErrorではなくSetup WAIT Stateとして扱われます。

---

## FBX Bridge完了後、AnimationをCopyできない

Imported AnimationLibraryが`[foreign]`になっている場合があります。

Original Characterの通常`AnimationPlayer`へCopyする前に**Make Animation Library Unique**を実行してください。

---

# ライセンス

GHEGはRelease PackageおよびこのDocumentation Directoryに含まれるLicense条件で配布されます。

参照:

[`LICENSE.txt`](LICENSE.txt)

---

# 関連URSS Component

- **G-HUB** — 中央Endpoint / Route / Timeline Controller
- **GHEC** — Cascadeur Endpoint
- **GHEU** — Unity Endpoint
- **GHEB** — Blender Endpoint
- **ShapeMixer Entangle (SE)** — Facial / Shape Key Authoring Endpoint

すべてのSynchronization RouteはG-HUBを通して調整されます。

---

## GHEG v1.0.0

**G-HUB Entangle for Godot**  
TeamGadget  
Godot 4.7 .NET Endpoint
