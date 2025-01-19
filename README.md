# Moje dotfiles

## Stow


### Instrukcja

Aby dodać linki na kompie, usunąć poszczególne katalogi z dotfiles,
a następnie wywołać, żeby utworzyć w to miejsce symlinki:
```bash
run.sh
```

### Jak działa stow, standarowe podejści

Wygenerowanie linków w oparciu o zawartośc `dotfiles`:
```
stow .
```

Jeśli jednak pliki docelowe istnieją, żeby ich nie kasować, można użyć poniższej
komendy. Oryginalne pliki zostaną skopiowane (i nadpiszą to co jes dotfiles), 
a następnie zastąpione linkami.
```
stow --adopt .
```

### Inne podejście

Gość pokazuje (tu)[https://www.youtube.com/watch?v=90xMTKml9O0] inne podejście,
potencjalnie spoko, do rozważenia.

W katalogu dotfiles ma podkatalogi dla każego programu. Ale do każdego podkatalogu
będziemy się odnosić tak jakby to był dotfiles z poprzedniego podejścia. Czyli
przykładowa ścieżka 
```
~/dotfiles/wezterm/.config/wezterm/wezterm.lua
~/dotfiles/bash/.bashrc
```
i wtedy komendą
```
stow wezterm
```
ogarnie ten jeden program, albo poniższą komendą wszystko co jest w katalogach:
```
stow */
```
Pierwsze podejście umożliwia oczywiście podejście indywidualne do różnych maszyn.
Dlatego napisałem skrypt, który zainstaluje wszystko z automatu:

```bash
run.sh
```


## Fish

Poza konfiguracją fish, jest jeszcze w katalogu `~/bin` fishmarks.

### fishmarks

### tide

Jak pisze autor, The ultimate Fish prompt. 
[https://github.com/IlanCosman/tide](https://github.com/IlanCosman/tide)

Modyfikacje jakie wprowadziłem, to dodanie innej ikony dla git-a, oraz
usunięcie spacji między ikoną a nazwą gałęzi.

## vimium
Roszerzenie przeglądarki. Jest to katalog, z którego należy później zaimportować
ustawienia. Nie wiem gdzie oryginalnie one leżą. 

Po dokonanych modyfikacjach w ustawieniach vimium, należy ustawienia 
wyeksportować w to miejsce.

