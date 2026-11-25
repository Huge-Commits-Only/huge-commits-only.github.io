# huge-commits-only.github.io

Strona organizacji [Huge Commits Only](https://github.com/Huge-Commits-Only), publikowana na GitHub Pages: https://huge-commits-only.github.io/

Statyczny HTML i CSS generowany przez Jekyll. Bez JavaScriptu, ciasteczek i zasobów z zewnątrz; ścisłe Content-Security-Policy i [security.txt](.well-known/security.txt).

## Nowy projekt na stronie
1. Wrzuć do `assets/projects/` trzy pliki o nazwie projektu (`<slug>`):
   - `<slug>.mp4`: demo, 10–20 s, szerokość 1040 px, bez dźwięku;
   - `<slug>.jpg`: kadr z demo (plakat wyświetlany przed startem wideo);
   - `<slug>.svg`: ikona aplikacji.

   Z GIF-a w README projektu:
   ```bash
   ffmpeg -i demo.gif -movflags +faststart -pix_fmt yuv420p -vf "scale=1040:-2,setsar=1" -c:v libx264 -crf 24 -an assets/projects/<slug>.mp4
   ffmpeg -ss 5 -i demo.gif -vf setsar=1 -frames:v 1 -q:v 3 assets/projects/<slug>.jpg
   ```
2. Dopisz wpis w [`_data/projects.yml`](_data/projects.yml), wzorując się na istniejących. Kolory `accent` i `accent2` weź z interfejsu aplikacji; `width` i `height` to wymiary wideo.
3. Otwórz pull request. CI sprawdza wpis (wymagane pola, istniejące pliki, adresy `https://`) i zbudowaną stronę (brak skryptów, zasobów z zewnątrz i niedziałających linków). Po scaleniu strona publikuje się sama.

Na stronę trafiają tylko projekty z publicznych repozytoriów.

## Podgląd lokalnie
```bash
docker run --rm -v "$PWD:/srv/jekyll" -p 4000:4000 jekyll/jekyll jekyll serve
```
