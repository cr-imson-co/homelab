name 'homer'
default_source :supermarket
run_list 'homer::default'
cookbook 'homer', path: '.'
