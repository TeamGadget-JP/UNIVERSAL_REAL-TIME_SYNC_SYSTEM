# G-HUB v1.0

**Universal Real-Time Sync Hub**

G-HUBは、**TeamGadget Universal Real-Time Sync System**の中央通信・Route管理コンポーネントです。

対応するTeamGadget Application間で、Endpoint接続、Character Slot Route、Body / Facial Data Route、Canonical Timeline同期を管理します。

> 通常利用では、G-HUB自体の操作をできるだけシンプルにすることを意図しています。G-HUBを起動し、各Endpointを接続すれば、以降のRoute管理はHubが担当します。

---

## 概要

G-HUBは、TeamGadget同期コンポーネント間の中央Hubとして動作します。

各Component同士は**直接通信しません**。対応ComponentはそれぞれG-HUBへ接続し、G-HUBがRoute、Character Slot割り当て、同期状態を管理します。

現在のTeamGadgetコンポーネントには以下があります。

- **G-HUB Entangle for Cascadeur (GHEC)** — Cascadeur側同期Component
- **G-HUB Entangle for Unity (GHEU)** — Unity同期Component
- **G-HUB Entangle for Blender (GHEB)** — Blender同期Component
- **ShapeMixer Entangle (SE)** — Facial Animation / Shape Key Authoring Tool

GHEC、GHEU、GHEB、ShapeMixer Entangleは、G-HUB経由で動作する独立したTeamGadget Toolです。

![G-HUB Main Window](images/g-hub-main.png)

---

## 機能

- 中央集約型リアルタイム通信Hub
- Dynamic Endpoint Connection管理
- 最大 **5 Character Slots**
- Body / Facial Data Routing
- Canonical Timeline同期
- 設定可能なControl Port
- 設定可能なUDP Base Port
- SlotごとのBody / Facial UDP Port自動割り当て
- Runtime Route / Channel Status表示
- 内蔵Event Log
- TeamGadget Entangle Component向け設計

---

## システム要件

- **Windows 64-bit**
- G-HUB v1.0はWindows向けプリビルドApplicationとして配布されます
- Installerは不要です

互換TeamGadget Componentは個別に配布されます。

---

## インストール

1. `G-HUB_v1.0_Windows_x64.zip` をダウンロードします。
2. ZIPを任意の書き込み可能なFolderへ展開します。
3. `GHub.exe` を実行します。

Installerは不要です。

> 展開したFolder内のFileはまとめて保持してください。`GHub.exe`だけを単独で移動しないでください。

---

## クイックスタート

1. **G-HUB**を起動します。
2. 使用するTeamGadget Componentを起動します。
3. Component側の**Control Port**がG-HUBと同じ値であることを確認します。
4. ComponentをG-HUBへ接続します。
5. 必要なCharacter Slotを有効化または割り当てます。
6. 同期を開始します。

通常運用では、G-HUB側で追加設定を行う必要はほとんどありません。

---

## メインウィンドウ

G-HUB Main Windowには、現在のNetwork / Route状態が表示されます。

HeaderのCounterは、Component接続やRouteのActive化に応じて自動更新されます。

![G-HUB Connected](images/g-hub-connected.png)

### Control

TeamGadget ComponentがG-HUBへ接続するためのTCP Control Endpointを表示します。

Default:

`127.0.0.1:8000`

Default設定は、同一Windows PC内でのLocal通信を想定しています。

### UDP Base

CharacterごとのBody / Facial Data Portを算出する基準UDP Portを表示します。

Default:

`8100`

Default Body Port:

| Character Slot | Body UDP Port |
| --- | ---: |
| C1 | 8101 |
| C2 | 8102 |
| C3 | 8103 |
| C4 | 8104 |
| C5 | 8105 |

Default Facial Port:

| Character Slot | Facial UDP Port |
| --- | ---: |
| C1 | 8201 |
| C2 | 8202 |
| C3 | 8203 |
| C4 | 8204 |
| C5 | 8205 |

### Endpoints

現在接続中のTeamGadget同期Component数を表示します。

例: GHEC、GHEU、GHEB、ShapeMixer Entangle。

### Channels

G-HUBが現在管理しているActive Data Channel数を表示します。

Channelは、接続ComponentやCharacter SlotのActive状態に応じてDynamicに作成・削除されます。

### Routes

現在Activeな同期Route数を表示します。

Routeは、互換TeamGadget Component間でG-HUBが管理するActive Data Pathです。

### Log

Log Areaには、Connection、Channel、Route、Timeline、Relay Eventが表示されます。

**CLEAR LOG**で表示中のLog履歴を消去できます。

Logを消去しても、Active Connectionや同期状態には影響しません。

---

## Advanced Network Settings

**ADVANCED SETTINGS**を開くとNetwork設定を変更できます。

![G-HUB Advanced Settings](images/g-hub-advanced-settings.png)

