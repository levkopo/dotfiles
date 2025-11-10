#!/bin/bash
set -e

DOTFILES_REPO="https://github.com/levkopo/dotfiles"
DOTFILES_DIR="$HOME/.config/levkopo-dotfiles"
BACKUP_DIR="$HOME/.config/config-backups/$(date +%F_%T)"

echo "Клонирование репозитория в $DOTFILES_DIR..."
[ -d "$DOTFILES_DIR" ] && rm -rf "$DOTFILES_DIR"
mkdir -p "$DOTFILES_DIR"
chmod 755 "$DOTFILES_DIR"
git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
cd "$DOTFILES_DIR"

echo "Создание резервной копии старых конфигов в $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"

CONFIGS=(ags fastfetch hypr)

for config in "${CONFIGS[@]}"; do
    if [ -d "$HOME/.config/$config" ]; then
        echo "Бэкап конфига: $config"
        mv "$HOME/.config/$config" "$BACKUP_DIR/"
    fi
    echo "Создание символической ссылки для $config..."
    ln -s "$DOTFILES_DIR/configs/$config" "$HOME/.config/$config"
done

hyprctl reload

echo "Пользовательские конфиги успешно установлены."

echo "Настройка GRUB..."
sudo cp ./grub/default/grub /etc/default/grub
sudo cp -r ./grub/themes/* /usr/share/grub/themes/
echo "Пересборка конфигурации GRUB. Это может занять некоторое время..."
sudo grub-mkconfig -o /boot/grub/grub.cfg
echo "GRUB успешно настроен."

echo "Настройка Plymouth..."
sudo cp -r ./plymouth/themes/* /usr/share/plymouth/themes/
sudo cp ./plymouth/plymouthd.conf /etc/plymouth/plymouthd.conf
sudo mkinitcpio -P

echo "Plymouth успешно настроен."

echo "Настройка SDDM..."
sudo cp -r ./sddm/themes/* /usr/share/sddm/themes/
sudo cp ./sddm/sddm.conf /etc/sddm.conf
sudo mkinitcpio -P

echo "SDDM успешно настроен."

echo "Настройка службы обновления.."
sudo cp dotfiles-sync.service /etc/systemd/system/dotfiles-sync.service
sudo systemctl daemon-reload
sudo systemctl enable dotfiles-sync.service
echo "Cлужба обновления успешно настроена"

echo "Установка завершена! Перезагрузите систему, чтобы увидеть все изменения."