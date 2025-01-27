
# Uruchomienie komendy stow z wybranymi katalogami
# W szczególności niektóre konfiguracje mogą być przeznaczone tylko na
# jedną maszynę. 

if [ $(uname -n) = arch ]; then
   stow bash_arch
fi
stow bin
stow cheat
stow eza
stow fish
stow nvim
#vimium jest konfiguracją do zaimportowania z dodatku
stow wezterm
