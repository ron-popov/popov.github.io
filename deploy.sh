#!/usr/bin/env bash

echo "Building site with zola..."
zola build --output-dir docs

echo "Commiting and pushing"
git add .
git commit -m "Deploy site $(date -u +'%Y-%m-%d %H:%M:%S UTC')"
git push

echo "Deployed"
