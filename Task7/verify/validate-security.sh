#!/bin/bash

set -e

echo "=============================="
echo "🔍 Проверка состояния Gatekeeper"
echo "=============================="
kubectl -n gatekeeper-system get pods -o wide
echo

echo "=============================="
echo "🔍 Проверка webhook'ов Gatekeeper"
echo "=============================="
kubectl get validatingwebhookconfiguration gatekeeper-validating-webhook-configuration -o yaml | grep "failurePolicy"
echo

echo "=============================="
echo "📌 Список ConstraintTemplates"
echo "=============================="
kubectl get constrainttemplates
echo

echo "=============================="
echo "📌 Список Constraints"
echo "=============================="
kubectl get constraints --all-namespaces
echo

echo "=============================="
echo "🚨 Проверка нарушений constraints"
echo "=============================="

# Получаем все CRD constraints (например K8sNoHostPath, K8sPrivileged, K8sRunAsNonRoot)
CRDS=$(kubectl get crd | grep constraints.gatekeeper.sh | awk '{print $1}')

for crd in $CRDS; do
    KIND=$(echo $crd | sed 's/\.constraints\.gatekeeper\.sh//')
    echo "---- Проверяем $KIND ----"
    kubectl get "$KIND" -o json | jq -r '
        .items[] |
        "Constraint: \(.metadata.name)\nViolations: \(.status.violations // [])\n"'
done
