#!/bin/bash
# Demo script for Mini Git
# Run this to see mygit in action!

set -e

echo "🔥 Mini Git Demo"
echo "================"
echo ""

# Clean up any previous demo
rm -rf demo-repo

# Create test repo
mkdir demo-repo
cd demo-repo

echo "1️⃣  Initialize repository"
../mygit init
echo ""

echo "2️⃣  Create some files"
echo "# Hello World Project" > README.md
echo "print('Hello, World!')" > hello.py
echo "*.pyc" > .gitignore
ls -la
echo ""

echo "3️⃣  Stage files"
../mygit add README.md
../mygit add hello.py
echo ""

echo "4️⃣  Check status"
../mygit status
echo ""

echo "5️⃣  First commit"
../mygit commit -m "Initial commit"
echo ""

echo "6️⃣  Modify a file and commit again"
echo "print('Goodbye, World!')" >> hello.py
../mygit add hello.py
../mygit commit -m "Add goodbye message"
echo ""

echo "7️⃣  View commit history"
../mygit log
echo ""

echo "8️⃣  Inspect the object storage"
echo "Objects created:"
find .mygit/objects -type f | wc -l | xargs echo "  Total objects:"
echo ""
echo "Object structure:"
ls -la .mygit/objects/
echo ""

echo "✅ Demo complete!"
echo ""
echo "Explore the .mygit directory to see how it works:"
echo "  cat .mygit/HEAD"
echo "  cat .mygit/refs/heads/main"
echo "  find .mygit/objects -type f"

# Return to parent
cd ..
