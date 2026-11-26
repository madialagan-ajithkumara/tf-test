#!/usr/bin/env bash
# AkOps Labs check for the Terraform project. Please don't edit this file.
set -uo pipefail
fail=0
pass() { echo "PASS  $1"; }
bad() { echo "FAIL  $1"; fail=1; }

for f in main.tf outputs.tf; do [ -f "$f" ] && pass "$f exists" || bad "$f exists"; done
grep -Eq '#[[:space:]]*TODO:' main.tf && bad "no # TODO: lines left in main.tf" || pass "no TODOs left"
terraform fmt -check -recursive >/dev/null 2>&1 && pass "terraform fmt: code is formatted" || echo "TIP   run terraform fmt to format your code (not required)"

cp tests/provider_override.tf ./akops_override.tf
trap 'rm -f akops_override.tf tfplan plan.json' EXIT
if ! terraform init -backend=false -input=false >/dev/null; then bad "terraform init"; exit 1; fi
if terraform validate; then pass "terraform validate"; else bad "terraform validate"; exit 1; fi
if ! terraform plan -input=false -refresh=false -out=tfplan >/dev/null; then bad "terraform plan"; terraform plan -input=false -refresh=false; exit 1; fi
pass "terraform plan"
terraform show -json tfplan > plan.json

chk() { # chk "label" "python expression on r (resources by type) and o (outputs)"
  if python3 - "$2" <<'PY' 2>/dev/null; then pass "$1"; else bad "$1"; fi
import json, sys
p = json.load(open("plan.json"))
cfg = p["configuration"]["root_module"]
r = {}
for x in p["planned_values"]["root_module"].get("resources", []):
    r.setdefault(x["type"], []).append(x["values"])
refs = {}
for x in cfg.get("resources", []):
    refs.setdefault(x["type"], []).append(x.get("expressions", {}))
o = cfg.get("outputs", {})
def ref(e, key):
    return " ".join(e.get(key, {}).get("references", []))
assert eval(sys.argv[1])
PY
}
chk "VPC 10.0.0.0/16 with DNS hostnames" "any(v['cidr_block']=='10.0.0.0/16' and v['enable_dns_hostnames'] for v in r['aws_vpc'])"
chk "VPC has a Name tag" "any((v.get('tags') or {}).get('Name') for v in r['aws_vpc'])"
chk "public subnet 10.0.1.0/24 with public IPs" "any(v['cidr_block']=='10.0.1.0/24' and v['map_public_ip_on_launch'] for v in r['aws_subnet'])"
chk "subnet and gateway are in the VPC" "'aws_vpc.' in ref(refs['aws_subnet'][0],'vpc_id') and 'aws_vpc.' in ref(refs['aws_internet_gateway'][0],'vpc_id')"
chk "route 0.0.0.0/0 to the internet gateway" "any(any(rt['cidr_block']=='0.0.0.0/0' for rt in v.get('route') or []) for v in r.get('aws_route_table',[])) or any(v.get('destination_cidr_block')=='0.0.0.0/0' for v in r.get('aws_route',[]))"
chk "route table attached to the subnet" "len(r.get('aws_route_table_association',[]))>=1"
chk "port 80 open to everyone" "any(i['from_port']<=80<=i['to_port'] and '0.0.0.0/0' in (i['cidr_blocks'] or []) for v in r['aws_security_group'] for i in v['ingress'])"
chk "port 22 only from var.my_ip" "all('0.0.0.0/0' not in (i['cidr_blocks'] or []) for v in r['aws_security_group'] for i in v['ingress'] if i['from_port']<=22<=i['to_port']) and any(i['from_port']<=22<=i['to_port'] for v in r['aws_security_group'] for i in v['ingress'])"
chk "instance uses var.ami_id and var.instance_type" "'var.ami_id' in ref(refs['aws_instance'][0],'ami') and 'var.instance_type' in ref(refs['aws_instance'][0],'instance_type')"
chk "instance is in the subnet with the security group" "'aws_subnet.' in ref(refs['aws_instance'][0],'subnet_id') and 'aws_security_group.' in ref(refs['aws_instance'][0],'vpc_security_group_ids')"
chk "outputs vpc_id and public_ip" "'vpc_id' in o and 'public_ip' in o"

echo
[ $fail -eq 0 ] && echo "All checks passed. Push and submit your repo on AkOps Labs." || echo "Some checks failed. Fix them and push again."
exit $fail
