name 'mounts'
default_source :supermarket
run_list 'mounts::default'
cookbook 'mounts', path: '.'
