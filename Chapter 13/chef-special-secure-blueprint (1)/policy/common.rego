package terraform.common

import future.keywords.if
import future.keywords.in
import future.keywords.contains

resource_changes := input.resource_changes

actions(rc) = rc.change.actions if { true }

is_create_or_update("create") if { true }
is_create_or_update("update") if { true }

is_create_or_update_rc(rc) if {
    some a in actions(rc)
    is_create_or_update(a)
}

changes_of_type(type) = [rc | 
    rc := resource_changes[_]
    rc.type == type
    is_create_or_update_rc(rc)
]

get_tags(rc) = object.get(rc.change.after, "tags", {}) 

has_key(m, k) if { 
    object.get(m, k, null) != null 
}

missing_keys(m, required) = {k |
    k := required[_]
    not has_key(m, k)
}

required_tags := ["cost_center", "environment", "owner"]