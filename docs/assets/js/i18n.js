/* Forchpad site i18n — the same eight languages the app speaks.
   Browser language wins on first visit; the choice sticks in localStorage. */

const FORCHPAD_LANGS = [
  { code: "en",      name: "English",    short: "EN" },
  { code: "zh-Hans", name: "简体中文",   short: "简" },
  { code: "zh-Hant", name: "繁體中文",   short: "繁" },
  { code: "ja",      name: "日本語",     short: "日" },
  { code: "ko",      name: "한국어",     short: "한" },
  { code: "fr",      name: "Français",   short: "FR" },
  { code: "es",      name: "Español",    short: "ES" },
  { code: "ar",      name: "العربية",    short: "عر" },
];

const FORCHPAD_I18N = {
  en: {
    "doc.title": "Forchpad — play your trackpad",
    "nav.features": "Features", "nav.how": "How it works", "nav.specs": "Specs",
    "nav.download": "Download", "nav.cta": "Download", "nav.language": "Language",
    "hero.eyebrow": "Free · Open source · macOS",
    "hero.title.1": "Your trackpad,", "hero.title.2": "now an instrument.",
    "hero.sub": "Forchpad turns your Mac's Force Touch trackpad into a grid of MIDI pads. Press one shortcut and every finger plays a note — straight into your DAW.",
    "hero.cta.download": "Download for macOS", "hero.cta.github": "View on GitHub",
    "hero.meta": "macOS 12+ on Apple Silicon · macOS 13+ on Intel · MIT license",
    "demo.title": "Forchpad — MIDI pads",
    "demo.hint": "Go ahead — tap the pads. They sound here, too.",
    "m.engine": "125 Hz engine", "m.shortcut": "Global shortcut ⇧⌘E",
    "m.pause": "Pointer pause ⇧⌘P", "m.deps": "Zero dependencies", "m.langs": "8 languages",
    "features.eyebrow": "Features",
    "features.title": "Everything you need. Nothing you don't.",
    "f1.title": "One shortcut to perform",
    "f1.body": "⇧⌘E summons the pad window on top of everything — even mid-session in your DAW. Press it again and the show ends, every note cleanly off.",
    "f2.title": "A real MIDI source",
    "f2.body": "Your DAW sees a virtual input named Forchpad — channel 10, notes from 36 up, ready-made for drums. No drivers, no setup.",
    "f3.title": "The pointer pauses",
    "f3.body": "While you play, the pointer freezes and hides, so no stray click can land mid-performance. ⇧⌘P pauses the music and hands it back.",
    "f4.title": "Your grid, your rules",
    "f4.body": "3×3 out of the box, up to 10×10. Rows, columns, MIDI channel, base note, velocity, per-pad colors — all yours in Settings.",
    "f5.title": "Lives in the menu bar",
    "f5.body": "No Dock icon, no clutter. A quiet F waits in your menu bar until the moment you need it.",
    "f6.title": "Speaks your language",
    "f6.body": "Switch instantly in Settings — it even defaults to your system language.",
    "how.eyebrow": "How it works", "how.title": "From glass to groove in three steps.",
    "s1.title": "Confirm once",
    "s1.body": "Pick your trackpad, grid size and MIDI values in Settings. The built-in trackpad is the default; external Magic Trackpads welcome.",
    "s2.title": "Press",
    "s2.body": "The pad window appears above everything. It can't be closed by accident — only the shortcut ends the show.",
    "s3.title": "Play",
    "s3.body": "Every finger lights a pad and plays a note. Two fingers on one pad are still one note; lift everything and silence returns.",
    "p.fingers": "Fingers", "p.grid": "Pad grid", "p.daw": "Your DAW",
    "how.note": "A 125 Hz engine edge-detects pads going down and up, sending clean Note On and Off — no stuck notes, ever.",
    "specs.eyebrow": "Before you play", "specs.title": "What you'll need.",
    "sp1.title": "A Force Touch trackpad",
    "sp1.body": "Built into MacBooks from 2015 on, or a Magic Trackpad 2 or newer — built-in or external, your call.",
    "sp2.title": "macOS 12 or later",
    "sp2.body": "macOS 12+ on Apple Silicon, macOS 13+ on Intel. Touch capture uses a private framework, so a macOS update could break it — it would fail with a clear message, never a crash.",
    "sp3.title": "Accessibility permission",
    "sp3.body": "Only needed to pause the pointer while you play. Prefer to keep your pointer? Turn the pause off in Settings — no permission asked, touches simply drive the pointer too.",
    "sp4.title": "System gestures off",
    "sp4.body": "Mission Control and friends belong to macOS and can't be blocked reliably. If they interrupt your groove, disable them in System Settings → Trackpad.",
    "download.title": "Get Forchpad.",
    "download.body": "Free and open source under the MIT license. One universal binary for Apple Silicon and Intel.",
    "download.button": "Download the latest release",
    "download.all": "All releases & notes",
    "download.note": "CI builds are ad-hoc signed: on first launch, right-click → Open, and macOS will let it run.",
    "footer.made": "Made for the Mac, in Swift. Zero dependencies.",
    "footer.releases": "Releases", "footer.issues": "Issues", "footer.license": "MIT License",
    "footer.oss": "Open source, free forever.",
  },

  "zh-Hans": {
    "doc.title": "Forchpad — 弹奏你的触控板",
    "nav.features": "功能", "nav.how": "工作原理", "nav.specs": "系统要求",
    "nav.download": "下载", "nav.cta": "下载", "nav.language": "语言",
    "hero.eyebrow": "免费 · 开源 · macOS",
    "hero.title.1": "你的触控板，", "hero.title.2": "从此是件乐器。",
    "hero.sub": "Forchpad 将 Mac 的 Force Touch 触控板变成一组 MIDI 打击垫。按一下快捷键，每根手指都能弹奏音符——直接送进你的 DAW。",
    "hero.cta.download": "下载 macOS 版", "hero.cta.github": "在 GitHub 查看",
    "hero.meta": "Apple Silicon 需 macOS 12+ · Intel 需 macOS 13+ · MIT 许可",
    "demo.title": "Forchpad — MIDI 打击垫",
    "demo.hint": "试试看——点一点这些打击垫，在这里也能出声。",
    "m.engine": "125 Hz 引擎", "m.shortcut": "全局快捷键 ⇧⌘E",
    "m.pause": "指针暂停 ⇧⌘P", "m.deps": "零依赖", "m.langs": "8 种语言",
    "features.eyebrow": "功能",
    "features.title": "应有尽有，毫无冗余。",
    "f1.title": "一个快捷键，即刻开演",
    "f1.body": "⇧⌘E 唤出置顶演奏窗口——即使在 DAW 会话进行中也没问题。再按一次，演出结束，所有音符干净关闭。",
    "f2.title": "真正的 MIDI 输入源",
    "f2.body": "你的 DAW 会看到名为 Forchpad 的虚拟输入——默认通道 10，音符从 36 起，为鼓组而生。无需驱动，即插即用。",
    "f3.title": "指针自动暂停",
    "f3.body": "演奏时指针冻结并隐藏，任何误点都不会落到其他窗口。按 ⇧⌘P 暂停演奏，指针即刻归还。",
    "f4.title": "你的网格，你做主",
    "f4.body": "默认 3×3，最大 10×10。行列数、MIDI 通道、起始音符、力度、每个垫的颜色——都在设置里由你定。",
    "f5.title": "常驻菜单栏",
    "f5.body": "没有 Dock 图标，没有多余窗口。一个安静的 F 驻留在菜单栏，随时待命。",
    "f6.title": "支持多语言",
    "f6.body": "在设置中即时切换——默认跟随系统语言。",
    "how.eyebrow": "工作原理", "how.title": "三步，从玻璃面板到律动。",
    "s1.title": "确认一次",
    "s1.body": "在设置里选好触控板、网格大小和 MIDI 参数。默认使用内置触控板，也欢迎外接妙控板。",
    "s2.title": "按下",
    "s2.body": "演奏窗口置顶出现，不会被误关——只有快捷键能结束演出。",
    "s3.title": "开演",
    "s3.body": "每根手指点亮一个垫、奏响一个音符。同一垫上的两根手指仍是一个音符；全部抬起，世界重归安静。",
    "p.fingers": "手指", "p.grid": "打击垫网格", "p.daw": "你的 DAW",
    "how.note": "125 Hz 引擎对垫的按下与抬起做边沿检测，发出干净的 Note On / Off——永不卡音。",
    "specs.eyebrow": "开始之前", "specs.title": "你需要准备：",
    "sp1.title": "一块 Force Touch 触控板",
    "sp1.body": "2015 年起的 MacBook 内置触控板，或妙控板 2 及更新型号——内置外接，随你选。",
    "sp2.title": "macOS 12 或更高",
    "sp2.body": "Apple Silicon 需 macOS 12+，Intel 需 macOS 13+。触摸捕获使用私有框架，macOS 更新可能使其失效——但只会给出明确提示，绝不崩溃。",
    "sp3.title": "辅助功能权限",
    "sp3.body": "仅用于演奏时暂停指针。想保留指针？在设置中关闭暂停即可——无需任何权限，触摸会照常驱动指针。",
    "sp4.title": "关闭系统手势",
    "sp4.body": "调度中心等系统手势由 macOS 掌管，无法被可靠屏蔽。若干扰演奏，请在 系统设置 → 触控板 中关闭。",
    "download.title": "获取 Forchpad。",
    "download.body": "MIT 许可下的免费开源软件。单个通用二进制，同时支持 Apple Silicon 与 Intel。",
    "download.button": "下载最新版本",
    "download.all": "所有版本与更新说明",
    "download.note": "CI 构建为 ad-hoc 签名：首次启动请右键 → 打开，macOS 便会放行。",
    "footer.made": "为 Mac 而生，Swift 编写，零依赖。",
    "footer.releases": "版本发布", "footer.issues": "问题反馈", "footer.license": "MIT 许可",
    "footer.oss": "开源，永久免费。",
  },

  "zh-Hant": {
    "doc.title": "Forchpad — 彈奏你的觸控板",
    "nav.features": "功能", "nav.how": "運作原理", "nav.specs": "系統需求",
    "nav.download": "下載", "nav.cta": "下載", "nav.language": "語言",
    "hero.eyebrow": "免費 · 開源 · macOS",
    "hero.title.1": "你的觸控板，", "hero.title.2": "從此是件樂器。",
    "hero.sub": "Forchpad 將 Mac 的 Force Touch 觸控板變成一組 MIDI 打擊墊。按一下快速鍵，每根手指都能彈奏音符——直接送進你的 DAW。",
    "hero.cta.download": "下載 macOS 版", "hero.cta.github": "在 GitHub 檢視",
    "hero.meta": "Apple Silicon 需 macOS 12+ · Intel 需 macOS 13+ · MIT 授權",
    "demo.title": "Forchpad — MIDI 打擊墊",
    "demo.hint": "試試看——點一下這些打擊墊，在這裡也能發聲。",
    "m.engine": "125 Hz 引擎", "m.shortcut": "全域快速鍵 ⇧⌘E",
    "m.pause": "指標暫停 ⇧⌘P", "m.deps": "零依賴", "m.langs": "8 種語言",
    "features.eyebrow": "功能",
    "features.title": "應有盡有，毫無冗贅。",
    "f1.title": "一個快速鍵，即刻開演",
    "f1.body": "⇧⌘E 喚出置頂演奏視窗——即使 DAW 工作階段進行中也沒問題。再按一次，演出結束，所有音符乾淨關閉。",
    "f2.title": "真正的 MIDI 輸入源",
    "f2.body": "你的 DAW 會看到名為 Forchpad 的虛擬輸入——預設通道 10，音符從 36 起，為鼓組而生。無需驅動，即插即用。",
    "f3.title": "指標自動暫停",
    "f3.body": "演奏時指標凍結並隱藏，任何誤點都不會落到其他視窗。按 ⇧⌘P 暫停演奏，指標即刻歸還。",
    "f4.title": "你的網格，你做主",
    "f4.body": "預設 3×3，最大 10×10。行列數、MIDI 通道、起始音符、力度、每個墊的顏色——都在設定裡由你決定。",
    "f5.title": "常駐選單列",
    "f5.body": "沒有 Dock 圖示，沒有多餘視窗。一個安靜的 F 駐留在選單列，隨時待命。",
    "f6.title": "支援多國語言",
    "f6.body": "在設定中即時切換——預設跟隨系統語言。",
    "how.eyebrow": "運作原理", "how.title": "三步，從玻璃面板到律動。",
    "s1.title": "確認一次",
    "s1.body": "在設定裡選好觸控板、網格大小與 MIDI 參數。預設使用內建觸控板，也歡迎外接巧控板。",
    "s2.title": "按下",
    "s2.body": "演奏視窗置頂出現，不會被誤關——只有快速鍵能結束演出。",
    "s3.title": "開演",
    "s3.body": "每根手指點亮一個墊、奏響一個音符。同一墊上的兩根手指仍是一個音符；全部抬起，世界重歸安靜。",
    "p.fingers": "手指", "p.grid": "打擊墊網格", "p.daw": "你的 DAW",
    "how.note": "125 Hz 引擎對墊的按下與抬起做邊緣偵測，發出乾淨的 Note On / Off——永不卡音。",
    "specs.eyebrow": "開始之前", "specs.title": "你需要準備：",
    "sp1.title": "一塊 Force Touch 觸控板",
    "sp1.body": "2015 年起的 MacBook 內建觸控板，或巧控板 2 及更新型號——內建外接，隨你選。",
    "sp2.title": "macOS 12 或以上",
    "sp2.body": "Apple Silicon 需 macOS 12+，Intel 需 macOS 13+。觸控擷取使用私有框架，macOS 更新可能使其失效——但只會給出明確訊息，絕不當機。",
    "sp3.title": "輔助使用權限",
    "sp3.body": "僅用於演奏時暫停指標。想保留指標？在設定中關閉暫停即可——無需任何權限，觸控會照常驅動指標。",
    "sp4.title": "關閉系統手勢",
    "sp4.body": "幕前調度等系統手勢由 macOS 掌管，無法被可靠阻擋。若干擾演奏，請在 系統設定 → 觸控板 中關閉。",
    "download.title": "取得 Forchpad。",
    "download.body": "MIT 授權下的免費開源軟體。單一通用二進位，同時支援 Apple Silicon 與 Intel。",
    "download.button": "下載最新版本",
    "download.all": "所有版本與更新說明",
    "download.note": "CI 建置為 ad-hoc 簽名：首次啟動請右鍵 → 打開，macOS 便會放行。",
    "footer.made": "為 Mac 而生，以 Swift 編寫，零依賴。",
    "footer.releases": "版本發布", "footer.issues": "問題回報", "footer.license": "MIT 授權",
    "footer.oss": "開源，永久免費。",
  },

  ja: {
    "doc.title": "Forchpad — トラックパッドを弾こう",
    "nav.features": "機能", "nav.how": "仕組み", "nav.specs": "動作環境",
    "nav.download": "ダウンロード", "nav.cta": "ダウンロード", "nav.language": "言語",
    "hero.eyebrow": "無料 · オープンソース · macOS",
    "hero.title.1": "トラックパッドが、", "hero.title.2": "楽器になる。",
    "hero.sub": "Forchpad は Mac の Force Touch トラックパッドを MIDI パッドのグリッドに変えます。ショートカットを一度押せば、指一本一本が音符を奏で、そのまま DAW へ。",
    "hero.cta.download": "macOS 版をダウンロード", "hero.cta.github": "GitHub で見る",
    "hero.meta": "Apple Silicon は macOS 12+ · Intel は macOS 13+ · MIT ライセンス",
    "demo.title": "Forchpad — MIDI パッド",
    "demo.hint": "どうぞ——パッドをタップしてみて。ここでも音が鳴ります。",
    "m.engine": "125 Hz エンジン", "m.shortcut": "グローバルショートカット ⇧⌘E",
    "m.pause": "ポインタ一時停止 ⇧⌘P", "m.deps": "依存ゼロ", "m.langs": "8 か国語",
    "features.eyebrow": "機能",
    "features.title": "必要なものすべて。余分なものなし。",
    "f1.title": "ショートカットひとつで演奏",
    "f1.body": "⇧⌘E でパッドウインドウが最前面に登場——DAW セッションの途中でも。もう一度押せば演奏終了、すべての音がきれいにオフ。",
    "f2.title": "本物の MIDI ソース",
    "f2.body": "DAW には Forchpad という仮想入力が見えます——チャンネル 10、ノート 36 から、ドラムに最適。ドライバ不要、設定不要。",
    "f3.title": "ポインタは一時停止",
    "f3.body": "演奏中、ポインタは固まって姿を消すので、迷子のクリックが別ウインドウに着弾しません。⇧⌘P で演奏を止めてポインタを取り戻せます。",
    "f4.title": "グリッドは思いのまま",
    "f4.body": "標準は 3×3、最大 10×10。行・列・MIDI チャンネル・基準ノート・ベロシティ・パッドごとの色——すべて設定で。",
    "f5.title": "メニューバーの住人",
    "f5.body": "Dock アイコンなし、散らかしなし。静かな F がメニューバーで、必要な瞬間を待っています。",
    "f6.title": "あなたの言語で",
    "f6.body": "設定で即座に切り替え——初期設定はシステム言語に従います。",
    "how.eyebrow": "仕組み", "how.title": "ガラスからグルーヴまで、3 ステップ。",
    "s1.title": "一度だけ確認",
    "s1.body": "設定でトラックパッド、グリッドサイズ、MIDI 値を選びます。標準は内蔵トラックパッド、外付け Magic Trackpad も歓迎。",
    "s2.title": "押す",
    "s2.body": "パッドウインドウが最前面に現れます。誤って閉じることはありません——終了できるのはショートカットだけ。",
    "s3.title": "演奏",
    "s3.body": "指一本ごとにパッドが灯り、音が鳴ります。同じパッドの指二本は一音のまま。すべて離せば、静寂が戻ります。",
    "p.fingers": "指", "p.grid": "パッドグリッド", "p.daw": "あなたの DAW",
    "how.note": "125 Hz エンジンがパッドのオン・オフをエッジ検出し、クリーンな Note On / Off を送信——音詰まりは起きません。",
    "specs.eyebrow": "演奏の前に", "specs.title": "必要なもの。",
    "sp1.title": "Force Touch トラックパッド",
    "sp1.body": "2015 年以降の MacBook 内蔵型、または Magic Trackpad 2 以降——内蔵・外付け、お好みで。",
    "sp2.title": "macOS 12 以降",
    "sp2.body": "Apple Silicon は macOS 12+、Intel は macOS 13+。タッチ取得はプライベートフレームワークを使うため、macOS の更新で動かなくなる可能性はあります——その場合も分かりやすいメッセージで終わり、クラッシュはしません。",
    "sp3.title": "アクセシビリティ権限",
    "sp3.body": "演奏中にポインタを止めるためだけに必要です。ポインタを残したい？設定でオフにすれば権限は不要。タッチはそのままポインタも動かします。",
    "sp4.title": "システムジェスチャはオフに",
    "sp4.body": "Mission Control などは macOS 管轄で、確実にはブロックできません。演奏の邪魔になる場合は システム設定 → トラックパッド でオフに。",
    "download.title": "Forchpad を入手。",
    "download.body": "MIT ライセンスの無料オープンソース。Apple Silicon と Intel を一枚のユニバーサルバイナリで。",
    "download.button": "最新版をダウンロード",
    "download.all": "すべてのリリースとノート",
    "download.note": "CI ビルドは ad-hoc 署名です：初回は右クリック → 開く で macOS が実行を許可します。",
    "footer.made": "Mac のために、Swift で。依存ゼロ。",
    "footer.releases": "リリース", "footer.issues": "課題", "footer.license": "MIT ライセンス",
    "footer.oss": "オープンソース、永遠に無料。",
  },

  ko: {
    "doc.title": "Forchpad — 트랙패드를 연주하세요",
    "nav.features": "기능", "nav.how": "작동 방식", "nav.specs": "시스템 요구 사항",
    "nav.download": "다운로드", "nav.cta": "다운로드", "nav.language": "언어",
    "hero.eyebrow": "무료 · 오픈 소스 · macOS",
    "hero.title.1": "트랙패드가,", "hero.title.2": "이제 악기가 됩니다.",
    "hero.sub": "Forchpad는 Mac의 Force Touch 트랙패드를 MIDI 패드 그리드로 바꿔줍니다. 단축키 한 번이면 손가락 하나하나가 음을 연주해 — 그대로 DAW로.",
    "hero.cta.download": "macOS용 다운로드", "hero.cta.github": "GitHub에서 보기",
    "hero.meta": "Apple Silicon은 macOS 12+ · Intel은 macOS 13+ · MIT 라이선스",
    "demo.title": "Forchpad — MIDI 패드",
    "demo.hint": "해 보세요 — 패드를 탭하면 여기서도 소리가 납니다.",
    "m.engine": "125 Hz 엔진", "m.shortcut": "전역 단축키 ⇧⌘E",
    "m.pause": "포인터 일시 정지 ⇧⌘P", "m.deps": "의존성 제로", "m.langs": "8개 언어",
    "features.eyebrow": "기능",
    "features.title": "필요한 건 다 있고, 쓸데없는 건 없습니다.",
    "f1.title": "단축키 하나로 공연 시작",
    "f1.body": "⇧⌘E를 누르면 패드 창이 모든 창 위에 나타납니다 — DAW 세션 도중에도. 다시 누르면 공연 종료, 모든 음이 깔끔하게 꺼집니다.",
    "f2.title": "진짜 MIDI 소스",
    "f2.body": "DAW에는 Forchpad라는 가상 입력이 보입니다 — 채널 10, 노트 36부터라 드럼에 딱. 드라이버도 설정도 필요 없습니다.",
    "f3.title": "포인터는 잠시 정지",
    "f3.body": "연주 중에는 포인터가 얼어붙고 사라져서, 새 나간 클릭이 다른 창에 닿지 않습니다. ⇧⌘P를 누르면 음악이 멈추고 포인터가 돌아옵니다.",
    "f4.title": "그리드는 내 마음대로",
    "f4.body": "기본 3×3, 최대 10×10. 행, 열, MIDI 채널, 기본 노트, 벨로시티, 패드별 색상 — 모두 설정에서.",
    "f5.title": "메뉴 막대에 상주",
    "f5.body": "Dock 아이콘도, 어수선한 창도 없습니다. 조용한 F가 메뉴 막대에서 필요한 순간을 기다립니다.",
    "f6.title": "당신의 언어로",
    "f6.body": "설정에서 즉시 전환 — 기본값은 시스템 언어를 따릅니다.",
    "how.eyebrow": "작동 방식", "how.title": "유리에서 그루브까지, 3단계.",
    "s1.title": "한 번만 확인",
    "s1.body": "설정에서 트랙패드, 그리드 크기, MIDI 값을 고르세요. 기본은 내장 트랙패드, 외장 Magic Trackpad도 환영합니다.",
    "s2.title": "누르기",
    "s2.body": "패드 창이 모든 것 위에 나타납니다. 실수로 닫힐 일은 없습니다 — 단축키만이 공연을 끝냅니다.",
    "s3.title": "연주",
    "s3.body": "손가락 하나하나가 패드를 밝히고 음을 냅니다. 한 패드의 두 손가락도 여전히 한 음. 모두 떼면 고요가 돌아옵니다.",
    "p.fingers": "손가락", "p.grid": "패드 그리드", "p.daw": "당신의 DAW",
    "how.note": "125 Hz 엔진이 패드의 눌림/뗌을 에지 감지해 깨끗한 Note On/Off를 보냅니다 — 끊기는 음은 없습니다.",
    "specs.eyebrow": "연주 전에", "specs.title": "필요한 것.",
    "sp1.title": "Force Touch 트랙패드",
    "sp1.body": "2015년 이후 MacBook 내장형, 또는 Magic Trackpad 2 이상 — 내장이든 외장이든 취향대로.",
    "sp2.title": "macOS 12 이상",
    "sp2.body": "Apple Silicon은 macOS 12+, Intel은 macOS 13+. 터치 캡처는 비공개 프레임워크를 사용하므로 macOS 업데이트로 깨질 수 있습니다 — 그래도 명확한 메시지로 끝나지, 절대 충돌하지 않습니다.",
    "sp3.title": "손쉬운 사용 권한",
    "sp3.body": "연주 중 포인터를 멈추기 위해서만 필요합니다. 포인터를 계속 쓰고 싶다면? 설정에서 끄면 권한 불필요 — 터치가 그대로 포인터도 움직입니다.",
    "sp4.title": "시스템 제스처 끄기",
    "sp4.body": "Mission Control 등은 macOS 소관이라 확실히 막을 수 없습니다. 연주를 방해하면 시스템 설정 → 트랙패드에서 끄세요.",
    "download.title": "Forchpad 받기.",
    "download.body": "MIT 라이선스의 무료 오픈 소스. Apple Silicon과 Intel을 하나의 유니버설 바이너리로.",
    "download.button": "최신 릴리스 다운로드",
    "download.all": "모든 릴리스와 노트",
    "download.note": "CI 빌드는 ad-hoc 서명입니다: 처음 실행할 때 우클릭 → 열기를 하면 macOS가 허용합니다.",
    "footer.made": "Mac을 위해, Swift로. 의존성 제로.",
    "footer.releases": "릴리스", "footer.issues": "이슈", "footer.license": "MIT 라이선스",
    "footer.oss": "오픈 소스, 영원히 무료.",
  },

  fr: {
    "doc.title": "Forchpad — jouez votre trackpad",
    "nav.features": "Fonctionnalités", "nav.how": "Fonctionnement", "nav.specs": "Configuration",
    "nav.download": "Télécharger", "nav.cta": "Télécharger", "nav.language": "Langue",
    "hero.eyebrow": "Gratuit · Open source · macOS",
    "hero.title.1": "Votre trackpad,", "hero.title.2": "désormais un instrument.",
    "hero.sub": "Forchpad transforme le trackpad Force Touch de votre Mac en grille de pads MIDI. Un raccourci, et chaque doigt joue une note — directement dans votre DAW.",
    "hero.cta.download": "Télécharger pour macOS", "hero.cta.github": "Voir sur GitHub",
    "hero.meta": "macOS 12+ sur Apple Silicon · macOS 13+ sur Intel · Licence MIT",
    "demo.title": "Forchpad — pads MIDI",
    "demo.hint": "Allez-y — touchez les pads. Ici aussi, ils sonnent.",
    "m.engine": "Moteur 125 Hz", "m.shortcut": "Raccourci global ⇧⌘E",
    "m.pause": "Pause du pointeur ⇧⌘P", "m.deps": "Zéro dépendance", "m.langs": "8 langues",
    "features.eyebrow": "Fonctionnalités",
    "features.title": "Tout ce qu'il faut. Rien de plus.",
    "f1.title": "Un raccourci pour jouer",
    "f1.body": "⇧⌘E fait apparaître la fenêtre de pads au premier plan — même en pleine session DAW. Pressez-le à nouveau et le spectacle s'achève, chaque note proprement coupée.",
    "f2.title": "Une vraie source MIDI",
    "f2.body": "Votre DAW voit une entrée virtuelle nommée Forchpad — canal 10, notes à partir de 36, parfaite pour la batterie. Aucun pilote, aucune configuration.",
    "f3.title": "Le pointeur fait pause",
    "f3.body": "Pendant que vous jouez, le pointeur se fige et disparaît : aucun clic perdu ne peut atterrir sur une autre fenêtre. ⇧⌘P met la musique en pause et vous le rend.",
    "f4.title": "Votre grille, vos règles",
    "f4.body": "3×3 par défaut, jusqu'à 10×10. Lignes, colonnes, canal MIDI, note de base, vélocité, couleurs par pad — tout se règle dans les Réglages.",
    "f5.title": "Vit dans la barre des menus",
    "f5.body": "Ni icône Dock, ni encombrement. Un F discret attend dans la barre des menus jusqu'au moment voulu.",
    "f6.title": "Parle votre langue",
    "f6.body": "Changement instantané dans les Réglages — et par défaut, il suit la langue du système.",
    "how.eyebrow": "Fonctionnement", "how.title": "Du verre au groove en trois étapes.",
    "s1.title": "Confirmez une fois",
    "s1.body": "Choisissez trackpad, taille de grille et valeurs MIDI dans les Réglages. Le trackpad intégré est le défaut ; les Magic Trackpad externes sont les bienvenus.",
    "s2.title": "Pressez",
    "s2.body": "La fenêtre de pads apparaît au-dessus de tout. Impossible de la fermer par accident — seul le raccourci termine le spectacle.",
    "s3.title": "Jouez",
    "s3.body": "Chaque doigt illumine un pad et joue une note. Deux doigts sur un pad restent une seule note ; tout se lève, le silence revient.",
    "p.fingers": "Doigts", "p.grid": "Grille de pads", "p.daw": "Votre DAW",
    "how.note": "Un moteur à 125 Hz détecte les fronts montants et descendants des pads et envoie des Note On/Off impeccables — jamais de note coincée.",
    "specs.eyebrow": "Avant de jouer", "specs.title": "Ce qu'il vous faut.",
    "sp1.title": "Un trackpad Force Touch",
    "sp1.body": "Intégré aux MacBook depuis 2015, ou Magic Trackpad 2 ou plus récent — intégré ou externe, à vous de choisir.",
    "sp2.title": "macOS 12 ou plus",
    "sp2.body": "macOS 12+ sur Apple Silicon, macOS 13+ sur Intel. La capture tactile passe par un framework privé : une mise à jour de macOS pourrait la casser — ce serait alors un message clair, jamais un plantage.",
    "sp3.title": "Autorisation d'accessibilité",
    "sp3.body": "Uniquement pour mettre le pointeur en pause pendant le jeu. Vous préférez garder le pointeur ? Désactivez la pause dans les Réglages — aucune autorisation demandée, et les touchers pilotent aussi le pointeur.",
    "sp4.title": "Gestes système désactivés",
    "sp4.body": "Mission Control et compagnie relèvent de macOS et ne peuvent être bloqués de façon fiable. S'ils coupent votre groove, désactivez-les dans Réglages Système → Trackpad.",
    "download.title": "Obtenez Forchpad.",
    "download.body": "Gratuit et open source sous licence MIT. Un seul binaire universel pour Apple Silicon et Intel.",
    "download.button": "Télécharger la dernière version",
    "download.all": "Toutes les versions et notes",
    "download.note": "Les builds CI sont signées ad hoc : au premier lancement, clic droit → Ouvrir, et macOS laissera faire.",
    "footer.made": "Fait pour le Mac, en Swift. Zéro dépendance.",
    "footer.releases": "Versions", "footer.issues": "Tickets", "footer.license": "Licence MIT",
    "footer.oss": "Open source, gratuit pour toujours.",
  },

  es: {
    "doc.title": "Forchpad — toca tu trackpad",
    "nav.features": "Funciones", "nav.how": "Cómo funciona", "nav.specs": "Requisitos",
    "nav.download": "Descargar", "nav.cta": "Descargar", "nav.language": "Idioma",
    "hero.eyebrow": "Gratis · Código abierto · macOS",
    "hero.title.1": "Tu trackpad,", "hero.title.2": "ahora un instrumento.",
    "hero.sub": "Forchpad convierte el trackpad Force Touch de tu Mac en una rejilla de pads MIDI. Pulsa un atajo y cada dedo toca una nota — directa a tu DAW.",
    "hero.cta.download": "Descargar para macOS", "hero.cta.github": "Ver en GitHub",
    "hero.meta": "macOS 12+ en Apple Silicon · macOS 13+ en Intel · Licencia MIT",
    "demo.title": "Forchpad — pads MIDI",
    "demo.hint": "Adelante — toca los pads. Aquí también suenan.",
    "m.engine": "Motor de 125 Hz", "m.shortcut": "Atajo global ⇧⌘E",
    "m.pause": "Pausa del puntero ⇧⌘P", "m.deps": "Cero dependencias", "m.langs": "8 idiomas",
    "features.eyebrow": "Funciones",
    "features.title": "Todo lo que necesitas. Nada que no.",
    "f1.title": "Un atajo para tocar",
    "f1.body": "⇧⌘E invoca la ventana de pads por encima de todo — incluso a mitad de sesión en tu DAW. Púlsalo de nuevo y la función termina, con cada nota apagada limpiamente.",
    "f2.title": "Una fuente MIDI de verdad",
    "f2.body": "Tu DAW ve una entrada virtual llamada Forchpad — canal 10, notas desde la 36, lista para percusión. Sin drivers, sin configuración.",
    "f3.title": "El puntero se pausa",
    "f3.body": "Mientras tocas, el puntero se congela y se oculta: ningún clic perdido puede caer sobre otra ventana. ⇧⌘P pausa la música y te lo devuelve.",
    "f4.title": "Tu rejilla, tus reglas",
    "f4.body": "3×3 de serie, hasta 10×10. Filas, columnas, canal MIDI, nota base, velocidad y colores por pad — todo en Ajustes.",
    "f5.title": "Vive en la barra de menús",
    "f5.body": "Sin icono en el Dock, sin desorden. Una F discreta espera en la barra de menús hasta que la necesites.",
    "f6.title": "Habla tu idioma",
    "f6.body": "Cambia al instante en Ajustes — y por defecto sigue el idioma del sistema.",
    "how.eyebrow": "Cómo funciona", "how.title": "Del cristal al groove en tres pasos.",
    "s1.title": "Confirma una vez",
    "s1.body": "Elige trackpad, tamaño de rejilla y valores MIDI en Ajustes. El trackpad integrado es el predeterminado; los Magic Trackpad externos son bienvenidos.",
    "s2.title": "Pulsa",
    "s2.body": "La ventana de pads aparece por encima de todo. No puede cerrarse por accidente — solo el atajo termina la función.",
    "s3.title": "Toca",
    "s3.body": "Cada dedo enciende un pad y toca una nota. Dos dedos en un pad siguen siendo una nota; levanta todo y vuelve el silencio.",
    "p.fingers": "Dedos", "p.grid": "Rejilla de pads", "p.daw": "Tu DAW",
    "how.note": "Un motor a 125 Hz detecta los flancos de bajada y subida de los pads y envía Note On/Off impecables — nunca una nota colgada.",
    "specs.eyebrow": "Antes de tocar", "specs.title": "Lo que necesitas.",
    "sp1.title": "Un trackpad Force Touch",
    "sp1.body": "Integrado en los MacBook desde 2015, o un Magic Trackpad 2 o posterior — integrado o externo, tú eliges.",
    "sp2.title": "macOS 12 o posterior",
    "sp2.body": "macOS 12+ en Apple Silicon, macOS 13+ en Intel. La captura táctil usa un framework privado, así que una actualización de macOS podría romperla — fallaría con un mensaje claro, nunca con un cuelgue.",
    "sp3.title": "Permiso de accesibilidad",
    "sp3.body": "Solo hace falta para pausar el puntero mientras tocas. ¿Prefieres conservar el puntero? Desactiva la pausa en Ajustes — no se pide permiso y los toques también mueven el puntero.",
    "sp4.title": "Gestos del sistema desactivados",
    "sp4.body": "Mission Control y compañía pertenecen a macOS y no se pueden bloquear con fiabilidad. Si interrumpen tu groove, desactívalos en Ajustes del Sistema → Trackpad.",
    "download.title": "Consigue Forchpad.",
    "download.body": "Gratuito y de código abierto bajo licencia MIT. Un único binario universal para Apple Silicon e Intel.",
    "download.button": "Descargar la última versión",
    "download.all": "Todas las versiones y notas",
    "download.note": "Las compilaciones CI llevan firma ad hoc: en el primer arranque, clic derecho → Abrir, y macOS lo dejará pasar.",
    "footer.made": "Hecho para el Mac, en Swift. Cero dependencias.",
    "footer.releases": "Versiones", "footer.issues": "Problemas", "footer.license": "Licencia MIT",
    "footer.oss": "Código abierto, gratis para siempre.",
  },

  ar: {
    "doc.title": "Forchpad — اعزف على لوحة اللمس",
    "nav.features": "الميزات", "nav.how": "كيف يعمل", "nav.specs": "المتطلبات",
    "nav.download": "تنزيل", "nav.cta": "تنزيل", "nav.language": "اللغة",
    "hero.eyebrow": "مجاني · مفتوح المصدر · macOS",
    "hero.title.1": "لوحة اللمس لديك،", "hero.title.2": "صارت آلة موسيقية.",
    "hero.sub": "يحوّل Forchpad لوحة اللمس Force Touch في Mac إلى شبكة من لوحات MIDI. اضغط اختصارًا واحدًا فيعزف كل إصبع نوتة — مباشرة إلى DAW لديك.",
    "hero.cta.download": "نزّل لنظام macOS", "hero.cta.github": "اعرضه على GitHub",
    "hero.meta": "macOS 12+ على Apple Silicon · macOS 13+ على Intel · رخصة MIT",
    "demo.title": "Forchpad — لوحات MIDI",
    "demo.hint": "تفضّل — المس اللوحات. تصدر صوتًا هنا أيضًا.",
    "m.engine": "محرك 125 هرتز", "m.shortcut": "اختصار عام ⇧⌘E",
    "m.pause": "إيقاف المؤشر ⇧⌘P", "m.deps": "بلا تبعيات", "m.langs": "8 لغات",
    "features.eyebrow": "الميزات",
    "features.title": "كل ما تحتاجه. ولا شيء زائد.",
    "f1.title": "اختصار واحد للعزف",
    "f1.body": "⇧⌘E يستدعي نافذة اللوحات فوق كل شيء — حتى في منتصف جلسة DAW. اضغطه مجددًا فينتهي العرض وكل نوتة تنطفئ بنظافة.",
    "f2.title": "مصدر MIDI حقيقي",
    "f2.body": "يرى DAW لديك مدخلًا افتراضيًا باسم Forchpad — القناة 10، والنوتات من 36 صعودًا، جاهز للإيقاعات. بلا تعريفات، بلا إعداد.",
    "f3.title": "المؤشر يتوقف مؤقتًا",
    "f3.body": "أثناء العزف يتجمد المؤشر ويختفي، فلا تقع نقرة شاردة على نافذة أخرى. ⇧⌘P يوقف الموسيقى ويعيد المؤشر إليك.",
    "f4.title": "شبكتك بقواعدك",
    "f4.body": "3×3 افتراضيًا، وحتى 10×10. الصفوف والأعمدة وقناة MIDI والنوتة الأساسية وشدة الضغط وألوان كل لوحة — كلها في الإعدادات.",
    "f5.title": "يسكن شريط القوائم",
    "f5.body": "بلا أيقونة في Dock وبلا فوضى. حرف F هادئ ينتظر في شريط القوائم حتى لحظة الحاجة.",
    "f6.title": "يتحدث لغتك",
    "f6.body": "بدّل فورًا من الإعدادات — ويتبع افتراضيًا لغة النظام.",
    "how.eyebrow": "كيف يعمل", "how.title": "من الزجاج إلى الإيقاع في ثلاث خطوات.",
    "s1.title": "أكّد مرة واحدة",
    "s1.body": "اختر لوحة اللمس وحجم الشبكة وقيم MIDI من الإعدادات. لوحة اللمس المدمجة هي الافتراضية، ولوحات Magic Trackpad الخارجية مرحّب بها.",
    "s2.title": "اضغط",
    "s2.body": "تظهر نافذة اللوحات فوق كل شيء. لا يمكن إغلاقها خطأً — الاختصار وحده ينهي العرض.",
    "s3.title": "اعزف",
    "s3.body": "كل إصبع يضيء لوحة ويعزف نوتة. إصبعان على لوحة واحدة يبقيان نوتة واحدة؛ ارفع الجميع فيعود الصمت.",
    "p.fingers": "الأصابع", "p.grid": "شبكة اللوحات", "p.daw": "DAW الخاص بك",
    "how.note": "محرك بسرعة 125 هرتز يرصد حواف ضغط اللوحات ورفعها ويرسل Note On/Off نظيفة — لا نوتات عالقة أبدًا.",
    "specs.eyebrow": "قبل أن تعزف", "specs.title": "ما ستحتاجه.",
    "sp1.title": "لوحة لمس Force Touch",
    "sp1.body": "مدمجة في أجهزة MacBook منذ 2015، أو Magic Trackpad 2 أو أحدث — مدمجة أو خارجية، الخيار لك.",
    "sp2.title": "macOS 12 أو أحدث",
    "sp2.body": "macOS 12+ على Apple Silicon وmacOS 13+ على Intel. التقاط اللمس يعتمد على إطار عمل خاص، فقد يعطّله تحديث macOS — وسيفشل حينها برسالة واضحة، لا بانهيار أبدًا.",
    "sp3.title": "إذن إمكانية الوصول",
    "sp3.body": "مطلوب فقط لإيقاف المؤشر أثناء العزف. تفضّل إبقاء المؤشر؟ أوقف الإيقاف من الإعدادات — لا إذن مطلوب، وتظل اللمسات تحرك المؤشر أيضًا.",
    "sp4.title": "عطّل إيماءات النظام",
    "sp4.body": "Mission Control وأخواتها من اختصاص macOS ولا يمكن حجبها بثقة. إن قطعت إيقاعك، عطّلها من إعدادات النظام ← لوحة اللمس.",
    "download.title": "احصل على Forchpad.",
    "download.body": "مجاني ومفتوح المصدر برخصة MIT. ملف ثنائي عالمي واحد لـ Apple Silicon وIntel.",
    "download.button": "نزّل أحدث إصدار",
    "download.all": "كل الإصدارات والملاحظات",
    "download.note": "بِنى CI موقّعة توقيعًا مخصصًا (ad hoc): عند أول تشغيل، انقر بزر اليمين ← فتح، وسيسمح macOS بتشغيله.",
    "footer.made": "صُنع للـ Mac بلغة Swift. بلا تبعيات.",
    "footer.releases": "الإصدارات", "footer.issues": "المشكلات", "footer.license": "رخصة MIT",
    "footer.oss": "مفتوح المصدر، مجاني للأبد.",
  },
};

