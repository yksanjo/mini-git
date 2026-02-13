# 🔥 Mini Git - Build Your Own Version Control System

> **Difficulty:** 6/10 | **Cool Factor:** 9/10

A simplified implementation of Git's core concepts, built from scratch in Python. This project teaches you how Git really works under the hood.

## 🎯 What You'll Learn

- **SHA-1 Hashing** - How Git creates unique identifiers for every object
- **Object Storage** - Blobs, trees, and commits stored as content-addressable files
- **Snapshot Architecture** - How Git stores complete snapshots, not diffs
- **Tree Structures** - How directories are represented as tree objects
- **References** - How HEAD and branches work

## 🚀 Quick Start

```bash
# Clone/navigate to this repo
cd mini-git

# Make it available globally (optional)
export PATH="$PATH:$(pwd)"

# Or run directly
./mygit init
```

## 📚 Commands

### `mygit init`
Initialize a new repository

```bash
$ mkdir my-project && cd my-project
$ mygit init
Initialized empty mygit repository in /path/to/my-project/.mygit
```

### `mygit add <file>`
Stage a file for the next commit

```bash
$ echo "Hello World" > hello.txt
$ mygit add hello.txt
Staged: hello.txt (3b18e51)
```

### `mygit commit -m "<message>"`
Create a snapshot of staged changes

```bash
$ mygit commit -m "Initial commit"
[main a1b2c3d] Initial commit
```

### `mygit log`
View commit history

```bash
$ mygit log
commit a1b2c3d4e5f6789012345678901234567890abcd
Parent: 0000000000000000000000000000000000000000
Author: User <user@example.com>
Date:   Thu Feb 13 14:32:00 2026
Tree:   3b18e51

    Initial commit
```

### `mygit status`
Check repository status

```bash
$ mygit status
On branch main
Current commit: a1b2c3d

Changes to be committed:
  (use "mygit reset HEAD <file>..." to unstage)

	new file:   hello.txt
```

## 🏗️ Architecture Deep Dive

### Object Storage (.mygit/objects/)

Git stores four types of objects, each identified by a SHA-1 hash:

```
.mygit/
└── objects/
    ├── 3b/           # First 2 chars of hash = directory
    │   └── 18e512... # Remaining 38 chars = filename
    ├── a1/
    │   └── b2c3d4...
    └── info/
```

Each object is **zlib compressed** and has the format:
```
<type> <size>\0<content>
```

#### 1. Blob Objects (File Content)
```python
# Stores raw file content
hash_object(b"Hello World\n", "blob")
# → 3b18e512dba79e4c8300dd08aeb37f8e728b8dad
```

**Key insight:** Same content = same hash. This deduplication saves space!

#### 2. Tree Objects (Directory Structure)
```
100644 hello.txt\0<20-byte-blob-hash>
100644 world.txt\0<20-byte-blob-hash>
```

A tree maps filenames to their blob hashes.

#### 3. Commit Objects (Snapshots)
```
tree <tree-hash>
parent <parent-commit-hash>  # (optional for first commit)
author User <user@example.com> 1707832320 +0000
committer User <user@example.com> 1707832320 +0000

Commit message here
```

### The Index (.mygit/index)

The staging area is a simple JSON file:
```json
{
  "hello.txt": "3b18e512dba79e4c8300dd08aeb37f8e728b8dad",
  "src/main.py": "aabbccdd..."
}
```

### References (.mygit/refs/)

```
.mygit/
├── HEAD              # "ref: refs/heads/main"
└── refs/
    └── heads/
        └── main      # "a1b2c3d4..." (commit hash)
```

## 🎓 Learning Path

### 1. Understanding Content-Addressable Storage
```bash
# Create a file
echo "test content" | python3 -c "
import sys, hashlib, zlib
data = sys.stdin.read().encode()
header = f'blob {len(data)}\0'.encode()
full = header + data
sha = hashlib.sha1(full).hexdigest()
print(f'Hash: {sha}')
print(f'Stored in: objects/{sha[:2]}/{sha[2:]}')
print(f'Compressed size: {len(zlib.compress(full))} bytes')
"
```

