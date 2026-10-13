# GHEB v1.0.1 — G-HUB Entangle for Blender

**G-HUB Entangle for Blender (GHEB)** は、G-HUBを介してBlenderと連携するための独立したTeamGadget同期コンポーネントです。

GHEBはBlenderを **TeamGadget Universal Real-Time Sync System** へ接続し、リアルタイムBody同期、Facial / Shape Key同期、Multi-Character Routing、Canonical Timeline同期、Smart Swizzle診断、任意のBody Interpolation、Blender ActionへのOffline Animation Bakeを提供します。

> GHEBは、Body / Facial / Timeline / Offline Bakeのすべてで、1つの共有Blender Endpointと1つのG-HUB Control接続を使用します。

---

## 概要

GHEBはTeamGadget同期システムのBlender側Endpointです。

GHEBはCascadeurやShapeMixer Entangleと**直接通信しません**。  
Route、Character Slot Matching、Canonical同期はすべて **G-HUB** を通して処理されます。

```text
Cascadeur / GHEC
       │
       ▼
     G-HUB
       │
       ▼
Blender / GHEB
```

```text
ShapeMixer Entangle / SE
          │
          ▼
        G-HUB
          │
          ▼
    Blender / GHEB
```

Body / Facial同期は同じGHEB Endpoint上で同時に利用できます。

![GHEB Main UI](images/gheb-main.png)
![GHEB Main UI](images/gheb-se.png)

## 機能

- G-HUB経由のリアルタイムBody同期
- G-HUB経由のリアルタイムFacial / Shape Key同期
- 最大 **5 Character Slots**
- C1～C5の独立Body / Facial Routing
- Body + Facialの同時Live同期
- 互換Character Structure向けRig-Agnostic Body同期
- Smart Swizzle Reference Pose Mapping
- Blender Sceneへ保持されるSmart Swizzle Cache
- Floating **SS Visualizer** Diagnostic Window
- BoneごとのSearch / Filter / Select / Frame / Copy Diagnostic
- 選択Boneの3D Diagnostic Axis
- Whole-character Diagnostic Marker / Resolved Target Axis
- Characterごとの任意Body Interpolation
- Canonical G-HUB Timeline同期
- Blender Armature ActionへのOffline Body Bake
- Blender Shape Key ActionへのOffline Facial Bake
- Body / Facialを別ActionとしてBake
- Multi-Mesh Facial同期 / Bake
- Active Face SlotすべてへのMulti-Character Facial Bake
- Canonical Timeを使ったMixed-FPS Offline Bake
- 設定可能なG-HUB Control Port
- 非破壊Live Synchronization Workflow

---

## 開発 / 検証環境

GHEB v1.0.1は以下の環境向けに開発・検証されています。

- **Blender 5.2 LTS**
- Windows 64-bit

v1.0.1 Workflowで使用した関連TeamGadget Component:

- **G-HUB v1.0**
- **GHEC v1.0.2**
- **ShapeMixer Entangle v1.0**

> GHEB v1.0.1の公式対応はBlender 5.2 LTSのみです。他Versionは公式サポート対象外です。

---

## 配布

推奨Release Package名:

```text
GHEB_v1_0_1_Blender5_2LTS.zip
```

Release ZIPにはPython Add-on Package Folderが含まれます。

```text
GHEB_v1_0
```

Install / Manual Copy時もInternal Add-on Folder名は変更しないでください。

BlenderはAdd-onをPython Packageとして読み込むため、Internal Folder名は有効なPython Module Nameである必要があります。

---

# インストール

## 1. GHEB Add-onをInstall

1. 以下をDownloadします。

```text
GHEB_v1_0_1_Blender5_2LTS.zip
```

2. **Blender 5.2 LTS**を起動します。
3. Blender **Preferences**を開き、Release ZIPからGHEB Add-onをInstallします。
4. 以下をEnableします。

```text
G-HUB Entangle for Blender (GHEB)
```

