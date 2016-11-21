## following line has to exist due skip raise error on guard execution
#guard :rspec, cmd: "bundle exec rspec --format html --out tmp/scoppie_rspec_output.html" {}

rspec_command = 'rspec --format html --out tmp/scoppie_rspec_output.html'

watch(%r{^spec/.+_spec\.rb$}) { %x[ #{rspec_command} ] }
watch(%r{^lib/.+\.rb$}) { %x[ #{rspec_command} ] }