### Control Port

Default:

`8000`

接続するすべてのTeamGadget Componentは、同じG-HUB Control Portを使用する必要があります。

### UDP Base Port

Default:

`8100`

G-HUBは、この値を基準にCharacter SlotごとのBody / Facial UDP Portを自動算出します。

### Network設定を変更する場合

Active Endpoint / Channel / Routeが存在している間は、Network設定を変更できません。

Network設定を変更する前に、Active ComponentをすべてDisconnectしてください。

Port変更は**SAVE**押下時に保存されますが、実際に反映されるのはG-HUB再起動後です。

- **DEFAULTS** — Control Port / UDP Base PortをDefault値へ戻します
- **CANCEL** — 現在の編集内容を適用せずDialogを閉じます
- **SAVE** — 現在値を保存します

Portを変更して保存した後は、Componentを再接続する前にG-HUBを再起動してください。

---

## Character Slots

G-HUBは最大 **5 Character Slots** をサポートします。

- C1
- C2
- C3
- C4
- C5

Character Slotにより、複数CharacterのBody / Facial / Bake / Synchronization Dataを分離します。

Slot Assignmentは、接続されたTeamGadget Component側で設定します。

G-HUBはActive Slot Configurationに従ってDataをRouteします。

---

## Canonical Timeline同期

G-HUBは、対応TeamGadget Componentで共用する中央Canonical Timeline Pathを提供します。

現在のTimeline OwnerがPlayback StateをG-HUBへPublishし、参加ComponentはそのCanonical Timeline Stateへ追従します。

接続Componentに応じて、同期対象には以下を含められます。

- Current Frame
- Play
- Pause
- Stop
- Scrub / Seek
- Timeline Range
- Frame Rate

Timeline同期は任意機能であり、対応TeamGadget Component側からON / OFFできます。

---

## Network Architecture

```text
Source-side components               Destination-side components
   ┌──────────────┐                         ┌─────────┐         
   │   Cascadeur  ├───── UDP Streaming ─────┤  Unity  │         
   │     GHEC     │                         │  GHEU   │         
   │              ├◄────── Handshake ──────►┤         │         
   └───────┬──────┘            ▲            └─────────┘         
           │                   │                 ▲              
           │             ┌─────┴─────┐           │              
           └────────────►┤           ├───────────┘              
                         │   G-HUB   │                          
           ┌────────────►┤           ├───────────┐              
           │             └─────┬─────┘           │              
           │                   │                 ▼              
   ┌───────┴──────┐            ▼            ┌─────────┐         
   │ ShapeMixer   ├◄────── Handshake ──────►┤ Blender │         
   │     Entangle │                         │  GHEB   │         
   │     (SE)     ├───── UDP Streaming ─────┤         │         
   └──────────────┘                         └─────────┘                           
```

リアルタイムBody / Facial DataはG-HUB経由でRouteされます。Control / Canonical Timeline同期は、接続Componentに応じて双方向に動作します。

**重要:** 接続Application同士は直接通信しません。G-HUBが中央Route / Synchronization Ownerです。

---

## トラブルシューティング

### Componentが接続できない

以下を確認してください。

- G-HUBが起動している
- ComponentがG-HUBと同じControl Portを使用している
- 設定Portを他Applicationが使用していない
- Windows Firewall / Security SoftwareがLocal通信をBlockしていない

### CharacterがDataを受信しない

以下を確認してください。

- ComponentがG-HUBへ接続済み
- 対象Character Slotが有効
- Sending / Receiving Applicationが対応するCharacter Slotを使用している
- G-HUB上でRouteがActive

### Timelineが追従しない

以下を確認してください。

- 参加ComponentでTimeline Syncが有効
- ComponentがG-HUBへ接続済み
- 他の参加ComponentがCanonical Timeline Ownerとして動作している

### Network設定を編集できない

先にActive ComponentをDisconnectしてください。

G-HUBは、Endpoint / Channel / Route StateがActiveな間、意図的にNetwork設定をLockします。

---

## 配布

G-HUBは**Windows 64-bitプリビルドApplication**として配布されます。

Public ReleaseにはSource Codeは含まれません。

他のTeamGadget同期Componentは個別配布されます。

---

## ライセンス

G-HUBは、同梱License条件の範囲で、個人・商用Animation Productionに無料で使用できます。

完全な条件・制限は `LICENSE.txt` を確認してください。

---

## Third-Party Notice

これは独立した**TeamGadget** Projectです。

TeamGadgetは、明示されている場合を除き、本Projectで参照されるThird-party ApplicationのDeveloper / Ownerと提携、承認、スポンサー、認証、公式サポート関係を持ちません。

Third-party製品名 / Trademarkは各権利者に帰属します。

---

## Project

**TeamGadget**  
**G-HUB v1.0 — Universal Real-Time Sync Hub**