Add-onは3D View Sidebarの以下Tabに表示されます。

```text
GHEB
```

> ZIPではなく展開済みFolderから導入する場合も、Package Folder名は配布時の`GHEB_v1_0`のままにしてください。

---

## 2. GHEB Sidebarを開く

Blender 3D ViewでSidebarを開き、以下Tabを選択します。

```text
GHEB
```

Sidebarには以下があります。

- **ShapeMixer Entangle**
- **GHEB Entangle**
- **Timeline & Bake**

---

# Character Setup要件

Body同期開始前に、Cascadeur / Blender双方で互換Characterを用意してください。

## 1. 互換Character Structureを使用

GHEBはActive Character RouteからRequestされたStructureに従ってBlender Boneを解決します。

最良の結果を得るため、Cascadeur / Blender Characterでは以下を対応させてください。

- Bone Hierarchy
- Bone Name
- Semantic Bone Role
- Reference Pose

GHEBは、互換Character Structureがある場合にユーザー作成のBone Mappingを不要にする設計です。

---

## 2. Reference Poseを一致させる

Smart Swizzle初期化前に、Source / Destination Characterを互換Reference Poseへ合わせます。

代表例:

- T-pose
- A-pose

Smart SwizzleはReference Pose間の関係を使い、Cascadeur / Blender間のLocal Axis差を解決します。

---

## 3. GHEBはHumanoid Rig限定ではない

GHEBはBlender Armatureを直接扱うため、Unity形式のHumanoid Avatarを必要としません。

Source / Destination Character Structureが適切に一致していれば、非HumanoidやCustom Bone-driven Characterも同期できます。

実際の互換性は、Hierarchy、Bone Identity、Reference Pose、両ApplicationのTransform Structureに依存します。

---

# クイックスタート — Body同期

1. **G-HUB**を起動します。
2. **Cascadeur**を起動し、**GHEC**を接続します。
3. Destination Characterを含むBlender Projectを開きます。
4. **GHEB** Sidebarを開きます。
5. **GHEB Entangle**で必要なCharacter SlotをEnableします。
6. Destination **Armature**を割り当てます。
7. 必要に応じて**Root / Pelvis** Translation Boneを設定します。
8. 既存Default挙動では**Translation Scale**を`1.0`のまま使用し、位置移動量を変更したい場合のみ調整します。
9. **Start Entangle**を押します。
10. 対応G-HUB Body RouteがActiveになるまで待ちます。
11. Cacheが未作成なら**Smart Swizzle**を実行します。
12. よりSmoothなLive Motionが必要なら**Body Interpolation**をEnableします。
13. Canonical Timeline同期が必要なら**Sync Timeline**をEnableします。

---

# ShapeMixer Entangle Panel

**ShapeMixer Entangle** Panelは、Blender側Facial / Shape Key同期を設定します。

GHEBは以下をサポートします。

```text
C1 | face_01
C2 | face_02
C3 | face_03
C4 | face_04
C5 | face_05
```

各Face Slotは独立して以下を持ちます。

- Active State
- Target Mesh Anchor
- G-HUB Facial Channel
- G-HUB Route
- Live Shape Key State

---

## Target

選択した**Target** Meshは、Facial同期のCharacter Anchorとして使用されます。

GHEBは同じCharacter Armatureに関連するShape Key Meshを探索し、1つのIncoming ShapeMixer Valueを複数Blender Mesh上の一致Shape Keyへ適用できます。

例えばFacial Targetが以下の別Meshへ分かれているCharacterで便利です。

- Head
- Eyes
- Teeth
- Tongue
- Hair / Accessory Facial Mesh

---

## Multi-Mesh Shape Key Matching

Incoming ShapeMixer Shape Nameごとに、Character参加Mesh全体から一致するBlender Shape Keyを解決します。

Matching対象:

- Shape Key名の完全一致
- Blender Shape Key名の最後の`.`以降をSuffix Aliasとして一致

