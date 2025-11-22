# Piano 88 Keys - 寿司打スタイル音ゲー 

88鍵盤ピアノアプリに寿司打風のコースシステムを搭載！

##  インストール方法

### 方法1: APKを直接インストール（超カンタン！）
1. **[Releases](https://github.com/furukawa1020/sushipiano/releases)** ページへGO！
2. 最新の `app-release.apk` をダウンロード
3. Androidデバイスで開く
4. **インストール完了！** 

>  初回は「提供元不明のアプリ」許可が必要な場合あり

### 方法2: 自分でビルド（開発者向け）
FlutterとAndroid Studio入ってる人はこっち！

```bash
# 1. リポジトリをクローン
git clone https://github.com/furukawa1020/sushipiano.git
cd sushipiano

# 2. 依存関係インストール
flutter pub get

# 3. APKビルド（リリース版）
flutter build apk --release

# 4. APKは build/app/outputs/flutter-apk/app-release.apk に生成される！
```

**インストール:**
```bash
# デバイスをUSB接続して
adb install build/app/outputs/flutter-apk/app-release.apk
```

**必要な環境:**
- Flutter SDK (latest stable)
- Android Studio + Android SDK
- NDK 26.3.11579264以上
- CMake 3.10.2以上（C++ビルド用）
- 外部Bluetoothスピーカー
※補足 このサイネージにはスピーカーないので必須です！

---

##  主な機能
### ピアノモード
波紋出したり色々できます。
処理軽くするために色々頑張りましたが正直激重です…
基本的に単音、和音、分けて演奏してください〜
だいぶマシになりましたがまじで応答性悪いです…
のでPR大歓迎！軽くしたいよ〜！
###  寿司打コースシステム
- **3000円コース** (初級): きらきら星、カエルの歌、ちょうちょう
- **5000円コース** (中級): ジングルベル、ハッピーバースデー、メリーさんの羊、エリーゼのために
- **10000円コース** (上級): All I Want for Christmas、天国と地獄、トルコ行進曲、ラカンパネラ
  (一万円コースは音微妙で曲になってなくて調整中です…)

###  自動演奏モード
- ボタンで自動演奏開始/停止
- ボタンで曲スキップ（全13曲）
- 寿司エフェクト付き！

###  C++ネイティブオーディオ
- 低レイテンシ音声生成
- Taylor展開による高速sin計算
- ADSRエンベロープ処理
- 5倍音合成でリッチな音色(これは微妙普通にチープ)

##  動作環境
- Android 8.0
- APKサイズ: 23.2MB
- デジタルサイネージLD290EJ5-FPN1ていうやつ用のプロジェクト。気になる人は調べてみてください〜！
- Bluetoothスピーカー(

##  技術スタック
- Flutter SDK
- C++17 (ネイティブオーディオ生成)
- CMake build system
- JNI (Java Native Interface)
- Method Channel (Flutter-Native通信)

##  ビルド方法
```bash
flutter build apk --release
```

##  ライセンス
MIT License

---

## これがほんとの寿司打！🍣
