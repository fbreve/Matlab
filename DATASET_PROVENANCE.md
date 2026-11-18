# Dataset and third-party resource provenance

**Documentation review: November 18, 2026.** The fixed reference for all counts is the original code/data commit [`3c309a9`](https://github.com/fbreve/Matlab/commit/3c309a98142f33cf80aac9d95056e82cf6c24aec) (September 12, 2019). **No datasets, papers, images, code or experimental results were changed, rerun or replaced.**

A historical copy is valuable when an old URL disappears or a newer version changes the experiment's inputs. **Preservation is not the same as establishing a legal right to redistribute** a third-party resource. The following source links identify likely projects or provide research background; they do not prove that every committed file was obtained from that exact URL.

## Historical file inventory

Sizes are in decimal MB and represent **summed uncompressed Git blob sizes**, not Git repository download size; an archive and its extracted contents may both be counted.

| Group | Tracked files | Size | Historical description |
| --- | ---: | ---: | --- |
| [`UCR_TS_Archive_2015/`](UCR_TS_Archive_2015/) | 170 | 461.2 MB | UCR Time Series Classification Archive, 2015 |
| [`uci-datasets/`](uci-datasets/) | 55 | 91.9 MB | UCI dataset copies and some local MATLAB conversions |
| [`ssl-book/`](ssl-book/) | 33 | 54.1 MB | Semi-Supervised Learning book (2006) benchmark splits |
| [`MSRC/`](MSRC/) | 490 | 102.1 MB | Historical segmentation images and GT, including BSDS300 |
| [`GSC/`](GSC/) | 453 | 26.4 MB | Image, ground truth and segmentation-related historical material |
| [`dataset-interactive-algorithms/`](dataset-interactive-algorithms/) | 151 | 0.3 MB | Andrade/Carrera interactive-segmentation evaluation material |
| [`BCT/`](BCT/) | 143 | 1.2 MB | Brain Connectivity Toolbox dated 2017-01-15 |
| [`SmallWorldNess/`](SmallWorldNess/) | 18 | 0.9 MB | Third-party MATLAB routines and supporting scientific material |
| [`Multilayer Social Networks/`](Multilayer%20Social%20Networks/) | 2 | 0.0 MB | Sample multilayer social-network data |
| Root-level scripts/data/results | 848 | 63.5 MB | Mixed experiment output, source variants and standalone data |

**Total:** 2,363 tracked files; 801.7 MB uncompressed.

## Provenance, historical references and permission caveats

| Folder | Source / related context | What is known locally | Redistribution / license status |
| --- | --- | --- | --- |
| `UCR_TS_Archive_2015/` | [UCR historical archive](https://www.cs.ucr.edu/~eamonn/time_series_data/) | 85 TRAIN/TEST pairs; the precise 2015 version matters for old comparisons | **No verified blanket license covering all contributed datasets** |
| `uci-datasets/` | [UCI Machine Learning Repository](https://archive.ics.uci.edu/) | Individual datasets and formats differ; this directory is not one single dataset | **Current UCI records often specify CC BY 4.0, but verify each historical dataset and its specific conditions** |
| `ssl-book/` | [Book publisher](https://mitpress.mit.edu/9780262033589/semi-supervised-learning/); [benchmark background](https://pypi.org/project/sslbookdata/) | Nine benchmark sets and saved splitting information, ZIP and historical HTML page | **Original bundle redistribution terms not established** |
| `MSRC/` | [Berkeley Segmentation Dataset and Benchmark](https://www2.eecs.berkeley.edu/Research/Projects/CS/vision/bsds/) | Contains Berkeley BSDS300 image archive plus other images and annotation files; sources must be distinguished | **Different image collections may have different rights; no blanket redistribution claim** |
| `GSC/` | [Oxford interactive-segmentation reference](https://www.robots.ox.ac.uk/~vgg/data/iseg/) | Related research context only; does not establish exact provenance of each local file | **Origin and redistribution conditions require file-level review** |
| `dataset-interactive-algorithms/` | [Bundled README](dataset-interactive-algorithms/README.md); [author page](https://ferandrade.com/blog/interactive-segmentation-dataset/) | The bundled README describes 50 images, ground truth and two sets of scribbles; cites GrabCut and Geodesic Star Convexity | **Public academic availability does not itself guarantee unrestricted reuse of images/annotations** |
| `BCT/` | [Historical releases](https://sites.google.com/site/bctnet/latest-releases); [NITRC](https://www.nitrc.org/projects/bct) | MATLAB toolbox with examples and data files, not simply a dataset | **Refer to exact historical code/data license notices, not a later mirror's license** |
| `SmallWorldNess/` | [Bundled README](SmallWorldNess/README.md) | Contains scripts, sample data, LICENSE.txt and two research-paper PDFs | **Rights for included paper PDFs may differ from license for code** |
| `Multilayer Social Networks/` | [Local sample files](Multilayer%20Social%20Networks/) | Florentine and monastery .mpx files; origin not independently established | **License and transformation history not documented** |

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