これにより、BlenderのDuplicate Name Suffixを残したまま、ShapeMixer Source Nameを変更せず利用できます。

---

## Start SYNC / Stop SYNC

`Start SYNC`はActive Face Slotを有効化し、対応G-HUB Facial Routeへ参加します。

Facial同期中はFace Slot設定がLockされます。

Active Face Slot / Target Meshを変更する前に同期を停止してください。

---

## Blend Shape All Reset

`Blend Shape All Reset`はActive Facial Characterに参加するShape Key値をResetします。

ResetはGHEBが解決したMulti-Mesh Character Set全体へ適用されます。

---

# GHEB Entangle Panel

**GHEB Entangle** Panelは共有Blender EndpointとBody同期を制御します。

---

## G-HUB Control

Default Endpoint:

```text
127.0.0.1:8000
```

HostはLocal固定です。

```text
127.0.0.1
```

**Port** FieldはG-HUB TCP Control Portを設定します。

Default:

```text
8000
```

GHEB Control PortはG-HUB設定と一致させてください。

共有GHEB EndpointがActiveな間、PortはLockされます。変更前にGHEBをStop / Reconnectしてください。

---

## Start Entangle / Stop Entangle

`Start Entangle`は共有Blender Endpointを起動し、Active Body Routeへ参加します。

`Stop Entangle`は、他のGHEB機能がEndpointを必要としていない場合に共有EndpointをDisconnectします。

Body / Facial / Timeline機能は、1つのGHEB Endpointと1つのG-HUB Control接続を共有します。

---

# Character Slots

GHEBは最大 **5 Character Slots** をサポートします。

| GHEB Slot | URSS Route |
| --- | --- |
| C1 | `char_01` |
| C2 | `char_02` |
| C3 | `char_03` |
| C4 | `char_04` |
| C5 | `char_05` |

GHEB v1.0.1は現在のURSS Explicit Character Routing Contractに従います。

Character IdentityはActive URSS Route / Slotが所有します。そのためGHEBは元のBone名をRequestし、`character1:`や`character2:`といったLegacy Cascadeur Prefixへ依存しません。

UIではRouteを直接表示します。

```text
C1 (char_01)
C2 (char_02)
...
C5 (char_05)
```

新規Blender SceneではC1がDefault Enableです。

---

## Armature

Character SlotのBody Routeを受信するBlender Armatureを割り当てます。

各Active Character Slotは独立したBody Route / Runtime Stateを持ちます。

---

## Root / Pelvis Translation Bones

以下のFieldで、Rotationに加えてTranslation Channelも受けるBody Boneを指定します。

- Root
- Pelvis 1
- Pelvis 2
- Pelvis 3

Mapped Body BoneはLive Rotation Dataを受けます。設定されたRoot / Pelvis BoneはPosition Sampleがある場合、Live Position Dataも受け取れます。

---

## Translation Scale

各Character Slotに`Translation Scale`設定があります。

Default:

```text
1.0
```

GHEBがIncoming Coordinate Conversionを解決した後、Position Translationのみに適用されます。

対象:

- Root
- Pelvis 1
- Pelvis 2
- Pelvis 3

同じMultiplierが**Live Sync**と**Offline Body Bake**の両方で使用されるため、Preview MotionとBaked Actionの位置Scaleは一致します。

Rotationには影響しません。

例:

- `1.0` — 既存Default挙動
- `0.5` — Translation量を半分
- `2.0` — Translation量を2倍

> Smart Swizzle Cache DataはUnit-neutralです。`Translation Scale`はSlotごとのOutput Multiplierであり、Cacheを再構築せず変更できます。

---

## Apply

`Apply`は、現在Blender FrameへLive Body PoseのKeyframeを挿入します。

これは明示的なUser Actionです。

GHEB停止時にLive同期Dataが自動的にCharacter Animationへ書き込まれることはありません。

