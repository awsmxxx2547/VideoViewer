#!/bin/bash

# Check if VERSION file exists
if [ ! -f VERSION ]; then
    echo "0.0.0" > VERSION
fi

current_version=$(cat VERSION)
echo "Current version: $current_version"

# Parse version components
IFS='.' read -ra parts <<< "$current_version"
major=${parts[0]}
minor=${parts[1]}
patch=${parts[2]}

# Bump version based on argument
case $1 in
    major)
        major=$((major + 1))
        minor=0
        patch=0
        ;;
    minor)
        minor=$((minor + 1))
        patch=0
        ;;
    patch|"")
        patch=$((patch + 1))
        ;;
    *)
        echo "Usage: $0 [major|minor|patch]"
        exit 1
        ;;
esac

new_version="$major.$minor.$patch"
echo "$new_version" > VERSION

# Update version.c
sed -i.bak "s/const char\* VERSION = \".*\"/const char\* VERSION = \"$new_version\"/" src/version.c
rm src/version.c.bak

echo "Version bumped to: $new_version"
