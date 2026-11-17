# iteration.md — pivot 性能优化版本记录

仓库：`Judy7-coder/perf-lab` · 题目：2022_IPCC / pivot（dim=2, n=500, k=2）

## 测量口径（每版保持一致，否则数字没有可比性）

- 取程序输出的 **Using time**，单位 ms；计时代码不许改（当前源码仅一处计时输出，已用 `grep -n "Using time" pivot.c` 核对）。
- 每版对拍：`diff result.txt refer-2dim-5h.txt`，无输出记为 `ok`（max 143351 / min 83226，各 1000 组且含顺序）。
- 编译参数固化在 `Makefile` 的 `CFLAGS`；改编译选项也算一版，否则两版之间没有文件 diff。
- 每版跑 3 次取中位数，原始值存 `bench/<版本>-times.txt`（v0 已于 2026-11-17 补测，三次值见 `bench/v0-times.txt`）。
- 每版火焰图存 `flamegraphs/<版本>.svg`；只交 SVG，不交 `perf.data` 和编译产物。

## 版本表

| 版本 | commit | 改了什么 | 耗时（中位数） | 相对上一版 | diff |
|---|---|---|---|---|---|
| v0-baseline | `5fb5c57` | 原始代码 | 495224.816 ms（3 次：494925.945 / 495224.816 / 495500.360） | — | ok |
| v1 | `v1` | | | | |
| v2 | `v2` | | | | |
| v3 | `v3` | | | | |
| v4 | `v4` | | | | |
| v5 | `v5` | | | | |

## 三个填表规矩

- `commit` 列填已生成 commit 的短 hash 或 tag 名（v0 填 `5fb5c57`，等价 tag 为 `v0-baseline`）。hash 在 commit 生成后才确定，**只能在后续 commit 里回填已经存在的 hash**；不要试图在同一个 commit 里写它自己的 hash，更不要用 `git commit --amend` 补写——amend 会换掉 hash，让已经推到远端的 tag 悬空。
- **不要用 `git commit --amend` 补表格**：amend 会换掉 hash，之前记录的引用全部失效。
- `diff` 列 = 对拍结果（与 refer 一致写 `ok`）。版本之间的代码差异另存 GitHub 对比链接，例如：
  `https://github.com/Judy7-coder/perf-lab/compare/v0-baseline...v1`

## 前期实验（W03 已完成，仅作对照，不回填成 commit）

| 编译参数 | 耗时 (ms) | 提速 |
|---|---|---|
| 无优化 | 495279 | 1.00× |
| -O1 | 98480 | 5.03× |
| -O2 | 71800 | 6.90× |
| -O3 | 56389 | 8.78× |
| -O3 -march=native | 77146 / 63429 / 67913 | 三跑取最小 63429，native 无提升 |

perf stat：IPC 6.67、retiring 96.5%、mem-bound 0.4%、branch-miss 0.04% → 计算密集。
perf report：SumDistance 占 99.49%（226K 样本，0 丢失）。
遗留两刀：① n×n 距离预查表 ② OpenMP 并行。
