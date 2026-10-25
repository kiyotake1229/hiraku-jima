# ひらく島 iOSアプリ（Capacitor）

Webアプリ本体（`../index.html`）をネイティブiOSアプリとして同梱したプロジェクトです。

- **申請・アップロードは岩崎さんが実施** → 手順は [`岩崎さんへの引き渡し手順.md`](岩崎さんへの引き渡し手順.md)
- このREADMEは開発側（アプリを作る人）向けのメモです

---

## 現在の状態（2026-10-23）

| 項目 | 状態 |
|------|------|
| Capacitorプロジェクト | 構築済み（`work.ltv.hiraku` / ひらく島） |
| Xcodeプロジェクト生成 | 済み（`ios/App/App.xcworkspace`） |
| Webアプリ同梱 | 済み（`ios/App/App/public/`。three.js r128 をローカル同梱し、CDN 参照なし） |
| アプリアイコン・スプラッシュ | 生成済み（1024px・透過なし） |
| ネイティブ触覚・通知 | 組み込み済み（`../index.html` の `NATIVE` 分岐） |
| `pod install` | 完了済み（4 pods 統合済み） |
| Xcode でのビルド | **未確認**（作成した Mac に Xcode がない。コマンドラインツールのみ） |
| `node_modules/` | Dropbox 同期を軽くするため削除済み。作業前に `npm install` |

## 構成

```
ios-app/
├── package.json              npm設定（Capacitor + プラグイン）
├── capacitor.config.json     アプリID・名前・WebView設定
├── sync-web.sh               ../ のWeb本体を www/ にコピーし、three.js の CDN 参照をローカルに書き換える
├── vendor/three.min.js       同梱用 three.js r128（sync-web.sh が初回だけ CDN から取得）
├── assets/                   アイコン元画像（icon.png 1024px 透過なし / logo.png スプラッシュ用）
├── www/                      同梱するWeb資産（自動生成・git管理外）
└── ios/                      Xcodeプロジェクト
    └── App/App.xcworkspace   ← これを開く
```

## よく使うコマンド

```bash
npm install        # 依存取得（初回・node_modules 削除後）
npm run sync       # ../index.html の変更をiOSプロジェクトへ反映（three.js 同梱・pod install 込み）
npm run icons      # アイコン・スプラッシュ再生成（assets/ から）
npm run open       # Xcodeで開く（要Xcode）
```

## アプリ本体を修正したら

1. `../index.html` を編集（Web版・iOS版は同じファイル）
2. `npm run sync` を実行
3. Xcodeで再ビルド
4. 終わったら `rm -rf node_modules`（Dropbox 対策）

## ネイティブ専用の動作

`../index.html` 内で `NATIVE`（Capacitor 検出）により分岐しています。Web版では従来どおり。

| 機能 | Web版 | ネイティブ版 |
|------|-------|-------------|
| 触覚 `haptic(ms)` | `navigator.vibrate` | Capacitor Haptics。ms（配列は最大値）が 30 以上で HEAVY、15 以上で MEDIUM、それ未満は LIGHT |
| 通知 | なし | 起動のたびに、翌朝 9:00 に「今日のおねがいが届いたよ」を1回予約し直す（id 2001）。初回起動で許可ダイアログ |
| Service Worker | http/https で登録 | 登録しない（同梱なので不要） |

## アイコンの作り方

`../icon.svg` は角丸（`rx="112"`）なので、iOS 用には角丸を外した正方形で描き直して透過を落としている。

```bash
sed 's/rx="112"/rx="0"/' ../icon.svg > /tmp/icon-square.svg
qlmanage -t -s 1024 -o /tmp /tmp/icon-square.svg      # → /tmp/icon-square.svg.png（透過あり）
# PIL で空色 #3fa8e0 に合成して assets/icon.png（RGB）に。logo.png は角丸のまま透過で保存
npm run icons
```

## メモ

- `npm run sync` の最後に `xcodebuild clean` が失敗しても、Pods の統合は済んでいる（Xcode がない環境で出る）
- iPhone は縦画面固定（`Info.plist` の `UISupportedInterfaceOrientations`）。iPad は縦横対応のまま
- `contentInset: never` にしてあり、本体側の `env(safe-area-inset-*)` でノッチを避ける
- `Pods/` `node_modules/` `www/` はgit管理外
