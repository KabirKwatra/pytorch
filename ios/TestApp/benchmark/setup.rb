# frozen_string_literal: true

require 'xcodeproj'
require 'fileutils'
require 'optparse'

options = {}
option_parser = OptionParser.new do |opts|
  opts.banner = 'Script for setting up TestApp.xcodeproj'
  opts.on('-t', '--team_id ', 'development team ID') do |value|
    options[:team_id] = value
  end
end.parse!
puts "Current directory: #{Dir.pwd}"
install_path = File.expand_path('../../../build_ios/install')
raise "path doesn't exist:#{install_path}!" unless Dir.exist? install_path

xcodeproj_path = File.expand_path('../TestApp.xcodeproj')
raise "path doesn't exist:#{xcodeproj_path}!" unless File.exist? xcodeproj_path

puts 'Setting up TestApp.xcodeproj...'
project = Xcodeproj::Project.open(xcodeproj_path)
targets = project.targets
header_search_path      = ['$(inherited)', "#{install_path}/include"]
libraries_search_path   = ['$(inherited)', "#{install_path}/lib"]
other_linker_flags      = ['$(inherited)', '-all_load']
# TestApp and TestAppTests
targets.each do |target|
  target.build_configurations.each do |config|
    config.build_settings['HEADER_SEARCH_PATHS'] = header_search_path
    config.build_settings['LIBRARY_SEARCH_PATHS']   = libraries_search_path
    config.build_settings['OTHER_LDFLAGS']          = other_linker_flags
    config.build_settings['ENABLE_BITCODE']         = 'No'
    dev_team_id = options[:team_id]
    config.build_settings['DEVELOPMENT_TEAM'] = dev_team_id if dev_team_id
  end
end
puts 'Installing the testing model...'
model_path = File.expand_path('./model.pt')
raise "model.pt can't be found!" unless File.exist?(model_path)

config_path = File.expand_path('./config.json')
raise "config.json can't be found!" unless File.exist?(config_path)

group = project.main_group.find_subpath(File.join('TestApp'), true)
group.set_source_tree('SOURCE_ROOT')
group.files.each do |file|
  next unless file.name.to_s.end_with?('.pt') || file.name == 'config.json'

  group.remove_reference(file)
  targets.each do |target|
    target.resources_build_phase.remove_file_reference(file)
  end
end
model_file_ref = group.new_reference(model_path)
config_file_ref = group.new_reference(config_path)
targets.each do |target|
  target.resources_build_phase.add_file_reference(model_file_ref, true)
  target.resources_build_phase.add_file_reference(config_file_ref, true)
end
puts 'Linking static libraries...'
libs = ['libc10.a', 'libclog.a', 'libnnpack.a', 'libXNNPACK.a', 'libeigen_blas.a', 'libcpuinfo.a', 'libpytorch_qnnpack.a', 'libtorch_cpu.a', 'libtorch.a']
targets.each do |target|
  target.frameworks_build_phases.clear
  libs.each do |lib|
    path = "#{install_path}/lib/#{lib}"
    if File.exist?(path)
      libref = project.frameworks_group.new_file(path)
      target.frameworks_build_phases.add_file_reference(libref)
    end
  end
end

project.save
puts 'Done.'