### 2. Visualizing the Object Graph
```bash
# After making commits, explore the objects
find .mygit/objects -type f | while read obj; do
    echo "=== $obj ==="
    python3 -c "
import zlib, sys
with open('$obj', 'rb') as f:
    content = zlib.decompress(f.read())
    null_idx = content.index(b'\0')
    header = content[:null_idx].decode()
    print(f'Type: {header}')
    print(f'Preview: {content[null_idx+1:null_idx+100]}...')
"
done
```

### 3. Understanding Immutability
```bash
# Modify a committed file
echo "modified" > hello.txt
mygit add hello.txt
mygit commit -m "Modify hello.txt"

# The old blob still exists!
ls .mygit/objects/3b/  # Original still there
```

## 🔍 How It Compares to Real Git

| Feature | Mini Git | Real Git |
|---------|----------|----------|
| Hashing | SHA-1 | SHA-1 (SHA-256 option) |
| Compression | zlib | zlib |
| Index Format | JSON | Binary (cache tree) |
| Tree Format | Custom | Binary (sorted entries) |
| Packfiles | ❌ | ✅ (major space saver) |
| Branches | Basic | Full ref support |
| Merging | ❌ | ✅ (3-way merge) |
| Diff | ❌ | ✅ (xdiff library) |

## 🛠️ Implementation Highlights

### SHA-1 Content Hashing
```python
def hash_object(self, content: bytes, obj_type: str = "blob") -> str:
    """Create a content-addressable hash"""
    header = f"{obj_type} {len(content)}\0".encode()
    full_content = header + content
    sha = hashlib.sha1(full_content).hexdigest()
    
    # Store compressed
    compressed = zlib.compress(full_content)
    (self.objects_dir / sha[:2] / sha[2:]).write_bytes(compressed)
    
    return sha
```

### Tree Construction
```python
def _write_tree(self, index: Dict[str, str]) -> str:
    """Convert index to tree object"""
    tree_content = b""
    for mode, name, sha in sorted(entries):
        tree_content += f"{mode} {name}\0".encode()
        tree_content += bytes.fromhex(sha)
    return self.hash_object(tree_content, "tree")
```

## 🧪 Test It Out

```bash
# 1. Create a test project
mkdir test-repo && cd test-repo
../mygit init

# 2. Create and stage files
echo "# My Project" > README.md
echo "print('hello')" > main.py
../mygit add README.md
../mygit add main.py

# 3. First commit
../mygit commit -m "Initial commit"

# 4. Make changes
echo "print('world')" >> main.py
../mygit add main.py
../mygit commit -m "Add more output"

# 5. View history
../mygit log

# 6. Explore the internals
find .mygit/objects -type f
cat .mygit/HEAD
cat .mygit/refs/heads/main
```

## 🎨 Why This Is Impressive

1. **Real Concepts** - Uses actual Git algorithms and data structures
2. **Working System** - Not a toy, it actually versions files
3. **Educational** - Reading the code teaches Git internals
4. **Interview Gold** - Shows deep understanding of VCS
5. **Extensible** - Easy to add features (branch, checkout, etc.)

## 🚀 Extensions to Try

- [ ] `mygit checkout <commit>` - Restore files from a commit
- [ ] `mygit branch <name>` - Create branches
- [ ] `mygit diff` - Compare working tree to index
- [ ] `mygit cat-file <hash>` - Inspect any object
- [ ] Packfiles - Delta compression for efficiency

## 📖 Resources

- [Git Internals - Git Objects](https://git-scm.com/book/en/v2/Git-Internals-Git-Objects)
- [Write Yourself a Git](https://wyag.thb.lt/)
- [Git's Design Documentation](https://github.com/git/git/blob/master/Documentation/technical/index-format.txt)

---

**Built with ❤️ for learning.** Happy hacking!
