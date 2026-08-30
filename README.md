<p align="center">
  <img src="src/resources/Haxefetch.png" width="85%" alt="Haxefetch">
</p>

<div align="center">
<br>

![last commit](https://img.shields.io/github/last-commit/Sbinator-hub/Haxefetch?display_timestamp=committer&style=for-the-badge&logo=git)
![repo stars](https://img.shields.io/github/stars/Sbinator-hub/Haxefetch?style=for-the-badge&logo=andela)
![repo size](https://img.shields.io/github/repo-size/Sbinator-hub/Haxefetch?style=for-the-badge&logo=files)

</div>

Haxefetch is fetch program inspired by fastfetch, neofetch, pfetch, nerdfetch, hyfetch, and so on written in Haxe. [Don't know what's Haxe? Read more](https://haxe.org/) and [learn Haxe if you don't know!](https://haxe.org/documentation/introduction/)

<p align="center">
  <img src="src/resources/screenshots/haxefetch.png" width="90%" alt="Haxefetch">
</p>
<p align="center">
  <img src="src/resources/screenshots/haxefetch_small.png" width="90%" alt="Haxefetch-small">
</p>
<p align="center">(Haxefetch preview)</p>

<p align="center">
  <img src="src/resources/screenshots/commands.png" width="90%" alt="Haxefetch commads">
</p>
<p align="center">(Haxefetch commands)</p>

<p align="center">
  <img src="src/resources/screenshots/configuration.png" width="50%" alt="Haxefetch configuration">
</p>
<p align="center">(Configuring Haxefetch with .conf support)</p>

## How to use this?

If you want to use, follow this:
<details>
    <summary>Getting a binary</summary>

Github releases with tarball
- [GH releases](https://github.com/Sbinator-hub/Haxefetch/releases)

For Arch Linux users
- I made [official Arch repo](https://github.com/Sbinator-hub/haxefetch-arch). Read more by clicking on "official Arch repo" text

For Fedora Linux users
- I made [official Fedora copr repo](https://github.com/Sbinator-hub/haxefetch-fedora). Read more by clicking on "official Fedora copr repo" text

For Gentoo Linux users
- I made [official overlay](https://github.com/Sbinator-hub/haxefetch-overlay) with included ebuilds. Read more by clicking on "official overlay" text

Getting binary using `wget`
- `wget https://raw.githubusercontent.com/Sbinator-hub/Haxefetch/main/binary/haxefetch && chmod +x haxefetch && sudo mv haxefetch /usr/bin/haxefetch`
</details>

<details>
    <summary>Getting Haxe and it's dependencies</summary>

1. Install dependencies.
   - Debian/Ubuntu: `apt-get install haxe git g++`
   - Fedora/RHEL/RPM: `dnf install haxe git g++`
   - openSUSE Leap/Tumbleweed: `zypper install haxe git g++`
   - Arch: `pacman -S base-devel haxe git`
   - Gentoo: `emerge --ask --verbose dev-lang/haxe dev-vcs/git sys-devel/gcc` (if you have packages that are masked, [unmask them](https://wiki.gentoo.org/wiki/Knowledge_Base:Unmasking_a_package))
2. Clone my repo.
   - `git clone https://github.com/ACoolioDude/Haxefetch.git`
2. Setup development.
   - `cd Haxefetch` > `haxelib setup` (requires Haxe!) > Set haxelib environent to Haxefetch folder `home/$USER/Haxefetch/.haxelib` > install HXCPP `haxelib install hxcpp`
3. Compile Haxefetch.
   - `haxe build.hxml`
</details>