---

# Body Interpolation

Incoming Live Body MotionはCharacter Slotごとに任意でSmooth化できます。

Body Interpolationは**Default OFF**です。

Enable時、GHEBは以下を使用します。

- Position: Blender `Vector.lerp`
- Rotation: Blender `Quaternion.slerp`

---

## Lerp Speed

Default:

```text
12.0
```

低い値ほど最新Live Poseへの収束が柔らかく遅くなります。

高い値ほどSourceを直接的に追従します。

Body InterpolationはLive Body同期のみに影響します。Offline BakeはAuthoritative Sampled Source Dataを使用します。

---

# Reference Pose / Smart Swizzle

GHEBはRig-Agnostic Body同期向けにCached Reference Pose Workflowを使用します。

Smart Swizzle初期化時、GHEBはBlender Character Reference PoseとG-HUB経由で受信したCascadeur Reference Pose Dataを比較します。

生成CacheはBlender Sceneへ保存され、互換Connectionで再利用できます。

---

## SS Cached

`SS Cached`はCharacter Slot向けSmart Swizzle Reference Dataが利用可能であることを示します。

Character Structure / Reference Pose変更時は隣接Delete ControlでCacheを消去してください。

---

## Run Smart Swizzle

Cacheがない場合はBody Route Active後に以下を実行します。

```text
Run Smart Swizzle
```

GHEBが対応Cascadeur Reference DataをRequestし、Blender側Mapping Cacheを構築します。

---

## SS Visualizer

`SS Visualizer`は選択Character Slot向けFloating Smart Swizzle Diagnostic Windowを開きます。

Characterが正常に動作している場合、通常同期でVisualizerは不要です。

---

# Smart Swizzle Visualizer

**SS Visualizer**はSmart Swizzle Pipeline全体を確認するFloating Diagnostic Toolです。

用途:

- 正しく同期しないRigの診断
- Reference Pose交換完了の確認
- BoneごとのMapping確認
- Rest / Live / Target Data欠落の特定
- Resolved TargetとActual Blender Poseの比較

---

## Character Status

上部には以下が表示されます。

- Route State
- Reference Cache State
- Mapped Bones
- Cascadeur Rest Count
- Live Samples Count
- Resolved Targets Count
- Diagnostic Issues / Pipeline Complete

健全なRouteではMapped Bones、Cascadeur Rest、Live Samples、Resolved Targetsが同じCountになる場合があります。

---

## Bone Browser

Bone Browserには以下があります。

- Search
- Filter
- Bone Selection
- Bone ID
- Cascadeur Request Name
- Diagnostic State
- Select Bone
- Frame Bone
- Copy Diagnostic

Filter例:

- All
- Issues
- Ready
- Missing Rest
- No Live
- No Target

`Copy Diagnostic`は選択BoneのDiagnostic DataをIssue Report / Technical Support向けにCopyします。

---

## Selected Bone 3D Diagnostics

選択BoneについてVisualizerは以下を表示できます。

- Rest Axes
- Live Axes
- Target Axes
- Actual Axes

現在のColor:

| Diagnostic | Color |
| --- | --- |
| Rest | Gray |
| Live | Cyan |
| Target | Orange |
| Actual | Magenta |

`Axis Size`で選択Bone Axis表示Scaleを調整します。

---

## Whole-Character Diagnostics

Visualizerは以下も表示できます。

- **All Bone Status Markers**
- **All Resolved Target Axes**
- 設定可能な**Marker Size**

Status Marker Color:

| State | Color |
| --- | --- |
| Ready | Green |
| Missing Rest | Orange-Red |
| No Live | Yellow |
| No Target | Red |
| Currently inspected Bone | White |

Whole-character診断により、Boneを1本ずつ調べなくてもRig上でMapping問題を直接見つけられます。

---

## Selected Bone Pipeline

下部Diagnostic Sectionには以下を表示できます。

