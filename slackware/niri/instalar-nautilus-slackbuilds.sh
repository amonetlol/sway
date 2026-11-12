#!/usr/bin/env bash
# Executar no chroot Slackware; compila SlackBuilds para Nautilus e dependencias.
set -euo pipefail
export PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
export MAKEFLAGS=-j2 NUMJOBS=-j2 OUTPUT=/var/tmp/ff-build/sbo-packages
root=/var/tmp/ff-build/slackbuilds
mkdir -p "$OUTPUT"
for path in libraries/gnome-autoar libraries/gnome-desktop libraries/exempi libraries/libgxps libraries/libiptcdata system/osinfo-db-tools system/osinfo-db libraries/libosinfo libraries/libuchardet libraries/totem-pl-parser system/tracker system/tracker-miners desktop/nautilus; do
 name=${path##*/}; dir="$root/$path"
 if compgen -G "/var/lib/pkgtools/packages/$name-[0-9]*" >/dev/null; then echo "Ja instalado: $name"; continue; fi
 cd "$dir"
 unset DOWNLOAD DOWNLOAD_x86_64 MD5SUM MD5SUM_x86_64 VERSION
 source "$name.info"
 urls=${DOWNLOAD_x86_64:-${DOWNLOAD:-}}
 sums=${MD5SUM_x86_64:-${MD5SUM:-}}
 [[ -n $urls && $urls != UNSUPPORTED ]] || { echo "Fonte indisponivel para $name"; exit 1; }
 read -r -a url_array <<< "$urls"; read -r -a sum_array <<< "$sums"
 [[ ${#url_array[@]} == ${#sum_array[@]} ]] || { echo "Checksums incompletos: $name"; exit 1; }
 for i in "${!url_array[@]}"; do
  file=${url_array[$i]##*/}; file=${file%%\?*}
  url=${url_array[$i]}
  if [[ "$url" == https://releases.pagure.org/libosinfo/* ]]; then url="https://gitlab.com/libosinfo/$name/-/releases/v$VERSION/downloads/$file"; fi
  [[ -f "$file" ]] || curl -fL --retry 3 "$url" -o "$file"
  printf '%s  %s\n' "${sum_array[$i]}" "$file" | md5sum -c -
 done
 echo "FF_SBO_BUILD_INICIO=$name"
 if [[ "$name" == tracker ]]; then
  if ! grep -q "FF tracker" "$name.SlackBuild"; then patch -p0 < ff-tracker-build-order.patch; fi
  sed -i "s/-Dstrip=true$/-Dman=false -Ddocs=false -Dstrip=true/" "$name.SlackBuild"
  if ! grep -q "FF create man directory" "$name.SlackBuild"; then sed -i '/find \$PKG\/usr\/man/i mkdir -p "$PKG/usr/man" # FF create man directory' "$name.SlackBuild"; fi
 fi
 if [[ "$name" == tracker-miners ]]; then
  if ! grep -q "FF callback" "$name.SlackBuild"; then patch -p0 < ff-tracker-miners-callback.patch; fi
  sed -i "s/-Dstrip=true/-Dfunctional_tests=false -Dman=false -Dstrip=true/" "$name.SlackBuild"
  if ! grep -q "FF create man directory" "$name.SlackBuild"; then sed -i '/find \$PKG\/usr\/man/i mkdir -p "$PKG/usr/man" # FF create man directory' "$name.SlackBuild"; fi
 fi
 ARCH=x86_64 bash "$name.SlackBuild"
 shopt -s nullglob; packages=("$OUTPUT/$name-$VERSION-"*.txz "$OUTPUT/$name-$VERSION-"*.tgz); shopt -u nullglob
 [[ ${#packages[@]} -eq 1 ]] || { echo "Pacote nao identificado: $name"; exit 1; }
 installpkg "${packages[0]}"
 ldconfig
 echo "FF_SBO_BUILD_CONCLUIDO=$name"
done
