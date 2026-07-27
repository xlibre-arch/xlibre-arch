# Maintainer: callmetango
# Contributor: artist <artist@artixlinux.org>
# Contributor: Vitalii Kuzhdin <vitaliikuzhdin@gmail.com>
# Contributor: Andreas Radke <andyrtr@archlinux.org>
# Contributor: Jan Alexander Steffens (heftig) <jan.steffens@gmail.com>
# Contributor: Jan de Groot <jgc@archlinux.org>
# Contributor: M Rawash <mrawash@gmail.com>

pkgname=xlibre-input-wacom
_pkgname=xf86-input-wacom
pkgver=25.0.0
pkgrel=8
pkgdesc="X.Org Wacom tablet driver"
arch=(x86_64)
url='https://github.com/X11Libre/xf86-input-wacom'
license=('GPL-2.0-or-later')
depends=('libxi' 'libxinerama' 'libxrandr' 'systemd-libs' 'libx11' 'glibc' 'xlibre-xserver')
makedepends=('xlibre-xserver-devel' 'X-ABI-XINPUT_VERSION=26.0' 'meson'
            'gobject-introspection'
            # for tests
            'python-libevdev' 'python-pytest' 'python-yaml' 'python-gobject' 'python-attrs')
provides=('xf86-input-wacom') # for wacomtablet
conflicts=('xf86-input-wacom' 'X-ABI-XINPUT_VERSION<26' 'X-ABI-XINPUT_VERSION>=27')
groups=('xlibre-drivers')
source=("${url}/archive/refs/tags/xlibre-${_pkgname}-${pkgver}.tar.gz")

# check at https://github.com/linuxwacom/xf86-input-wacom/releases
sha256sums=('12878547b271f4e59ecd5098f935d4c0bd4560d0c2a3a667385d916bc63d00af')

build() {
  arch-meson $_pkgname-xlibre-$_pkgname-$pkgver build \
    -D xorg-conf-dir=/usr/share/X11/xorg.conf.d/ \
    -D systemd-unit-dir=/usr/lib/systemd/system/ \
    -D unittests=enabled

  # Print config
  meson configure build
  ninja -C build
}

check() {
  meson test -C build || /bin/true
}

package() {
  DESTDIR="$pkgdir" ninja -C build install
}
