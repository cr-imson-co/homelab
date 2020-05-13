current_dir = File.expand_path(__dir__)
file_cache_path current_dir.to_s
cookbook_path "#{current_dir}/cookbooks"
node_name 'nomad'
solo true
