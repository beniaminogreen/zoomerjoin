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

# for file in $rust_files; do
#     perl -i -0777 -pe 's{/\*.*?\*/}{}gs; s{//.*$}{}mg' "$file"
# done
#
#
for file in $rust_files; do
    # Skip vendor/target directories and files containing 'zerocopy'
    if [[ "$file" != *"/vendor/"* && "$file" != *"/target/"* && "$file" != *zerocopy* && "$file" != *syn* ]]; then
        perl -i -pe '
            s{//.*$}{} unless /#/ || m{".*//.*"};
        ' "$file"
    fi
done


cd ..

python rehash.py

tar -cJ --no-xattrs -f vendor.tar.xz vendor

sed -i "s/checksum.*//g" Cargo.lock

ls -lhtr
