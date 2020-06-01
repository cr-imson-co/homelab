name 'notifications'
default_source :supermarket
run_list 'notifications::default'
cookbook 'notifications', path: '.'
