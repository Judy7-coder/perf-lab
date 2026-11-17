# iteration.md — pivot 性能优化版本记录

仓库：`Judy7-coder/perf-lab` · 题目：2022_IPCC / pivot（dim=2, n=500, k=2）

## 测量口径（每版保持一致，否则数字没有可比性）

- 取程序输出的 **Using time**，单位 ms；计时代码不许改（当前源码仅一处计时输出，已用 `grep -n "Using time" pivot.c` 核对）。
- 每版对拍：`diff result.txt refer-2dim-5h.txt`，无输出记为 `ok`（max 143351 / min 83226，各 1000 组且含顺序）。
- 编译参数固化在 `Makefile` 的 `CFLAGS`；改编译选项也算一版，否则两版之间没有文件 diff。
- v1 起同参数跑 3 次取中位数，原始值存 `bench/<版本>-times.txt`；基线沿用 W03 单次实测并标注。
- 每版火焰图存 `flamegraphs/<版本>.svg`；只交 SVG，不交 `perf.data` 和编译产物。

## 版本表

| 版本 | commit | 改了什么 | 耗时（中位数） | 相对上一版 | diff |
|---|---|---|---|---|---|
| v0-baseline | `v0-baseline` | 原始代码 | 495279 ms（W03 单次实测，非中位数） | — | ok |
| v1 | `v1` | | | | |
| v2 | `v2` | | | | |
| v3 | `v3` | | | | |
| v4 | `v4` | | | | |
| v5 | `v5` | | | | |

## 三个填表规矩

- `commit` 列填 **tag 名**，不填 hash。commit hash 由内容算出，而这张表就在那个 commit 里，填 hash 会自指矛盾；需要 hash 时把 `git log --oneline --decorate` 的输出贴在文末做对照表。
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
