name 'homelab_proxy'
default_source :supermarket
run_list 'homelab_proxy::default'
cookbook 'homelab_proxy', path: '.'