- Cascadeur Rest State
- Cascadeur Live State
- Blender Target State
- Rest Position
- Rest Quaternion
- Resolved Live Rotation
- Resolved Live Position
- Actual Local Rotation
- Actual Local Position

Body Interpolation OFF時、Resolved TargetとActual Blender Poseは通常ほぼ一致します。

Body Interpolation ON時、Smooth化中はActual Blender Poseが最新Resolved Live Targetへ意図的に遅れて追従します。

---

# Timeline & Bake

**Timeline & Bake** SectionはCanonical Timeline参加とOffline Bakeを提供します。

Timeline同期とOffline Bakeは独立機能ですが、同じ共有GHEB Endpointを使用します。

---

# Canonical Timeline同期

以下を使用してG-HUB Canonical Timelineへ参加します。

```text
Sync Timeline
```

GHEBは以下が可能です。

- BlenderからCanonical TimelineをDrive
- Cascadeur / GHECへ追従
- ShapeMixer Entangle / SEへ追従
- Canonical Time上でScrub / Seek
- Play / Pause / Stop Stateへ追従
- Local Frame Rateが異なっても正しく同期

G-HUBがCanonical Timeline State / Ownershipを管理します。

他EndpointがPlayback Ownerの場合、GHEBは独自の競合Playback Clockを動かさず、受信Canonical Positionへ追従します。これにより遅いRemote Playback RateでもForward / Backward Chatterを防ぎます。

---

## Mixed FPS

GHEBは同じFrame番号ではなくCanonical Timeで同期します。

例:

```text
30 FPS → Frame 30 = 1.0 second
60 FPS → Frame 60 = 1.0 second
```

表示Frame番号は異なってもAnimation Timeは一致します。

---

# Offline Bake

GHEBはG-HUB経由で正確なSampled Animation DataをRequestし、Blender Actionとして直接書き込みます。

利用可能Mode:

```text
Body
Facial
Body + Facial
```

---

## Body

Body BakeはBlender Armature Actionを作成し、以下を含みます。

- Mapped BoneのQuaternion Rotation Curve
- 設定Root / Pelvis Translation BoneのPosition Curve

生成Action名:

```text
GHEB_Body_<Armature>_<Start>_<End>
```

---

## Facial

Facial BakeはShape Key AnimationをBlenderへ直接作成します。

`Mode = Facial`では、GHEBは**ActiveかつValidなFace Slotすべて**をC1～C5の順にSequential処理します。

各Characterへ独立したFacial Actionが作成されます。

Facial Actionは、同じCharacterに属する複数Blender Shape Key Datablock上の一致Shape KeyをDriveできます。

生成Action名:

```text
GHEB_Face_<Target>_<Start>_<End>
```

---

## Body + Facial

`Body + Facial`は選択Characterを2つの独立Blender ActionとしてBakeします。

- Armature Body Action
- Facial Shape Key Action

Body / Facial結果は独立したProduction Assetとして維持されます。

---

## Bake Target Behavior

v1.0.1の現在挙動:

- **Body** — 選択1 Character
- **Facial** — ActiveでValidな全Face Slot
- **Body + Facial** — 選択1 Character

Multi-Character Facial Bakeの利便性を保ちつつ、Body Transactionは明確で予測可能な単体処理にしています。

---

## Bake Range

以下でBlender Output Frame Rangeを指定します。

- Start
- End

---

## Bake Delay

Default:

```text
0.02
```

Bake Delayは、完了したOffline Bake Frame Transaction間に任意のPauseを追加します。

Advanced Use / Test向けに`0.00`も利用できます。

v1.0.1ではDefault `0.02`を推奨Safe値としています。

---

## Mixed-FPS Offline Bake

Source / Destination Frame Rateは一致不要です。

Blender Destination FrameごとにCanonical Timeへ変換し、Routed Endpointへ対応Source TimeをRequestします。

