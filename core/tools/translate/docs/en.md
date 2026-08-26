## Package Information

- **Name:** Translate Shell
- **Tags:** translation, languages
- **Project:** https://www.soimort.org/translate-shell/
- **Source:** https://github.com/soimort/translate-shell
- **Dependencies:** None required by Core

## What is it?

:speech_balloon: Command-line translator using Google Translate, Bing Translator, Yandex.Translate, etc.

## How to use it?

### Usage

$ trs
    Usage: translate {[SL]=[TL]} TEXT|TEXT_FILENAME
           translate {[SL]=[TL1]+[TL2]+...} TEXT|TEXT_FILENAME
           translate TEXT1 TEXT2 ...

    TEXT: Source text (The text to be translated)
          Can also be the filename of a plain text file.
      SL: Source language (The language of the source text)
      TL: Target language (The language to translate the source text into)
          Language codes as listed here:
        * http://developers.google.com/translate/v2/using_rest#language-params
          Ignore the code where you want the system to identify it for you.
          Prefix the code with an ampersat @ to show the result phonetically.

### Examples

Translate anything of any language into English.

    $ trs Weltschmerz
    world-weariness

    $ trs Weltschmerz コスプレ "Bon appétit." 周星馳
    world-weariness
    Cosplay
    Good appetite.
    Stephen Chow

Translate "Hello, world" into Esperanto.

    $ trs {=eo} "Hello, world"
    Saluton, mondo

Translate "Hello, world" into Chinese, Japanese, Korean and Thai.

    $ trs {=zh+ja+ko+th} "Hello, world"
    您好，世界
    世界よこんにちは
    안녕하세요, 세계
    สวัสดีโลก

Translate a Latin phrase into English.

    $ trs {la=} "Ego sum qui sum."
    I am who I am.

Translate Japanese to French.

    $ trs {ja=fr} "愛してる。"
    Je t'aime!

Show the phonetics of a Japanese quote and translate it into both English and Traditional Chinese.

    $ trs {ja=@ja+en+zh-TW} "あなたは死なないわ、私が守るもの。"
    Anata wa shinanai wa, watashi ga mamoru mono. 
    What you'll not die, I will protect you.
    你會不會死，我會保護你。

Translate an English context text file into Chinese.

e.g. `POETRY.txt`:

    Afternoon Of Circus And Citadel
    by Paul Celan

    In Brest, before the Fire-Hoops burning,
    In the Tent, where Tigers sprang,
    there I heard you, Finite, singing,
    there I saw you, Mandelstam.

## Notes

- Supported platforms: **termux, ubuntu, wsl**.
- Termux uses platform-specific installers; Ubuntu/WSL use official channels.
- Spanish (when available): `core show translate:es`.
