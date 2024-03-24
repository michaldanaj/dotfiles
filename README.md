# Moje dotfiles

## Stow

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

Gość pokazuje (tu)[https://www.youtube.com/watch?v=90xMTKml9O0] inne podejście, potencjalnie spoko, do rozważenia.

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

## Fish

Poza konfiguracją fish, jest jeszcze w katalogu `~/bin` fishmarks.

### fishmarks

## vimium
Roszerzenie przeglądarki. Jest to katalog, z którego należy później zaimportować
ustawienia. Nie wiem gdzie oryginalnie one leżą. 

Po dokonanych modyfikacjach w ustawieniach vimium, należy ustawienia 
wyeksportować w to miejsce.

