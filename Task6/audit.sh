#!/bin/bash
echo "Проверка на события доступа к secrets"
jq 'select(.objectRef.resource=="secrets" and .verb=="get")' audit.log

echo "Проверка на kubectl exec в чужие поды:"
jq 'select(.verb=="create" and .objectRef.subresource=="exec")' audit.log

echo "Привилегированные поды"
jq 'select(.objectRef.resource=="pods" and .requestObject.spec.containers[].securityContext.privileged==true)' audit.log

echo "Удаление или изменение audit policy"
grep -i 'audit-policy.yaml' audit.log