これによりCascadeur、ShapeMixer Entangle、BlenderのFPSが異なっていてもAnimation Timingを保持します。

---

# Live StateとBlender File

Live同期は意図的に非破壊です。

現在Live PoseはRuntime Stateであり、`.blend` Fileへ自動保存されません。

Blender終了後に`.blend`を再度開いた場合:

1. CharacterはBlender Fileに保存されているPoseで表示されます。
2. GHEBをStart / Reconnectします。
3. 現在のLive Source Poseが再受信され適用されます。

Smart Swizzle Reference DataはBlender Sceneへ保存できますが、Current Live Stream PoseはPersistent Animation Dataとして扱いません。

Animation DataをBlenderへ書き込む場合は**Apply**または**Offline Bake**を使用してください。

---

# トラブルシューティング

## GHEBがG-HUBへ接続できない

以下を確認してください。

- G-HUBが起動している
- GHEB / G-HUBが同じControl Portを使用している
- Blender 5.2 LTSを使用している
- Windows Firewall / Security SoftwareがLocal通信をBlockしていない

---

## Body RouteがActiveにならない

以下を確認してください。

- 対象C1～C5 Character SlotがEnable
- Target Armatureが割り当て済み
- GHECがG-HUBへ接続済み
- GHECが対応Character Slotを使用
- G-HUB上に一致Body Routeが存在

Route ActiveでもPoseが不正な場合は**SS Visualizer**でCharacterを確認してください。

---

## Smart Swizzle Cacheがない

以下を確認してください。

- Body RouteがActive
- Destination Armatureが割り当て済み
- Cascadeur / Blender CharacterのBone Name / Hierarchyに互換性がある
- 両Characterが互換Reference Poseを使用

その後、**Smart Swizzle**を再実行してください。

---

## Facial RouteはActiveだが1 Meshしか動かない

以下を確認してください。

- 設定Target Meshが対象Characterに属している
- 追加Facial Meshが同じCharacter Armatureへ解決される
- Shape Key Nameが一致、または対応Blender Suffix Aliasを使用している

GHEB Live Facial同期はIncoming Nameの一致Shapeを参加Character Mesh全体へBroadcastする設計です。

---

## 他Endpointが遅いPlayback RateのときTimelineが前後に揺れる

GHEB v1.0.1はExternal Canonical PlaybackへPassive Followします。

この現象が出る場合、現行v1.0.1 GHEB FileがInstallされているか、古いDevelopment Buildが有効になっていないか確認してください。

---

## Offline Bakeが開始しない

以下を確認してください。

- 必要なBody / Facial RouteがActive
- 選択CharacterがBody Bake向けに設定済み
- Active Face SlotにFacial Bake用Valid Target Meshがある
- Bake Start / End Rangeが有効

---

## Blender再起動後、以前のLive Poseではなく保存Poseで開く

正常挙動です。

Live Pose DataはRuntime Synchronization Stateであり、`.blend` Fileへ自動Persistent化されません。

GHEBをReconnectして現在Live Source Poseを復元するか、**Apply** / **Offline Bake**でPersistent Animation Dataを作成してください。

---

# Open Source

GHEBはOpen-source Blender Endpointです。

適用LicenseはGHEB同梱の`LICENSE` Fileを参照してください。

---

# Third-Party Notice

BlenderはBlender FoundationのTrademarkです。

CascadeurはNekkiのTrademarkです。

GHEB、G-HUB、GHEC、GHEU、ShapeMixer Entangle、TeamGadget Universal Real-Time Sync Systemは独立したTeamGadget Projectです。

明示されている場合を除き、TeamGadgetはBlender Foundation、Nekki、Unity Technologies、その他参照Third-party Vendorと提携、承認、スポンサー、認証、公式サポート関係を持ちません。

Third-party製品名 / Trademarkは各権利者に帰属します。

---

# Project

**TeamGadget**  
**G-HUB Entangle for Blender (GHEB) v1.0.1**