(function () {
  const STORE_KEY = "forchpad-lang";
  const RTL = new Set(["ar"]);
  const codes = new Set(FORCHPAD_LANGS.map((l) => l.code));

  function detect() {
    try {
      const saved = localStorage.getItem(STORE_KEY);
      if (saved && codes.has(saved)) return saved;
    } catch (e) { /* private mode */ }
    const nav = (navigator.language || "en").toLowerCase();
    if (nav.startsWith("zh")) {
      return /tw|hk|mo|hant/.test(nav) ? "zh-Hant" : "zh-Hans";
    }
    for (const code of codes) {
      if (nav.startsWith(code.toLowerCase())) return code;
    }
    return "en";
  }

  function apply(code) {
    const dict = FORCHPAD_I18N[code] || FORCHPAD_I18N.en;
    const fallback = FORCHPAD_I18N.en;
    document.querySelectorAll("[data-i18n]").forEach((el) => {
      const key = el.getAttribute("data-i18n");
      const val = dict[key] || fallback[key];
      if (val) el.textContent = val;
    });
    document.querySelectorAll("[data-i18n-aria]").forEach((el) => {
      const key = el.getAttribute("data-i18n-aria");
      const val = dict[key] || fallback[key];
      if (val) el.setAttribute("aria-label", val);
    });
    document.title = dict["doc.title"] || fallback["doc.title"];
    document.documentElement.lang = code;
    document.documentElement.dir = RTL.has(code) ? "rtl" : "ltr";

    const meta = FORCHPAD_LANGS.find((l) => l.code === code) || FORCHPAD_LANGS[0];
    const current = document.getElementById("langCurrent");
    if (current) current.textContent = meta.short;
    document.querySelectorAll(".lang-menu button").forEach((b) => {
      b.classList.toggle("active", b.dataset.code === code);
    });
    try { localStorage.setItem(STORE_KEY, code); } catch (e) { /* private mode */ }
  }

  function buildMenu() {
    const menu = document.getElementById("langMenu");
    if (!menu) return;
    FORCHPAD_LANGS.forEach((l) => {
      const li = document.createElement("li");
      const btn = document.createElement("button");
      btn.type = "button";
      btn.textContent = l.name;
      btn.dataset.code = l.code;
      btn.setAttribute("role", "option");
      btn.addEventListener("click", () => {
        apply(l.code);
        menu.classList.remove("open");
        document.getElementById("langButton")?.setAttribute("aria-expanded", "false");
      });
      li.appendChild(btn);
      menu.appendChild(li);
    });
  }

  document.addEventListener("DOMContentLoaded", () => {
    buildMenu();
    apply(detect());

    const btn = document.getElementById("langButton");
    const menu = document.getElementById("langMenu");
    if (btn && menu) {
      btn.addEventListener("click", (e) => {
        e.stopPropagation();
        const open = menu.classList.toggle("open");
        btn.setAttribute("aria-expanded", String(open));
      });
      document.addEventListener("click", (e) => {
        if (!menu.contains(e.target) && e.target !== btn) {
          menu.classList.remove("open");
          btn.setAttribute("aria-expanded", "false");
        }
      });
      document.addEventListener("keydown", (e) => {
        if (e.key === "Escape") {
          menu.classList.remove("open");
          btn.setAttribute("aria-expanded", "false");
        }
      });
    }
  });
})();
