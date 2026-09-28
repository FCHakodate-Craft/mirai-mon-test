# ミライモン 登録テスト

同一URLで端末ごとに1～3人を登録・切り替える試作品。キャラクター育成、端末間引き継ぎ、来館特典は未実装。

## 設定
1. Supabase の Authentication → Providers で Anonymous sign-ins を有効にする。
2. SQL Editor で schema.sql を実行する。
3. index.html を GitHub Pages などの HTTPS サイトで公開する。
4. 最初の画面に Project URL と publishable key を入力する。secret/service_role key は入力しない。
5. A/B/C の各端末で同じURLを開き、1/2/3人登録する。C端末の4人目が拒否されることと、各端末を再起動しても自分の登録だけ表示されることを確認する。

## テスト上の限界
匿名認証のセッションはブラウザに保存される。保存データを消した場合や別のブラウザでは新しい匿名利用者になるため、物理端末あたり3人の厳密な保証にはならない。登録済みプロフィールは試作画面から削除できない。実名などの個人情報は入力しないこと。
