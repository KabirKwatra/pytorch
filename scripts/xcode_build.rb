# frozen_string_literal: true

require 'optparse'
require 'xcodeproj'

options = {}
option_parser = OptionParser.new do |opts|
  opts.banner = 'Tools for building PyTorch iOS framework on MacOS'
  opts.on('-i', '--install_path ', 'path to the cmake install folder') do |value|
    options[:install] = value
  end
  opts.on('-x', '--xcodeproj_path ', 'path to the XCode project file') do |value|
    options[:xcodeproj] = value
  end
  opts.on('-p', '--platform ', 'platform for the current build, OS or SIMULATOR') do |value|
    options[:platform] = value
  end
  opts.on('-c', '--provisioning_profile ', 'provisioning profile for code signing') do |value|
    options[:profile] = value
  end
  opts.on('-t', '--team_id ', 'development team ID') do |value|
    options[:team_id] = value
  end
end.parse!
puts options.inspect

install_path = File.expand_path(options[:install])
raise "path don't exist:#{install_path}!" unless Dir.exist? install_path

xcodeproj_path = File.expand_path(options[:xcodeproj])
raise "path don't exist:#{xcodeproj_path}!" unless File.exist? xcodeproj_path

project = Xcodeproj::Project.open(xcodeproj_path)
target = project.targets.first # TestApp
header_search_path      = ['$(inherited)', "#{install_path}/include"]
libraries_search_path   = ['$(inherited)', "#{install_path}/lib"]
other_linker_flags      = ['$(inherited)', '-all_load']

target.build_configurations.each do |config|
  config.build_settings['HEADER_SEARCH_PATHS'] = header_search_path
  config.build_settings['LIBRARY_SEARCH_PATHS']   = libraries_search_path
  config.build_settings['OTHER_LDFLAGS']          = other_linker_flags
  config.build_settings['ENABLE_BITCODE']         = 'No'
  dev_team_id = options[:team_id]
  unless dev_team_id
    raise 'Please sepecify a valid development team id for code signing'
  end

  config.build_settings['DEVELOPMENT_TEAM'] = dev_team_id
end

# link static libraries
target.frameworks_build_phases.clear
libs = ['libc10.a', 'libclog.a', 'libnnpack.a', 'libXNNPACK.a', 'libeigen_blas.a', 'libcpuinfo.a', 'libpytorch_qnnpack.a', 'libtorch_cpu.a', 'libtorch.a']
libs.each do |lib|
  path = "#{install_path}/lib/#{lib}"
  if File.exist?(path)
    libref = project.frameworks_group.new_file(path)
    target.frameworks_build_phases.add_file_reference(libref)
  end
end
project.save

sdk = nil
if options[:platform] == 'SIMULATOR'
  sdk = 'iphonesimulator'
elsif options[:platform] == 'OS'
  sdk = 'iphoneos'
else
  raise "unsupported platform #{options[:platform]}"
end

profile = options[:profile]
raise 'no provisioning profile found!' unless profile

# run xcodebuild
exec "xcodebuild clean build  -project #{xcodeproj_path}  -target #{target.name} -sdk #{sdk} -configuration Release PROVISIONING_PROFILE_SPECIFIER=#{profile}"
