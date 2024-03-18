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

## Fish

Poza konfiguracją fish, jest jeszcze w katalogu `~/bin` fishmarks.

### fishmarks

## vimium
Roszerzenie przeglądarki. Jest to katalog, z którego należy później zaimportować
ustawienia. Nie wiem gdzie oryginalnie one leżą. 

Po dokonanych modyfikacjach w ustawieniach vimium, należy ustawienia 
wyeksportować w to miejsce.

