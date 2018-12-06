# 对比分析迁移学习和传统机器学习在手写数字识别问题上的性能差异
## 工作内容：
* 运用matlab读取MNIST上手写数字识别数据集，对其分别进行传统机器学习建模和迁移学习。对比分析两者性能差异。
## 工作计划：
1. 下载MNIST数据集，进行前期的数据清洗工作，使其转化成机器学习算法能够输入的数据结构。

2. 用传统机器学习对其进行建模（svm、logistics回归、决策树、xgboost、lightgbm等视matlab能够提供的算法包决定）

3. 用CNN网络进行迁移学习。原网络架构和参数试matlab能够提供的网络参数决定。

4. 对比分析两者训练时间、训练误差等性能差异。

5. 得出结论：在手写数字识别问题中哪种方法可以获得合适的需求的性能。
## 结论分析
- 迁移学习不是很受原网络架构影响，本次训练了matlab自带的LettersClassificationNet(以下简称LCnet)和大名鼎鼎Alexnet，两者网络复杂程度完全不是一个量级，LCnet专门是训练的用来分类字母和数字的7x7x1输入的网络，而Alexnet是在2012Imagenet竞赛大放异彩的可以分类1000种图片的大型网络，输入为127x127x3但是从分类正确率上来说,两者都非常出色，Alexnet甚至可以达到100%，由此可见只要原网络起初训练的任务相同（视觉、语音、翻译等大类），由复杂任务网络迁移学习简单任务是非常好的方法。
- 越复杂的网络因为硬件条件的限制（GPU缓存大小）可以承受的mini-batchsize上界越小，但是也不容易不收敛。LCnet在mini-batchsize=16时就不能收敛，然而Alexnetzai 在mini-batchsize=16仍然有很好的性能
## 实验反思和改进策略：
### 反思
- mini-batchsize参数很能够影响系统训练后的性能，太小则会在最优解附近转圈不能收敛到一个最优值，太大则会超出GPU内存限制
### 改进策略
- 本次实验限制于硬件设备和时间因素只调整了mini-batchsize参数，可以对其他训练参数进行分析