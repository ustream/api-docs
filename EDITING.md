# Editing the documentation

## How to add a new version of documentation?

* Examine the directory structure in the `/_posts` directory, focus on the `*.md` files
* Locate your platform, e.g. `/_posts/android`
* Create a new directory for the new version, e.g. `/_posts/android/0.6`
* Copy your documentation files from your SDK (`README.md`, `CHANGELOG.md`) into that directory
    - `README.md` => `/_posts/android/0.6/README.md`
    - `CHANGELOG.md` => `/_posts/android/0.6/CHANGELOG.md`
* Every documentation file must have a corresponding YAML Front Matter file which specifies the published location, 
title and layout. For each of your documentation file, copy an existing YAML Front Matter file from the previous version (e.g. `0.5`) 
and rename it to include the release's date e.g. `2017-06-15`:
    - `/_posts/android/0.6/README.md`:
        - `/_posts/android/0.5/2017-02-09-readme.md` => `/_posts/android/0.6/2017-06-15-readme.md`:
    - `/_posts/android/0.6/CHANGELOG.md`:
        - `/_posts/android/0.5/2017-02-09-changelog.md` => `/_posts/android/0.6/2017-06-15-changelog.md`:
* Edit the YAML Front Matter files, so they have the **new version** at least in the `title` and `permalink` section
```yaml
    ---
    
    ...
    layout: markdown
    title: Player SDK for Android (v0.6.0)
    categoryItemIsShown: 0
    permalink: /player-sdk/android/0.6/
    ...
    
    ---
```
* Make sure you replaced the old version number with the **new version** in all of the new YAML Front Matter files
* Upper in the directory tree, edit the platform index files, 
    e.g. `/_posts/android/2017-02-09-readme.md`, so they have the **new version** number everywhere
```yaml
    ---

    ...
    title: Player SDK for Android (v0.6.x)
    ...
    
    ---
    ... include_relative 0.6/README.md ...
```
* Make sure you replace the old version number with the **new version** in the `include_relative` command too
* You should rename the platform index files to reflect the latest release's date
e.g. `/_posts/android/2017-02-09-readme.md` => `/_posts/android/2017-06-15-readme.md`
