mkdir -p /tmp/dotfiles
git clone https://github.com/levkopo/dotfiles /tmp/dotfiles

cd /tmp/dotfiles
rm -rf ~/.config/hypr
rm -rf ~/.config/ags
rm -rf ~/.config/fastfetch
cp ./configs/* ~/.config

sudo cp ./grub/default/grub /etc/default/grub
sudo cp -r ./grub/themes /usr/share/grub
sudo grub-mkconfig -o /boot/grub/grub.cfg

sudo cp -r ./plymouth/themes /usr/share/plymouth
sudo cp ./plymouth/plymouthd.conf /etc/plymouth