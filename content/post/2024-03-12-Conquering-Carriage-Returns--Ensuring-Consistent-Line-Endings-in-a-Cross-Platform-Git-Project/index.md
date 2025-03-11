---
title: "Conquering Carriage Returns and Permissions: Ensuring a Smooth Cross-Platform Git Workflow"
author: "Blagovest Petrov"
date: 2025-03-12T00:12:02+03:00
tags:
  - "Git"
  - "Programming"
  - "Windows"
categories:
  - "Programming"
draft: false
---

If you work on a project that primarily runs on Linux or another Unix-like environment but collaborate with colleagues on Windows, you’ve likely run into two recurring headaches:

  1. Inconsistent line endings (`CRLF` vs. `LF`) leading to unnecessary diffs, merge conflicts, or even runtime errors in scripts.
  2. Missing Unix permissions when cloning to an NTFS-based filesystem, which doesn’t store executable bits the way Linux filesystems do.

These issues are especially frustrating if your software ultimately deploys on a Linux server, yet company policy mandates Windows workstations for development. Luckily, Git offers several ways to unify line endings, and there are reliable workarounds to preserve Unix file permissions—even on NTFS.


## Unified line endings

The root of the issue is that Windows uses `CRLF` (`\r\n`) for line endings, while Linux, macOS, and BSD systems use `LF` (`\n`). Mixing them can bloat your diffs, introduce merge conflicts, or break shell scripts expecting pure LF characters.

### Strategy #1: Enforce LF via `.gitattributes`

A `.gitattributes` file at the root of your repo is the most reliable way to enforce consistent line endings. A typical snippet might look like:

```giattributes
* text eol=lf
```

What it does:

* Concerts `CRLF` -> `LF` whenever text files are committed.
* Windows users may still see `CRLF` in their local working copy (if their Git config is set up that way), but the repository itself remains LF-only.

### Renormalizing Existing Files

If your repo already contains mixed endings, normalize them after adding `.gitattributes`:

```shell
git add --renormalize .
git commit -m "Normalize line endings to LF"
```

### Strategy #2: Local Git Config (`core.autocrlf`)

If you don’t or can’t commit `.gitattributes`, you can rely on local Git settings:

On Windows:

```shell
git config --global core.autocrlf true
```

This commits files with LF but checks them ou as CRLF locally.

On Linux/MacOS/BSD:

```shell
git config --global core.autocrlf input
```

This stores everything as LF and does not convert to CRLF on checkout.

This method works well if everyone’s Git config is aligned, but `.gitattributes` is generally safer for project-wide consistency.

### Quick fix: `dos2unix`

If you need to quickly convert Windows line endings to Unix style, use `dos2unix <filename>`. This is helpful if you must manually fix a handful of files.

## Preserving UNIX Permissions on NTFS

Unfortunately, the problem with Unix privileges (execute bits, etc.) when cloning to an NTFS filesystem cannot be solved by Git alone. NTFS doesn’t store Unix-like permission bits (including the executable bit) in the same way Linux filesystems do. Here are your options:

1. Use WSL's native filesystem (Recommended):

    If you’re on Windows 10/11 using WSL (Windows Subsystem for Linux), consider cloning your repository inside the WSL filesystem (`/home/<user>/my-project`). The default WSL filesystem is typically ext4, which preserves full Unix permissions.
2. Mount Your NTFS Partition with Metadata Support in WSL:

    If you must work off NTFS, edit `/etc/wsl.conf` to enable “metadata”:

    ```ini
    [automount]
    enabled = true
    options = "metadata"
    ```

    Then restart WSL (`wsl --shutdown`). This allows NTFS to track Unix permissions more accurately, including the executable bit.

3. Adjust Git Settings in Windows

    On NTFS, Git may see changes in file mode (`+x` bit), which can lead to phantom diffs. You can disable file-mode tracking:

    ```shell
    git config core.fileMode false
    ```

    This tells Git not to treat permission changes as a diff, though you’ll still need to apply `chmod +x` in a proper Linux filesystem if you require executables.

4. Manually Enforce the Execute Bit

    If you only have a few scripts that need the executable permission in the repository:

    ```shell
    git update-index --chmod=+x path/to/script.sh
    ```

Git will store that setting in the repo metadata, but your local NTFS file might not reflect it unless you mount with metadata support or use WSL’s ext4 filesystem.
