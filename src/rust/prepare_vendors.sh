#!/usr/bin/env sh

cargo vendor

cd vendor/

R -e "rextendr::vendor_pkgs()"

find . -type f -name "*LICENSE*" | xargs rm
find . -type f -name "*license*" | xargs rm

echo $(find . -type f -name "*.md") | xargs rm
echo $(find . -type f -name "*.rst") | xargs rm
echo $(find . -name "tests" -type d) | xargs rm -rf
echo $(find . -name "examples" -type d) | xargs rm -rf
echo $(find . -name "benches" -type d) | xargs rm -rf
echo $(find . -name "misc" -type d) | xargs rm -rf
echo $(find . -name "ci" -type d) | xargs rm -rf

rust_files=$(find . -type f -name "*.rs")

for file in $rust_files; do
    sed -i "s/^\s*\\/\{2,\}.*$//g" $file
done

cd ..

python rehash.py

tar -cJ --no-xattrs -f vendor.tar.xz vendor

sed -i "s/checksum.*//g" Cargo.lock

ls -lhtr
