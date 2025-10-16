plantiSMASH release process
=========================

This file documents the release process of plantiSMASH.


Preparation work
----------------

Make sure all relevant pull requests have been merged, and check if any
showstopper bugs are still open. Showstopper bugs mainly include regressions
from previous versions.


What version number will the new release get?
---------------------------------------------

plantiSMASH is using [semantic versioning](http://semver.org/). Unfortunately,
semantic versioning focuses on libaries and other things that present APIs,
making it an imperfect match for antiSMASH.

Reflecting the basic ideas behind semantic versioning, we should consider our
command line the "API" of antiSMASH for now, as antiSMASH is certainly called
from many in-house scripts. As a result, we should be increasing the MINOR
version if we add new features that have additional command line options, and
increase the MAJOR version when we remove command line options.

We should also increase the MINOR version if we add new secondary metabolite
classes to be detected. This rule wasn't followed previously, but should be
followed for future releases.


# 🏷️ Tag the Actual Release

Before tagging a new **plantiSMASH** release, follow the steps below to ensure version consistency and correct tagging across all systems.

---

### 1️⃣ Update Contributor Information

Make sure the [`CONTRIBUTORS`](./CONTRIBUTORS) file is up to date.  
Commit any new contributors before tagging:

```bash
git add CONTRIBUTORS
git commit -m "Update CONTRIBUTORS"
```

---

### 2️⃣ Update the Version (Single Source of Truth)

Update the version number **only once** in  
[`antismash/__init__.py`](./antismash/__init__.py):

```python
__version__ = "2.1.0"
```

This value is automatically used in the [`pyproject.toml`](./pyproject.toml) via:

```toml
[tool.setuptools.dynamic]
version = { attr = "antismash.__init__.__version__" }
```

You can confirm the currently set version by running:

```bash
python run_antismash.py -h
```

Then commit the change:

```bash
git commit -am "Bump version to 2.1.0"
```

---

### 3️⃣  Automatic Tagging via GitHub Actions

If you prefer, you can skip the manual tag step and let GitHub Actions handle it.

When you push a branch named:
```
release/<MAJOR>.<MINOR>.<PATCH>
```

the workflow [`.github/workflows/tag-on-version.yml`](./.github/workflows/tag-on-version.yml) will automatically:

1. Extract the version from `antismash/__init__.py`  
2. Verify that it matches your branch name (`release/2.1.0` → `__version__ = "2.1.0"`)  
3. Create and push the tag `plantismash-2.1.0`

If the branch name and internal version **don’t match**, the workflow fails early with a clear error message — preventing accidental mismatched tags.

---

### 6️⃣ Zenodo Archiving

All tagged releases are automatically tracked and archived in  
[**Zenodo**](https://zenodo.org/) at [![DOI](https://zenodo.org/badge/185329393.svg)](https://doi.org/10.5281/zenodo.15412176)  

---

### 7️⃣ Update Documentation Links (Optional Manual Check)

In [`antismash/output_modules/html/generator.py`](./antismash/output_modules/html/generator.py),  
the function [`add_overview_entry()`](./antismash/output_modules/html/generator.py#L350-L380) includes a hard-coded documentation link for the changelog section:

```python
a.attr('href', "https://plantismash.github.io/documentation/changelog/2.0/#supported-cluster-types-version-2")
```

When making new releases containing an updated set of BGC detection rules (e.g. `2.1` → `2.2`), update this URL so the link points to the corresponding changelog version:

```
https://plantismash.github.io/documentation/changelog/<MAJOR>.<MINOR>/#supported-cluster-types-version-<MAJOR>
```

For example:

```
https://plantismash.github.io/documentation/changelog/2.1/#supported-cluster-types-version-2
```

---

### ✅ Summary

| Step | Task | Script / File |
|------|------|----------------|
| 1 | Update contributors | [`CONTRIBUTORS`](./CONTRIBUTORS) |
| 2 | Update version | [`antismash/__init__.py`](./antismash/__init__.py) |
| 3 | Generate notes | [`changes.txt`](./changes.txt) |
| 4 | Tag release manually | — |
| 5 | Or tag automatically | [`.github/workflows/tag-on-version.yml`](./.github/workflows/tag-on-version.yml) |
| 6 | Verify Zenodo tracking | [![DOI](https://zenodo.org/badge/185329393.svg)](https://doi.org/10.5281/zenodo.15412176) 
| 7 | Check documentation link | [`generator.py`](./antismash/output_modules/html/generator.py) |







