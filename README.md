# MATLAB research workspace — historical research material

> **Historical research snapshot (2018–2019).** This repository stores an old mixed-purpose MATLAB research workspace. It is **not** a maintained software distribution or a reproducible, ready-to-run software environment.

The last pre-documentation code/data commit was [`3c309a9`](https://github.com/fbreve/Matlab/commit/3c309a98142f33cf80aac9d95056e82cf6c24aec), dated September 12, 2019. The repository preserves old versions of MATLAB and C/MEX algorithms, scripts for experiments, parameter sweeps, results, workspace files, and downloaded benchmark collections. Some source filenames reflect backup copies and historical merge/synchronization conflicts; do not assume they are supported interfaces.

## Focused implementations and related research projects

The repositories below provide **specific algorithms, examples or research code** with a clearer scope than this mixed MATLAB workspace. The last two are related research lines, **not updated versions of the MATLAB algorithms stored here**.

| Repository | What it contains |
| --- | --- |
| [Particle Competition and Cooperation (PCC)](https://github.com/fbreve/Particle-Competition-and-Cooperation) | The original **graph-based semi-supervised learning method** based on competing and cooperating particles (IEEE TKDE, 2012). Provides `pcc.m`, graph construction, MATLAB and accelerated C/MEX execution paths, plus Wine/Digits examples. |
| [PyPCC](https://github.com/fbreve/pypcc) | A **Python implementation of PCC**, with NumPy, Numba and Cython propagation backends, graph-building utilities, runnable examples and regression tests. This is a separate implementation, not a copy of the MATLAB workspace. |
| [LNPCC](https://github.com/fbreve/LNPCC) | A PCC extension for **semi-supervised learning with noisy or incorrect initial labels** (Neurocomputing, 2015). Includes the MATLAB algorithm, C/MEX propagation code and an example evaluating robustness to label noise. |
| [LPCN](https://github.com/fbreve/LPCN) | **Interactive image segmentation** by label propagation through complex networks (Expert Systems with Applications, 2019). Uses user-provided scribbles, coarse graph-based propagation and a second boundary-refinement stage; includes MATLAB/C-MEX code and sample images. |
| [NoisyGL — PCC+GCN research fork](https://github.com/fbreve/NoisyGL) | A modified **graph neural network benchmark for learning with label noise**, integrating PCC+GCN experiments, multi-GPU scheduling and hyperparameter searches. It is a different, later Python research workflow rather than a standalone MATLAB PCC release. |
| [Chaotic oscillator object-selection study](https://github.com/fbreve/grid-image-contrast-ijcnn2009extended) | Historical **C++Builder/VCL software for image-object selection using chaotic oscillator synchronization**; associated with the extended *Neural Networks* journal article (2009). A separate research line, not a successor to this MATLAB workspace. |

These projects **do not replace** all the intermediate `strwalk*`, `cnsslis*`, `fit*`, or other experimental versions retained here.

## Preserved datasets and third-party resources

Some original source URLs or historical dataset versions may be difficult to retrieve today. This repository retains the **originally committed copies** for provenance and possible scientific reproduction, without silently replacing them with current editions.

| Path | What is preserved |
| --- | --- |
| [`UCR_TS_Archive_2015/`](UCR_TS_Archive_2015/) | **2015 UCR time-series classification collection:** 85 datasets, each with the original locally stored `TRAIN` and `TEST` split (170 files). Useful for comparing experiments against this older version rather than a later UCR release. |
| [`uci-datasets/`](uci-datasets/) | **Traditional machine-learning benchmarks:** classification datasets in their downloaded text formats, documentation and some locally converted MATLAB `.mat` files; includes a KDD Cup 1999 sample and examples such as Wine. |
| [`ssl-book/`](ssl-book/) | **Semi-Supervised Learning book benchmarks (2006):** saved datasets, predefined labeled/unlabeled splits and a combined MATLAB ZIP, with a copy of the original benchmark description. |
| [`MSRC/`](MSRC/) | **Segmentation image resources:** a BSDS300 image archive and extracted images, together with additional image/ground-truth material. The folder mixes sources and should not be treated as a single licensed dataset. |
| [`GSC/`](GSC/) | **Images and segmentation annotations:** source images, ground-truth masks and related image files used in historical segmentation experiments; per-image provenance is not fully established. |
| [`dataset-interactive-algorithms/`](dataset-interactive-algorithms/) | **Interactive segmentation evaluation:** ground truth and two sets of user-scribble annotations; the included README describes the 50-image evaluation collection of Andrade and Carrera (2015). |
| [`BCT/`](BCT/) | **Brain Connectivity Toolbox snapshot (January 2017):** MATLAB network measures, graph-analysis utilities, example scripts and sample connectivity matrices. This is third-party **software as well as data**. |
| [`SmallWorldNess/`](SmallWorldNess/) | **Small-world network analysis:** MATLAB scripts for calculating/testing small-worldness, example graph data, a bundled code license and two copies of research papers. |
| [`Multilayer Social Networks/`](Multilayer%20Social%20Networks/) | **Two multilayer network examples:** Florentine and monastery data stored in `.mpx` format. |
| Repository root | **Experimental MATLAB and C/MEX research code:** successive `strwalk*` and `cnsslis*` segmentation/graph-learning variants, `fit*` and `trbatch*` experiment drivers, matrices, historical results and local MATLAB configuration files. |

The historical tree has **2,363 tracked files**, including **607 MATLAB `.m` files**, totaling **801.7 MB of uncompressed content**. File counts and archive sizes are *not* counts of independently licensed datasets.

See **[`DATASET_PROVENANCE.md`](DATASET_PROVENANCE.md)** for checked-in file counts, sizes, research sources and known gaps in licensing/provenance documentation.

## Reproducibility and licensing cautions

- This documentation **does not claim to have rerun experiments**, compiled MEX extensions, recreated figures or validated the historical results.
- The MATLAB version, toolboxes, local paths and external dependencies are not fully pinned. Files such as `pathdef.m` contain machine-specific configuration and should not be used blindly on a new installation.
- Third-party code, photographs, annotations, datasets and PDFs do **not necessarily share a license**. This workspace has **no root-level LICENSE**; no blanket permission is claimed here for its full contents.
- Preserving a public research copy may help reproduce older studies, but **public availability is not itself proof of redistribution rights**. Review individual authors and dataset pages before republishing or adapting a specific collection.
- Do not remove or rewrite historical data, results, or experimental code simply to make this repository look like a polished modern package.

## Repository scope and ongoing maintenance

This repository **remains public and is not archived on GitHub**. Its historical code and datasets are retained for reference, and the documentation can continue to be improved. The original 2019 source/data state is identifiable through the Git commit linked above; document any future changes rather than silently replacing historical experiment inputs. For focused software and examples, use the dedicated repositories listed earlier.
