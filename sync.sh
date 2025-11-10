#!/bin/bash
set -e

DOTFILES_REPO="https://github.com/levkopo/dotfiles"
DOTFILES_DIR="/usr/share/levkopo-dotfiles"
BACKUP_DIR="$HOME/.config/config-backups/$(date +%F_%T)"

echo "Клонирование репозитория в $DOTFILES_DIR..."
[ -d "$DOTFILES_DIR" ] && rm -rf "$DOTFILES_DIR"
git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
cd "$DOTFILES_DIR"

echo "Создание резервной копии старых конфигов в $BACKUP_DIR..."
sudo mkdir -p "$BACKUP_DIR"

CONFIGS=(ags fastfetch hypr)

for config in "${CONFIGS[@]}"; do
    if [ -d "$HOME/.config/$config" ]; then
        echo "Бэкап конфига: $config"
        mv "$HOME/.config/$config" "$BACKUP_DIR/"
    fi
    echo "Создание символической ссылки для $config..."
    ln -s "$DOTFILES_DIR/configs/$config" "$HOME/.config/$config"
done

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
echo "Установка завершена! Перезагрузите систему, чтобы увидеть все изменения."