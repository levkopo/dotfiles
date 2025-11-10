#!/bin/bash

DOTFILES_DIR="$HOME/.config/levkopo-dotfiles"

cd "$DOTFILES_DIR" || exit 1

git fetch
BEFORE=$(git rev-parse HEAD)
git pull
AFTER=$(git rev-parse HEAD)

if [ "$BEFORE" == "$AFTER" ]; then
    echo "Дотфайлы в актуальном состоянии. Выход."
    exit 0
fi

echo "Обнаружены обновления в дотфайлах. Применяем изменения..."

if ! git diff --quiet "$BEFORE" "$AFTER" -- ./grub/default/grub; then
    echo "Обнаружены изменения в конфигурации GRUB. Обновление..."
    sudo cp "$DOTFILES_DIR/grub/default/grub" /etc/default/grub
    sudo cp -r "$DOTFILES_DIR/grub/themes"/* /usr/share/grub/themes/
    sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

if ! git diff --quiet "$BEFORE" "$AFTER" -- ./plymouth; then
    echo "Обнаружены изменения в конфигурации Plymouth. Обновление..."
    sudo cp -r "$DOTFILES_DIR/plymouth/themes"/* /usr/share/plymouth/themes/
    sudo cp "$DOTFILES_DIR/plymouth/plymouthd.conf" /etc/plymouth/plymouthd.conf
    sudo mkinitcpio -P
fi

if ! git diff --quiet "$BEFORE" "$AFTER" -- ./sddm; then
    echo "Обнаружены изменения в конфигурации SDDM. Обновление..."
    sudo cp -r "$DOTFILES_DIR/sddm/themes"/* /usr/share/sddm/themes/
    sudo cp "$DOTFILES_DIR/sddm/sddm.conf" /etc/sddm.conf
    sudo mkinitcpio -P
fi

echo "Синхронизация завершена."