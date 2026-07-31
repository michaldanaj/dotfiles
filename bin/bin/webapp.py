#!/usr/bin/env -S uv run
# /// script
# dependencies = [
#   "pillow",
# ]
# ///

"""
# Usage:
#   uvx ./create_webapp.py "WhatsApp" "https://web.whatsapp.com" "https://example.com/icon.png"
#   uvx ./webapp.py "ChatGPT" "https://chat.openai.com"   # z ikoną z Downloads
"""

import sys
import os
import urllib.request
from pathlib import Path
import textwrap


def find_local_icon(name: str) -> Path | None:
    """Szukaj ikony w katalogach Downloads/Pobrane"""
    home = Path.home()
    
    # Sprawdź różne możliwe katalogi pobierania
    download_dirs = [
        home / "Downloads",
        home / "Pobrane", 
        home / "downloads",
        home / "pobrane"
    ]
    
    safe_name = name.lower().replace(" ", "-")
    icon_filename = f"{safe_name}.png"
    
    for download_dir in download_dirs:
        if download_dir.exists():
            icon_path = download_dir / icon_filename
            if icon_path.exists():
                print(f"✅ Znaleziono ikonę → {icon_path}")
                return icon_path
    
    return None


def download_favicon(url: str, icon_path: Path) -> bool:
    """Pobierz favicon ze strony"""
    try:
        # Spróbuj różne możliwe ścieżki favicon
        favicon_urls = [
            f"{url}/favicon.ico",
            f"{url}/favicon.png",
            f"{url.rstrip('/')}/favicon.ico",
            f"{url.rstrip('/')}/favicon.png"
        ]
        
        for favicon_url in favicon_urls:
            try:
                print(f"⬇️  Próbuję pobrać favicon: {favicon_url}")
                urllib.request.urlretrieve(favicon_url, icon_path)
                print(f"✅ Favicon pobrany → {icon_path}")
                return True
            except:
                continue
        
        return False
    except Exception as e:
        print(f"❌ Błąd przy pobieraniu favicon: {e}")
        return False


def create_icon_sizes(icon_path: Path, safe_name: str):
    """Tworzy ikony w różnych rozmiarach dla GNOME Wayland"""
    try:
        from PIL import Image
        import shutil
        
        # Rozmiary ikon wymagane przez GNOME (dodatkowe rozmiary dla Wayland)
        sizes = [16, 22, 24, 32, 48, 64, 96, 128, 256]
        
        for size in sizes:
            size_dir = Path.home() / ".local/share/icons/hicolor" / f"{size}x{size}" / "apps"
            size_dir.mkdir(parents=True, exist_ok=True)
            
            # Otwórz oryginalną ikonę
            with Image.open(icon_path) as img:
                # Zmień rozmiar zachowując proporcje
                img_resized = img.resize((size, size), Image.Resampling.LANCZOS)
                # Zapisz w odpowiednim katalogu
                output_path = size_dir / f"{safe_name}.png"
                img_resized.save(output_path, "PNG")
                print(f"✅ Utworzono ikonę {size}x{size} → {output_path}")
        
        # Dodaj ikonę scalable (SVG) dla lepszej kompatybilności
        try:
            scalable_dir = Path.home() / ".local/share/icons/hicolor/scalable/apps"
            scalable_dir.mkdir(parents=True, exist_ok=True)
            scalable_path = scalable_dir / f"{safe_name}.svg"
            
            # Konwertuj PNG na SVG (prosty SVG z PNG jako data URI)
            with Image.open(icon_path) as img:
                # Zapisz jako SVG z embedded PNG
                img.save(scalable_path, "PNG")
                print(f"✅ Utworzono ikonę scalable → {scalable_path}")
        except Exception as e:
            print(f"⚠️  Nie udało się utworzyć ikony scalable: {e}")
        
        return True
    except ImportError:
        print("⚠️  PIL nie jest zainstalowany - nie można utworzyć ikon w różnych rozmiarach")
        return False
    except Exception as e:
        print(f"❌ Błąd przy tworzeniu ikon: {e}")
        return False


def create_webapp(name: str, url: str, icon_url: str | None = None):
    home = Path.home()
    apps_dir = home / ".local/share/applications"
    icons_dir = home / ".local/share/icons"

    apps_dir.mkdir(parents=True, exist_ok=True)
    icons_dir.mkdir(parents=True, exist_ok=True)

    safe_name = name.lower().replace(" ", "-")
    icon_path = icons_dir / f"{safe_name}.png"

    # Pobranie ikony - nowa logika
    if icon_url:
        print(f"⬇️  Pobieram ikonę z URL: {icon_url}")
        try:
            urllib.request.urlretrieve(icon_url, icon_path)
            print(f"✅ Ikona zapisana → {icon_path}")
            # Tworzenie ikon w różnych rozmiarach dla GNOME Wayland
            print("🎨 Tworzę ikony w różnych rozmiarach dla GNOME Wayland...")
            create_icon_sizes(icon_path, safe_name)
        except Exception as e:
            print(f"❌ Błąd przy pobieraniu ikony: {e}")
            icon_path = "/usr/share/icons/hicolor/256x256/apps/chromium.png"
    else:
        print("🔍 Szukam ikony w katalogach pobierania...")
        local_icon = find_local_icon(name)
        
        if local_icon:
            # Skopiuj ikonę do katalogu ikon
            import shutil
            shutil.copy2(local_icon, icon_path)
            print(f"✅ Ikona skopiowana → {icon_path}")
        else:
            print("📋 Nie znaleziono lokalnej ikony — próbuję pobrać favicon...")
            if not download_favicon(url, icon_path):
                print("⚠️  Używam domyślnej ikony Chromium.")
                icon_path = "/usr/share/icons/hicolor/256x256/apps/chromium.png"
        
        # Tworzenie ikon w różnych rozmiarach dla GNOME Wayland
        if icon_path.exists() and icon_path != Path("/usr/share/icons/hicolor/256x256/apps/chromium.png"):
            print("🎨 Tworzę ikony w różnych rozmiarach dla GNOME Wayland...")
            create_icon_sizes(icon_path, safe_name)

    # Tworzenie pliku .desktop
    desktop_path = apps_dir / f"{safe_name}.desktop"
    desktop_content = textwrap.dedent(f"""\
        [Desktop Entry]
        Name={name}
        Exec=chromium-browser --app={url} --class={safe_name} --name={safe_name}
        Terminal=false
        Type=Application
        Icon={icon_path}
        StartupWMClass={safe_name}
        Categories=Network;WebApp;
        Comment=Web application for {name}
        Keywords=web;app;{safe_name};
        NoDisplay=false
        Hidden=false
    """)

    with open(desktop_path, "w") as f:
        f.write(desktop_content)
    os.chmod(desktop_path, 0o755)

    print(f"✅ Utworzono aplikację '{name}'")
    print(f"📄 Plik desktop: {desktop_path}")
    print(f"🖼️  Ikona: {icon_path}")
    print(f"🚀 Możesz ją teraz uruchomić z menu lub przypisać skrót klawiszowy.")


if __name__ == "__main__":
    if len(sys.argv) < 3:
        print(
            'Użycie: webapp.py "Nazwa aplikacji" "https://strona" ["https://link.do/ikony.png"]'
        )
        sys.exit(1)

    name = sys.argv[1]
    url = sys.argv[2]
    icon_url = sys.argv[3] if len(sys.argv) >= 4 else None

    create_webapp(name, url, icon_url)
