#!/bin/bash
# Author: Memeti Rejan
# Date:   2025-12-05
# Desc:   DESCRIPTION

log_step "2/4 – IAM-Rolle und Policies einrichten"

TRUST_POLICY="iam/trust-policy.json"
POLICY_LIST="iam/policies.txt"

if ! [[ -f "$TRUST_POLICY" ]]; then
  error_exit "Trust-Policy fehlt: $TRUST_POLICY"
fi
if ! [[ -f "$POLICY_LIST" ]]; then
  error_exit "Policy-Liste fehlt: $POLICY_LIST"
fi

if aws_cmd iam get-role --role-name "$ROLE_NAME" >/dev/null 2>&1; then
  log_info "IAM-Rolle '$ROLE_NAME' existiert bereits."
else
  log_info "Erstelle IAM-Rolle '$ROLE_NAME'..."
  aws_cmd iam create-role \
    --role-name "$ROLE_NAME" \
    --assume-role-policy-document "file://$TRUST_POLICY" >/dev/null
  log_success "IAM-Rolle '$ROLE_NAME' erstellt."
fi

while IFS= read -r arn; do
  [[ -z "$arn" || "$arn" =~ ^# ]] && continue
  log_info "Hänge Policy an: $arn"
  if ! aws_cmd iam attach-role-policy \
    --role-name "$ROLE_NAME" \
    --policy-arn "$arn" 2>/dev/null; then
    log_warn "Policy '$arn' konnte evtl. nicht angehängt werden (vielleicht schon vorhanden)."
  fi
done < "$POLICY_LIST"

log_success "IAM-Konfiguration abgeschlossen."
 