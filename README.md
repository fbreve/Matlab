# MATLAB research workspace — historical archive

> **Historical research snapshot (2018–2019).** This repository stores an old mixed-purpose MATLAB research workspace. It is **not** a maintained software distribution or a reproducible, ready-to-run software environment.

The last pre-documentation code/data commit was [`3c309a9`](https://github.com/fbreve/Matlab/commit/3c309a98142f33cf80aac9d95056e82cf6c24aec), dated September 12, 2019. The repository preserves old versions of MATLAB and C/MEX algorithms, scripts for experiments, parameter sweeps, results, workspace files, and downloaded benchmark collections. Some source filenames reflect backup copies and historical merge/synchronization conflicts; do not assume they are supported interfaces.

## Focused repositories for code and usage examples

| Project | Focus |
| --- | --- |
| [Particle Competition and Cooperation (PCC)](https://github.com/fbreve/Particle-Competition-and-Cooperation) | Maintained/focused MATLAB and C/MEX PCC implementation |
| [PyPCC](https://github.com/fbreve/pypcc) | Python implementation |
| [LNPCC](https://github.com/fbreve/LNPCC) | Focused research code for label propagation / PCC |
| [LPCN](https://github.com/fbreve/LPCN) | Dedicated network-learning research project |
| [NoisyGL](https://github.com/fbreve/NoisyGL) | Subsequent graph learning under noise |
| [Grid-image contrast study](https://github.com/fbreve/grid-image-contrast-ijcnn2009extended) | Related dedicated research archive |

These repositories are **related**, not complete replacements for all historical files. This workspace retains many additional early and experimental algorithm versions.

## Preserved datasets and third-party resources

Some original source URLs or historical dataset versions may be difficult to retrieve today. This repository retains the **originally committed copies** for provenance and possible scientific reproduction, without silently replacing them with current editions.

| Path | Material |
| --- | --- |
| [`UCR_TS_Archive_2015/`](UCR_TS_Archive_2015/) | UCR Time Series Classification Archive, 2015 |
| [`uci-datasets/`](uci-datasets/) | UCI dataset copies and some local MATLAB conversions |
| [`ssl-book/`](ssl-book/) | Semi-Supervised Learning book (2006) benchmark splits |
| [`MSRC/`](MSRC/) | Historical segmentation images and GT, including BSDS300 |
| [`GSC/`](GSC/) | Image, ground truth and segmentation-related historical material |
| [`dataset-interactive-algorithms/`](dataset-interactive-algorithms/) | Andrade/Carrera interactive-segmentation evaluation material |
| [`BCT/`](BCT/) | Brain Connectivity Toolbox dated 2017-01-15 |
| [`SmallWorldNess/`](SmallWorldNess/) | Third-party MATLAB routines and supporting scientific material |
| [`Multilayer Social Networks/`](Multilayer%20Social%20Networks/) | Sample multilayer social-network data |
| Repository root | PCC/`strwalk*`, `cnsslis*`, `fit*`, `trbatch*` scripts, C/MEX routines, experiments, saved data/results and local MATLAB configuration files |

The historical tree has **2,363 tracked files**, including **607 MATLAB `.m` files**, totaling **801.7 MB of uncompressed content**. File counts and archive sizes are *not* counts of independently licensed datasets.

See **[`DATASET_PROVENANCE.md`](DATASET_PROVENANCE.md)** for checked-in file counts, sizes, research sources and known gaps in licensing/provenance documentation.

## Reproducibility and licensing cautions

- This documentation **does not claim to have rerun experiments**, compiled MEX extensions, recreated figures or validated the historical results.
- The MATLAB version, toolboxes, local paths and external dependencies are not fully pinned. Files such as `pathdef.m` contain machine-specific configuration and should not be used blindly on a new installation.
- Third-party code, photographs, annotations, datasets and PDFs do **not necessarily share a license**. This workspace has **no root-level LICENSE**; no blanket permission is claimed here for its full contents.
- Preserving a public research copy may help reproduce older studies, but **public availability is not itself proof of redistribution rights**. Review individual authors and dataset pages before republishing or adapting a specific collection.
- Do not remove or rewrite historical data, results, or experimental code simply to make this repository look like a polished modern package.

## Archive policy

This workspace is preserved primarily as a **historical reference**. For active development, prefer the focused projects linked above. Future documentation changes should maintain the intact 2019 code/data state and distinguish archived observations from newly rerun results.
