import pandas as pd
from sklearn.svm import SVC
from sklearn.model_selection import cross_val_predict
from sklearn.metrics import roc_auc_score
from sklearn.preprocessing import LabelEncoder
from sklearn.model_selection import train_test_split
from sklearn.metrics import roc_auc_score
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import KFold
import os

default_folder = r'D:/2023/renal_tumor_vat/radiomics/isup_grade/LASSO'  # 设置默认文件夹路径

# 更改当前工作目录为默认文件夹路径
os.chdir(default_folder)

# Read data
# traindata = pd.read_excel("train_fold1_tumor.xlsx")
# valdata = pd.read_excel("val_fold1_tumor.xlsx")
# testdata = pd.read_excel("test_fold1_tumor.xlsx")

traindata = pd.read_excel("train_fold5_vat6.xlsx")
valdata = pd.read_excel("val_fold5_vat6.xlsx")
testdata = pd.read_excel("test_fold5_vat6.xlsx")

# 将标签转换为数值
train_labels = traindata["grade"]
val_labels = valdata["grade"]
test_labels = testdata["grade"]


# Remove the first column
traindata = traindata.iloc[:, 1:]
valdata = valdata.iloc[:, 1:]
testdata = testdata.iloc[:, 1:]

# 将数据分为特征和标签
train_features = traindata.drop(columns=["grade"])
val_features = valdata.drop(columns=["grade"])
test_features = testdata.drop(columns=["grade"])

# 使用Z-score标准化对特征进行处理
scaler = StandardScaler()
train_features_scaled = scaler.fit_transform(train_features)
val_features_scaled = scaler.transform(val_features)
test_features_scaled = scaler.transform(test_features)

# Train SVM model
#svm_model = SVC(kernel='rbf', C=1, probability=True, random_state=42) #py_svc/data1
svm_model = SVC(kernel='rbf', C=1, gamma=0.01,probability=True, random_state=42) #py_svc/data2
svm_model.fit(train_features_scaled, train_labels)

# Predict probabilities on validation and test sets
train_pred_prob = svm_model.predict_proba(train_features_scaled)
val_pred_prob = svm_model.predict_proba(val_features_scaled)
test_pred_prob = svm_model.predict_proba(test_features_scaled)

# Calculate ROC AUC scores
train_auc = roc_auc_score(train_labels, train_pred_prob[:, 1])
val_auc = roc_auc_score(val_labels, val_pred_prob[:, 1])
test_auc = roc_auc_score(test_labels, test_pred_prob[:, 1])

# Print AUC values for validation and test sets
print("Train AUC:",train_auc)
print("Validation AUC:", val_auc)
print("Test AUC:", test_auc)

# Combine data and labels into a DataFrame
combined_data = pd.DataFrame({
    'Probability': list(train_pred_prob[:, 1]) + list(val_pred_prob[:, 1]) + list(test_pred_prob[:, 1]),
    'grade': list(train_labels) + list(val_labels) + list(test_labels),
    'Dataset': ['Train'] * len(train_pred_prob[:, 1]) + ['Validation'] * len(val_pred_prob[:, 1]) + ['Test'] * len(test_pred_prob[:, 1])
})

# Save to a new Excel file
combined_data.to_excel("py_fold5_combined_predictions_vat6.xlsx", index=False)