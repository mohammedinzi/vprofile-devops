#!/usr/bin/env bash
#
# copy-sgs.sh — Safely replicate AWS Security Groups (SGs) across regions
#
# 🎯Value:
# - Demonstrates AWS networking knowledge (SGs are regional, VPC-bound).
# - Shows automation discipline: Bash + AWS CLI + jq for JSON parsing.
# - Highlights engineering maturity: distinguishes between *real* errors and *expected* benign ones.
# - Emphasizes operational excellence: logs are clean, structured, zero noise.
#
# Usage:
#   ./copy-sgs.sh \
#     --source-region eu-north-1 \
#     --target-region us-east-1 \
#     --target-vpc vpc-xxxxxxxx \
#     --sg-ids sg-aaaaaaa sg-bbbbbbb sg-ccccccc \
#     [--account-id 123456789012] \
#     [--profile myprofile]
#

set -euo pipefail

# ------------------------
# 1. Parse Arguments
# ------------------------
SOURCE_REGION=""
TARGET_REGION=""
TARGET_VPC=""
ACCOUNT_ID=""
PROFILE=""
SG_IDS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --source-region) SOURCE_REGION="$2"; shift 2 ;;
    --target-region) TARGET_REGION="$2"; shift 2 ;;
    --target-vpc)    TARGET_VPC="$2"; shift 2 ;;
    --account-id)    ACCOUNT_ID="$2"; shift 2 ;; # optional, but useful for tagging
    --profile)       PROFILE="--profile $2"; shift 2 ;;
    --sg-ids)
      shift
      while [[ $# -gt 0 && $1 != --* ]]; do
        SG_IDS+=("$1")
        shift
      done
      ;;
    *) echo "❌ Unknown arg: $1"; exit 1 ;;
  esac
done

if [[ -z "$SOURCE_REGION" || -z "$TARGET_REGION" || -z "$TARGET_VPC" || ${#SG_IDS[@]} -eq 0 ]]; then
  echo "❌ Missing required arguments. See script header for usage."
  exit 1
fi

echo "🚀 Starting SG replication..."
echo "   Source Region : $SOURCE_REGION"
echo "   Target Region : $TARGET_REGION"
echo "   Target VPC    : $TARGET_VPC"
[[ -n "$ACCOUNT_ID" ]] && echo "   Account ID    : $ACCOUNT_ID"
echo "   Security Groups: ${SG_IDS[*]}"
echo

# ------------------------
# 2. Utility: Create SG in target region
# ------------------------
create_sg() {
  local sg_id="$1"
  local name desc

  # Fetch SG metadata
  read -r name desc <<<"$(aws ec2 describe-security-groups \
    --region "$SOURCE_REGION" $PROFILE \
    --group-ids "$sg_id" \
    --query 'SecurityGroups[0].[GroupName,Description]' \
    --output text)"

  echo "📦 Creating SG: $name ($desc)"
  new_sg_id=$(aws ec2 create-security-group \
    --region "$TARGET_REGION" $PROFILE \
    --group-name "$name" \
    --description "$desc" \
    --vpc-id "$TARGET_VPC" \
    --query 'GroupId' --output text)

  # Optional: Tag for traceability
  if [[ -n "$ACCOUNT_ID" ]]; then
    aws ec2 create-tags \
      --region "$TARGET_REGION" $PROFILE \
      --resources "$new_sg_id" \
      --tags Key=ClonedFrom,Value="$sg_id" Key=Account,Value="$ACCOUNT_ID"
  fi

  echo "✅ Created $new_sg_id"
  echo "$sg_id $new_sg_id" >> sg-map.tmp
}

# ------------------------
# 3. Build SG Map (old→new IDs)
# ------------------------
> sg-map.tmp
for sg in "${SG_IDS[@]}"; do
  create_sg "$sg"
done

# Helper: map source SG → new SG
map_sg() {
  grep -w "$1" sg-map.tmp | awk '{print $2}'
}

# ------------------------
# 4. Replicate Inbound + Outbound Rules
# ------------------------
for sg in "${SG_IDS[@]}"; do
  new_sg=$(map_sg "$sg")
  echo "🔄 Copying rules for $sg → $new_sg"

  # Extract all rules in source SG
  rules=$(aws ec2 describe-security-groups \
    --region "$SOURCE_REGION" $PROFILE \
    --group-ids "$sg" \
    --query 'SecurityGroups[0].{In:IpPermissions,Out:IpPermissionsEgress}' \
    --output json)

  # Inbound
  inbound=$(echo "$rules" | jq '.In')
  if [[ "$inbound" != "[]" ]]; then
    echo "   ➡️ Authorizing inbound rules..."
    echo "$inbound" | jq -c '.[]' | while read -r rule; do
      # Map referenced SGs if needed
      mapped=$(echo "$rule" | jq 'if .UserIdGroupPairs|length>0 then
        .UserIdGroupPairs |= map(.GroupId = "'"$(map_sg $(echo "$rule" | jq -r .UserIdGroupPairs[0].GroupId))"'")
      else . end')
      aws ec2 authorize-security-group-ingress \
        --region "$TARGET_REGION" $PROFILE \
        --group-id "$new_sg" \
        --ip-permissions "$mapped" 2> >(grep -v "InvalidPermission.Duplicate" >&2)
    done
  fi

  # Outbound (egress)
  outbound=$(echo "$rules" | jq '.Out')
  if [[ "$outbound" != "[]" ]]; then
    echo "   ⬅️ Authorizing outbound rules..."
    echo "$outbound" | jq -c '.[]' | while read -r rule; do
      aws ec2 authorize-security-group-egress \
        --region "$TARGET_REGION" $PROFILE \
        --group-id "$new_sg" \
        --ip-permissions "$rule" 2> >(grep -v "InvalidPermission.Duplicate" >&2)
    done
  fi

  echo "   ✅ Rules copied for $new_sg"
done

echo
echo "🎉 Done! Security Groups replicated successfully."
echo "   Mapping file: sg-map.tmp (source → target)"
