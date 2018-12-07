# SVM多分类
## 默认设置
```matlab
Mdl = fitcecoc(X,Y);
```
  **test accuracy = 87.9%**


## 自动优化
```matlab
rng default;
Mdl = fitcecoc(X,Y,'OptimizeHyperparameters','auto',...
'HyperparameterOptimizationOptions',struc('AcquisitionFunctionName',...
    'expected-improvement-plus'));
```
| Iter | Eval result| Objective | Objective runtime | BestSoFar (observed)| BestSoFar (estim.) |Coding | BoxConstraint| 
|------|------------|-----------|------------------|----------------------|-------------------|-------|---------------|
|    1 | Best   |    0.56956 |     290.82 |    0.56956 |    0.56956 |     onevsall |    0.0089562 |       310.42 |
## 线性核函数 
> 已经调整lambda到最优
```matlab
t = templateLinear('Lambda',0.008);
Mdl = fitcecoc(X',Y,'Learners',t,'ObservationsIn','columns');
```
**test accuracy=87.0%**
## 常规核函数
```matlab
t = templateSVM('Standardize',1);
Mdl = fitcecoc(X,Y,'Learners',t);
```
**test accuracy=86.5%**

