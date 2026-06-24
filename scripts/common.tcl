proc env_default {name default} {
    if {[info exists ::env($name)] && $::env($name) ne ""} {
        return $::env($name)
    }
    return $default
}

proc script_dir {} {
    return [file normalize [file dirname [info script]]]
}

proc repo_root {} {
    return [file normalize [file join [script_dir] ..]]
}

proc cfg {} {
    set root [env_default REPO_ROOT [repo_root]]
    set build [env_default BUILD [file join $root build default]]
    return [dict create \
        repo_root [file normalize $root] \
        build [file normalize $build] \
        project_name as02mc04_template \
        top [env_default TOP top] \
        part [env_default PART xcku3p-ffvb676-2-e] \
        board_part [env_default BOARD_PART tiferking.cn:as02mc04:part0:1.0] \
        board_constraints [env_default BOARD_CONSTRAINTS 1] \
        led_iostandard [env_default LED_IOSTANDARD BOARD] \
        jobs [env_default JOBS 4] \
        hw_freq [env_default HW_FREQ 1000000] \
        stage [env_default STAGE bit] \
        confirm [env_default CONFIRM 0]]
}

proc project_dir {c} {
    return [file join [dict get $c build] project]
}

proc project_xpr {c} {
    return [file join [project_dir $c] "[dict get $c project_name].xpr"]
}

proc ensure_dir {path} {
    if {![file exists $path]} {
        file mkdir $path
    }
}

proc glob_or_empty {pattern} {
    return [glob -nocomplain $pattern]
}

proc fail {message} {
    puts stderr "ERROR: $message"
    exit 1
}

proc run_finished_ok {run_name} {
    set status [get_property STATUS [get_runs $run_name]]
    puts "$run_name status: $status"
    if {![regexp -nocase {(complete|write_bitstream Complete)} $status]} {
        fail "$run_name did not complete successfully: $status"
    }
}

proc print_config {c} {
    puts "Repository : [dict get $c repo_root]"
    puts "Build      : [dict get $c build]"
    puts "Top        : [dict get $c top]"
    puts "Part       : [dict get $c part]"
    puts "Board part : [dict get $c board_part]"
}
