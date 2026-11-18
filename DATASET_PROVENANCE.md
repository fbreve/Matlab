# Dataset and third-party resource provenance

**Documentation review: November 18, 2026.** The fixed reference for all counts is the original code/data commit [`3c309a9`](https://github.com/fbreve/Matlab/commit/3c309a98142f33cf80aac9d95056e82cf6c24aec) (September 12, 2019). **No datasets, papers, images, code or experimental results were changed, rerun or replaced.**

A historical copy is valuable when an old URL disappears or a newer version changes the experiment's inputs. **Preservation is not the same as establishing a legal right to redistribute** a third-party resource. The following source links identify likely projects or provide research background; they do not prove that every committed file was obtained from that exact URL.

## Historical file inventory

Sizes represent **summed uncompressed Git blob sizes** (decimal MB, or KB for the smallest folder), not Git repository download size; compressed files and their extracted copies may both be counted.

| Folder or group | Files | Size | What the historical copy contains |
| --- | ---: | ---: | --- |
| [`UCR_TS_Archive_2015/`](UCR_TS_Archive_2015/) | 170 | 461.2 MB | **85 train/test pairs** of time-series classification datasets from the 2015 UCR collection, retained with their original local file names and splits. |
| [`uci-datasets/`](uci-datasets/) | 55 | 91.9 MB | UCI-type classification benchmarks and documentation in text formats, plus MATLAB conversions; includes the KDD Cup 1999 10% sample. |
| [`ssl-book/`](ssl-book/) | 33 | 54.1 MB | Nine sets of semi-supervised learning benchmarks, predefined label splits, a MATLAB ZIP distribution and a saved historical description page. |
| [`MSRC/`](MSRC/) | 490 | 102.1 MB | Berkeley **BSDS300** archive/extracted images and other images, segmentation ground-truth files and compressed resources; mixed origins. |
| [`GSC/`](GSC/) | 453 | 26.4 MB | Segmentation input images and corresponding masks/annotation images; individual files need separate source attribution. |
| [`dataset-interactive-algorithms/`](dataset-interactive-algorithms/) | 151 | 0.3 MB | Ground-truth and scribble-mask sets for the **50-image interactive segmentation** evaluation described by Andrade and Carrera. |
| [`BCT/`](BCT/) | 143 | 1.2 MB | **Brain Connectivity Toolbox**, January 2017 snapshot: graph measures, MATLAB demos and small example network matrices. |
| [`SmallWorldNess/`](SmallWorldNess/) | 18 | 0.9 MB | Small-worldness analysis scripts, sample network, code license and two research-paper PDFs. |
| [`Multilayer Social Networks/`](Multilayer%20Social%20Networks/) | 2 | 16.3 KB | Florentine and monastery multilayer social networks in `.mpx` format. |
| Root-level scripts/data/results | 848 | 63.5 MB | Many successive MATLAB/C/MEX implementations, experiment drivers, logs, saved matrices and machine-specific configuration. |

**Total:** 2,363 tracked files; 801.7 MB uncompressed.

## Provenance, historical references and permission caveats

| Folder | Source / related context | What is known locally | Redistribution / license status |
| --- | --- | --- | --- |
| `UCR_TS_Archive_2015/` | [UCR historical archive](https://www.cs.ucr.edu/~eamonn/time_series_data/) | The committed **2015 train/test pairs** provide a fixed input set for comparing historical time-series classification experiments. | **Dataset-specific rights need verification; no archive-wide redistribution permission is asserted.** |
| `uci-datasets/` | [UCI Machine Learning Repository](https://archive.ics.uci.edu/) | Data files, original-style documentation and local MATLAB conversions; the bundle spans **multiple independent datasets**. | **Check each dataset's current and historical terms; do not assume one license covers all files or conversions.** |
| `ssl-book/` | [Book publisher](https://mitpress.mit.edu/9780262033589/semi-supervised-learning/); [benchmark background](https://pypi.org/project/sslbookdata/) | Data and **predefined labeled/unlabeled splits** from the nine-set book benchmark, along with a saved source description. | **Original dataset-bundle redistribution terms have not been established.** |
| `MSRC/` | [Berkeley Segmentation Dataset and Benchmark](https://www2.eecs.berkeley.edu/Research/Projects/CS/vision/bsds/) | **BSDS300 images and archive**, plus other image and ground-truth material stored together for segmentation research. | **Images, annotations and archives may have different terms; folder name alone does not establish origin or rights.** |
| `GSC/` | [Oxford interactive-segmentation reference](https://www.robots.ox.ac.uk/~vgg/data/iseg/) | Input images and segmentation masks are preserved, but a **one-to-one source mapping has not been reconstructed**. | **Oxford is related context, not verified source for every local file; check per-image rights.** |
| `dataset-interactive-algorithms/` | [Bundled README](dataset-interactive-algorithms/README.md); [author page](https://ferandrade.com/blog/interactive-segmentation-dataset/) | The **50-image evaluation** provides ground truth and two scribble sets representing different annotation effort, as documented by Andrade/Carrera. | **Original source image and scribble permissions need confirmation; academic availability is not a blanket grant.** |
| `BCT/` | [Historical releases](https://sites.google.com/site/bctnet/latest-releases); [NITRC](https://www.nitrc.org/projects/bct) | The January 2017 **MATLAB graph-analysis toolbox** includes algorithms, demonstrations and example connectivity matrices. | **Review the relevant historical software notices and separate conditions for sample data.** |
| `SmallWorldNess/` | [Bundled README](SmallWorldNess/README.md) | MATLAB routines for **computing and statistically assessing small-worldness**, together with one sample network and two source papers. | **The bundled code LICENSE.txt does not automatically authorize redistribution of the scholarly PDFs.** |
| `Multilayer Social Networks/` | [Local sample files](Multilayer%20Social%20Networks/) | Two network examples in **multilayer .mpx format** (Florentine and monastery data). | **Original source, transformations and redistribution terms remain undocumented.** |

### Notes for scientific reuse

- **UCR 2015:** the directory has exactly **170 files representing 85 TRAIN/TEST pairs**. The legacy [UCR time-series archive page](https://www.cs.ucr.edu/~eamonn/time_series_data/) still provides context on the 2015 collection; later releases expanded or changed the archive. Preserving the historical edition avoids silently changing experiment inputs.
- **UCI:** modern individual UCI dataset pages frequently display a Creative Commons Attribution 4.0 license. Do **not** infer that all copies made before that notice, all local transformations, or all bundled collections have identical terms.
- **SSL Book:** the committed `ssl-book/Semi-Supervised Learning Book.htm` describes nine sets and their labeled/unlabeled split formats. This saved page gives historical context but **is not a license grant**.
- **MSRC and BSDS300:** a Berkeley BSDS300 archive appears inside `MSRC/` alongside other images and annotation files. The folder should not be treated as exclusively Berkeley- or Microsoft-owned; identify original image and annotation provenance when reusing a specific sample.
- **Interactive segmentation data:** the original `dataset-interactive-algorithms/README.md` describes GrabCut-derived images and geodesic-star-convexity scribbles. Preserve the attribution to the cited authors and check rights for original images separately.
- **BCT:** the `BCT/2017_01_15_BCT/` directory is a specific old MATLAB toolbox snapshot. Modern copies may be distributed under terms not proven for these historical bytes; evaluate its code and bundled samples separately.
- **SmallWorldNess:** its `LICENSE.txt` does not automatically cover copies of scholarly PDFs in the same folder.
- **Root files:** source, results, locally generated MATLAB matrices and miscellaneous benchmark files are intermixed; a complete file-by-file derivation/rights inventory has **not** been attempted.

### Integrity and maintenance

The original source state is preserved in Git history at [`3c309a98142f33cf80aac9d95056e82cf6c24aec`](https://github.com/fbreve/Matlab/commit/3c309a98142f33cf80aac9d95056e82cf6c24aec). To inspect historical object identities locally without changing any source files:

```sh
git ls-tree -r 3c309a98142f33cf80aac9d95056e82cf6c24aec -- UCR_TS_Archive_2015/
git hash-object UCR_TS_Archive_2015/50words/50words_TRAIN
```

A Git blob SHA-1 is not a conventional SHA-1 digest of raw bytes or a SHA-256 checksum. No tests were run against the old MATLAB/MEX workflows and no independent rights audit of every third-party item has been performed.

**No root license is added:** this documentation neither relicenses historical code nor asserts permission to distribute all datasets and third-party files. If a rights holder flags material, address the specific files separately without sacrificing the privately retained historical record.
