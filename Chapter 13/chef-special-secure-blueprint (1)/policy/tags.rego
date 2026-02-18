package policy.tags

import future.keywords.if
import future.keywords.in
import future.keywords.contains

import data.terraform.common

required_tags := {"cost_center", "environment", "owner"}

deny contains msg if {
    rc := common.resource_changes[_]
    common.is_create_or_update_rc(rc)
    tags := common.get_tags(rc)
    missing := common.missing_keys(tags, common.required_tags)
    count(missing) > 0
    msg := sprintf("Resource %s is missing required tags: %v", [rc.address, sort(missing)])
}