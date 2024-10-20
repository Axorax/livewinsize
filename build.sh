#!/bin/bash

echo "Copying..."

src_folder="compiled"
dest_folder="compiled-copy"

if [ ! -d "$dest_folder" ]; then
    mkdir "$dest_folder"
fi

cp -r "$src_folder"/* "$dest_folder"

echo "Minification starting..."

find "$src_folder" -type f -name "*.html" -exec echo "Minifying {}" \; -exec npx html-minifier-terser --collapse-whitespace --remove-comments --output {} {} \;
find "$src_folder" -type f -name "*.css" -exec echo "Minifying {}" \; -exec npx uglifycss --output {} {} \;
find "$src_folder" -type f -name "*.js" -exec echo "Minifying {}" \; -exec npx terser --compress --mangle --output {} -- {} \;

echo "Building..."

npm run build &

wait $!

echo "Cleaning up..."

rm -rf "$src_folder"
mv "$dest_folder" "$src_folder"
