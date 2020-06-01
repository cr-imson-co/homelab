name 'homelab'
default_source :supermarket
run_list 'homelab::default'
cookbook 'homelab', path: '.'
